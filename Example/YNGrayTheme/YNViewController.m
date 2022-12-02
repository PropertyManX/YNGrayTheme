//
//  YNViewController.m
//  YNGrayTheme
//
//  Created by PropertyManX on 12/02/2022.
//  Copyright (c) 2022 PropertyManX. All rights reserved.
//

#import "YNViewController.h"
#import <WebKit/WebKit.h>

@interface YNViewController ()

@property (weak, nonatomic) IBOutlet WKWebView *webView;
@property (weak, nonatomic) IBOutlet UIImageView *imageview;

@end

@implementation YNViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.imageview setImage:[UIImage imageNamed:@"缅怀江泽民同志"]];
    NSURL *url=[NSURL URLWithString:@"https://baike.baidu.com/item/%E6%B1%9F%E6%B3%BD%E6%B0%91/115299"];
    NSURLRequest *request=[NSURLRequest requestWithURL:url];
    [self.webView loadRequest:request];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
