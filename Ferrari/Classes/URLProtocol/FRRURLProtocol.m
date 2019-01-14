//
//  FRRURLProtocol.m
//  weather
//
//  Created by CaydenK on 2016/11/24.
//  Copyright © 2016年 CaydenK. All rights reserved.
//

#import "FRRURLProtocol.h"
#import <UIKit/UIKit.h>
#import "FRRWebEngine.h"
#import "FRRMacroDefine.h"
#import "NSObject+FRRHybridKit.h"
#import "FRRCacheCenter.h"
#import "FRRUtility.h"
#ifdef SD_WEBP
#import <SDWebImage/UIImage+MultiFormat.h>
#endif


static NSString * const kFRRURLProtocolKey = @"_kFRRURLProtocolKey";

static NSOperationQueue * const FRRURLClientSessionQueue() {
    static NSOperationQueue *_sessionQueue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sessionQueue = [[NSOperationQueue alloc] init];
        _sessionQueue.name = @"com.ferrari.ferrari.session_queue";
        _sessionQueue.maxConcurrentOperationCount = 1;
        _sessionQueue.qualityOfService = NSQualityOfServiceUserInitiated;
    });
    return _sessionQueue;
}


@interface FRRURLProtocol ()<NSURLSessionDelegate>

@property (strong, nonatomic) NSURLSession *session;
@property (strong, nonatomic) NSURLSessionDataTask *task;
@property (strong, nonatomic) NSMutableData *data;

@property (nonatomic, strong) NSThread *clientThread;

@end

@implementation FRRURLProtocol

+ (BOOL)canInitWithRequest:(NSURLRequest *)request {
    if ([[NSURLProtocol propertyForKey:kFRRURLProtocolKey inRequest:request] boolValue]) {
        return NO;
    }
    
    NSDictionary *headerFields = request.allHTTPHeaderFields;
    NSString *userAgent = headerFields[@"User-Agent"];
    if (userAgent && [userAgent rangeOfString:FRRWebEngine.customUserAgent].location != NSNotFound) {
        return YES;
    }
    
    return NO;
}

+ (BOOL)requestIsCacheEquivalent:(NSURLRequest *)a toRequest:(NSURLRequest *)b {
    return [super requestIsCacheEquivalent:a toRequest:b];
}


+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request {
    return request;
}

- (void)startLoading {
    assert(self.clientThread == nil); // // you can't call -startLoading twice
    self.clientThread = [NSThread currentThread];
    
    NSMutableURLRequest *request = self.request.mutableCopy;
    [FRRURLProtocol setProperty:@(YES) forKey:kFRRURLProtocolKey inRequest:request];
    
    [self syncCookieToRequest:request];
    NSURL *url = request.URL;
    if ([FRRCacheCenter containsDiskObjectForKey:url.path]) {
        //本地存在资源，不发起请求
        //能存在本地，则必定不是URI等接口数据
        NSData *cacheData;
        if ([url.pathExtension isEqualToString:@"html"] || [url.pathExtension isEqualToString:@"htm"]) {
            cacheData = [FRRUtility wholeHTMLDiskObjectForKey:url.path]; //html 直接取出html后，再拼接
        } else {
            cacheData = [FRRCacheCenter diskObjectForKey:url.path];//非html，直接取
        }
        
        NSURLResponse *response = [FRRUtility responseWithURL:url expectedContentLength:cacheData.length textEncodingName:nil];
        [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
        [self.client URLProtocol:self didLoadData:cacheData];
        [self.client URLProtocolDidFinishLoading:self];
        return;
    }
    
    //否则降级，请求网络资源

    NSURLSessionConfiguration *config = (NSURLSessionConfiguration *)({
        NSURLSessionConfiguration *_config = [NSURLSessionConfiguration defaultSessionConfiguration];
        _config.protocolClasses = @[[self class]];
        _config;
    });
    
    self.session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:FRRURLClientSessionQueue()];
    self.task = [self.session dataTaskWithRequest:request];
    [self.task resume];
}

- (void)stopLoading {
    [self.session invalidateAndCancel];
    [self.task cancel];
    self.task = nil;
}

