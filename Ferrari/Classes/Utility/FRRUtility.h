//
//  FRRUtility.h
//  weather
//
//  Created by CaydenK on 2016/12/6.
//  Copyright © 2016年 CaydenK. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FRRUtility : NSObject


///**
// 验证是否符合正则表达式
//
// @param aString 待验证的字符串
// @param regularArray 正则表达式列表
// @return 是否符合
// */
//+ (BOOL)verifyString:(NSString *)aString regularArray:(NSArray<NSString *> *)regularArray;
//

/**
 验证是包含正则表达式的内容

 @param string 待验证的字符串
 @param regexStr 正则表达式
 @return 是否符合
 */
+ (BOOL)verifyString:(NSString*)string containsRegex:(NSString*)regexStr;

/**
 URL中的query解析为字典
 */
+ (NSDictionary<NSString *, NSString *>*)queryParamsFromURL:(NSURL*)url;

+ (id)jsonDataFromString:(NSString *)paramString;
+ (NSString *)jsonStringFromData:(id)json;


/**
 拼接完整的HTML

 @param key html完整URL的path
 @return <#return value description#>
 */
+ (NSData *)wholeHTMLDiskObjectForKey:(NSString *)key;

/**
 解析静态HTML所需的Data Keys

 @param html 静态HTML
 @return 内联所需数据key列表
 */
+ (NSArray<NSString *> *)analyseDataKeysWithStaticHTMLString:(NSString *)html;

/**
 组装数据块到HTML

 @param html 待组装数据的HTML
 @param dataDict 数据对应字典
 @return 组装完数据的HTML
 */
+ (NSString *)packageHTML:(NSString *)html dataDict:(NSDictionary *)dataDict;

+ (NSURLResponse *)responseWithURL:(NSURL *)url expectedContentLength:(NSInteger)length textEncodingName:(NSString *)name;

@end
