//
//  FRRAlert.h
//  Ferrari
//
//  Created by 周夏赛 on 2018/12/21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FRRAlert : NSObject

+ (void)showAlertWithTitle:(NSString *)title message:(NSString *)message style:(UIAlertControllerStyle)style actionTitles:(NSArray<NSString *> *)actionTitles actionStyles:(NSArray<NSNumber *> *)actionStyles handler:( void(^ _Nullable)(UIAlertAction *action, NSUInteger index))handler;

@end

NS_ASSUME_NONNULL_END
