//
//  NSInvocation+FRRHybridKit.h
//  Ferrari
//
//  Created by 周夏赛 on 2018/12/29.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSInvocation (FRRHybridKit)

- (void)frr_setArgument:(id)argumentValue atIndex:(NSUInteger)index;

@end

NS_ASSUME_NONNULL_END
