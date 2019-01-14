//
//  FRRWebViewController.m
//  weather
//
//  Created by CaydenK on 2016/11/28.
//  Copyright © 2016年 CaydenK. All rights reserved.
//

#import "FRRWebViewController.h"
#import "FRRWKWebViewController.h"
#import "FRRUIWebViewController.h"
#import "FRRWebDebugView.h"
#import "FRRWebProtocol.h"
#import "FRRWebInputModel.h"

@interface FRRWebViewController ()<FRRWebViewControllerNavigation>
    
@property (strong, nonatomic) FRRWebInputModel *inputParams;
@property (weak, nonatomic) FRRWebDebugView *webDebugView;
@property (strong, nonatomic) UIViewController<FRRWebViewControl> *childVC;

@end

@implementation FRRWebViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureChildViewController];
    [self.childVC loadURL:self.inputParams.url];

    [self configureSubviews];
    [self configureLayout];
    [self configureNavigationBar];
}

- (void)configureChildViewController {
    UIViewController<FRRWebViewControl> *vc;
    if (FRRWebEngine.engineType == FRRWKWebView) {
         vc = [[FRRWKWebViewController alloc] init];
    } else if (FRRWebEngine.engineType == FRRUIWebView) {
        vc = [[FRRUIWebViewController alloc] init];
    }
    vc.delegate = self;
    [self addChildViewController:vc];
    [self.view  addSubview:vc.view];
    [vc didMoveToParentViewController:self];
    self.childVC = vc;
}

- (void)disposeDetailWithSender:(id)sender {
    [self.childVC reload];
}

- (void)configureSubviews {
    if (FRRWebEngine.debug) {
        __weak typeof(self) weakSelf = self;
        FRRWebDebugView *webDebugView = [FRRWebDebugView webDebugViewWithCurrentURL:^NSString *{
            return weakSelf.childVC.currentWebViewURL;
        } completion:^(NSString *urlString) {
            [weakSelf.childVC loadURL:urlString];
        }];
        self.webDebugView = webDebugView;
        [self.view addSubview:webDebugView];
    }
}

- (void)webViewDidFinishChanged {
    [self updateLeftNavigationBar];
    [self configureTitle:self.childVC.currentWebViewTitle];
}

- (void)goBackWithSender:(id)sender {
    if ([self.childVC canGoBack]) {
        [self.childVC goBack];
    } else {
        [self goBack];
    }
}
- (void)closeWithSender:(id)sender {
    [self goBack];
}

- (void)goBack {
    if (self.presentingViewController) {
        [self dismissViewControllerAnimated:YES completion:NULL];
    } else {
        if (self.navigationController.viewControllers.count == 1) {
//            NSString *js = @"if( window.history.length > 1 ) { window.history.back( -( window.history.length - 1 ) ) };";
//            [self.webView evaluateJavaScript:js completionHandler:NULL];
            return;
        }
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)configureLayout {
    if (FRRWebEngine.debug) {
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.webDebugView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeRight multiplier:1 constant:0]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.webDebugView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1 constant:100]];
    }
}


- (void)configureNavigationBar {
    [self updateLeftNavigationBar];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Ferrari.bundle" ofType:nil];
    NSBundle *bundle = [NSBundle bundleWithPath:path];
    UIImage *refreshImage = [UIImage imageNamed:@"hybrid_refresh.png" inBundle:bundle compatibleWithTraitCollection:nil];
    
    
    UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc] initWithImage:refreshImage style:UIBarButtonItemStylePlain target:self action:@selector(disposeDetailWithSender:)];
    
    [self configureRightBarButtonItem:rightBarButton];
}


- (void)updateLeftNavigationBar {
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Ferrari.bundle" ofType:nil];
    NSBundle *bundle = [NSBundle bundleWithPath:path];
    UIImage *backImage = [UIImage imageNamed:@"hybrid_goBack.png" inBundle:bundle compatibleWithTraitCollection:nil];
    UIImage *closeImage = [UIImage imageNamed:@"hybrid_close.png" inBundle:bundle compatibleWithTraitCollection:nil];
    
    UIBarButtonItem *leftBarButton = [[UIBarButtonItem alloc] initWithImage:backImage style:UIBarButtonItemStylePlain target:self action:@selector(goBackWithSender:)];
    UIBarButtonItem *closeBarButton = [[UIBarButtonItem alloc] initWithImage:closeImage style:UIBarButtonItemStylePlain target:self action:@selector(closeWithSender:)];
    
    self.navigationItem.leftBarButtonItems = @[leftBarButton, closeBarButton];
    
    // 视图为nav root 且不是 present，不显示左边bar item
    if (self.navigationController.viewControllers.count == 1 && !self.presentingViewController && !self.childVC.canGoBack)
    {
        UIBarButtonItem *leftBarItem = [[UIBarButtonItem alloc] initWithCustomView:[[UIView alloc] init]];
        self.navigationItem.leftBarButtonItems = @[leftBarItem];
    }
    if (self.parentViewController) {
        self.parentViewController.navigationItem.leftBarButtonItems =  self.navigationItem.leftBarButtonItems;
    }
}

#pragma mark Parent
- (void)configureTitle:(NSString *)title {
    self.navigationItem.title = title;
    if (self.parentViewController) {
        self.parentViewController.navigationItem.title =  title;
    }
}

- (void)configureRightBarButtonItem:(UIBarButtonItem*)rightBarButtonItem
{
    self.navigationItem.rightBarButtonItem = rightBarButtonItem;
    if (self.parentViewController) {
        self.parentViewController.navigationItem.rightBarButtonItem =  rightBarButtonItem;
    }
}

@end