#pragma mark - NSURLSessionDelegate
-(void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    assert(self.clientThread);
    assert([NSThread currentThread] != [NSThread mainThread]);
    
    if( error ) {
        /**
         https://developer.apple.com/library/content/samplecode/CustomHTTPProtocol/Listings/Read_Me_About_CustomHTTPProtocol_txt.html
         
         In addition, an NSURLProtocol subclass is expected to call the various methods of the NSURLProtocolClient protocol from the client thread, including all of the following:
         -URLProtocol:wasRedirectedToRequest:redirectResponse:
         -URLProtocol:didReceiveResponse:cacheStoragePolicy:
         -URLProtocol:didLoadData:
         -URLProtocolDidFinishLoading:
         -URLProtocol:didFailWithError:
         -URLProtocol:didReceiveAuthenticationChallenge:
         -URLProtocol:didCancelAuthenticationChallenge:
         */
        [self frr_performOnThread:self.clientThread waitUntilDone:YES block:^{
            [self.client URLProtocol:self didFailWithError:error];
        }];
    } else {
        NSURL *url = task.response.URL;
        BOOL need = YES;
        if ([[FRRWebEngine withoutSource] containsObject:url.lastPathComponent]) {
            need = NO;
        } else {
            need = [[FRRWebEngine enabledTypes] containsObject:url.pathExtension];
        }
        
        if (need) {
            NSData *finalData = self.data;
#ifdef SD_WEBP
            if ([task.currentRequest.URL.pathExtension isEqualToString:@"webp"]) {
                UIImage *image = [UIImage sd_imageWithData:self.data];
                NSData *transData = UIImagePNGRepresentation(image);
                finalData = transData;
                [self.client URLProtocol:self didLoadData:transData];
            }
#endif
            //此处不需要判断是否存在，因为startLoading的时候，已经判断过了，如果存在就不发起请求
            [FRRCacheCenter setDiskObject:finalData key:url.path withBlock:NULL];
        }
        /**
         https://developer.apple.com/library/content/samplecode/CustomHTTPProtocol/Listings/Read_Me_About_CustomHTTPProtocol_txt.html
         
         In addition, an NSURLProtocol subclass is expected to call the various methods of the NSURLProtocolClient protocol from the client thread, including all of the following:
         -URLProtocol:wasRedirectedToRequest:redirectResponse:
         -URLProtocol:didReceiveResponse:cacheStoragePolicy:
         -URLProtocol:didLoadData:
         -URLProtocolDidFinishLoading:
         -URLProtocol:didFailWithError:
         -URLProtocol:didReceiveAuthenticationChallenge:
         -URLProtocol:didCancelAuthenticationChallenge:
         */
        
        [self frr_performOnThread:self.clientThread waitUntilDone:YES block:^{
            [self.client URLProtocolDidFinishLoading:self];
        }];
    }
}

-(void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler
{
    assert(self.clientThread);
    assert([NSThread currentThread] != [NSThread mainThread]);
    [self frr_performOnThread:self.clientThread waitUntilDone:YES block:^{
        [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
    }];
    completionHandler(NSURLSessionResponseAllow);
}

-(void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data
{
    [self.data appendData:data];
    assert(self.clientThread);
    assert([NSThread currentThread] != [NSThread mainThread]);
    [self frr_performOnThread:self.clientThread waitUntilDone:YES block:^{
#ifdef SD_WEBP
        if (![dataTask.currentRequest.URL.pathExtension isEqualToString:@"webp"]) {
            //webp 移动到 didComplete 里
            [self.client URLProtocol:self didLoadData:data];
        }
#else
        [self.client URLProtocol:self didLoadData:data];
#endif
    }];
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task willPerformHTTPRedirection:(NSHTTPURLResponse *)response newRequest:(NSURLRequest *)newRequest completionHandler:(void (^)(NSURLRequest * _Nullable))completionHandler {
    if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
        NSHTTPURLResponse *HTTPResponse = (NSHTTPURLResponse *)response;
        if ([HTTPResponse statusCode] == 301 || [HTTPResponse statusCode] == 302) {
            NSMutableURLRequest *mutableRequest = [newRequest mutableCopy];
            [mutableRequest setURL:[NSURL URLWithString:[[HTTPResponse allHeaderFields] objectForKey:@"Location"]]];
            newRequest = [mutableRequest copy];
            [self frr_performOnThread:self.clientThread waitUntilDone:YES block:^{
                [[self client] URLProtocol:self wasRedirectedToRequest:newRequest redirectResponse:response];
            }];
        }
    }
    completionHandler(newRequest);
}

#pragma mark - Cookie handle

- (void)syncCookieToRequest:(NSMutableURLRequest *)request {
    
    NSMutableDictionary *cookieDic = [NSMutableDictionary dictionary];
    NSMutableString *cookieValue = [NSMutableString stringWithFormat:@""];
    NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (NSHTTPCookie *cookie in [cookieStorage cookies]) {
        cookieDic[cookie.name] = cookie.value;
    }
    
    // cookie重复，先放到字典进行去重，再进行拼接
    for (NSString *key in cookieDic) {
        NSString *appendString = [NSString stringWithFormat:@"%@=%@;", key, [cookieDic valueForKey:key]];
        [cookieValue appendString:appendString];
    }
    [request addValue:cookieValue forHTTPHeaderField:@"Cookie"];
}




#pragma mark - Get & Set
- (NSMutableData *)data {
    if (!_data) {
        _data = [NSMutableData data];
    }
    return _data;
}

@end
