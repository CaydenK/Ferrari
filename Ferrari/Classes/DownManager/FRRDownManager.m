//
//  FRRDownManager.m
//  Ferrari
//
//  Created by CaydenK on 2017/10/9.
//

#import "FRRDownManager.h"


@implementation FRRDownManager

+ (void)downloadFileWithURL:(NSURL *)url completion:(void (^)(BOOL, id))completion {
    NSMutableURLRequest * request = [[NSMutableURLRequest alloc]initWithURL:url];
    NSURLSession *section = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    NSURLSessionDataTask *task = [section dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (!completion) { return ; }
        if (error) {
            completion(NO,error);
        } else {
            completion(YES,data);//[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding]);
        }
    }];
    [task resume];
}

+ (void)asyncDownloadFilesWithURLs:(NSArray<NSString *> *)urls
                         condition:(BOOL(^)(NSURL *url))condition
                    fileCompletion:(void (^)(BOOL success, NSURL *url, id responseObject))fileCompletion
                        completion:(void(^)(BOOL success))completion {
    dispatch_group_t group;
    if (completion) { group = dispatch_group_create(); }
    __block BOOL completionSuccess = YES;
    //创建并行队列
    dispatch_queue_t queue = dispatch_queue_create("com.ferrari.hybrid.download_queue", DISPATCH_QUEUE_CONCURRENT);
    
    //并行下载
    for (NSString *path in urls) {
        NSURL *url = [NSURL URLWithString:path];
        BOOL needDown = condition ? condition(url) : YES;
        if (needDown) {
            if (group) { dispatch_group_enter(group); }
            dispatch_async(queue, ^{
                [self downloadFileWithURL:url completion:^(BOOL success, id responseObject) {
                    !fileCompletion ?: fileCompletion(success,url,responseObject);
                    @synchronized (urls) { // 防止 data race
                        completionSuccess = (completionSuccess & success);
                    }
                    if (group) { dispatch_group_leave(group); }
                }];
            });
        }
    }
    if (group) {
        dispatch_group_notify(group, dispatch_get_main_queue(), ^(){
            !completion ?: completion(completionSuccess);
        });
    }
}


@end
