//
//  ViewController.m
//  ZWSCountdown
//
//  Created by dengwz on 2016/12/28.
//  Copyright © 2016年 dengwz. All rights reserved.
//

#import "ViewController.h"
#import "ZWSCountdownUtils.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UILabel *labTime;
@property (strong,nonatomic) ZWSCountdownUtils *countdownUtils;
- (IBAction)buttonAction:(id)sender;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if(_countdownUtils){
        [_countdownUtils stopCountdown];
    }
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
    UIButton *button = sender;
    if(!button.selected){
        if(_countdownUtils){
            [_countdownUtils stopCountdown];
        }
        _countdownUtils = [ZWSCountdownUtils getCountdownUtils];
        __weak typeof(self) weakSelf = self;
        [_countdownUtils startCountdown:@"991" business:@"119" second:30 callback:^(int countdownSecond) {
            weakSelf.labTime.text = [NSString stringWithFormat:@"%lds",(long)countdownSecond];
        }];
    }
}

@end


