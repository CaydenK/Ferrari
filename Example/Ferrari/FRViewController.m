//
//  FRViewController.m
//  Ferrari
//
//  Created by 菘蓝 on 09/19/2017.
//  Copyright (c) 2017 菘蓝. All rights reserved.
//

#import "FRViewController.h"
#import "Ferrari.h"
#import <objc/message.h>
#import "FRRWebInputModel.h"

@interface FRViewController ()

@end

@implementation FRViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)btnAction:(id)sender {
    NSLog(@"start____:%lf",CFAbsoluteTimeGetCurrent());
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"demo" ofType:@"html"];
    NSURL *url = [NSURL fileURLWithPath:filePath]; // file:///user/...../index.html
//    NSURL *url = [NSURL URLWithString:@"https://www.baidu.com"];
    
    FRRWebViewController *webViewController = [[FRRWebViewController alloc] init];
    FRRWebInputModel *inputModel = [[FRRWebInputModel alloc] init];
    inputModel.url = url.absoluteString;
    [webViewController setValue:inputModel forKey:@"inputParams"];

    [self.navigationController pushViewController:webViewController animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
