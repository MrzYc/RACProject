//
//  LoginViewController.m
//  RACProject
//
//  Created by zhYch on 2018/9/11.
//  Copyright © 2018年 zhaoyongchuang. All rights reserved.
//

#import "LoginViewController.h"
#import "ReactiveObjC.h"

@interface LoginViewController ()
@property (weak, nonatomic) IBOutlet UITextField *accountTf;
@property (weak, nonatomic) IBOutlet UITextField *passwordTf;
@property (weak, nonatomic) IBOutlet UIButton *loginBtn;


@end

@implementation LoginViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    RAC(_loginBtn, enabled) = [RACSignal combineLatest:@[_accountTf.rac_textSignal, _passwordTf.rac_textSignal] reduce:^id _Nonnull(NSString *account, NSString *password){
        NSLog(@"%@ %@", account, password);
        return @(account.length && (password.length > 5));
    }];

    
    //监听登录成功的信号，同时去监听command的执行过程
    RACCommand *btnPressCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
        NSLog(@"组合参数，准备发送登录请求 %@", input);
        return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
            NSLog(@"开始请求");
            NSLog(@"请求成功");
            NSLog(@"处理数据");
            [subscriber sendNext:@"请求完成"];
            return [RACDisposable disposableWithBlock:^{
                NSLog(@"结束了");
            }];
        }];
    }];
    
    [btnPressCommand.executionSignals.switchToLatest subscribeNext:^(id  _Nullable x) {
        NSLog(@"登录成功");
    }];
    
    [[btnPressCommand.executing skip:1] subscribeNext:^(NSNumber * _Nullable x) {
        if ([x boolValue]) {
            NSLog(@"正在执行");
        }else {
            NSLog(@"执行结束了");
        }
    }];
    
    @weakify(self)
    [[_loginBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self)
        NSLog(@"点击了");
        [btnPressCommand execute:@{@"account":self.accountTf.text,@"password":self.passwordTf.text}];
    }];
    

}

@end
