//
//  FRRJSCachePlugin.m
//  Ferrari
//
//  Created by CaydenK on 2017/9/25.
//

#import "FRRJSCachePlugin.h"
#import "FRRJSCache.h"
#import "FRRUtility.h"

static NSString * const kFRRJSDiskCacheSetMethodName = @"setDiskCache";
static NSString * const kFRRJSDiskCacheGetMethodName = @"getDiskCache";


@implementation FRRJSCachePlugin

+ (void)setDiskCache:(NSString *)htmlPath cacheKey:(NSString *)cacheKey dataValue:(NSString *)dataValue FRRJSMethod {
    [FRRJSCache setDiskObject:dataValue forHtmlPath:htmlPath key:cacheKey withBlock:NULL];
}
+ (id)getDiskCache:(NSString *)htmlPath cacheKey:(NSString *)cacheKey FRRJSMethod {
    id value = [FRRJSCache diskObjectForHtmlPath:htmlPath key:cacheKey];
    return value;
}

+ (void)setMemoryCache:(NSString *)cacheKey cacheObj:(id)cacheObj FRRJSMethod {
    [FRRJSCache setMemoryObject:cacheObj forKey:cacheKey];
}

+ (id)getMemoryCache:(NSString *)cacheKey FRRJSMethod {
    return [FRRJSCache memoryObjectForKey:cacheKey];
}

@end
