//
//  ViewController.m
//  RACProject
//
//  Created by zhYch on 2018/9/10.
//  Copyright © 2018年 zhaoyongchuang. All rights reserved.
//

#import "ViewController.h"
#import "ReactiveObjC.h"
#import "NSObject+RACKVOWrapper.h"
#import "NSObject+RACSelectorSignal.h"
#import "SecondView.h"
#import "RACReturnSignal.h"
#import "Person.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIView *bgView;
@property (weak, nonatomic) IBOutlet UIButton *signalBtn;
@property (weak, nonatomic) IBOutlet UITextField *textField;

@property (weak, nonatomic) IBOutlet SecondView *secondView;

@property (weak, nonatomic) IBOutlet UIButton *makeSureBtn;

/** 倒计时时间  */
@property (nonatomic, assign) NSInteger  time;

/** RAC的GCD  */
@property (nonatomic, strong) RACDisposable *dispoable;


@end

@implementation ViewController

- (IBAction)buttonClick:(id)sender {

}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
//    _bgView.frame = CGRectMake(100, 100, 200, 200);
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
}



- (void)filter {
    //bool值决定是否订阅信号
    [[self.textField.rac_textSignal filter:^BOOL(NSString * _Nullable value) {
        NSLog(@"value = %@",value);
        return value.length > 5;
    }] subscribeNext:^(NSString * _Nullable x) {
        NSLog(@"%@", x);
    }];
    
    
    //忽略信号
    RACSubject *subject = [RACSubject subject];
    [[subject ignore:@"a"] subscribeNext:^(id  _Nullable x) {
        NSLog(@"%@",x);
    }];
    
    //忽略掉所有的值
    [[subject ignoreValues] subscribeNext:^(id  _Nullable x) {
        NSLog(@"%@",x);
    }];
    
    
    [subject sendNext:@"a"];
    [subject sendNext:@"a1"];
    [subject sendNext:@"b"];
    
    //忽略掉 1 2 3 4
    [[[[[subject ignore:@"1"] ignore:@"2"] ignore:@"3"] ignore:@"4"] subscribeNext:^(id  _Nullable x) {
        NSLog(@"%@",x);
    }];
    
    //指定那些信号 正序
    RACSubject * subject1 = [RACSubject subject];
    [[subject1 take:1] subscribeNext:^(id  _Nullable x) {
        NSLog(@"take = %@",x);
    }];
    
    //takeLast 必须要写 一定要告诉系统，发送完成了 sendCompleted
    [[subject1 takeLast:1] subscribeNext:^(id  _Nullable x) {
        NSLog(@"takeLast = %@",x);
    }];
    
    [subject1 sendNext:@"1"];
    [subject1 sendNext:@"2"];
    [subject1 sendNext:@"3"];
    [subject1 sendNext:@"4"];
    [subject1 sendNext:@"5"];
    [subject1 sendCompleted];
    
    
    //信号标记，当标记了这个信号发送数据的时候，就会停止订阅所有信号
    RACSubject * subject2 = [RACSubject subject];
    RACSubject * subject3 = [RACSubject subject];
    [[subject2 takeUntil:subject1] subscribeNext:^(id  _Nullable x) {
        NSLog(@"%@",x);
    }];
    
    [subject3 subscribeNext:^(id  _Nullable x) {
        NSLog(@"%@",x);
    }];
    
    [subject2 sendNext:@"1"];
    [subject2 sendNext:@"2"];
    [subject2 sendNext:@"3"];
    
    [subject3 sendNext:@"Stop"];
    
    [subject2 sendNext:@"4"];
    [subject2 sendNext:@"5"];
    
    //剔除一样的信号,还可以忽略掉数组、字典，但是不可以忽略模型
    RACSubject * subject4 = [RACSubject subject];
    [[subject4 distinctUntilChanged] subscribeNext:^(id  _Nullable x) {
        NSLog(@"%@",x);
    }];
    
    [subject4 sendNext:@"x"];
    [subject4 sendNext:@"x"];
    [subject4 sendNext:@"x"];
    
    [subject4 sendNext:@[@1]];
    [subject4 sendNext:@[@1]];
    
    [subject4 sendNext:@{@"name":@"jack"}];
    [subject4 sendNext:@{@"name":@"jack"}];
    
    Person * p1 = [[Person alloc] init];
    p1.name = @"jj";
    p1.age = 20;
    
    Person * p2 = [[Person alloc] init];
    p2.name = @"jj";
    p2.age = 20;
    
    [subject4 sendNext:p1];
    [subject4 sendNext:p2];

}

