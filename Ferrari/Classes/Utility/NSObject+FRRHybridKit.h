//
//  NSObject+FRRHybridKit.h
//  FRRHybridKit
//
//  Created by infiq on 2017/8/12.
//

#import <Foundation/Foundation.h>

typedef void (^FRRPerformBlock)(void);

@interface NSObject (FRRHybridKit)

- (void)frr_performOnThread:(NSThread*)thread waitUntilDone:(BOOL)wait block:(FRRPerformBlock)block;

@end
