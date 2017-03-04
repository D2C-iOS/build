//
//  SvnhelpModel.m
//  FrameWorkHelper
//
//  Created by d2c_cyf on 17/3/4.
//  Copyright © 2017年 d2c_cyf. All rights reserved.
//

#import "SvnhelpModel.h"

@implementation SvnhelpModel
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
    [SvnhelpModel shareInstance].productPath = [dic objectForKey:@"productPath"];
    [SvnhelpModel shareInstance].productSign = [dic objectForKey:@"productSign"];
    [SvnhelpModel shareInstance].state       = [[dic objectForKey:@"state"] integerValue];
    [SvnhelpModel shareInstance].errorInfo   = [dic objectForKey:@"errorInfo"];
    return [SvnhelpModel shareInstance];
}

+ (SvnhelpModel *)shareInstance {
    static SvnhelpModel *share;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        share = [[self alloc] init];
        share.state = 0;
    });
    return share;
}

+ (void)reset {
    [SvnhelpModel shareInstance].productSign = nil;
    [SvnhelpModel shareInstance].productPath = nil;
    [SvnhelpModel shareInstance].state       = 0;
    [SvnhelpModel shareInstance].errorInfo   = nil;
}
@end
