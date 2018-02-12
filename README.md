#### 一、业务场景
1.1、应用挂起后倒计时不停止\
1.2、不同业务同号码倒计时不停止\
![image](https://note.youdao.com/yws/api/personal/file/WEBf63966d68bad728b89332142edcd0abb?method=download&shareKey=23f7f4ea97f393f37adb2a3b4ecbfef3)
#### 二、解决几个问题
##### 2.1、基础数据存储与管理
记录对应业务号码与时间的关系，数据容量小，因此使用NSUserDefaults存储管理即可：

```
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
```
##### 2.2、 程序生命周期监听
- **Application挂起与进入**：
```
[[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
[[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
```
对应接收操作：

```
-(void)didEnterBackground
{
    [self saveBusinessInfo:_currentSecond];
}

-(void)didBecomeActive
{
    [self initCountdown];
}
```

- **UIController退出viewDisappear**：\
为了尽量减少组件的配置，通过runtime中Method Swizzling(函数混淆)来监听viewWillDisappear，实现Category:
```
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
```
对应接收通知：

```
[[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(swiz_viewWillDisappear) name:@"zws_swiz_viewWillDisappear" object:nil];
```
以及接收后操作：

```
-(void)swiz_viewWillDisappear
{
    [self saveBusinessInfo:_currentSecond];
}
```
- **NSTimer启动后所持有对象的释放问题**：\
Timer控件在启动后，会添加到NSRunLoop中，因此如果不主动invalidate，action将持续，添加：

```
[[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(stopCountdown) name:@"zws_cancelReplayTimer" object:nil];
```
#### 三、总结
功能实现没有什么难点，主要是程序逻辑实现问题：NSTimer中消息进程问题与runtimer的简单使用完善相关配置。[ZWSCountdownUtils](https://github.com/zhaowensky/ZWSCountdownUtils)




