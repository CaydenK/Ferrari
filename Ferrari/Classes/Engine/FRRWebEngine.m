//
//  FRRWebEngine.m
//  weather
//
//  Created by CaydenK on 2016/11/28.
//  Copyright © 2016年 CaydenK. All rights reserved.
//

#import "FRRWebEngine.h"
#import "FRRURLProtocol.h"
#import "FRRWebViewController.h"
#import "FRRMacroDefine.h"
#import "FRRUtility.h"
#import "FRRCookieModel.h"
#import "FRRWebInputModel.h"
#import "NSBundle+FRRHybridKit.h"
#import "FRRJSCenter.h"
#import "FRRJSCachePlugin.h"
#import "FRRNavigationUIPlugin.h"
#import "FRRCacheCenter.h"
#import "FRRDownManager.h"
#import "NSURLProtocol+WebKitSupport.h"
#import <WebKit/WebKit.h>
#ifdef SD_WEBP
#import <SDWebImage/UIImage+MultiFormat.h>
#endif
#import <objc/runtime.h>
#import "FRRAlert.h"

NSString * const FRRAppLanugageKey    = @"FRRAppLanugageKey";
NSString * const FRRLanugageBundleKey = @"FRRLanugageBundleKey";

NSString * const kFRRConfigUrlTypeList  = @"hybridUnifyList";
NSString * const kFRRConfigUrlTypeRegex = @"matchUrl";
NSString * const kFRRConfigUrlType      = @"targetType";
NSString * const kFRRConfigUrlVerifyPath      = @"hostPath";


@interface FRRWebEngine ()

@property (nonatomic, strong) NSDictionary *hybridConfig;
@property (nonatomic, strong) NSDictionary *scanPrompt;
@property (nonatomic, strong) NSArray *enabledTypes;
@property (nonatomic, assign) BOOL cacheSwitch;
@property (nonatomic, copy)   FRRAppLanguageFeatchBlock appLanguageFetchBlock;
@property (copy, nonatomic) NSString *customUserAgent;
@property (assign, nonatomic) BOOL debug;
@property (nonatomic, assign) FRRWebViewEngine engineType;

@property (nonatomic, copy) NSString *preUALang;

@end

@implementation FRRWebEngine

+ (FRRWebEngine *)shareEngine {
    static FRRWebEngine *shareInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareInstance = [[FRRWebEngine alloc] init];
        shareInstance.cacheSwitch = YES;
    });
    return shareInstance;
}


