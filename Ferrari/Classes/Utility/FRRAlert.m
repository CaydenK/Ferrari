//
//  FRRAlert.m
//  Ferrari
//
//  Created by 周夏赛 on 2018/12/21.
//

#import "FRRAlert.h"

@implementation FRRAlert

+ (void)showAlertWithTitle:(NSString *)title message:(NSString *)message style:(UIAlertControllerStyle)style actionTitles:(NSArray<NSString *> *)actionTitles actionStyles:(NSArray<NSNumber *> *)actionStyles handler:(void (^ _Nullable)(UIAlertAction * _Nonnull, NSUInteger))handler {
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:style];
    for (int i = 0; i < actionTitles.count; i++) {
        UIAlertActionStyle style = actionStyles.count > i ? [actionStyles[i] integerValue] : UIAlertActionStyleDefault;
        UIAlertAction *action = [UIAlertAction actionWithTitle:actionTitles[i] style:style handler:^(UIAlertAction * _Nonnull action) {
            !handler ?: handler(action, i);
        }];
        [alertVC addAction:action];
    }
    [self.visibleViewContrller presentViewController:alertVC animated:YES completion:nil];
}

+ (UIViewController *)visibleViewContrller {
    UIViewController *rootViewController =[UIApplication sharedApplication].delegate.window.rootViewController;
    return [self getVisibleViewControllerFrom:rootViewController];
}

+ (UIViewController *) getVisibleViewControllerFrom:(UIViewController *) vc {
    if ([vc isKindOfClass:[UINavigationController class]]) {
        return [self getVisibleViewControllerFrom:[((UINavigationController *) vc) visibleViewController]];
    } else if ([vc isKindOfClass:[UITabBarController class]]) {
        return [self getVisibleViewControllerFrom:[((UITabBarController *) vc) selectedViewController]];
    } else {
        if (vc.presentedViewController) {
            return [self getVisibleViewControllerFrom:vc.presentedViewController];
        } else {
            return vc;
        }
    }
}


@end
