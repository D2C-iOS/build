//
//  ESBuild.m
//  Server
//
//  Created by 翟泉 on 2017/3/3.
//  Copyright © 2017年 翟泉. All rights reserved.
//

#import "ESBuild.h"
#import "UploadIPA.h"

@implementation ESBuild

+ (NSString *)buildWithDirectoryPath:(NSString *)directoryPath
{
    NSString *xcworkspacePath = [NSString stringWithFormat:@"%@/buyer.xcworkspace", directoryPath];
    if (![[NSFileManager defaultManager] fileExistsAtPath:xcworkspacePath]) {
        return NULL;
    }
    
    [[NSTask launchedTaskWithLaunchPath:@"/Applications/Xcode.app/Contents/Developer/usr/bin/xcodebuild" arguments:@[@"-workspace", xcworkspacePath, @"-scheme", @"buyer", @"-configuration", @"Release", @"clean"]] waitUntilExit];
    [[NSTask launchedTaskWithLaunchPath:@"/Applications/Xcode.app/Contents/Developer/usr/bin/xcodebuild" arguments:@[@"-workspace", xcworkspacePath, @"-scheme", @"buyer", @"-configuration", @"Release"]] waitUntilExit];
    
    NSString *appPath = [NSString stringWithFormat:@"%@/DerivedData/buyer/Build/Products/Release-iphoneos/buyer.app", directoryPath];
    if ([[NSFileManager defaultManager] fileExistsAtPath:appPath]) {
        NSString *shell = [NSString stringWithFormat:@"xcrun -sdk iphoneos -v PackageApplication %@ -o %@/buyer.ipa", appPath, directoryPath];
        [[NSTask launchedTaskWithLaunchPath:@"/bin/sh" arguments:@[@"-c", shell]] waitUntilExit];
        
        return [NSString stringWithFormat:@"%@/buyer.ipa", directoryPath];
        
        
//        NSString *shell2 = [NSString stringWithFormat:@"curl -F \"file=@%@/buyer.ipa\" -F \"uKey=2140f4f3af4ef69776efb692e92f6395\" -F \"_api_key=f8daeb0fef1b5e143708ee75b6c767b7\" http://www.pgyer.com/apiv1/app/upload", directoryPath];
//        [[NSTask launchedTaskWithLaunchPath:@"/bin/sh" arguments:@[@"-c", shell2]] waitUntilExit];
    }
    else {
        printf("APP编译失败\n");
        return NULL;
    }
}

@end

