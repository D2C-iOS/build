//
//  SendEmail.h
//  Test_upload
//
//  Created by cyf on 17/3/1.
//  Copyright © 2017年 cyf. All rights reserved.
//

#import <Foundation/Foundation.h>

//邮件服务地址
#define SendEmailManager @"./Server/SendEmail/sendEmail-v1.56/sendEmail"

//发送者邮箱
#define SenderMail       @"cyfsoftware@126.com"

//发送者昵称
#define SendUserName     @"cyfsoftware"

//发送者smtp密码
#define SenderPassword   @"cyf123456789"

//发送者smtp
#define SenderSmtpHost   @"smtp.126.com"

@interface SendEmail : NSObject

/**
 发送邮件

 @param mails   接受者的数组
 @param title   邮件标题
 @param content 邮件的主体
 @return        是否发送成功
 */
+ (BOOL)sendMessageWithEmails:(NSArray *)mails title:(NSString *)title content:(NSString *)content;
@end
