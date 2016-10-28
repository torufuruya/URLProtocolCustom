//
//  URLProtocolCustom.m
//  adc31
//
//  Created by Toru Furuya on 2016/10/28.
//  Copyright © 2016年 com.example. All rights reserved.
//

#import "URLProtocolCustom.h"
#import "ViewController.h"

@interface URLProtocolCustom()

@property NSString *appPath;

@end

@implementation URLProtocolCustom

+ (BOOL)canInitWithRequest:(NSURLRequest*)theRequest
{
  NSLog(@"%@", theRequest.URL.absoluteString);
  if ([theRequest.URL.scheme caseInsensitiveCompare:@"myapp"] == NSOrderedSame) {
    return YES;
  }
  return NO;
}

+ (NSURLRequest*)canonicalRequestForRequest:(NSURLRequest*)theRequest
{
  return theRequest;
}

- (void)startLoading
{
  NSLog(@"%@", self.request.URL);

  NSString *cachePath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0];
  self.appPath = [[NSURL fileURLWithPath:cachePath] URLByAppendingPathComponent:@"adc31"].path;

//  NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"image" ofType:@"jpeg"];
  NSURL *imagePath = [self getAssetFilePath:@"image.jpeg"];
  NSData *data = [NSData dataWithContentsOfURL:imagePath];
//  NSData *data = [NSData dataWithContentsOfFile:imagePath];

  NSURLResponse *response = [[NSURLResponse alloc] initWithURL:[self.request URL]
                                                      MIMEType:@"image/png"
                                         expectedContentLength:data.length
                                              textEncodingName:nil];

  [[self client] URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
  [[self client] URLProtocol:self didLoadData:data];
  [[self client] URLProtocolDidFinishLoading:self];
}

- (void)stopLoading
{
  NSLog(@"request cancelled. stop loading the response, if possible");
}

- (NSURL *)getAssetFilePath:(NSString *)filename {
  return [NSURL fileURLWithPathComponents:@[self.appPath, filename]];
}

@end
