//
//  LoginViewModel.m
//  RACProject
//
//  Created by zhYch on 2018/9/13.
//  Copyright © 2018年 zhaoyongchuang. All rights reserved.
//

#import "LoginViewModel.h"

@implementation LoginViewModel


- (instancetype)init {
    self = [super init];
    if (self) {
        [self setBtnSignal];
        [self setupCommand];
    }
    return self;
}

- (void)setBtnSignal {
    _btnEnableSignal = [RACSignal combineLatest:@[RACObserve(self, account),RACObserve(self, password)] reduce:^id _Nonnull(NSString * account,NSString * password){
        return @(account.length && (password.length > 5));
    }];
}


- (void)setupCommand {
    _loginCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
        NSLog(@"组合参数，准备发送登录请求 - %@",input);
        return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
            NSLog(@"开始请求");
            NSLog(@"请求成功");
            NSLog(@"处理数据");
            
            [subscriber sendNext:@"请求完成"];
            [subscriber sendCompleted];
            return [RACDisposable disposableWithBlock:^{
                NSLog(@"结束了");
            }];
        }];
    }];
    
    [[_loginCommand.executing skip:1] subscribeNext:^(NSNumber * _Nullable x) {
        if ([x boolValue]) {
            NSLog(@"正在执行中。。。。");
        }else{
            NSLog(@"执行结束了。。。");
        }
    }];
}

@end
