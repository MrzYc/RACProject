//
//  LoginViewModel.h
//  RACProject
//
//  Created by zhYch on 2018/9/13.
//  Copyright © 2018年 zhaoyongchuang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ReactiveObjC.h"
@interface LoginViewModel : NSObject

@property (nonatomic, strong) NSString *account;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, strong) RACSignal *btnEnableSignal;
@property (nonatomic, strong) RACCommand *loginCommand;


@end
