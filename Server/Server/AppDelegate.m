//
//  AppDelegate.m
//  Server
//
//  Created by 翟泉 on 2017/3/3.
//  Copyright © 2017年 翟泉. All rights reserved.
//

#import "AppDelegate.h"
#import "ESHTTPServer.h"
#import "SvnManager.h"

#import "ESBuild.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    
    [[ESHTTPServer sharedInstance] start];
//    [SvnManager getSvnFileListWithPath:@"https://192.xx.xx.xx:443/svn/app-xxx-xxx-xxx/tags"];
    
//    [ESBuild buildWithDirectoryPath:@"/Users/cezr/Documents/Cornerstone/2.3.1"];
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}


@end
