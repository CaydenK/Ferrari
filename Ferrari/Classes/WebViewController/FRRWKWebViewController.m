//
//  FRRWKWebViewController.m
//  Ferrari
//
//  Created by CaydenK on 2018/10/29.
//

#import "FRRWKWebViewController.h"
#import "FRRWebView.h"
#import <WebKit/WebKit.h>
#import "FRRWebProtocol.h"
#import "NSBundle+FRRHybridKit.h"
#import "FRRWebEngine.h"


@interface FRRWKWebViewController ()<WKUIDelegate,WKNavigationDelegate,FRRWebViewControl>

@property (strong, nonatomic) FRRWebView *webView;

@end

@implementation FRRWKWebViewController
@synthesize delegate;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureSubviews];
    [self configureLayout];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.webView removeObserver:self forKeyPath:@"estimatedProgress"];
}

#pragma makr - WKUIDelegate
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:[NSBundle frr_localizedStringForKey:@"Hint"] message:message?:@"" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:([UIAlertAction actionWithTitle:[NSBundle frr_localizedStringForKey:@"Sure"] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler();
    }])];
    [self presentViewController:alertController animated:YES completion:nil];
    
}
- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL))completionHandler{
    //    DLOG(@"msg = %@ frmae = %@",message,frame);
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:[NSBundle frr_localizedStringForKey:@"Hint"] message:message?:@"" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:([UIAlertAction actionWithTitle:[NSBundle frr_localizedStringForKey:@"Cancel"] style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(NO);
    }])];
    [alertController addAction:([UIAlertAction actionWithTitle:[NSBundle frr_localizedStringForKey:@"Sure"] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(YES);
    }])];
    [self presentViewController:alertController animated:YES completion:nil];
}
- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * _Nullable))completionHandler{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:prompt message:@"" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.text = defaultText;
    }];
    [alertController addAction:([UIAlertAction actionWithTitle:[NSBundle frr_localizedStringForKey:@"Done"] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(alertController.textFields[0].text?:@"");
    }])];
    
    
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - WKNavigationDelegate
- (void)webView:(FRRWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    NSURL *url = navigationAction.request.URL;
    static NSArray<NSString *> *schemes;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        schemes = @[@"https", @"http"];
    });
    if ([schemes containsObject:url.scheme]) {
        decisionHandler(WKNavigationActionPolicyAllow);
    } else {
        if (@available(iOS 10.0, *)) {
            [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:NULL];
        } else {
            [[UIApplication sharedApplication] openURL:url];
        }
        decisionHandler(WKNavigationActionPolicyCancel);
    }
}
- (void)webView:(FRRWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    
}

- (void)webView:(FRRWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    [self.delegate webViewDidFinishChanged];
}
- (void)webView:(FRRWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation {
    
}

#pragma mark - estimatedProgress Observer
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"estimatedProgress"]) {
        NSLog(@"%f",self.webView.estimatedProgress);
        
        //因部分网页，goBack后，不执行 webView:didFinishNavigation: 方法，只能在这里调用
        if (self.webView.estimatedProgress == 1) {
            [self.delegate webViewDidFinishChanged];
        }
    }
}

#pragma mark - FRRWebViewControl
- (NSString *)currentWebViewTitle {
    return self.webView.title;
}
- (NSString *)currentWebViewURL {
    return self.webView.URL.absoluteString;
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

- (FRRWebView *)webView {
    if (!_webView) {
        WKUserContentController *c = [[WKUserContentController alloc] init];
        
        NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"Ferrari.bundle" ofType:nil];
        NSBundle *bundle = [NSBundle bundleWithPath:bundlePath];
        //        NSBundle *bundle = [NSBundle mainBundle];
        NSURL *path = [bundle URLForResource:@"ferrari" withExtension:@"js"];
        NSString *source1 = [NSString stringWithContentsOfURL:path encoding:NSUTF8StringEncoding error:NULL];
        NSURL *path2 = [[NSBundle mainBundle] URLForResource:@"ferrariExport" withExtension:@"js"];
        NSString *source2 = [NSString stringWithContentsOfURL:path2 encoding:NSUTF8StringEncoding error:NULL];
        
        NSString *source = [source1 stringByAppendingString:source2];
        
        WKUserScript *s = [[WKUserScript alloc] initWithSource:source injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:YES];
        [c addUserScript:s];
        WKUserScript *s2 = [[WKUserScript alloc] initWithSource:@"window.FRRWebEngine = 0" injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:YES];
        [c addUserScript:s2];
        
        for (NSString *script in FRRWebEngine.injectScripts) {
            if (![script isKindOfClass:[NSString class]]) { break; }
            WKUserScript *s2 = [[WKUserScript alloc] initWithSource:script injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:YES];
            [c addUserScript:s2];
        }

        WKWebViewConfiguration *conf = [[WKWebViewConfiguration alloc] init];
        conf.userContentController = c;
        conf.allowsInlineMediaPlayback = YES;
        
        
        

        
        _webView = [[FRRWebView alloc] initWithFrame:[UIScreen mainScreen].bounds configuration:conf];
        _webView.navigationDelegate = self;
        _webView.UIDelegate = self;
        _webView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _webView;
}


@end

