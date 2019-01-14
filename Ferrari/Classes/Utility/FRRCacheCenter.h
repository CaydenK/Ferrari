//
//  FRRCacheCenter.h
//  Ferrari
//
//  Created by CaydenK on 2017/10/13.
//

#import <Foundation/Foundation.h>

@interface FRRCacheCenter : NSObject

//Disk Cache
//统一采用Data数据存储
+ (BOOL)containsDiskObjectForKey:(NSString *)key;
+ (void)setDiskObject:(NSData *)object key:(NSString *)key withBlock:(void(^)(void))block;
+ (NSData *)diskObjectForKey:(NSString *)key;

//Memory Cache
+ (void)setMemoryObject:(id)object forKey:(id)key;
+ (id)memoryObjectForKey:(id)key;

//Clean Cache
+ (void)cleanCache;

//Cache Size
+ (unsigned long long)cacheSize;

@end
