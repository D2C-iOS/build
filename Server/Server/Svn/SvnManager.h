//
//  SvnManager.h
//  Server
//
//  Created by cyf on 17/3/3.
//  Copyright © 2017年 翟泉. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SvnhelpModel.h"
//代码仓位置
#define FrameworkSvnPath  @"svn://localhost/T/branches/ceshi"
//项目plist文件名称
#define FrameWorkName     @"Property List.plist"
//相对主项目的依赖库文件目录
#define FrameDocumentAboutProduct @"buyer/Frameworks"




//↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓暂时不用↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓
//依赖库SVN地址
#define SVNPath       @"svn://localhost/T/branches/ceshi"
//SVN用户名
#define SVNUserName   @"cyf"
//SVN密码
#define SVNPassword   @"123456"


@interface SvnManager : NSObject
/**
 获取SVN URL下的文件列表

 @param path SVN URL
 @return <#return value description#>
 */
+ (NSArray *)getSvnFileListWithPath:(NSString *)path;



/**
 根据连接 查看本地代码仓与依赖库的信息

 @param buildPath 请求地址
 @param localPath 本地指定文件夹
 @return model
 */
+ (SvnhelpModel *)getLocalInfoWithBuildPath:(NSString *)buildPath localPath:(NSString *)localPath;


+ (BOOL)checkOutWithBuildPath:(NSString *)buildPath localPath:(NSString *)localPath;

















///**
// checkout
//
// @param path <#path description#>
// */
//+ (void)checkOutFromPath:(NSString *)path;
//
//
///**
// 覆盖本地
//
// @param path <#path description#>
// */
//+ (void)revertLocalWithPach:(NSString *)path;
//
///**
// 按照配置文件更新  只更新配置文件存在的
//
// @param path <#path description#>
// */
//+ (void)checkoutWithInfoPlist:(NSString *)path;

@end
