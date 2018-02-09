//
//  ZWSHookUtils.h
//  ZWSCountdown
//
//  Created by zhaowensky on 2018/2/9.
//  Copyright © 2018年 ZWS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZWSHookUtils : NSObject

+ (void)swizzlingInClass:(Class)cls originalSelector:(SEL)originalSelector swizzledSelector:(SEL)swizzledSelector;

@end