+ (NSArray<NSString *> *)injectScripts {
    return objc_getAssociatedObject(self, _cmd);
}
+ (void)setInjectScripts:(NSArray<NSString *> *)injectScripts {
    objc_setAssociatedObject(self, @selector(injectScripts), injectScripts, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

+ (NSArray *)enabledTypes {
    return [self shareEngine].enabledTypes;
}
+ (void)setEnabledTypes:(NSArray *)enabledTypes {
    [self shareEngine].enabledTypes = enabledTypes;
}
+ (BOOL)cacheSwitch {
    return [self shareEngine].cacheSwitch;
}
+ (void)setCacheSwitch:(BOOL)cacheSwitch {
    [self shareEngine].cacheSwitch = cacheSwitch;
}

+ (void)setEngineType:(FRRWebViewEngine)engineType {
    [self shareEngine].engineType = engineType;
}
+ (FRRWebViewEngine)engineType {
    return [self shareEngine].engineType;
}

/**
 设置app当前语言获取方法

 @param block 获取方式
 */
+ (void)setAppLanguageFetchBlock:(FRRAppLanguageFeatchBlock)block {
    [self shareEngine].appLanguageFetchBlock = block;
}


/**
 app当前语言获取方法

 @return 返回app当前语言获取方法
 */
+ (FRRAppLanguageFeatchBlock)appLanguageFetchBlock {
    return [self shareEngine].appLanguageFetchBlock;
}

+ (void)setCustomUserAgent:(NSString *)customUserAgent {
    [self shareEngine].customUserAgent = customUserAgent;
}
+ (NSString *)customUserAgent {
    return [self shareEngine].customUserAgent;
}

+ (void)setDebug:(BOOL)debug {
    [self shareEngine].debug = debug;
}

+ (BOOL)debug {
    return [self shareEngine].debug;
}

+ (NSArray *)withoutSource {
    return @[@"hm.gif",@"0.gif",@"v.gif"];
}

+ (void)setCookies:(NSArray<FRRCookieModel *> *)cookies{
    [cookies enumerateObjectsUsingBlock:^(FRRCookieModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSHTTPCookie *cookie = [NSHTTPCookie cookieWithProperties:@{
                                                                    NSHTTPCookieDomain:obj.cookieDomain ?: @"",
                                                                    NSHTTPCookiePath:@"/",
                                                                    NSHTTPCookieName:obj.cookieKey ?: @"",
                                                                    NSHTTPCookieValue:obj.cookieValue ?: @"",
                                                                    }];
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
    }];
    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookieAcceptPolicy:NSHTTPCookieAcceptPolicyAlways];
}
+ (void)clearCookies {
    NSArray *cookies = [NSArray arrayWithArray:[[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies]];
    for (NSHTTPCookie *cookie in cookies) {
//        if ([baseURL.host isEqualToString:cookie.properties[NSHTTPCookieDomain]]) {
            [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
//        }
    }
}
+ (NSDictionary *)hybridConfig {
    return [self shareEngine].hybridConfig;
}
+ (NSDictionary *)scanPrompt {
    return [self shareEngine].scanPrompt;
}

+ (void)registerHybridConfig:(NSDictionary *)hybridConfig scanPrompt:(NSDictionary *)scanPrompt {
    [self shareEngine].hybridConfig = hybridConfig;
    [self shareEngine].scanPrompt = scanPrompt;
}

+ (void)startEngine {
//    [NSURLProtocol registerClass:[FRRURLProtocol class]];
//    [FRRURLProtocol wk_registerScheme:@"https"];
//    [FRRURLProtocol wk_registerScheme:@"http"];
    UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectZero];
    [webView loadHTMLString:@"" baseURL:nil];       //start web thread
    [self updateUserAngent]; // 更新UA
}

- (NSString*)newUserAngetAppendLang:(NSString*)oldUserAgent {
    NSString *lang = @" zh_CN";
    NSString *newAgent = oldUserAgent;
    
    if (self.appLanguageFetchBlock) {
        lang = [NSString stringWithFormat:@" %@",self.appLanguageFetchBlock()[FRRAppLanugageKey]] ?: @" zh_CN";
    }
    if (self.preUALang) {
        NSRange oldRange = [newAgent rangeOfString:self.preUALang];
        if (oldRange.location != NSNotFound) {
            newAgent = [newAgent stringByReplacingOccurrencesOfString:self.preUALang withString:lang];
        }else {
            newAgent = [newAgent stringByAppendingString:lang];
        }
    }else {
        newAgent = [newAgent stringByAppendingString:lang];
    }
    self.preUALang = lang;
    return newAgent;
}


/**
 更新 UA, UIWebView 和 WKWebView 采用相同的 UA 配置方式
 */
+ (void)updateUserAngent {
    NSString *build = [[[NSBundle mainBundle]infoDictionary] objectForKey:@"CFBundleVersion"];
    UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectZero];
    NSString *oldAgent = [webView stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"];
    NSString *newAgent = oldAgent;
    if ([oldAgent rangeOfString:self.customUserAgent].location == NSNotFound) {
        newAgent = [oldAgent stringByAppendingString:self.customUserAgent];
        newAgent = [newAgent stringByAppendingFormat:@".%@",build];
    }
    
    newAgent = [[self shareEngine] newUserAngetAppendLang:newAgent];
    [[NSUserDefaults standardUserDefaults] registerDefaults:@{@"UserAgent":newAgent}];
}


/**
 清除缓存数据
 */
+ (void)clearCacheInfos {
    //YYCache 中的缓存清除
    [FRRCacheCenter cleanCache];
}
/**
 缓存大小
 */
+ (unsigned long long)cacheSize {
    return [FRRCacheCenter cacheSize];
}

/**
 更新离线增量包
 
 @param config 配置参数
 */
+ (void)updateOfflinePackageWithConfig:(NSDictionary *)config {
    [self updateOfflinePackageWithConfig:config forProject:nil];
}

+ (void)updateOfflinePackageWithConfig:(NSDictionary *)config forProject:(NSString *)project {
    //除HTML外其他资源监测文件是否存在
    for (NSString *key in config.allKeys) {
        if ([key isEqualToString:@"version"] || [key isEqualToString:@"html"]) { break; }
        
        NSArray<NSString *> *paths = config[key];
        [FRRDownManager asyncDownloadFilesWithURLs:paths condition:^BOOL(NSURL *url) {
            return ![FRRCacheCenter containsDiskObjectForKey:url.path];
        } fileCompletion:^(BOOL success, NSURL *url, id responseObject) {
            if (success) {
                id finalData = responseObject;
#ifdef SD_WEBP
                if ([url.pathExtension isEqualToString:@"webp"]) {
                    UIImage *image = [UIImage sd_imageWithData:responseObject];
                    NSData *transData = UIImagePNGRepresentation(image);
                    finalData = transData;
                }
#endif
                [FRRCacheCenter setDiskObject:finalData key:url.path withBlock:NULL];
            }
        } completion:NULL];
    }
    
    //HTML使用版本控制
    NSString *pVersion = project ? [project stringByAppendingString:@"_version"] : @"version";
    NSNumber *version = config[@"version"];
    NSNumber *localVersion = [NSKeyedUnarchiver unarchiveObjectWithData:[FRRCacheCenter diskObjectForKey:pVersion]];
    if (version.unsignedIntegerValue <= localVersion.unsignedIntegerValue) { /*无更新*/ return; }
    
    //HTML  有更新则全量更新
    NSArray<NSString *> *htmlPaths = config[@"html"];
    [FRRDownManager asyncDownloadFilesWithURLs:htmlPaths condition:NULL fileCompletion:^(BOOL success, NSURL *url, id responseObject) {
        if (success) {
            [FRRCacheCenter setDiskObject:responseObject key:url.path withBlock:NULL];
        }
    } completion:^(BOOL success) {
        if (success) {
            NSData *versionData = [NSKeyedArchiver archivedDataWithRootObject:version];
            [FRRCacheCenter setDiskObject:versionData key:pVersion withBlock:NULL];
        }
    }];
}

+ (FRRWebViewController *)fetchWebVCWithURL:(NSURL *)url {
    if (url == nil) {
        NSString *invalidUrl = [self shareEngine].scanPrompt[@"invalidUrlPrompt"];
        [FRRAlert showAlertWithTitle:[NSBundle frr_localizedStringForKey:@"Warn"] message:invalidUrl ?: [NSBundle frr_localizedStringForKey:@"CannotAccess"] style:UIAlertControllerStyleAlert actionTitles:@[[NSBundle frr_localizedStringForKey:@"OK"]] actionStyles:@[@(UIAlertActionStyleCancel)] handler:nil];
        return nil;
    }
    FRRWebViewController *webVC = [self webViewControllerWithURL:url];
    return webVC;
}

+ (FRRWebViewController *)webViewControllerWithURL:(NSURL *)url {
    FRRWebViewController *webViewController = [[FRRWebViewController alloc] init];
    FRRWebInputModel *inputModel = [[FRRWebInputModel alloc] init];
    inputModel.url = url.absoluteString;
    [webViewController setValue:inputModel forKey:@"inputParams"];
    return webViewController;
}

#pragma mark - Get & Set
- (NSArray *)enabledTypes {
    if (!_enabledTypes) {
        //默认配置
        _enabledTypes = @[@"css",@"js",@"jpg",@"jpeg",@"png",@"gif"
#ifdef SD_WEBP
                          ,@"webp"
#endif
                          ];
    }
    return _enabledTypes;
}

- (NSString *)customUserAgent {
    if (!_customUserAgent) {
        _customUserAgent = kFRRWebRequestUserAgentCustomInfo;
    }
    return _customUserAgent;
}



@end