- (void)map {
    //    RACSubject *subject = [RACSubject subject];
    
    //可处理信号中的信号
    //    [[subject flattenMap:^__kindof RACSignal * _Nullable(id  _Nullable value) {
    //        value = [NSString stringWithFormat:@"%@ 这个是什么",value];
    //        return [RACReturnSignal return:value];
    //    }] subscribeNext:^(id  _Nullable x) {
    //        NSLog(@"%@", x);
    //    }];
    //
    //    [subject sendNext:@"what happend?"];
    
    RACSubject * subjectOfSignal = [RACSubject subject];
    
    RACSubject * subject1 = [RACSubject subject];
    
    [[subjectOfSignal flattenMap:^__kindof RACSignal * _Nullable(id  _Nullable value) {
        return value;
    }] subscribeNext:^(id  _Nullable x) {
        NSLog(@"%@",x);
    }];
    
    [subjectOfSignal sendNext:subject1];
    
    [subject1 sendNext:@"弄啥嘞"];
    
    
    
    //    [[subject map:^id _Nullable(id  _Nullable value) {
    //        return [NSString stringWithFormat:@"%@ 这个是什么",value];
    //    }] subscribeNext:^(id  _Nullable x) {
    //        NSLog(@"%@", x);
    //    }];
    //
    //    [subject sendNext:@"what happend?"];
    
}

- (void)rac_liftSelector {
    
    RACSignal * signal1 = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        [subscriber sendNext:@"我是图片1"];
        return nil;
    }];
    
    RACSignal * signal2 = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        [subscriber sendNext:@"我是图片2"];
        return nil;
    }];
    
    RACSignal * signal3 = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        [subscriber sendNext:@"我是图片3"];
        return nil;
    }];
    
    //主线程运行
    [self rac_liftSelector:@selector(updateUIPic:pic2:pic3:) withSignalsFromArray:@[signal1, signal2, signal3]];
}


- (void)updateUIPic:(id)pic1 pic2:(id)pic2 pic3:(id)pic3{
    NSLog(@"我要加载了 : pic1 - %@ pic2 - %@ pic3 - %@",pic1,pic2,pic3);
}
- (void)RACTuple {
    //rac 元祖
    RACTuple *tuple =  [RACTuple tupleWithObjects:@"6666",@"8888",@"11111",@"22222", nil];
    id value =tuple[0];
    id value1 = tuple.first;
    NSLog(@"%@ || %@", value, value1);
    
    //替代数组
    NSArray *array = @[@"6666",@"8888",@"11111",@"22222"];
    //    RACSequence *sequence = array.rac_sequence;
    //    RACSignal *signal = sequence.signal;
    //    [signal subscribeNext:^(id  _Nullable x) {
    //        NSLog(@"%@", x);
    //    }];
    
    //便利数组
    [array.rac_sequence.signal subscribeNext:^(id  _Nullable x) {
        NSLog(@"%@", x);
    }];
    
    
    //代替字典
    NSDictionary *dict = @{@"11111":@"22222",@"aaaaa":@"bbbb",@"MMMM":@"NNNN"};
    [dict.rac_sequence.signal subscribeNext:^(id  _Nullable x) {
        NSLog(@"key ==%@ value = %@", x[0], x[1]);
    }];
    
    [dict.rac_sequence.signal subscribeNext:^(id  _Nullable x) {
        RACTupleUnpack(NSString *key, id value) = x;
        NSLog(@"key ==%@ value = %@", key, value);
    }];
    
    //字典转模型
    //    NSArray *personArray = @[@{@"name":@"小明",@"age":@"10"},@{@"name":@"小红",@"age":@"18"}];
    //
    //    NSMutableArray *mArray = [NSMutableArray array];
    //
    //    [array.rac_sequence.signal subscribeNext:^(id  _Nullable x) {
    //        [mArray addObject:[Person personWithDict:x]];
    //    }];

//    NSString * filePath = [[NSBundle mainBundle] pathForResource:@"Model.plist" ofType:nil];
//
//    NSArray * array = [NSArray arrayWithContentsOfFile:filePath];
//
//    //id  _Nullable value 这里的value就是NSDictionary 所以我们就改成NSDictionary
//    NSArray * persons = [[array.rac_sequence map:^id _Nullable(NSDictionary* value) {
//        return [Person personWithDict:value];
//    }] array];
//
//    NSLog(@"%@",persons);
    
    
}

