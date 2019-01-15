//
//  FRAppDelegate.m
//  Ferrari
//
//  Created by 菘蓝 on 09/19/2017.
//  Copyright (c) 2017 菘蓝. All rights reserved.
//

#import "FRAppDelegate.h"
#import <Ferrari/Ferrari.h>
#import <Ferrari/FRRUtility.h>


@implementation FRAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    UINavigationController *navi = (id)self.window.rootViewController;
    
    [FRRWebEngine startEngine];
    FRRWebEngine.debug = YES;
    FRRWebEngine.engineType = FRRUIWebView;
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     manifest.json 格式：
     
     {
         "version": 1547432397,
         "html": [
            "https://example.domain.com/demo.html",
         ],
         "js": [
            "https://example.domain.com/demo.js",
         ],
         "css": [
            "https://example.domain.com/demo.css",
         ],
         "img": [
            "https://example.domain.com/demo.png",
         ]
     }
     */
    ///*
    NSURL *url = [NSURL URLWithString:@"http://example.domain.com/manifest.json"];
    NSMutableURLRequest * request = [[NSMutableURLRequest alloc]initWithURL:url];
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    configuration.requestCachePolicy = NSURLRequestReturnCacheDataDontLoad;
    NSURLSession *section = [NSURLSession sessionWithConfiguration:configuration];
    NSURLSessionDataTask *task = [section dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (!error) {
            NSString *jsonString = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
            NSDictionary *config = [FRRUtility jsonDataFromString:jsonString];
            [FRRWebEngine updateOfflinePackageWithConfig:config];
        }
    }];
    [task resume];
    //*/
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
