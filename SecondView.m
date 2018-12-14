//
//  SecondView.m
//  RACProject
//
//  Created by zhYch on 2018/9/11.
//  Copyright © 2018年 zhaoyongchuang. All rights reserved.
//

#import "SecondView.h"


@implementation SecondView

- (RACSubject *)btnClickSignal {
    if (!_btnClickSignal) {
        _btnClickSignal = [RACSubject subject];
    }
    return _btnClickSignal;
}

- (IBAction)click:(id)sender {
    [_btnClickSignal sendNext:@"代理事件替代"];
}


@end
