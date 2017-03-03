//
//  ESHTTPConnection.m
//  Server
//
//  Created by 翟泉 on 2017/3/3.
//  Copyright © 2017年 翟泉. All rights reserved.
//

#import "ESHTTPConnection.h"

#import <CocoaHTTPServer/HTTPDataResponse.h>


@interface ESHTTPConnection ()

@property (atomic, assign) BOOL isBuilding;

@property (nonatomic, strong) NSString *statusInfo;

@end

@implementation ESHTTPConnection
{
    NSDictionary *_parameter;
}




- (BOOL)expectsRequestBodyFromMethod:(NSString *)method atPath:(NSString *)path
{
    return [super expectsRequestBodyFromMethod:method atPath:path];
}

- (BOOL)supportsMethod:(NSString *)method atPath:(NSString *)path
{
    return [super supportsMethod:method atPath:path];
}

- (NSObject<HTTPResponse> *)httpResponseForMethod:(NSString *)method URI:(NSString *)path
{
    // /repo/list?name=xxx 获取代码仓库列表
    // /build?repo=xxx&environment=xxx&apihost=xxx  打包
    
    NSLog(@"收到请求: %@", path);
    
    if ([method isEqualToString:@"GET"]) {
        if ([path isEqualToString:@"/"]) {
            NSDictionary *dict = @{@"text": @"Hello World."};
            NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:kNilOptions error:NULL];
            return [[HTTPDataResponse alloc] initWithData:data];
        }
        else if ([path hasPrefix:@"/repo/list"]) {
            
        }
        else if ([path hasPrefix:@"/build"]) {
            if (self.isBuilding) {
                NSString *resultMsg = [NSString stringWithFormat:@"正在打包:%@ 当前状态:%@", _parameter[@"repo"], _statusInfo];
                return [[HTTPDataResponse alloc] initWithData:[resultMsg dataUsingEncoding:NSUTF8StringEncoding]];
            }
            else {
                self.isBuilding = YES;
                _parameter = [self parameterForPath:path];
                if (![_parameter objectForKey:@"repo"] ||
                    ![_parameter objectForKey:@"environment"] ||
                    ![_parameter objectForKey:@"apihost"]) {
                    self.isBuilding = NO;
                    return [[HTTPDataResponse alloc] initWithData:[@"参数错误" dataUsingEncoding:NSUTF8StringEncoding]];
                }
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    [self buildWithRepo:_parameter[@"repo"] environment:_parameter[@"environment"] apihost:_parameter[@"apihost"]];
                });
                return [[HTTPDataResponse alloc] initWithData:[@"开始打包" dataUsingEncoding:NSUTF8StringEncoding]];
            }
        }
    }
    return [super httpResponseForMethod:method URI:path];
}


/**
 打包

 @param repo 代码仓库名称
 @param environment 环境
 @param apihost API HOST
 */
- (void)buildWithRepo:(NSString *)repo environment:(NSString *)environment apihost:(NSString *)apihost
{
    // 校验是否已经存在IPA
    
    
    
    // 下载项目代码
    
    _statusInfo = @"下载项目代码";
    NSString *projDirPath;
    
    
    
    // 打包IPA
    
    _statusInfo = @"校验项目目录";
    NSString *xcworkspacePath = [NSString stringWithFormat:@"%@/buyer.xcworkspace", projDirPath];
    if (![[NSFileManager defaultManager] fileExistsAtPath:xcworkspacePath]) {
        return;
    }
    
    _statusInfo = @"清理编译文件";
    [[NSTask launchedTaskWithLaunchPath:@"/Applications/Xcode.app/Contents/Developer/usr/bin/xcodebuild" arguments:@[@"-workspace", xcworkspacePath, @"-scheme", @"buyer", @"-configuration", @"Release", @"clean"]] waitUntilExit];
    
    _statusInfo = @"编译项目";
    [[NSTask launchedTaskWithLaunchPath:@"/Applications/Xcode.app/Contents/Developer/usr/bin/xcodebuild" arguments:@[@"-workspace", xcworkspacePath, @"-scheme", @"buyer", @"-configuration", @"Release"]] waitUntilExit];
    
    
    NSString *appPath = [NSString stringWithFormat:@"%@/DerivedData/buyer/Build/Products/Release-iphoneos/buyer.app", projDirPath];
    if (![[NSFileManager defaultManager] fileExistsAtPath:appPath]) {
        _statusInfo = @"编译失败";
        return;
    }
    
    _statusInfo = @"APP->IPA";
    NSString *ipaShell = [NSString stringWithFormat:@"xcrun -sdk iphoneos -v PackageApplication %@ -o %@/buyer.ipa", appPath, projDirPath];
    [[NSTask launchedTaskWithLaunchPath:@"/bin/sh" arguments:@[@"-c", ipaShell]] waitUntilExit];
    
    NSString *ipaPath = [NSString stringWithFormat:@"%@/buyer.ipa", projDirPath];
    if (![[NSFileManager defaultManager] fileExistsAtPath:ipaPath]) {
        _statusInfo = @"打包失败";
        return;
    }
    
    // 上传至蒲公英
    
    // 发送邮件
    
    
    return;
}




#pragma mark Utils

/**
 从请求路径中解析参数

 @param path 请求路径
 @return 参数
 */
- (NSDictionary *)parameterForPath:(NSString *)path
{
    NSArray *components = [path componentsSeparatedByString:@"?"];
    if (components.count != 2) {
        return NULL;
    }
    NSString *parameterString = components[1];
    NSArray *parameterComponents = [parameterString componentsSeparatedByString:@"&"];
    
    NSMutableDictionary *parameter = [NSMutableDictionary dictionaryWithCapacity:parameterComponents.count];
    for (NSString *parameterComponent in parameterComponents) {
        NSArray *keyValue = [parameterComponent componentsSeparatedByString:@"="];
        if (keyValue.count != 2) {
            break;
        }
        [parameter setObject:keyValue[1] forKey:keyValue[0]];
    }
    return parameter.count > 0 ? [parameter copy] : NULL;
}


- (void)setStatusInfo:(NSString *)statusInfo
{
    _statusInfo = statusInfo;
    NSLog(@"StatusInfo: %@", statusInfo);
}


@end
