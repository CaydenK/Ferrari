//
//  FRRJSCache.m
//  Ferrari
//
//  Created by CaydenK on 2017/9/25.
//

#import "FRRJSCache.h"
#import "FRRCacheCenter.h"


@implementation FRRJSCache

static NSString * FRRCacheKeyForDisk(NSString *htmlPath, NSString *key) {
    NSString *cacheKey = [NSString stringWithFormat:@"jsbridge_%@_%@",(htmlPath ?: @""),(key ?: @"")];
    return cacheKey;
}

//Disk Cache
+ (BOOL)containsDiskObjectForHtmlPath:(NSString *)htmlPath key:(NSString *)key {
    return [FRRCacheCenter containsDiskObjectForKey:FRRCacheKeyForDisk(htmlPath, key)];
}
+ (void)setDiskObject:(NSString *)object forHtmlPath:(NSString *)htmlPath key:(NSString *)key withBlock:(void(^)(void))block {
    NSData *data = [object dataUsingEncoding:NSUTF8StringEncoding];
    [FRRCacheCenter setDiskObject:data key:FRRCacheKeyForDisk(htmlPath, key) withBlock:block];
}
+ (NSString *)diskObjectForHtmlPath:(NSString *)htmlPath key:(NSString *)key {
    NSData *data = [FRRCacheCenter diskObjectForKey:FRRCacheKeyForDisk(htmlPath, key)];
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

//Memory Cache
+ (void)setMemoryObject:(id)object forKey:(id)key {
    [FRRCacheCenter setMemoryObject:object forKey:key];
}
+ (id)memoryObjectForKey:(id)key {
    return [FRRCacheCenter memoryObjectForKey:key];
}

//Clean Cache
+ (void)cleanCache {
    [FRRCacheCenter cleanCache];
}

@end
