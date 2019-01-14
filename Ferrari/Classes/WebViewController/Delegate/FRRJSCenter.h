//
//  FRRJSCenter.h
//  weather
//
//  Created by CaydenK on 2016/12/5.
//  Copyright © 2016年 CaydenK. All rights reserved.
//

#import <Foundation/Foundation.h>

#define FRRJSMethod __attribute__((nonnull))


@class JSContext,WKWebView;


@protocol FRRJSExport <NSObject>

@end

@interface FRRJSCenter : NSObject

@property (weak, nonatomic) JSContext *context;
@property (weak, nonatomic) WKWebView *webView;

@end
