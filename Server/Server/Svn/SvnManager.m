//
//  SvnManager.m
//  Server
//
//  Created by cyf on 17/3/3.
//  Copyright © 2017年 翟泉. All rights reserved.
//

#import "SvnManager.h"

@implementation SvnManager
//check 具体版本的代码与依赖库  并把依赖库拷贝到项目的具体文件内
+ (BOOL)checkOutWithBuildPath:(NSString *)buildPath localPath:(NSString *)localPath {
    //    NSRange buildRange = [buildPath rangeOfString:SVNPath];
    //    if (buildRange.location == NSNotFound) {
    //        [SvnhelpModel shareInstance].errorInfo = @"请求地址svn路径与约定svn路径不同";
    //        return;
    //    }
    //    //拿到最后的路径如 tags/xxx_2.3.0  releace/xxx_2.3.0
    //    NSString *buildtStr  = [buildPath substringFromIndex:buildRange.length];
    //
    //    //需要查找的完整本地路径
    //    NSString *searchPath = [localPath stringByAppendingPathComponent:buildtStr];
    
    __block BOOL codeFlag      = NO;
    __block BOOL frameworkFlag = NO;
    NSBlockOperation *checkCodeOperation = [NSBlockOperation blockOperationWithBlock:^{
        codeFlag      = [[self class] checkOutFromPath:buildPath localPath:localPath isFramework:NO];
    }];
    
    NSBlockOperation *checkFrameworkOperation = [NSBlockOperation blockOperationWithBlock:^{
        frameworkFlag = [[self class] checkOutFromPath:FrameworkSvnPath localPath:localPath isFramework:YES];
    }];
    
    [checkFrameworkOperation addDependency:checkCodeOperation];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [queue addOperations:@[checkCodeOperation, checkFrameworkOperation] waitUntilFinished:YES];
    
    
    BOOL copyFlag = NO;
    if (codeFlag && frameworkFlag) {
        NSLog(@"代码与依赖库库 下载完成 复制依赖库到指定目录");
        NSString *lastPath = [[self class] getLocalProductPathWithbuildPath:buildPath localPath:localPath];
        copyFlag = [[self class] copyFromPath:[localPath stringByAppendingPathComponent:@"Framework"] toPath:[lastPath stringByAppendingPathComponent:@"Framework"]];
    }
    
    if (copyFlag) {
        NSLog(@"依赖库复制完成");
        return YES;
    }
    else {
        return NO;
    }
    
}

//check代码具体操作
+ (BOOL)checkOutFromPath:(NSString *)path localPath:(NSString *)localPath isFramework:(BOOL)frameworkFlag{
    NSFileManager *manager  = [NSFileManager defaultManager];
    NSString *lastLocalPath = nil;
    if (frameworkFlag) {
        lastLocalPath = [localPath stringByAppendingPathComponent:@"Framework"];
    }
    else {
        lastLocalPath = [[self class] getLocalProductPathWithbuildPath:path localPath:localPath];
    }
    if ([[self class] hasPath:lastLocalPath]) {
        //todo 覆盖？？？
        NSLog(@"存在");
    }
    else {
        NSError *error = nil;
        BOOL flag = [manager createDirectoryAtPath:localPath withIntermediateDirectories:YES attributes:nil error:&error];
        NSLog(@"%d  %@",flag,error);
    }
    NSArray *array = @[
                       @"checkout",
                       path,
                       //                       [NSString stringWithFormat:@"--username=%@",SVNUserName],
                       //                       [NSString stringWithFormat:@"--password=%@",SVNPassword],
                       lastLocalPath
                       ];
    NSString *resultStr = [[self class] taskReturnStrWithpath:@"/usr/bin/svn" arguments:array];
    if ([resultStr rangeOfString:@"Error"].location == NSNotFound) {
        return YES;
    }
    else {
        return NO;
    }
    //    NSLog(@"%@",resultArray);
}


