//
//  ESHTTPServer.m
//  Server
//
//  Created by 翟泉 on 2017/3/3.
//  Copyright © 2017年 翟泉. All rights reserved.
//

#import "ESHTTPServer.h"
#import <CocoaHTTPServer/HTTPServer.h>
#import "ESHTTPConnection.h"

#import <arpa/inet.h>
#import <net/if.h>
#import <ifaddrs.h>
#import <SystemConfiguration/CaptiveNetwork.h>


@implementation ESHTTPServer
{
    HTTPServer *_httpServer;
}

+ (instancetype)sharedInstance
{
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init
{
    if (self = [super init]) {
        _httpServer = [[HTTPServer alloc] init];
        [_httpServer setType:@"_http._tcp."];
        [_httpServer setConnectionClass:[ESHTTPConnection class]];
    }
    return self;
}

- (BOOL)start
{
    if (_httpServer.isRunning) {
        return YES;
    }
    
    NSString *IPAddress = [ESHTTPServer IPAddress];
    NSLog(@"%@", IPAddress);
    NSLog(@"%@", [ESHTTPServer WiFiIPAddress]);
    
    [_httpServer setPort:22333];
    [_httpServer setInterface:IPAddress];
    
    NSError *error;
    if (![_httpServer start:&error]) {
        NSLog(@"%@", error);
        return NO;
    }
    
    
    
    return YES;
}


#pragma mark - Utils

+ (NSString *)IPAddress; {
    NSString *localIP = nil;
    struct ifaddrs *addrs;
    if (getifaddrs(&addrs)==0) {
        const struct ifaddrs *cursor = addrs;
        while (cursor != NULL) {
            if (cursor->ifa_addr->sa_family == AF_INET && (cursor->ifa_flags & IFF_LOOPBACK) == 0)
            {
                localIP = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)cursor->ifa_addr)->sin_addr)];
                break;
            }
            cursor = cursor->ifa_next;
        }
        freeifaddrs(addrs);
    }
    return localIP;
}
/*
+ (NSString *)WifiName; {
    NSString *wifiName = nil;
    CFArrayRef wifiInterfaces = CNCopySupportedInterfaces();
    if (!wifiInterfaces) {
        return nil;
    }
    NSArray *interfaces = (__bridge NSArray *)wifiInterfaces;
    for (NSString *interfaceName in interfaces) {
        CFDictionaryRef dictRef = CNCopyCurrentNetworkInfo((__bridge CFStringRef)(interfaceName));
        if (dictRef) {
            NSDictionary *networkInfo = (__bridge NSDictionary *)dictRef;
            NSLog(@"network info -> %@", networkInfo);
            wifiName = [networkInfo objectForKey:(__bridge NSString *)kCNNetworkInfoKeySSID];
            CFRelease(dictRef);
        }
    }
    
    CFRelease(wifiInterfaces);
    return wifiName;
}*/


+ (NSString *)WiFiIPAddress; {
    BOOL success;
    struct ifaddrs * addrs;
    const struct ifaddrs * cursor;
    
    success = getifaddrs(&addrs) == 0;
    if (success) {
        cursor = addrs;
        while (cursor != NULL) {
            // the second test keeps from picking up the loopback address
            if (cursor->ifa_addr->sa_family == AF_INET && (cursor->ifa_flags & IFF_LOOPBACK) == 0)
            {
                NSString *name = [NSString stringWithUTF8String:cursor->ifa_name];
                if ([name isEqualToString:@"en0"])  // Wi-Fi adapter
                    return [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)cursor->ifa_addr)->sin_addr)];
            }
            cursor = cursor->ifa_next;
        }
        freeifaddrs(addrs);
    }
    return nil;
}


@end
