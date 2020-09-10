//
//  ViewController.m
//  AsyncToSync
//
//  Created by Key on 2020/9/10.
//  Copyright © 2020 Key. All rights reserved.
//

#import "ViewController.h"
#import "KAsyncToSync.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton * btn1 = [UIButton buttonWithType:UIButtonTypeCustom];
    btn1.frame = CGRectMake(20, 80, 200, 40);
    btn1.backgroundColor = [UIColor orangeColor];
    [btn1 setTitle:@"GCD" forState:UIControlStateNormal];
    [btn1 addTarget:self action:@selector(gcd_test) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn1];
    
    UIButton * btn2 = [UIButton buttonWithType:UIButtonTypeCustom];
    btn2.frame = CGRectMake(20, 140, 200, 40);
    btn2.backgroundColor = [UIColor orangeColor];
    [btn2 setTitle:@"RunLoop" forState:UIControlStateNormal];
    [btn2 addTarget:self action:@selector(runLoop_test) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn2];
}

// 可以点击屏幕来测试是否阻塞当前线程
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    NSLog(@"%s", __func__);
}


- (void)gcd_test {
    NSLog(@"gcd_test begin -----");
    
    k_async_task_callback async_task_callback = ^(id obj, ...) {
        
        va_list args;
        va_start(args, obj);
        
        id string = va_arg(args, id);
        while (string) {
            string = va_arg(args, id);
        }
        va_end(args);
        
        NSLog(@"gcd_test task complete -----");
    };
    
    k_async_task task = ^(id obj, k_async_task_callback callback) {

        // 开始执行异步费时操作
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), queue, ^{

            // 在异步操作完成后，必须调用 callback: 第一个参数 obj 必须传
            // 这里 后面可以跟多个参数，不过在获取时注意参数个数
            callback(obj, @"aaa", nil);
        });
    };
    k_async_to_sync(task, async_task_callback);
    NSLog(@"gcd_test end -----");
    
    
    
    NSLog(@"gcd_test111 begin -----");
    
    __block k_async_task_interrupt_handler custom_interrupt_handler;
    k_async_task_interruptable interrupt_task = ^(id obj, k_async_task_interrupt_handler interrupt_handler, k_async_task_callback callback) {
        // 保存 interrupt handler，外界可以随时打断 task
        custom_interrupt_handler = [interrupt_handler copy];
        
        // 开始执行异步费时操作
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), queue, ^{
            
            callback(obj, @"aaa", nil);
        });
    };
    k_async_to_sync_interruptable(interrupt_task, async_task_callback);
    
    NSLog(@"gcd_test111 end -----");
}





- (void)runLoop_test {
    NSLog(@"runLoop_test begin -----");
    
    k_async_task_callback async_task_callback = ^(id obj, ...) {
        
        va_list args;
        va_start(args, obj);
        
        id string = va_arg(args, id);
        while (string) {
            string = va_arg(args, id);
        }
        va_end(args);
        
        NSLog(@"runLoop_test task complete -----");
    };
    
    
    k_async_task task = ^(id obj, k_async_task_callback callback) {

        // 开始执行异步费时操作
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), queue, ^{

            // 在异步操作完成后，必须调用 callback: 第一个参数 obj 必须传
            // 这里 后面可以跟多个参数，不过在获取时注意参数个数
            callback(obj, @"aaa", nil);
        });
    };
    k_async_to_sync_nonblocking(task, async_task_callback);
    NSLog(@"runLoop_test end -----");
    
    
    
    NSLog(@"runLoop_test111 begin -----");
    
    __block k_async_task_interrupt_handler custom_interrupt_handler;
    k_async_task_interruptable interrupt_task = ^(id obj, k_async_task_interrupt_handler interrupt_handler, k_async_task_callback callback) {
        // 保存 interrupt handler，外界可以随时打断 task
        custom_interrupt_handler = [interrupt_handler copy];
        
        // 开始执行异步费时操作
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), queue, ^{
            
            callback(obj, @"aaa", nil);
        });
    };
    k_async_to_sync_nonblocking_interruptable(interrupt_task, async_task_callback);
    
    NSLog(@"runLoop_test111 end -----");
}

@end
