//
//  FRRTestObject.h
//  Ferrari_Example
//
//  Created by CaydenK on 2018/10/18.
//  Copyright © 2018 菘蓝. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Ferrari/Ferrari.h>

NS_ASSUME_NONNULL_BEGIN

@interface HSATestInput : NSObject

@property (copy,   nonatomic)           NSString *propertyName;
@property (copy,   nonatomic)           NSNumber *propertyName1;
@property (copy,   nonatomic)           NSNumber *phone;


@property (copy,   nonatomic) void(^callback)(NSArray *output);




@end

@interface HSATestOutput : NSObject

@property (copy,   nonatomic)           NSString *propertyName;
@property (copy,   nonatomic)           NSNumber *propertyName1;

@end


@interface FRRTestObject : NSObject <FRRJSExport>

@end

NS_ASSUME_NONNULL_END
