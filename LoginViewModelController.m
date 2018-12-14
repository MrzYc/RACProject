//
//  LoginViewModelController.m
//  RACProject
//
//  Created by zhYch on 2018/9/13.
//  Copyright © 2018年 zhaoyongchuang. All rights reserved.
//

#import "LoginViewModelController.h"
#import "ReactiveObjC.h"
#import "LoginViewModel.h"

@interface LoginViewModelController ()
@property (weak, nonatomic) IBOutlet UITextField *accountTf;
@property (weak, nonatomic) IBOutlet UITextField *passwordTf;
@property (weak, nonatomic) IBOutlet UIButton *loginBtn;

/** 登录的ViewModel  */
@property (nonatomic, strong) LoginViewModel *loginVM;

@end

@implementation LoginViewModelController


- (LoginViewModel *)loginVM {
    if (!_loginVM) {
        _loginVM = [[LoginViewModel alloc] init];
    }
    return _loginVM;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    RAC(self.loginVM,account) = _accountTf.rac_textSignal;
    RAC(self.loginVM,password) = _passwordTf.rac_textSignal;
    RAC(_loginBtn, enabled) = self.loginVM.btnEnableSignal;
    @weakify(self)
    [[_loginBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self)
        NSLog(@"点击了登录按钮");
        [self.loginVM.loginCommand execute:@{@"account":self.accountTf.text,@"password":self.passwordTf.text}];
    }];

    
}


@end
