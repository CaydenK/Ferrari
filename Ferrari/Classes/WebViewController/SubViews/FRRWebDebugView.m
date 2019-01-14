//
//  FRRWebDebugView.m
//  weather
//
//  Created by CaydenK on 2017/5/9.
//  Copyright © 2017年 CaydenK. All rights reserved.
//

#import "FRRWebDebugView.h"

@interface FRRWebDebugView ()

@property (strong, nonatomic) UIButton *debugButton;
@property (strong, nonatomic) UITextField *textField;
@property (strong, nonatomic) UIButton *sureButton;
@property (weak, nonatomic) NSLayoutConstraint *widthConstraint;

@property (copy, nonatomic) void(^completion)(NSString *url);
@property (copy, nonatomic) NSString *(^urlHandler)(void);

@end

@implementation FRRWebDebugView

+ (BOOL)requiresConstraintBasedLayout {
    return NO;
}

+ (instancetype)webDebugViewWithCurrentURL:(NSString *(^)(void))urlHandler completion:(void(^)(NSString *url))completion {
    FRRWebDebugView *webDebugView = [[self alloc] init];
    webDebugView.completion = completion;
    webDebugView.urlHandler = urlHandler;
    return webDebugView;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.translatesAutoresizingMaskIntoConstraints = NO;
        self.backgroundColor = UIColor.brownColor;
        [self configureSubviews];
        [self configureLayouts];
        [self closeDebugView];
    }
    return self;
}

- (void)openDebugView {
    if (self.urlHandler) {
        NSString *url = self.urlHandler();
        self.textField.text = url;
    }
    
    self.widthConstraint.constant = 300;
    self.debugButton.hidden = YES;
    self.textField.hidden = NO;
    self.sureButton.hidden = NO;
    [UIView animateWithDuration:0.25 animations:^{
        [self setNeedsLayout];
        [self layoutIfNeeded];
    }];
}

- (void)closeDebugView {
    self.widthConstraint.constant = 60;
    self.debugButton.hidden = NO;
    self.textField.hidden = YES;
    self.sureButton.hidden = YES;
    [UIView animateWithDuration:0.25 animations:^{
        [self setNeedsLayout];
        [self layoutIfNeeded];
    }];
}

- (void)debugButtonAction:(UIButton *)sender {
    [self openDebugView];
}
- (void)sureButtonAction:(UIButton *)sender {
    //回调
    !self.completion ?: self.completion(self.textField.text);
    [self endEditing:YES];
    //关闭
    [self closeDebugView];
}

#pragma mark - Subviews & Layouts
- (void)configureSubviews {
    [self addSubview:self.debugButton];
    [self addSubview:self.textField];
    [self addSubview:self.sureButton];
}
- (void)configureLayouts {
    NSLayoutConstraint *widthConstraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:60];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:44] ];
    [self addConstraint:widthConstraint];
    self.widthConstraint = widthConstraint;
    
    {//debugButton
        //left
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.debugButton attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1 constant:0]];
        //top
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.debugButton attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
        //bottom
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.debugButton attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
        
        
        [self.debugButton addConstraint:[NSLayoutConstraint constraintWithItem:self.debugButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:64]];
    }
    
    {//sureButton
        //right
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.sureButton attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1 constant:0]];
        //top
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.sureButton attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
        //bottom
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.sureButton attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
        
        [self.sureButton addConstraint:[NSLayoutConstraint constraintWithItem:self.sureButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:60]];
    }

    
    {//textField
        //right
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.textField attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.sureButton attribute:NSLayoutAttributeLeft multiplier:1 constant:0]];
        //top
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.textField attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
        //bottom
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.textField attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
        
        [self.textField addConstraint:[NSLayoutConstraint constraintWithItem:self.textField attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:240]];
    }
}

#pragma mark - Getter
- (UIButton *)debugButton {
    if (!_debugButton) {
        _debugButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _debugButton.translatesAutoresizingMaskIntoConstraints = NO;
        [_debugButton addTarget:self action:@selector(debugButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [_debugButton setTitle:@"调试" forState:UIControlStateNormal];
    }
    return _debugButton;
}

- (UITextField *)textField {
    if (!_textField) {
        _textField = [[UITextField alloc] initWithFrame:CGRectZero];
        _textField.translatesAutoresizingMaskIntoConstraints = NO;
        _textField.keyboardType = UIKeyboardTypeURL;
        _textField.placeholder = @"fuck网址";
    }
    return _textField;
}

- (UIButton *)sureButton {
    if (!_sureButton) {
        _sureButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _sureButton.translatesAutoresizingMaskIntoConstraints = NO;
        [_sureButton addTarget:self action:@selector(sureButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [_sureButton setTitle:@"确定" forState:UIControlStateNormal];
    }
    return _sureButton;
}


@end
