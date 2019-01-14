//
//  FRRCacheCenter.m
//  Ferrari
//
//  Created by CaydenK on 2017/10/13.
//

#import "FRRCacheCenter.h"
#import "YYCache.h"

static YYDiskCache const * FRRJSDiskCache() {
    static YYDiskCache *diskCache = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES) firstObject];
        NSString *path = [documentPath stringByAppendingPathComponent:@"hybrid_cache"];
        diskCache = [[YYDiskCache alloc]initWithPath:path];
        diskCache.name = @"hybridDiskCache";
    });
    return diskCache;
}

static YYMemoryCache * FRRJSMemoryCache() {
    static YYMemoryCache *memoryCache = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        memoryCache = [[YYMemoryCache alloc] init];
        memoryCache.name = @"hybridMemoryCache";
        memoryCache.didReceiveMemoryWarningBlock = ^(YYMemoryCache * _Nonnull cache) {
            [cache removeAllObjects];
        };
    });
    return memoryCache;
}


@implementation FRRCacheCenter

//Disk Cache
+ (BOOL)containsDiskObjectForKey:(NSString *)key {
    return [FRRJSDiskCache() containsObjectForKey:key];
}
+ (void)setDiskObject:(NSData *)object key:(NSString *)key withBlock:(void(^)(void))block {
    [FRRJSDiskCache() setObject:object forKey:key withBlock:block];
}
+ (NSData *)diskObjectForKey:(NSString *)key {
    return (NSData *)[FRRJSDiskCache() objectForKey:key];
}

//Memory Cache
+ (void)setMemoryObject:(id)object forKey:(id)key {
    [FRRJSMemoryCache() setObject:object forKey:key];
}
+ (id)memoryObjectForKey:(id)key {
    return [FRRJSMemoryCache() objectForKey:key];
}

//Clean Cache
+ (void)cleanCache {
    [FRRJSMemoryCache() removeAllObjects];
    [FRRJSDiskCache() removeAllObjects];
}

//Cache Size
+ (unsigned long long)cacheSize {
    return [FRRJSDiskCache() totalCost];
}

@end
