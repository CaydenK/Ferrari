//
//  FRRNavigationUIPlugin.m
//  Ferrari
//
//  Created by CaydenK on 2018/8/10.
//

#import "FRRNavigationUIPlugin.h"
#import "FRRWebViewController.h"

static NSString * const kFRRSetNavigationRightMethodName = @"setRightNavigation";
static NSString * const kFRRResetNavigationMethodName = @"resetNavigation";

//@implementation FRRNavigationUIPlugin
//@synthesize webController;
//
//+ (void)performBlock:(void(^)(void))block onThread:(NSThread *)thr {
//    [self performSelector:@selector(executeBlock:) onThread:thr withObject:block waitUntilDone:YES];
//}
//+ (void)executeBlock:(void(^)(void))block {
//    !block ?: block();
//}
//
//
//#pragma mark - FRRJSBridgeProtocol
//+ (BOOL)isSupportMethodWithMethodName:(NSString *)methodName {
//    if (!methodName) { return NO; }
//    if ([methodName isEqualToString:kFRRSetNavigationRightMethodName]) {
//        return YES;
//    } else if ([methodName isEqualToString:kFRRResetNavigationMethodName]) {
//        return YES;
//    }
//    return NO;
//}
//
//- (void)executeMethodWithName:(NSString *)methodName params:(id)params completion:(void (^)(FRRJSBridgeCompletionType, id))completion {
//    if ([methodName isEqualToString:kFRRSetNavigationRightMethodName]) {
//        NSThread *webThread = [NSThread currentThread];
//        
//        
//        NSString *imgType = params[@"img"];
//        NSString *path = [[NSBundle mainBundle] pathForResource:@"Ferrari.bundle" ofType:nil];
//        NSBundle *bundle = [NSBundle bundleWithPath:path];
//        UIImage *img;
//
//        if ([imgType isEqualToString:@"share"]) {
//            img = [UIImage imageNamed:@"hybrid_share.png" inBundle:bundle compatibleWithTraitCollection:nil];
//        } else if ([imgType isEqualToString:@"reload"]) {
//            img = [UIImage imageNamed:@"hybrid_refresh.png" inBundle:bundle compatibleWithTraitCollection:nil];
//        }
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [self.webController configureRightBarWithImage:img action:^(UIBarButtonItem *barButtonItem) {
//                [FRRNavigationUIPlugin performBlock:^{
//                    completion(FRRJSBridgeTypeSuccess,nil);
//                } onThread:webThread];
//            }];
//        });
//    } else if ([methodName isEqualToString:kFRRResetNavigationMethodName]) {
//        dispatch_async(dispatch_get_main_queue(), ^{
//           [self.webController configureNavigationBar];
//        });
//    }
//}
//
//
//@end