- (void)racBind {
    RACSubject *subject = [RACSubject subject];
    RACSignal * signal = [subject bind:^RACSignalBindBlock _Nonnull{
        return ^RACSignal *(id _Nullable value, BOOL *stop){
            NSLog(@"%@", value);
            return [RACReturnSignal return:value];
        };
    }];
    [signal subscribeNext:^(id  _Nullable x) {
        NSLog(@"收到的数据 - %@",x);
    }];
    [subject sendNext:@"启动自毁程序"];
}

-(void)racCommand {
    RACCommand *command = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
        NSLog(@"input = %@", input);
        return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
            [subscriber sendNext:@"66666"];
            [subscriber sendCompleted];
            return nil;
        }];
    }];
    
    
    [command.executionSignals.switchToLatest subscribeNext:^(id  _Nullable x) {
        NSLog(@"接收数据 %@", x);
    }];
    
    [[command.executing skip:1] subscribeNext:^(NSNumber * _Nullable x) {
        if ([x boolValue]) {
            NSLog(@"还在执行");
        }else{
            NSLog(@"执行结束");
        }
    }];
    
    [command execute:@"99999"];
    
    // skip跳过第几个判断 filter 过滤某些 ignore 忽略某些值 startWith 从哪里开始 take 取几次正值 正序 takeLast 取几次值 倒序
}

- (void)racConnect {
    RACSignal *signal = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        NSLog(@"发送网络请求");
        [subscriber sendNext:@"得到网络请求数据"];
        return nil;
    }];
    
    RACMulticastConnection *connect = [signal publish];
    [connect.signal subscribeNext:^(id  _Nullable x) {
        NSLog(@"1 - %@",x);
    }];
    
    [connect.signal subscribeNext:^(id x) {
        NSLog(@"2 - %@",x);
    }];
    
    [connect.signal subscribeNext:^(id x) {
        NSLog(@"3 - %@",x);
    }];
    
    [connect connect];
}


- (void)RacTimer {
    @weakify(self)
    [[_makeSureBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self)
        x.enabled = false;
        self.time = 10;
        
        self.dispoable = [[RACSignal interval:1.0 onScheduler:[RACScheduler mainThreadScheduler]] subscribeNext:^(NSDate * _Nullable x) {
            self.time--;
            NSString *title = self.time > 0 ? [NSString stringWithFormat:@"请等待 %ld 秒后重试",self.time] : @"发送验证码";
            [self.makeSureBtn setTitle:title forState:UIControlStateNormal | UIControlStateDisabled];
            self.makeSureBtn.enabled = (self.time ==0) ? YES : NO;
            if (self.time == 0) {
                [self.dispoable dispose];
            }
        }];
    }];
}

