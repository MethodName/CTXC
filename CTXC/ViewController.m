//
//  ViewController.m
//  CTXC
//
//  Created by 唐明明 on 2018/5/2.
//  Copyright © 2018年 Methodname. All rights reserved.
//

#import "ViewController.h"
#import "TMMWebViewViewController.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UISwitch *sw;
@property (weak, nonatomic) IBOutlet UITextField *usdt;
@property (weak, nonatomic) IBOutlet UISwitch *swcb;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self.usdt setText:[[NSUserDefaults standardUserDefaults] objectForKey:@"_UserDefaultKeyUsdt"]];
}


- (IBAction)swChange:(UISwitch *)sender {
    
    if (sender.isOn) {
        [self.usdt setTextColor:[UIColor greenColor]];
    }
    else
    {
        [self.usdt setTextColor:[UIColor redColor]];
    }
    
    
}

- (IBAction)tapClick:(UIControl *)sender {
    
    [self.view endEditing:YES];
    
}

- (IBAction)startClick:(UIButton *)sender {
    
    if (self.usdt.text.doubleValue <= 0.0f) {
        return;
    }
    
    [[NSUserDefaults standardUserDefaults]setObject:self.usdt.text forKey:@"_UserDefaultKeyUsdt"];
     TMMWebViewViewController *tmm = [TMMWebViewViewController new];
    tmm.sw = self.sw.on;
    tmm.swcb = self.swcb.on;
    tmm.usdTotal = self.usdt.text.doubleValue;
    if (sender.tag == 0) {
        tmm.url = @"https://www.huobipro.com/zh-cn/ctxc_usdt/exchange/";
    }
    else if (sender.tag == 1){
        tmm.url = @"https://www.huobipro.com/zh-cn/wicc_eth/exchange/";
    }
    else if (sender.tag == 2){
        tmm.url = @"https://www.huobipro.com/zh-cn/ctxc_eth/exchange/";
    }
    [self.navigationController pushViewController:tmm animated:YES];
}




@end
