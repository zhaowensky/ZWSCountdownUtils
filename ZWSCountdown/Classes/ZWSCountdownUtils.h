//
//  ZWSCountdownUtils.h
//  ZWSCountdown
//
//  Created by zhaowensky on 2016/12/28.
//  Copyright © 2016年 ZWS. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef void(^ZWSCountdownUtilsHandle)(int countdownSecond);

@interface ZWSCountdownUtils : NSObject

+ (instancetype)getCountdownUtils;

/**
 开启倒计时

 @param phoneNumber 电话号码
 @param business 业务代号
 @param second 倒计时长
 @param handle 当前剩余时间回调
 */
- (void)startCountdown:(NSString*)phoneNumber
              business:(NSString*)business
                second:(int)second
              callback:(ZWSCountdownUtilsHandle)handle;

/**
 检查当前号码及业务是否存在倒计时

 @param phoneNumber 电话号码
 @param business 业务代号
 @return result YES/NO
 */
-(BOOL)checkCountdown:(NSString*)phoneNumber
             business:(NSString*)business;


/**
 视图消失时调用，eg：viewDidDisappear
 */
-(void)stopCountdown;


@end