- (void)RACUICreate {
    [[self rac_signalForSelector:@selector(buttonClick:)] subscribeNext:^(RACTuple * _Nullable x) {
        NSLog(@" button %@", x);
    }];
    
    //改变的时候监听
    [_bgView rac_observeKeyPath:@"frame" options:NSKeyValueObservingOptionNew observer:nil block:^(id value, NSDictionary *change, BOOL causedByDealloc, BOOL affectedOnlyLastComponent) {
        NSLog(@"1 - %@",value);
    }];
    
    //初始化的时候监听
    [[_bgView rac_valuesForKeyPath:@"frame" observer:self] subscribeNext:^(id  _Nullable x) {
        NSLog(@"2 - %@",x);
    }];
    
    //初始化的时候监听
    [RACObserve(_bgView, frame) subscribeNext:^(id  _Nullable x) {
        NSLog(@"3 - %@",x);
    }];
    
    [[_signalBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        NSLog(@"%@",x );
    }];
    
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:@"UIKeyboardDidShowNotification" object:nil] subscribeNext:^(NSNotification * _Nullable x) {
        NSLog(@"%@",x);
    }];
    
    [_textField.rac_textSignal subscribeNext:^(NSString * _Nullable x) {
        NSLog(@"%@",x);
    }];
    
    //    RAC(对象，对象的属性) = (一个信号);
    [_secondView.btnClickSignal subscribeNext:^(id  _Nullable x) {
        NSLog(@"btnClickSignal %@", x);
    }];
}


- (void)RACSubject {
    //可以被多次订阅，但是需要先订阅后发布, 既能订阅信息又能发送信息
    RACSubject *subject = [RACSubject subject];
    //发送
    [subject sendNext:@"先发送数据"];
    [subject subscribeNext:^(id  _Nullable x) {
        NSLog(@"111 %@", x);
    }];
    
    [subject subscribeNext:^(id  _Nullable x) {
        NSLog(@"2222 %@", x);
    }];
    
    [subject sendNext:@"发送数据"];
    
    //可以先发送后订阅信号
    RACReplaySubject *replaySubject = [RACReplaySubject subject];
    [replaySubject sendNext:@"先发送试试"];
    [replaySubject subscribeNext:^(id  _Nullable x) {
        NSLog(@"replaySubject %@", x);
    }];
    

}


- (void)RACCommand {
    //创建命令返回的是信号
    RACCommand *command = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
        return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
            [subscriber sendNext:input];
            [subscriber sendCompleted];
            return [RACDisposable disposableWithBlock:^{
                
            }];
        }];
    }];
    
    //订阅命令中的信号发出
    [command.executionSignals.switchToLatest subscribeNext:^(id  _Nullable x) {
        NSLog(@"switchToLatest = %@", x);
    }];
    
    //判断命令是否在执行 0 是不执行 1 是执行
    [command.executing subscribeNext:^(NSNumber * _Nullable x) {
        NSLog(@"executing = %@", x);
    }];
    
    [command execute:@"执行命令"];
}

- (void)RACSignal {
    
    RACSignal *signal = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        [subscriber sendNext:@"发送next信号"];
        [subscriber sendCompleted];
        //取消订阅用于清理资源用
        return  [RACDisposable disposableWithBlock:^{
            NSLog(@"disposable");
        }];
    }];
    
//    [signal subscribeNext:^(id  _Nullable x) {
//        NSLog(@"%@", x);
//    }];
    
//    [signal subscribeError:^(NSError * _Nullable error) {
//        NSLog(@"error = %@", error);
//    }];
    
    //订阅信号完成
//    [signal subscribeCompleted:^{
//        NSLog(@"complected");
//    }];
    
    RACDisposable *disposable = [signal subscribeNext:^(id  _Nullable x) {
        NSLog(@"%@",x);
    }];
    
    //主动触发取消订阅
    [disposable dispose];
}




@end
