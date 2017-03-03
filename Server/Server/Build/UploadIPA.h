//
//  UploadIPA.h
//  111111
//
//  Created by fengjiwen on 17/3/1.
//  Copyright © 2017年 fengjiwen. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol UploadIPADelegate <NSObject>

//进度
- (void)connectionTotalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite;

//当接收到服务器的响应（连通了服务器）时会调用

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response;

//服务器返回数据
 /*
   appShortcutUrl	    应用短链接
   appQRCodeURL		    应用二维码地址
   appUpdateDescription	应用更新说明
   appVersion		    版本号
 */
-(void)connectionappShortcutUrl:(NSString *)appShortcutUrl appQRCodeURL:(NSString *)appQRCodeURL appUpdateDescription:(NSString *)appUpdateDescription appVersion:(NSString *)appVersion;

@end

@interface UploadIPA : NSObject

@property (nonatomic, weak) id<UploadIPADelegate> delegate;

- (instancetype)initWithUKey:(NSString *)uKey withAIPKey:(NSString *)apiKey;

- (void)uploadIPA:(NSString *)ipaPath description:(NSString *)description;

- (void)cancel;

@end
