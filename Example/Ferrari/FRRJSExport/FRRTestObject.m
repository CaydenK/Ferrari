//
//  FRRTestObject.m
//  Ferrari_Example
//
//  Created by CaydenK on 2018/10/18.
//  Copyright © 2018 菘蓝. All rights reserved.
//

#import "FRRTestObject.h"

@implementation HSATestInput
@end
@implementation HSATestOutput
+ (instancetype)testObject {
    HSATestOutput * output = [[HSATestOutput alloc] init];
    output.propertyName = @"1";
    output.propertyName1 = @(2333);
    return output;
}
@end


@implementation FRRTestObject

#pragma mark - 所有都有
+ (HSATestOutput *)allTypeWithInput:(HSATestInput *)inputParam abcabc:(void(^)(NSString *))completion FRRJSMethod {
    completion(@"2fjhsdjfkl32j2lkj3rl2l3jl2j3lkj23kl2jl32j");
//    return [HSATestOutput testObject];
    return [HSATestOutput testObject];
}

@end

