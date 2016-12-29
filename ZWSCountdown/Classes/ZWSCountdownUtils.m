//
//  ZWSCountdownUtils.m
//  ZWSCountdown
//
//  Created by zhaowensky on 2016/12/28.
//  Copyright © 2016年 ZWS. All rights reserved.
//

#import "ZWSCountdownUtils.h"
#import <UIKit/UIKit.h>

@interface ZWSCountdownUtils ()
@property (nonatomic,strong) NSTimer                 *timer;
@property (nonatomic,copy  ) ZWSCountdownUtilsHandle handle;
@property (nonatomic,copy  ) NSString                *phoneNumber;
@property (nonatomic,copy  ) NSString                *business;

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
    }
    return self;
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

#pragma mark - application
-(void)didEnterBackground
{
    [self saveCountdown:_phoneNumber business:_business second:_currentSecond];
}

-(void)didBecomeActive
{
    [self getCountDown];
}

#pragma mark - control
-(void)startCountdown:(NSString*)phoneNumber
             business:(NSString*)business
               second:(int)second
             callback:(ZWSCountdownUtilsHandle)handle
{
    self.phoneNumber = phoneNumber;
    self.business = business;
    self.totalSecond = second;
    
    NSAssert(phoneNumber, @"phoneNumber is nil.");
    NSAssert(business, @"business is nil.");
    NSAssert(!(second == 0), @"second > 0");
    
    [self getCountDown];
    self.handle = handle;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateTimer) userInfo:nil repeats:YES];
}

-(void)stopCountdown
{
    if(self.timer){
        [self.timer invalidate];
        self.timer = nil;
    }
    if(self.currentSecond == 0){
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *key = [NSString stringWithFormat:@"%@_%@",_phoneNumber,_business];
        [defaults removeObjectForKey:key];
        [defaults synchronize];
    }else{
        [self saveCountdown:_phoneNumber business:_business second:_currentSecond];
    }
}

-(void)updateTimer
{
    if(self.handle){
        self.handle(self.currentSecond);
        if(self.currentSecond == 0){
            [self.timer invalidate];
            self.timer = nil;
        }else{
            self.currentSecond --;
        }
    }
}

-(BOOL)checkCountdown:(NSString *)phoneNumber
             business:(NSString *)business
{
    return [self getCountDownTime:phoneNumber business:business] > 0;
}

#pragma mark - set/get time
-(void)saveCountdown:(NSString*)phoneNumber
            business:(NSString*)business
              second:(int)second
{
    NSDictionary *countValue = @{@"second":[NSNumber numberWithInt:second],
                                 @"saveDate":[NSDate date]};
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *key = [NSString stringWithFormat:@"%@_%@",_phoneNumber,_business];
    [defaults setObject:countValue forKey:key];
    [defaults synchronize];
}

-(void)getCountDown
{
    int result = [self getCountDownTime:_phoneNumber business:_business];
    if(result == 0){
        self.currentSecond = self.totalSecond;
    }else{
        self.currentSecond = result;
    }
}

-(int)getCountDownTime:(NSString*)phone business:(NSString*)business
{
    int result = 0;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *key = [NSString stringWithFormat:@"%@_%@",phone,business];
    NSDictionary *countValue = [defaults objectForKey:key];
    NSDate *saveDate = [countValue objectForKey:@"saveDate"];
    if(saveDate){
        int second = [[countValue objectForKey:@"second"] intValue];
        NSTimeInterval timeInterval = [[NSDate date] timeIntervalSinceDate:saveDate];
        if(timeInterval >= second){
            result = 0;
        }else{
            result = second - timeInterval;
        }
    }
    return result;
}


@end
