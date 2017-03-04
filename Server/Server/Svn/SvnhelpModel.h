//
//  SvnhelpModel.h
//  FrameWorkHelper
//
//  Created by d2c_cyf on 17/3/4.
//  Copyright © 2017年 d2c_cyf. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SvnhelpModel : NSObject
/**
 打包项目绝对路径  完整代码
 */
@property(nonatomic, copy)NSString *productPath;

/**
 项目标示
 */
@property(nonatomic, copy)NSString *productSign;

/**
 错误信息
 */
@property(nonatomic, copy)NSString *errorInfo;

/**
 状态
 */
@property(nonatomic, assign)NSInteger state;




/**
 返回model
 
 @param dic 传入字典
 @return 模型
 */
+ (instancetype)svnModelWithDic:(NSDictionary *)dic;


/**
 单利传递信息

 @return 模型
 */
+ (SvnhelpModel *)shareInstance;

/**
 重置
 */
+ (void)reset;
@end