//获取本地代码仓与依赖库信息
+ (SvnhelpModel *)getLocalInfoWithBuildPath:(NSString *)buildPath localPath:(NSString *)localPath {
    [SvnhelpModel reset];
    if (!localPath || [localPath isEqualToString:@""]) {
        [SvnhelpModel shareInstance].errorInfo = @"本地项目地址为空";
        return [SvnhelpModel shareInstance];
    } else if (!buildPath || [buildPath isEqualToString:@""]) {
        [SvnhelpModel shareInstance].errorInfo = @"请求地址路径为空";
        return [SvnhelpModel shareInstance];
    }
    
    
    NSFileManager *fileManaher = [NSFileManager defaultManager];
    //    NSRange buildRange = [buildPath rangeOfString:SVNPath];
    //    if (buildRange.location == NSNotFound) {
    //        [SvnhelpModel shareInstance].errorInfo = @"请求地址svn路径与约定svn路径不同";
    //        return [SvnhelpModel shareInstance];
    //    }
    
    //需要查找的完整本地路径
    NSString *searchPath = [[self class] getLocalProductPathWithbuildPath:buildPath localPath:localPath];
    
    //项目代码不存在
    if (![fileManaher fileExistsAtPath:searchPath]) {
        [SvnhelpModel shareInstance].errorInfo = @"本地未发现与请求相同的代码";
        return [SvnhelpModel shareInstance];
    }
    
    
    //拿本地代码svn提交号
    NSArray *codeSvnArray = @[
                              @"log",
                              searchPath
                              ];
    NSString *codeResult = [[self class] taskReturnStrWithpath:@"/usr/bin/svn" arguments:codeSvnArray];
    NSString *codeResion  = [[self class] getResignWithtaskResultStr:codeResult result:^(BOOL flag, NSString *resion) {
        
    }];
    
    //拿到framework提交号
    NSArray *svnFrameworkArray = @[
                                   @"log",
                                   [searchPath stringByAppendingPathComponent:@"Framework"]
                                   ];
    NSString *frameworkResult = [[self class] taskReturnStrWithpath:@"/usr/bin/svn" arguments:svnFrameworkArray];
    
    if ([frameworkResult isEqualToString:@""]) {
        NSArray *svnFrameworkArray = @[
                                       @"log",
                                       [[localPath stringByDeletingLastPathComponent] stringByAppendingPathComponent:@"Framework"]
                                       ];
        frameworkResult = [[self class] taskReturnStrWithpath:@"/usr/bin/svn" arguments:svnFrameworkArray];
    }
    
    NSString *frameworkRevision = [[self class] getResignWithtaskResultStr:frameworkResult result:^(BOOL flag, NSString *resion) {
        
    }];
    
    
    
    
    if (codeResion && frameworkRevision) {
        [SvnhelpModel shareInstance].errorInfo = nil;
        [SvnhelpModel shareInstance].state     = 1;
        [SvnhelpModel shareInstance].productPath = searchPath;
        [SvnhelpModel shareInstance].productSign = [NSString stringWithFormat:@"%@_%@",codeResion,frameworkRevision];
    }
    else if (!codeResion) {
        [SvnhelpModel reset];
        [SvnhelpModel shareInstance].errorInfo = @"本地不存在该版本号代码";
    }
    else if (!codeResult) {
        [SvnhelpModel reset];
        [SvnhelpModel shareInstance].errorInfo = @"本地不存在Framework";
    }
    
    return [SvnhelpModel shareInstance];
}

//根据返回信息 svn命令返回数据 得到返回信息
+ (NSString *)getResignWithtaskResultStr:(NSString *)resultStr result:(void(^)(BOOL flag, NSString *resion))result {
    if (!resultStr) {
        result(NO,@"");
        return nil;
    }
    NSRange newRevisionRange = [resultStr rangeOfString:@"---\nr"];
    
    if (newRevisionRange.location == NSNotFound) {
        NSString *error = [NSString stringWithFormat:@"svn取log失败 详情:%@",resultStr];
        result(NO,error);
        return nil;
    }
    else {
        
        NSRange  newRevisionTail = [resultStr rangeOfString:@" |"];
        NSInteger begin = newRevisionRange.length + newRevisionRange.location;
        NSInteger end   = newRevisionTail.location - begin;
        NSString *codeResion = [resultStr substringWithRange:NSMakeRange(begin, end)];
        result(YES,codeResion);
        return codeResion;
    }
}

//根据请求和本地仓库  获得确定版本的绝对路径
+ (NSString *)getLocalProductPathWithbuildPath:(NSString *)buildPath localPath:(NSString *)localPath {
    if (!buildPath || !localPath) {
        return nil;
    }
    NSArray *compontFromePathArray = [buildPath componentsSeparatedByString:@"/"];
    if (compontFromePathArray.count < 2) {
        return nil;
    }
    NSString *document = [NSString stringWithFormat:@"%@/%@",compontFromePathArray[compontFromePathArray.count-2],[compontFromePathArray lastObject]];
    NSString *lastLocalPath = [localPath stringByAppendingPathComponent:document];
    return lastLocalPath;
    
}

//拷贝
+ (BOOL)copyFromPath:(NSString *)fromPath toPath:(NSString *)toPath {
    NSFileManager *manager = [NSFileManager defaultManager];
    if (![manager fileExistsAtPath:fromPath] || ![manager fileExistsAtPath:toPath]) {
        return NO;
    }
    BOOL deleteFlag = [[self class] deleteFromPath:toPath];
    if (!deleteFlag) {
        return NO;
    }
    NSArray *array = [manager contentsOfDirectoryAtPath:fromPath error:nil];
    NSError *error = nil;
    for (NSString *fileName in array) {
        BOOL flag =   [manager copyItemAtPath:[fromPath stringByAppendingPathComponent:fileName] toPath:[toPath stringByAppendingPathComponent:fileName] error:&error];
        if (!flag) {
            NSLog(@"%@",error);
            return NO;
        }
        
    }
    return YES;
}

//删除
+ (BOOL)deleteFromPath:(NSString *)path {
    NSFileManager *manager = [NSFileManager defaultManager];
    NSError *error = nil;
    NSArray *array = [manager contentsOfDirectoryAtPath:path error:&error];
    for (NSString *fileName in array) {
        BOOL flag = [manager removeItemAtPath:[path stringByAppendingPathComponent:fileName] error:&error];
        if (!flag) {
            NSLog(@"%@",error);
            return NO;
        }
    }
    return YES;
    
}

/**
 创建任务  返回数组
 
 @param path  命令
 @param array 参数
 @return 数组
 */
+ (NSMutableArray *)taskWithpath:(NSString *)path arguments:(NSArray *)array {
    NSString *result = [[self class] taskReturnStrWithpath:path arguments:array];
    //返回数据转为数组
    NSMutableArray  *resultArray = [NSMutableArray arrayWithArray:[result componentsSeparatedByString:@"\n"]];
    [resultArray removeLastObject];
    return resultArray;
}



/**
 创建任务 返回字符串
 
 @param path  命令
 @param array 参数
 @return 字符串
 */
+ (NSString *)taskReturnStrWithpath:(NSString *)path arguments:(NSArray *)array {
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
    
    return result;
}


//获取目录文件下的文件名称
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
