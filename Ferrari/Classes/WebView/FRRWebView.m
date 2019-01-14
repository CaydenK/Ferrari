//
//  FRRWebView.m
//  Ferrari
//
//  Created by CaydenK on 2018/10/22.
//

#import "FRRWebView.h"
#import "FRRJSCenter.h"

@interface FRRJSCenter ()
+ (NSString *)jsbridgeDisposeWithPrompt:(NSString *)prompt defaultText:(nullable NSString *)defaultText completion:(void(^)(NSString *compJS))completion;
@end


@interface FRRWebView ()<WKUIDelegate>

@end


@implementation FRRWebView {
    __weak id <WKUIDelegate> _UIDelegate;
}
@dynamic UIDelegate;

#pragma mark - WKUIDelegate
- (nullable WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures {
    if( self.UIDelegate && [self.UIDelegate respondsToSelector:@selector(webView:createWebViewWithConfiguration:forNavigationAction:windowFeatures:)]){
        return [self.UIDelegate webView:webView createWebViewWithConfiguration:configuration forNavigationAction:navigationAction windowFeatures:windowFeatures];
    }
    return  nil;
}
- (void)webViewDidClose:(WKWebView *)webView API_AVAILABLE(macosx(10.11), ios(9.0)) {
    if( self.UIDelegate && [self.UIDelegate respondsToSelector:@selector(webViewDidClose:)]){
        [self.UIDelegate webViewDidClose:webView];
    }
}
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler {
    if( self.UIDelegate &&  [self.UIDelegate respondsToSelector:@selector(webView:runJavaScriptAlertPanelWithMessage:initiatedByFrame:completionHandler:)]) {
        [self.UIDelegate webView:webView runJavaScriptAlertPanelWithMessage:message initiatedByFrame:frame completionHandler:completionHandler];
    }
}
- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL result))completionHandler {
    if(self.UIDelegate&& [self.UIDelegate respondsToSelector:@selector(webView:runJavaScriptConfirmPanelWithMessage:initiatedByFrame:completionHandler:)]) {
        [self.UIDelegate webView:webView runJavaScriptConfirmPanelWithMessage:message initiatedByFrame:frame completionHandler:completionHandler];
    }
}
- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(nullable NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * _Nullable result))completionHandler {
    //24F20539 为 ferrariBridge 字符串进行adler32算法运算后获得，降低prompt正常用法和bridge的碰撞概率
    if ([prompt hasPrefix:@"ferrariBridge_24F20539"]) {
        completionHandler([FRRJSCenter jsbridgeDisposeWithPrompt:prompt defaultText:defaultText completion:^(NSString *compJS) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [webView evaluateJavaScript:compJS completionHandler:NULL];
            });
        }]);
    } else if (self.UIDelegate && [self.UIDelegate respondsToSelector:@selector(webView:runJavaScriptTextInputPanelWithPrompt:defaultText:initiatedByFrame:completionHandler:)]){
        [self.UIDelegate webView:webView runJavaScriptTextInputPanelWithPrompt:prompt defaultText:defaultText initiatedByFrame:frame completionHandler:completionHandler];
    } else {
        completionHandler(defaultText);
    }
}

- (BOOL)webView:(WKWebView *)webView shouldPreviewElement:(WKPreviewElementInfo *)elementInfo API_AVAILABLE(ios(10.0)) {
    if( self.UIDelegate && [self.UIDelegate respondsToSelector:@selector(webView:shouldPreviewElement:)]) {
        return [self.UIDelegate webView:webView shouldPreviewElement:elementInfo];
    }
    return NO;
}
- (nullable UIViewController *)webView:(WKWebView *)webView previewingViewControllerForElement:(WKPreviewElementInfo *)elementInfo defaultActions:(NSArray<id <WKPreviewActionItem>> *)previewActions API_AVAILABLE(ios(10.0)) {
    if( self.UIDelegate && [self.UIDelegate respondsToSelector:@selector(webView:previewingViewControllerForElement:defaultActions:)]){
        return [self.UIDelegate webView:webView previewingViewControllerForElement:elementInfo defaultActions:previewActions];
    }
    return  nil;
}
- (void)webView:(WKWebView *)webView commitPreviewingViewController:(UIViewController *)previewingViewController API_AVAILABLE(ios(10.0)) {
    if( self.UIDelegate && [self.UIDelegate respondsToSelector:@selector(webView:commitPreviewingViewController:)]){
        return [self.UIDelegate webView:webView commitPreviewingViewController:previewingViewController];
    }
}



#pragma initialize
- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        super.UIDelegate = self;
    }
    return self;
}
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        super.UIDelegate = self;
    }
    return self;
}
- (instancetype)initWithFrame:(CGRect)frame configuration:(WKWebViewConfiguration *)configuration
{
    self = [super initWithFrame:frame configuration:configuration];
    if (self) {
        super.UIDelegate = self;
    }
    return self;
}


#pragma mark - getter & setter
- (id<WKUIDelegate>)UIDelegate {
    return _UIDelegate;
}
- (void)setUIDelegate:(id<WKUIDelegate>)UIDelegate {
    _UIDelegate = UIDelegate;
    super.UIDelegate = self;
}

@end

