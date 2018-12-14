//
//  SecondView.h
//  RACProject
//
//  Created by zhYch on 2018/9/11.
//  Copyright © 2018年 zhaoyongchuang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ReactiveObjC.h"

@interface SecondView : UIView

@property (nonatomic,strong) RACSubject *btnClickSignal;

@end
