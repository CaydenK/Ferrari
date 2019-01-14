//
//  FRRCookieModel.m
//  weather
//
//  Created by CaydenK on 2016/12/13.
//  Copyright © 2016年 CaydenK. All rights reserved.
//

#import "FRRCookieModel.h"
#import <YYModel/YYModel.h>

@implementation FRRCookieModel

+ (NSArray<FRRCookieModel *> *)cookiesWithJSONArray:(NSArray *)jsonArray {
    return [NSArray yy_modelArrayWithClass:[self class] json:jsonArray];
}
+ (FRRCookieModel *)cookieWithJSON:(NSDictionary *)json {
    return [self yy_modelWithJSON:json];
}

- (NSUInteger)hash {
    return [self yy_modelHash];
}
- (BOOL)isEqual:(id)object {
    return [self yy_modelIsEqual:object];
}

- (NSString *)debugDescription {
    return [self yy_modelDescription];
}

@end
