//
//  FRRWebProtocol.h
//  Ferrari
//
//  Created by CaydenK on 2018/10/29.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol FRRWebViewControllerNavigation <NSObject>

- (void)webViewDidFinishChanged;


@end


@protocol FRRWebViewControl <NSObject>

@required
@property (weak, nonatomic) id<FRRWebViewControllerNavigation> delegate;
- (NSString *)currentWebViewTitle;
- (NSString *)currentWebViewURL;
- (void)loadURL:(NSString *)url;
- (BOOL)canGoBack;
- (void)goBack;
- (void)reload;

@end

NS_ASSUME_NONNULL_END
