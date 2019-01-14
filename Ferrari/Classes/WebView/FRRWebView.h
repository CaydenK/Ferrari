//
//  FRRWebView.h
//  Ferrari
//
//  Created by CaydenK on 2018/10/22.
//

#import <WebKit/WebKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FRRWebView : WKWebView

@property (nullable, nonatomic, weak) id <WKUIDelegate> UIDelegate;

@end

NS_ASSUME_NONNULL_END
