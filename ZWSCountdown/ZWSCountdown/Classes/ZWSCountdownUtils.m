//
//  ZWSCountdownUtils.m
//  ZWSCountdown
//
//  Created by zhaowensky on 2016/12/28.
//  Copyright © 2016年 ZWS. All rights reserved.
//

#import "ZWSCountdownUtils.h"
#import <UIKit/UIKit.h>
#import "ZWSHookUtils.h"


@interface ZWSCountdownUtils ()
@property (nonatomic,weak  ) NSTimer                 *timer;
@property (nonatomic,copy  ) NSString                *phoneNumber;
@property (nonatomic,copy  ) NSString                *business;
@property (nonatomic,copy  ) ZWSCountdownUtilsHandle handle;

@property (nonatomic,assign) int                     currentSecond;
@property (nonatomic,assign) int                     totalSecond;

@end

@implementation ZWSCountdownUtils

#pragma makr - init
+ (instancetype)getCountdownUtils
{
    return [[ZWSCountdownUtils alloc]init];
}

-(id)init
{
    self = [super init];
    if(self){
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(swiz_viewWillDisappear) name:@"zws_swiz_viewWillDisappear" object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(stopCountdown) name:@"zws_cancelReplayTimer" object:nil];
    }
    return self;
}

-(void)dealloc
{
    if(_timer){
        [_timer invalidate];
        _timer = nil;
    }
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

#pragma mark - notification
-(void)didEnterBackground
{
    [self saveBusinessInfo:_currentSecond];
}

-(void)didBecomeActive
{
    [self initCountdown];
}

-(void)swiz_viewWillDisappear
{
    [self saveBusinessInfo:_currentSecond];
}

#pragma mark - control
-(void)startCountdown:(NSString*)phoneNumber
             business:(NSString*)business
               second:(int)second
             callback:(ZWSCountdownUtilsHandle)handle
{
    NSAssert(phoneNumber, @"phoneNumber is nil.");
    NSAssert(business, @"business is nil.");
    NSAssert(!(second == 0), @"second > 0");
    
    self.handle = handle;
    self.phoneNumber = phoneNumber;
    self.business = business;
    self.totalSecond = second;
    
    [self initCountdown];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"zws_cancelReplayTimer" object:nil]; //中止多次start造成的timer持有
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(countdownTimer) userInfo:nil repeats:YES];
}

-(void)stopCountdown
{
    if(_timer){
        [_timer invalidate];
        _timer = nil;
    }
    if(_currentSecond == 0){
        [self removeBusinessInfo];
    }else{
        [self saveBusinessInfo:_currentSecond];
    }
}

-(BOOL)checkCountdown:(NSString *)phoneNumber
             business:(NSString *)business
{
    _phoneNumber = phoneNumber;
    _business = business;
    return [self queryTime] > 0;
}

#pragma mark - business
-(void)initCountdown
{
    int result = [self queryTime];
    if(result == 0){
        self.currentSecond = self.totalSecond;
    }else{
        self.currentSecond = result;
    }
}

-(void)countdownTimer
{
    if(_handle){
        _handle(_currentSecond);
        if(_currentSecond == 0){
            [_timer invalidate];
        }else{
            _currentSecond --;
        }
    }
}

-(int)queryTime
{
    int result = 0;
    NSDictionary *countValue = [self queryBusinessInfo];
    if(countValue){
        NSDate *saveDate = [countValue objectForKey:@"saveDate"];
        int second = [[countValue objectForKey:@"second"] intValue];
        NSTimeInterval timeInterval = [[NSDate date] timeIntervalSinceDate:saveDate];
        if(timeInterval < second){
            result = second - timeInterval;
        }
    }
    return result;
}

#pragma mark - NSUserDefaults Data
//获取当前业务号码的存储数据
-(NSDictionary*)queryBusinessInfo
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *key = [self userDefaultsKey];
    NSDictionary *countValue = [defaults objectForKey:key];
    return countValue;
}

//保存当前业务的最后剩余时间
-(void)saveBusinessInfo:(int)second
{
    NSDictionary *countValue = @{@"second":[NSNumber numberWithInt:second],@"saveDate":[NSDate date]};
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *key = [self userDefaultsKey];
    [defaults setObject:countValue forKey:key];
    [defaults synchronize];
}

//删除当前业务的存储数据
-(void)removeBusinessInfo
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *key = [self userDefaultsKey];
    [defaults removeObjectForKey:key];
    [defaults synchronize];
}

-(NSString*)userDefaultsKey
{
    return [NSString stringWithFormat:@"ZWS_%@_%@",_phoneNumber,_business];
}

//清理所有业务存储数据
+(void)clearData
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *dic = [defaults dictionaryRepresentation];
    for (id key in dic.allKeys) {
        if([key isKindOfClass:[NSString class]]){
            if([key hasPrefix:@"ZWS_"]){
                [defaults removeObjectForKey:key];
            }
        }
    }
    [defaults synchronize];
}

@end


#pragma mark - hook post notification
@interface UIViewController(lifeCycleSwizHook)
@end

@implementation UIViewController(lifeCycleSwizHook)

+ (void)initialize
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SEL originalSelector2 = @selector(viewWillDisappear:);
        SEL swizzledSelector2 = @selector(zws_swiz_viewWillDisappear:);
        [ZWSHookUtils swizzlingInClass:[self class] originalSelector:originalSelector2 swizzledSelector:swizzledSelector2];
    });
}

-(void)zws_swiz_viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter]postNotificationName:@"zws_swiz_viewWillDisappear" object:nil];
    [self zws_swiz_viewWillDisappear:animated];
}

@end








