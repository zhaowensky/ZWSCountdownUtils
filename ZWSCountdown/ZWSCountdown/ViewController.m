//
//  ViewController.m
//  ZWSCountdown
//
//  Created by zhaowensky on 2016/12/28.
//  Copyright © 2016年 dengwz. All rights reserved.
//

#import "ViewController.h"
#import "ZWSCountdownUtils.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UILabel *labTime;
- (IBAction)buttonAction:(id)sender;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //检查当前业务号码倒记时是否结束
    ZWSCountdownUtils *countdownUtils = [ZWSCountdownUtils getCountdownUtils];
    if([countdownUtils checkCountdown:@"991" business:@"119"]){
        [self buttonAction:nil];
    }
    
    [ZWSCountdownUtils clearData];
}

-(void)dealloc
{
    NSLog(@"ViewController dealloc");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (IBAction)buttonAction:(id)sender
{
    ZWSCountdownUtils *countdownUtils = [ZWSCountdownUtils getCountdownUtils];
    __weak typeof(ViewController*) weakSelf = self;
    [countdownUtils startCountdown:@"991" business:@"119" second:60 callback:^(int countdownSecond) {
        weakSelf.labTime.text = [NSString stringWithFormat:@"%lds",(long)countdownSecond];
        NSLog(@">>>%@",weakSelf.labTime.text);
    }];
}


@end







