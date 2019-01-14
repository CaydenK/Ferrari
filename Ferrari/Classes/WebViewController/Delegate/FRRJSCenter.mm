//
//  FRRJSCenter.mm
//  weather
//
//  Created by CaydenK on 2016/12/5.
//  Copyright © 2016年 CaydenK. All rights reserved.
//

#import "FRRJSCenter.h"
#import <JavaScriptCore/JavaScriptCore.h>
#import <WebKit/WebKit.h>
#import <YYModel/YYModel.h>
#import "NSObject+FRRHybridKit.h"
#import "NSInvocation+FRRHybridKit.h"


typedef NS_ENUM(NSUInteger, _FRRBridgeParamsType) {
    _FRRBridgeParamsTypeObject = 0,
    _FRRBridgeParamsTypeFunction = 1,
};

@interface _FRRBridgeParams : NSObject
@property (copy, nonatomic)  NSString *cls;
@property (strong, nonatomic)  id content;
@property (assign, nonatomic)  _FRRBridgeParamsType type;
@end
@implementation _FRRBridgeParams
+ (NSDictionary *)modelCustomPropertyMapper {
    return @{ @"cls" : @"class" };
}
@end

@interface _FRRBridgeMessage : NSObject
@property (copy,   nonatomic) NSString *className;
@property (copy,   nonatomic) NSString *selectorName;
@property (strong, nonatomic) NSArray<_FRRBridgeParams *>  *params;
@property (copy,   nonatomic) NSString *returnType;
@end
@implementation _FRRBridgeMessage
+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"params" : [_FRRBridgeParams class]};
}
@end


@protocol FRRWebJSExport <JSExport>

@required
- (NSString *)jsbridgeNativeDisposeWithMesage:(NSString *)messageString;

@end



@interface FRRJSCenter ()<FRRWebJSExport>

@end

@implementation FRRJSCenter

static NSString *FRRJSCenterCreateCallbackJSMethod(NSString *selector,NSString *callbackID,id callbackParams) {
    NSString *callbackJS = [NSString stringWithFormat:@"ferrari.callJS('%@','%@',%@);",selector,callbackID,callbackParams?:@"null"];
    return callbackJS;
}

static BOOL FRRJSCenterClassIsCustomClass(Class cls) {
    NSBundle *mainB = [NSBundle bundleForClass:cls];
    return [mainB isEqual:[NSBundle mainBundle]];
}

#pragma mark - jscore bridge
- (NSString *)jsbridgeNativeDisposeWithMesage:(NSString *)messageString {
    NSThread *thread = [NSThread currentThread];
    
    __weak typeof(self) wSelf = self;
    return [FRRJSCenter disposeJSMessage:messageString asyncCompletion:^(NSString *selector,NSString *callbackID,id callbackParams) {
        [wSelf frr_performOnThread:thread waitUntilDone:NO block:^{
            [wSelf.context evaluateScript:FRRJSCenterCreateCallbackJSMethod(selector,callbackID,callbackParams)];
        }];
    }];
}

#pragma mark - webkit bridge
+ (NSString *)jsbridgeDisposeWithPrompt:(NSString *)prompt defaultText:(nullable NSString *)defaultText completion:(void(^)(NSString *compJS))completion{
    return [self disposeJSMessage:defaultText asyncCompletion:^(NSString *selector,NSString *callbackID,id callbackParams) {
        completion(FRRJSCenterCreateCallbackJSMethod(selector,callbackID,callbackParams));
    }];
}


+ (NSString *)disposeJSMessage:(NSString *)messageString asyncCompletion:(void(^)(NSString *selector,NSString *callbackID,id callbackParams))completionHandler {
    _FRRBridgeMessage *message = [_FRRBridgeMessage yy_modelWithJSON:messageString];
    
    Class targetCls = NSClassFromString(message.className);
    SEL sel = NSSelectorFromString(message.selectorName);
    
    NSMutableDictionary *resultDict = @{@"code":@(1)}.mutableCopy;
    if ([targetCls respondsToSelector:sel]) {
        
        NSMethodSignature *sig = [targetCls methodSignatureForSelector:sel];
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:sig];
        invocation.target = targetCls;
        invocation.selector = sel;
        
        for (int i = 2; i < sig.numberOfArguments; i++) {
            if (i - 2 >= message.params.count) {
                NSNull *null = [NSNull null];
                [invocation setArgument:&null atIndex:i];
                break;
            }
            
            _FRRBridgeParams *param = message.params[i-2];
            __autoreleasing id p;
            if (param.type == _FRRBridgeParamsTypeObject) {
                Class cls = NSClassFromString(param.cls);
                if (cls && FRRJSCenterClassIsCustomClass(cls)) {
                    p = [cls yy_modelWithJSON:param.content];
                    [invocation setArgument:&p atIndex:i];
                } else {
                    p = param.content;
                }
            } else if (param.type == _FRRBridgeParamsTypeFunction) {                
                if ([param.cls isEqualToString:@"void"]) {
                    p = ^(void){ completionHandler(message.selectorName,param.content,nil); };
                } else {
                    p = ^(id callbackParam){
                        NSMutableDictionary *mdic = @{}.mutableCopy;
                        mdic[@"data"] = callbackParam;
                        completionHandler(message.selectorName,param.content,[mdic yy_modelToJSONString]);
                    };
                }
            }
            [invocation frr_setArgument:p atIndex:i];
        }
        [invocation invoke];
        
        if (*(sig.methodReturnType) != 'v') {
            void *tempResultValue;
            [invocation getReturnValue:&tempResultValue];
            id resultValue = (__bridge id)tempResultValue;
            if (resultValue) {
                resultDict[@"data"] = resultValue;
            }
        }
    } else {
        resultDict[@"code"] = @(-1);
    }
    return [resultDict yy_modelToJSONString];
}

@end

