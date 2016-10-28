//
//  Downloader.m
//  adc31
//
//  Created by Toru Furuya on 2016/10/28.
//  Copyright © 2016年 com.example. All rights reserved.
//

#import "Downloader.h"

@interface Downloader()

@property (nonatomic) NSFileManager *manager;
@property (nonatomic, copy) NSString *cachePath;
@property (nonatomic, copy) NSString *appPath;

@property (nonatomic) NSURLSession *session;
@property (nonatomic) NSURLSessionDownloadTask *task;

@end

@implementation Downloader

NSString *const kSessionId = @"jp.glossom.Sugar";
const long kTimeoutIntervalForDownload = 60.0 * 60.0;  // an hour

- (instancetype)init
{
  self = [super init];
  if (self) {
    _manager = [NSFileManager defaultManager];
    _cachePath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0];
    _appPath = [[NSURL fileURLWithPath:_cachePath] URLByAppendingPathComponent:@"adc31"].path;

    NSURL *url = [NSURL URLWithString:@"https://d3v1lb83psg9di.cloudfront.net/output_static/ui/v4vc-btn-cancel-down-x2.png"];

    NSURLSessionConfiguration *config;
    config = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@"adc31"];
    config.timeoutIntervalForResource = 60;
    _session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:nil];
    _task = [_session downloadTaskWithURL:url];
    [_task resume];
  }
  return self;
}

#pragma mark - NSURLSessionDownloadDelegate

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location {
  NSString *filename = location.pathComponents.lastObject;
  NSString *original = downloadTask.response.suggestedFilename;
  if (original) {
    filename = @"image.jpeg";
  }

  NSHTTPURLResponse *res = (NSHTTPURLResponse *)downloadTask.response;
  if (res.statusCode != 200) {
    NSLog(@"=====================");
    return;
  }

  NSURL *newLocation = [self getAssetFilePath:filename];
  [self save:location destinationURL:newLocation completion:^(NSURL *filepath, NSError *error) {
    if (error) {
      self.completionHandler(error);
      return;
    }

    self.completionHandler(nil);
  }];
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
  [self.session finishTasksAndInvalidate];
  self.task = nil;

  if (error != nil) {
    self.completionHandler(error);
  }
}

- (NSURL *)getAssetFilePath:(NSString *)filename {
  return [NSURL fileURLWithPathComponents:@[self.appPath, filename]];
}

- (void)save:(NSURL *)originalURL destinationURL:(NSURL *)dest completion:(void (^)(NSURL *, NSError *))completionHandler {

  NSError *error = nil;
  [self.manager moveItemAtPath:originalURL.path toPath:dest.path error:&error];
  if (error) {
    NSLog(@"%@", [NSString stringWithFormat:@"from: %@, to: %@", originalURL.path, dest.path]);
    NSLog(@"%@", error.localizedDescription);
    completionHandler(nil, error);
    return;
  }

  // Disable to backup to iTunes and iCloud
  [dest setResourceValue:[NSNumber numberWithBool:YES] forKey:NSURLIsExcludedFromBackupKey error:&error];
  if (error) {
    NSLog(@"%@", [NSString stringWithFormat:@"from: %@, to: %@", originalURL.path, dest.path]);
    NSLog(@"%@", error.localizedDescription);
    completionHandler(nil, error);
    return;
  }

  completionHandler(dest, nil);
}

@end
