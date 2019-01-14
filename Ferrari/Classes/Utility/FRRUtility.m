//
//  FRRUtility.m
//  weather
//
//  Created by CaydenK on 2016/12/6.
//  Copyright © 2016年 CaydenK. All rights reserved.
//

#import "FRRUtility.h"
#import "FRRCacheCenter.h"
#import "FRRJSCache.h"

static NSString * const kStaticHTMLDataKeyRegex = @"<!--\\{hybrid_data:([A-Za-z]\\w{2,19})\\}-->";


@implementation FRRUtility

///**
// 验证是否符合正则表达式
// 
// @param aString 待验证的字符串
// @param regularArray 正则表达式列表
// @return 是否符合
// */
//+ (BOOL)verifyString:(NSString *)aString regularArray:(NSArray<NSString *> *)regularArray {
//    for (NSString *regular in regularArray) {
//        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regular options:NSRegularExpressionCaseInsensitive error:NULL];
//        NSArray<NSTextCheckingResult *> *result = [regex matchesInString:aString options:0 range:NSMakeRange(0, aString.length)];
//        if (result.count) {
//            return YES;
//        }
//    }
//    return NO;
//}

+ (NSArray<NSTextCheckingResult *> *)regexResultArrayWithString:(NSString *)string regex:(NSString *)regex {
    NSError *error;
    NSRegularExpression *regexExpression = [NSRegularExpression regularExpressionWithPattern:regex options:NSRegularExpressionCaseInsensitive error:&error];
    NSArray<NSTextCheckingResult *> *resultArray = [regexExpression matchesInString:string options:0 range:NSMakeRange(0, string.length)];
    return resultArray;
    
    
}


+ (BOOL)verifyString:(NSString*)string containsRegex:(NSString*)regexStr {
    if (string.length == 0 || regexStr.length == 0) {
        return NO;
    }
    NSArray<NSTextCheckingResult *> *result = [self regexResultArrayWithString:string regex:regexStr];
    return result.count > 0;
}

/**
 URL中的query解析为字典
 */
+(NSDictionary<NSString *, NSString *>*)queryParamsFromURL:(NSURL*)url {
    NSURLComponents* urlComponents = [NSURLComponents componentsWithURL:url resolvingAgainstBaseURL:NO];
    NSMutableDictionary<NSString *, NSString *> *queryParams = @{}.mutableCopy;
    for (NSURLQueryItem* queryItem in [urlComponents queryItems])
    {
        if (queryItem.value == nil) {
            continue;
        }
        [queryParams setObject:queryItem.value forKey:queryItem.name];
    }
    return queryParams;
}

+ (id)jsonDataFromString:(NSString *)paramString {
    NSData *detailData = [paramString dataUsingEncoding:NSUTF8StringEncoding];
    if (detailData == nil) {
        return nil;
    }
    return [NSJSONSerialization JSONObjectWithData:detailData options:0 error:nil];
}

+ (NSString *)jsonStringFromData:(id)json {
    if (json == nil) { return nil; }
    NSString *jsonString = nil;
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:json
                                                       options:0
                                                         error:&error];
    if (! jsonData) {
        NSLog(@"Got an error: %@", error);
    } else {
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    return jsonString;
}

+ (NSData *)wholeHTMLDiskObjectForKey:(NSString *)key {
    NSData *htmlData = [FRRCacheCenter diskObjectForKey:key];
    NSString *html = [[NSString alloc] initWithData:htmlData encoding:NSUTF8StringEncoding];
    NSArray<NSString *> *dataKeys = [FRRUtility analyseDataKeysWithStaticHTMLString:html];
    
    //解析HTML所需Data
    NSMutableDictionary *dataDict = @{}.mutableCopy;
    for (NSString *dataKey in dataKeys) {
        NSString *data = [FRRJSCache diskObjectForHtmlPath:key key:dataKey];
        if (data) {
            [dataDict setObject:data forKey:key];
        }
    }
    
    //拼装Data到HTML
    html = [FRRUtility packageHTML:html dataDict:dataDict];
    
    NSData *wholeHtmlData = [html dataUsingEncoding:NSUTF8StringEncoding];
    return wholeHtmlData;
}


+ (NSArray<NSString *> *)analyseDataKeysWithStaticHTMLString:(NSString *)html {
    /*
    Hello this is shop v2
    <!-- 直出数据 start -->
    <!--{hybrid_data:some_key}-->
    <!-- 直出数据 end -->
    <script type="text/javascript">
    var __server_data = {
    head: "<!--{hybrid_data:some_key}-->"
    }
     */
    NSArray<NSTextCheckingResult *> *resultArray = [self regexResultArrayWithString:html regex:kStaticHTMLDataKeyRegex];
    NSMutableArray *keyArray = @[].mutableCopy;
    for (NSTextCheckingResult *result in resultArray) {
        NSString *key = [html substringWithRange:[result rangeAtIndex:1]];
        [keyArray addObject:key];
    }
    return keyArray.copy;
}
+ (NSString *)packageHTML:(NSString *)html dataDict:(NSDictionary *)dataDict {
    /*
     Hello this is shop v2
     <!-- 直出数据 start -->
     <!--{hybrid_data:some_key}-->
     <!-- 直出数据 end -->
     <script type="text/javascript">
     var __server_data = {
     head: "<!--{hybrid_data:some_key}-->"
     }
     */
    NSArray<NSTextCheckingResult *> *resultArray = [self regexResultArrayWithString:html regex:kStaticHTMLDataKeyRegex];
    NSMutableString *mutableHTML = html.mutableCopy;
    for (NSInteger i = resultArray.count - 1; i >= 0; i--) {
        NSTextCheckingResult *result = resultArray[i];
        NSString *key = [html substringWithRange:[result rangeAtIndex:1]];
        NSString *data = dataDict[key];
        if (data) {
            [mutableHTML replaceCharactersInRange:result.range withString:data];
        }
    }
    return mutableHTML.copy;
}

+ (NSURLResponse *)responseWithURL:(NSURL *)url expectedContentLength:(NSInteger)length textEncodingName:(NSString *)name {
    NSString *pathExtension = url.pathExtension;
    static NSArray *imagePathExtensionArray = nil;
    static NSArray *textPathExtensionArray = nil;
    static NSArray *htmlPathExtensionArray = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        imagePathExtensionArray = @[@"jpg",@"jpeg",@"png",@"gif"];
        textPathExtensionArray = @[@"css",@"js"];
        htmlPathExtensionArray = @[@"htm",@"html"];
    });
    //MIME : https://developer.mozilla.org/zh-CN/docs/Web/HTTP/Basics_of_HTTP/MIME_types
    NSString *mime = nil;
    if ([imagePathExtensionArray containsObject:pathExtension]) {
        mime = [NSString stringWithFormat:@"image/%@",[pathExtension isEqualToString:@"jpg"] ? @"jpeg" : pathExtension];
    } else if ([textPathExtensionArray containsObject:pathExtension]) {
        mime = [NSString stringWithFormat:@"text/%@",[pathExtension isEqualToString:@"js"] ? @"javascript" : pathExtension];
    } else if ([htmlPathExtensionArray containsObject:pathExtension]) {
        mime = [NSString stringWithFormat:@"text/%@",[pathExtension isEqualToString:@"htm"] ? @"html" : pathExtension];
    } else {
        mime = @"application/octet-stream"; //默认类型
    }
    
    NSURLResponse *response = [[NSURLResponse alloc] initWithURL:url MIMEType:mime expectedContentLength:length textEncodingName:name];
    return response;
}

@end
