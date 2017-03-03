//
//  SendEmail.m
//  Test_upload
//
//  Created by d2c_cyf on 17/3/1.
//  Copyright © 2017年 d2c_cyf. All rights reserved.
//

#import "SendEmail.h"

@implementation SendEmail
+ (BOOL)hasDocument:(NSString *)path {
    NSError *error = nil;
    NSArray<NSString *> *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:&error];
    if (error) {
        NSLog(@"%s:%@",__FUNCTION__,error);
        return NO;
    }
    __block BOOL result = NO;
    [contents enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isEqualToString:@"sendEmail"]) {
            result = YES;
            *stop  = YES;
        }
    }];
    return result;
}

+ (BOOL)sendMessageWithEmails:(NSArray *)mails title:(NSString *)title content:(NSString *)content {
    NSString *str = [SendEmailManager stringByDeletingLastPathComponent];
    if (![[self class] hasDocument:str]) {
        NSLog(@"SendMail在目录地址不存在");
        return NO;
    }
    
    
    NSArray *array = @[
                       @"-f", SenderMail,
                       @"-xu",SendUserName,
                       @"-xp",SenderPassword,
                       @"-s", SenderSmtpHost,
                       @"-u", title,
                       @"-m", content,
                       @"-o", @"message-charset=utf-8",
                       @"-t"
                       ];

    NSMutableArray *muarray = [[NSMutableArray alloc] initWithArray:array];
    for (NSString *mail in mails) {
        [muarray addObject:mail];
    }
    
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath:SendEmailManager];
    [task setArguments:muarray];
    
    NSPipe *pipe = [NSPipe pipe];
    [task setStandardOutput:pipe];
    
    NSFileHandle *file = [pipe fileHandleForReading];
    [task launch];
    [task waitUntilExit];
    
    NSData *dataRead = [file readDataToEndOfFile];
    
    
    NSString *result = [[NSString alloc] initWithData:dataRead encoding:NSUTF8StringEncoding];
    
    if ([result rangeOfString:@"Error"].location == NSNotFound) {
        NSLog(@"==%@",result);
        return NO;
    }
    else {
        return YES;
    }
}
@end
