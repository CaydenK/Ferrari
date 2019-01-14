//
//  FRRWebEngine.h
//  weather
//
//  Created by CaydenK on 2016/11/28.
//  Copyright © 2016年 CaydenK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FRRMacroDefine.h"

@class FRRWebViewController;
@class FRRCookieModel;

/**
 URL 类型

 - FRRWebEngineURLTypeNormal: 未知地址，默认类型
 - FRRWebEngineURLTypeLichKing: 公司内部地址
 - FRRWebEngineURLTypeWhite: 信任的地址
 - FRRWebEngineURLTypeBlack: 不信任的地址
 - FRRWebEngineURLTypeLocal: 本地地址
 - FRRWebEngineURLTypeOther: 其他地址 - android
 - FRRWebEngineURLTypeSpecifie: 活动特殊url - 如果不是成类型的其实没必要放这里处理
 */
typedef NS_ENUM(NSInteger, FRRWebEngineURLType) {
    FRRWebEngineURLTypeNormal,
    FRRWebEngineURLTypeWhite,
    FRRWebEngineURLTypeBlack,
};

// 当前app语言获取block
typedef NSDictionary*(^FRRAppLanguageFeatchBlock)(void);
extern NSString * const FRRAppLanugageKey;
extern NSString * const FRRLanugageBundleKey;

@interface FRRWebEngine : NSObject

#pragma mark - Config Infos

/**
 app当前语言获取方法
 */
@property (class, copy, nonatomic) FRRAppLanguageFeatchBlock appLanguageFetchBlock;
/**
 离线资源类型
 默认支持css,js,jpg,jpeg,png,gif 这些类型
 */
@property (class, strong, nonatomic) NSArray *enabledTypes;
/**
 缓存开关
 */
@property (class, assign, nonatomic) BOOL cacheSwitch;

@property (class, strong, nonatomic) NSArray<NSString *> *injectScripts;
@property (class, strong, nonatomic, readonly) NSArray *withoutSource;
@property (class, strong, nonatomic, readonly) NSDictionary *hybridConfig;
@property (class, strong, nonatomic, readonly) NSDictionary *scanPrompt;
@property (class, assign, nonatomic, readonly) unsigned long long cacheSize;//缓存大小
@property (class, copy, nonatomic) NSString *customUserAgent;
@property (class, assign, nonatomic) BOOL debug;
@property (class, nonatomic, assign) FRRWebViewEngine engineType;


/**
 设置cookie
 */
+ (void)setCookies:(NSArray<FRRCookieModel *> *)cookies;
/**
 清除cookie
 */
+ (void)clearCookies;

#pragma mark - Engine

+ (void)registerHybridConfig:(NSDictionary *)hybridConfig scanPrompt:(NSDictionary *)scanPrompt;
/**
 启动网络URL拦截
 */
+ (void)startEngine;

/**
 清除缓存数据
 */
+ (void)clearCacheInfos;

/**
 更新离线增量包

 @param config 配置参数
 */
+ (void)updateOfflinePackageWithConfig:(NSDictionary *)config;

/**
 更新离线增量包
 
 @param config 配置参数
 @param project 工程名称
 */
+ (void)updateOfflinePackageWithConfig:(NSDictionary *)config forProject:(NSString *)project;

+ (FRRWebViewController *)fetchWebVCWithURL:(NSURL *)url;

@end
