//
//  FRRJSCache.h
//  Ferrari
//
//  Created by CaydenK on 2017/9/25.
//

#import <Foundation/Foundation.h>

@interface FRRJSCache : NSObject

//Disk Cache
//JSBridge持久化统一使用String格式
+ (BOOL)containsDiskObjectForHtmlPath:(NSString *)htmlPath key:(NSString *)key;
+ (void)setDiskObject:(NSString *)object forHtmlPath:(NSString *)htmlPath key:(NSString *)key withBlock:(void(^)(void))block;
+ (NSString *)diskObjectForHtmlPath:(NSString *)htmlPath key:(NSString *)key;

//Memory Cache
+ (void)setMemoryObject:(id)object forKey:(id)key;
+ (id)memoryObjectForKey:(id)key;

//Clean Cache
+ (void)cleanCache;

@end
