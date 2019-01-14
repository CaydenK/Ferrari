//
//  NSObject+FRRHybridKit.m
//  FRRHybridKit
//
//  Created by infiq on 2017/8/12.
//

#import "NSObject+FRRHybridKit.h"

@implementation NSObject (FRRHybridKit)

- (void)frr_performOnThread:(NSThread*)thread waitUntilDone:(BOOL)wait block:(FRRPerformBlock)block {
    thread = thread ?: [NSThread currentThread];
    [self performSelector:@selector(frr_execBlock:) onThread:thread withObject:block waitUntilDone:wait];
}

- (void)frr_execBlock:(FRRPerformBlock)block {
    if (block) {
        block();
    }
}

@end
