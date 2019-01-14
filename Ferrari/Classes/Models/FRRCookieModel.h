//
//  FRRCookieModel.h
//  weather
//
//  Created by CaydenK on 2016/12/13.
//  Copyright © 2016年 CaydenK. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FRRCookieModel : NSObject

@property (copy, nonatomic) NSString *cookieKey;
@property (copy, nonatomic) NSString *cookieValue;
@property (copy, nonatomic) NSString *cookieDomain;

+ (NSArray<FRRCookieModel *> *)cookiesWithJSONArray:(NSArray *)jsonArray;
+ (FRRCookieModel *)cookieWithJSON:(NSDictionary *)json;

@end
