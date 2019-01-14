//
//  FRRUIWebViewController.m
//  Ferrari
//
//  Created by CaydenK on 2018/10/29.
//

#import "FRRUIWebViewController.h"
#import "FRRMacroDefine.h"
#import <JavaScriptCore/JavaScriptCore.h>
#import "FRRJSCenter.h"
#import "FRRWebEngine.h"
#import "FRRUtility.h"
#import "FRRWebInputModel.h"
#import "NSBundle+FRRHybridKit.h"
#import "FRRWebDebugView.h"
#import "FRRCacheCenter.h"
#import "FRRJSCache.h"
#import "FRRWebProtocol.h"

@interface FRRUIWebViewController ()<UIWebViewDelegate,FRRWebViewControl>

@property (strong, nonatomic) UIWebView *webView;
@property (strong, nonatomic) JSContext *jsContext;
@property (strong, nonatomic) FRRJSCenter *jsDelegate;

@end

@implementation FRRUIWebViewController
@synthesize delegate;


- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureSubviews];
    [self configureLayout];
}

#pragma mark - UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    return YES;
}
- (void)webViewDidStartLoad:(UIWebView *)webView {
    //    [self.toolBar setLoadingStatus:YES];
}
- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self.delegate webViewDidFinishChanged];
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    
}
#pragma mark - FRRWebViewControl
- (NSString *)currentWebViewTitle {
    return [self.webView stringByEvaluatingJavaScriptFromString:@"document.title"];
}
- (NSString *)currentWebViewURL {
    return self.webView.request.URL.absoluteString;
}

- (void)loadURL:(NSString *)url {
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60];
    [self.webView loadRequest:request];
}
- (BOOL)canGoBack {
    return self.webView.canGoBack;
}
- (void)goBack {
    [self.webView goBack];
}
- (void)reload {
    [self.webView reload];
}


#pragma mark - TSWebViewDelegate
/**
 JavaScriptContext创建的时候回调
 
 @param webView self.webview
 @param ctx jsContext
 */
- (void)webView:(UIWebView *)webView didCreateJavaScriptContext:(JSContext *)ctx
{
    self.jsContext = ctx;
    self.jsContext[kFRRJSBridgeName] = self.jsDelegate;
    self.jsDelegate.context = self.jsContext;
    self.jsContext.exceptionHandler = ^(JSContext *context, JSValue *exceptionValue) {
        context.exception = exceptionValue;
        NSLog(@"异常信息：%@", exceptionValue);
    };
    
    //inject scripts
    for (NSString *script in FRRWebEngine.injectScripts) {
        if (![script isKindOfClass:[NSString class]]) { break; }
        [self.jsContext evaluateScript:script];
    }
    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"Ferrari.bundle" ofType:nil];
    NSBundle *bundle = [NSBundle bundleWithPath:bundlePath];
    NSURL *path = [bundle URLForResource:@"ferrari" withExtension:@"js"];
    NSString *source1 = [NSString stringWithContentsOfURL:path encoding:NSUTF8StringEncoding error:NULL];
    NSURL *path2 = [[NSBundle mainBundle] URLForResource:@"ferrariExport" withExtension:@"js"];
    NSString *source2 = [NSString stringWithContentsOfURL:path2 encoding:NSUTF8StringEncoding error:NULL];
    
    NSString *source = [source1 stringByAppendingString:source2];
    [self.jsContext evaluateScript:source];
    [self.jsContext evaluateScript:@"window.FRRWebEngine = 1"];
    
    NSLog(@"stop____:%lf",CFAbsoluteTimeGetCurrent());
}



#pragma mark - load subviews
- (void)configureSubviews {
    if (@available(iOS 11.0, *)) {
        self.webView.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    //title 颜色/字体跟随系统设置
    [self.view addSubview:self.webView];
}

#pragma mark - configure layout
- (void)configureLayout {
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.webView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.webView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view attribute:NSLayoutAttributeRight multiplier:1 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.webView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.webView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
}

#pragma mark - Get & Set

- (UIWebView *)webView {
    if (!_webView) {
        _webView = [[UIWebView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        _webView.delegate = self;
        _webView.translatesAutoresizingMaskIntoConstraints = NO;
        _webView.dataDetectorTypes = UIDataDetectorTypeNone;
    }
    return _webView;
}

- (FRRJSCenter *)jsDelegate {
    if (!_jsDelegate) {
        _jsDelegate = [[FRRJSCenter alloc] init];
    }
    return _jsDelegate;
}

- (void)dealloc
{
    self.jsContext[kFRRJSBridgeName] = nil;
    _jsDelegate = nil;
    _jsContext = nil;
}

@end

