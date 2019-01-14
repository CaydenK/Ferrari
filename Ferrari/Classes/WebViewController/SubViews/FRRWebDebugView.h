//
//  FRRWebDebugView.h
//  weather
//
//  Created by CaydenK on 2017/5/9.
//  Copyright © 2017年 CaydenK. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FRRWebDebugView : UIView

+ (instancetype)webDebugViewWithCurrentURL:(NSString *(^)(void))urlHandler completion:(void(^)(NSString *url))completion;

@end
