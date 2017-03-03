//
//  ESHTTPConnection.m
//  Server
//
//  Created by 翟泉 on 2017/3/3.
//  Copyright © 2017年 翟泉. All rights reserved.
//

#import "ESHTTPConnection.h"

#import <CocoaHTTPServer/HTTPDataResponse.h>

@implementation ESHTTPConnection

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
    
    if ([method isEqualToString:@"GET"]) {
        NSDictionary *dict = @{@"text": @"Hello World."};
        NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:kNilOptions error:NULL];
        return [[HTTPDataResponse alloc] initWithData:data];
    }
    return [super httpResponseForMethod:method URI:path];
}


/**
 打包

 @param repo <#repo description#>
 @param environment <#environment description#>
 @param apihost <#apihost description#>
 */
- (void)buildWithRepoPath:(NSString *)repo environment:(NSString *)environment apihost:(NSString *)apihost
{
    
}

@end
