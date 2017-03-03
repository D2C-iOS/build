//
//  ESHTTPServer.h
//  Server
//
//  Created by 翟泉 on 2017/3/3.
//  Copyright © 2017年 翟泉. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ESHTTPServer : NSObject

+ (instancetype)sharedInstance;

- (BOOL)start;

@end
