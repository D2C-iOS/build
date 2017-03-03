//
//  SvnManager.m
//  Server
//
//  Created by cyf on 17/3/3.
//  Copyright © 2017年 翟泉. All rights reserved.
//

#import "SvnManager.h"

@implementation SvnManager
+ (NSArray *)getSvnFileListWithPath:(NSString *)path {
    NSArray *argumentArray = @[
                               @"list",
                               path
                               ];
    NSMutableArray *resultArray = [[self class] taskWithpath:@"/usr/bin/svn" arguments:argumentArray];
    
    for (int i = 0; i < resultArray.count; i++) {
        if ([resultArray[i] rangeOfString:@"/"].location != NSNotFound && [resultArray[i] length] > 0) {
            resultArray[i]  = [resultArray[i] substringWithRange:NSMakeRange(0, [resultArray[i] length]-1)];
        }
    }
    return resultArray;
}


+ (void)checkOutFromPath:(NSString *)path {
    NSString *frameWorkPath = [path stringByAppendingPathComponent:FrameDocumentAboutProduct];
    
    if (![[self class] hasPath:frameWorkPath]) {
        NSLog(@"目录不存在");
        return;
    }
    NSArray *array = @[
                       @"checkout",
                       SVNPath,
                       [NSString stringWithFormat:@"--username=%@",SVNUserName],
                       [NSString stringWithFormat:@"--password=%@",SVNPassword],
                       frameWorkPath
                       ];
    NSArray *resultArray = [[self class] taskWithpath:@"/usr/bin/svn" arguments:array];
    NSLog(@"%@",resultArray);
}

+ (void)revertLocalWithPach:(NSString *)path {
    NSString *frameWorkPath = [path stringByAppendingPathComponent:FrameDocumentAboutProduct];
    
    if (![[self class] hasPath:frameWorkPath]) {
        NSLog(@"目录不存在");
        return;
    }
    [[NSTask launchedTaskWithLaunchPath:@"/usr/bin/svn" arguments:@[@"update",frameWorkPath]] waitUntilExit];
    [[NSTask launchedTaskWithLaunchPath:@"/usr/bin/svn" arguments:@[@"revert",@"-R",frameWorkPath]] waitUntilExit];
}



+ (void)checkoutWithInfoPlist:(NSString *)path {
    NSString *frameWorkPath = [path stringByAppendingPathComponent:FrameDocumentAboutProduct];
    
    NSString *plistPath = [[path stringByDeletingLastPathComponent] stringByAppendingPathComponent:FrameWorkName];
    if (![[self class] hasPath:plistPath]) {
        NSLog(@"目录下不存在配置文件");
        return;
    }
    NSMutableDictionary *frameworkDic = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
    for (NSString *key in [frameworkDic allKeys]) {
        if (!key || [key isEqualToString:@""]) {
            NSLog(@"更新失败 配置文件版本配置错误请检查");
            [[self class] printDic:frameworkDic];
            return;
        }
        
        NSArray *propertyArray = @[
                                   @"update",@"-r",
                                   [frameworkDic objectForKey:key],
                                   frameWorkPath,
                                   ];
        NSArray *array = [[self class] taskWithpath:@"/usr/bin/svn" arguments:propertyArray];
        NSLog(@"%@",array);
        
    }
}




/**
 创建任务
 
 @param path  命令
 @param array 参数
 @return 返回值
 */
+ (NSMutableArray *)taskWithpath:(NSString *)path arguments:(NSArray *)array {
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath:path];
    [task setArguments:array];
    
    NSPipe *pipe = [NSPipe pipe];
    [task setStandardOutput:pipe];
    
    NSFileHandle *file = [pipe fileHandleForReading];
    [task launch];
    [task waitUntilExit];
    
    NSData *dataRead = [file readDataToEndOfFile];
    
    
    NSString *result = [[NSString alloc] initWithData:dataRead encoding:NSUTF8StringEncoding];
    
    //返回数据转为数组
    NSMutableArray  *resultArray = [NSMutableArray arrayWithArray:[result componentsSeparatedByString:@"\n"]];


    [resultArray removeLastObject];
    return resultArray;
}


/**
 目录是否存在
 
 @param path 目录地址
 @return <#return value description#>
 */
+ (BOOL)hasPath:(NSString *)path {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    return [fileManager fileExistsAtPath:path];
}

/**
 打印字典
 
 @param dic <#dic description#>
 */
+ (void)printDic:(NSDictionary *)dic {
    for (NSString *key in dic) {
        NSLog(@"key:%@",key);
        NSLog(@"value:%@",[dic objectForKey:key]);
    }
}
@end
