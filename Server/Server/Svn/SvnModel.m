//
//  SvnModel.m
//  Server
//
//  Created by d2c_cyf on 17/3/7.
//  Copyright © 2017年 翟泉. All rights reserved.
//

#import "SvnModel.h"

@implementation SvnModel
//- (instancetype)initWithDic:(NSDictionary *)dic {
//    if (self = [super init]) {
//        self.productPath = [dic objectForKey:@"productPath"];
//        self.productSign = [dic objectForKey:@"productSign"];
//        self.state       = [[dic objectForKey:@"state"] integerValue];
//        self.errorInfo   = [dic objectForKey:@"errorInfo"];
//    }
//    return self;
//}

+ (instancetype)svnModelWithDic:(NSDictionary *)dic {
    [SvnModel shareInstance].productPath = [dic objectForKey:@"productPath"];
    [SvnModel shareInstance].productSign = [dic objectForKey:@"productSign"];
    [SvnModel shareInstance].state       = [[dic objectForKey:@"state"] boolValue];
    [SvnModel shareInstance].errorInfo   = [dic objectForKey:@"errorInfo"];
    return [SvnModel shareInstance];
}

+ (SvnModel *)shareInstance {
    static SvnModel *share;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        share = [[self alloc] init];
        share.state = 0;
    });
    return share;
}

+ (void)reset {
    [SvnModel shareInstance].productSign = nil;
    [SvnModel shareInstance].productPath = nil;
    [SvnModel shareInstance].state       = NO;
    [SvnModel shareInstance].errorInfo   = nil;
}

@end
