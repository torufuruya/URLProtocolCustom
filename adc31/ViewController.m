//
//  ViewController.m
//  adc31
//
//  Created by Toru Furuya on 2016/10/28.
//  Copyright © 2016年 com.example. All rights reserved.
//

#import "ViewController.h"
#import "URLProtocolCustom.h"
#import "Downloader.h"

@interface ViewController ()

@end

@implementation ViewController

@synthesize webView;

- (void)awakeFromNib
{
  [super awakeFromNib];
  
  self.webView = [[UIWebView alloc] initWithFrame:CGRectMake(20, 20, 280, 420)];
  [self.view addSubview:webView];
  
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  // Do any additional setup after loading the view, typically from a nib.

  // ----> IMPORTANT!!! :) <----
  [NSURLProtocol registerClass:[URLProtocolCustom class]];

  Downloader *downloader = [Downloader new];
  downloader.completionHandler = ^(NSError *error) {
    if (error) {
      NSLog(@"%@", error.localizedDescription);
      return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
      [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"file:///Users/toru.furuya/file.html"]]];
    });
  };
}


- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}


@end
