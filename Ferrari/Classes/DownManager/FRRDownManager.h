//
//  FRRDownManager.h
//  Ferrari
//
//  Created by CaydenK on 2017/10/9.
//

#import <Foundation/Foundation.h>

@interface FRRDownManager : NSObject

+ (void)downloadFileWithURL:(NSURL *)url completion:(void(^)(BOOL success, id responseObject))completion;
+ (void)asyncDownloadFilesWithURLs:(NSArray<NSString *> *)urls
                         condition:(BOOL(^)(NSURL *url))condition
                    fileCompletion:(void (^)(BOOL success, NSURL *url, id responseObject))fileCompletion
                        completion:(void(^)(BOOL success))completion;
@end
