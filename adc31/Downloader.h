//
//  Downloader.h
//  adc31
//
//  Created by Toru Furuya on 2016/10/28.
//  Copyright © 2016年 com.example. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Downloader : NSObject<NSURLSessionDownloadDelegate>

@property (nonatomic) void (^completionHandler)(NSError *);

@end
