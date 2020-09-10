//
//  KAsyncToSync.m
//  KAsyncToSync
//
//  Created by Key on 2020/9/10.
//  Copyright © 2020 Key. All rights reserved.
//

#import "KAsyncToSync.h"

@interface KAsyncToSyncObserver : NSObject
@property (nonatomic, copy) k_async_task_interrupt_handler interrupt_handler;
@end

@implementation KAsyncToSyncObserver
- (instancetype)initWithHandler:(k_async_task_interrupt_handler)handler {
    self = [super init];
    if (self) {
        self.interrupt_handler = [handler copy];
    }
    return self;
}

- (void)dealloc {
    if (self.interrupt_handler) {
        self.interrupt_handler();
        self.interrupt_handler = nil;
    }
}
@end


void
_k_async_to_sync_wait_until_interrupt(k_async_task_interruptable task, k_async_task_callback callback, k_async_task_interrupt_handler interrupt_handler, void (^wait_until_interrupt)(void)) {
    
    @autoreleasepool {
        id observer = [[KAsyncToSyncObserver alloc] initWithHandler:interrupt_handler];
        task(observer, interrupt_handler, callback);
    }
    wait_until_interrupt();
}




void
k_async_to_sync(k_async_task task, k_async_task_callback callback) {
    
    k_async_task_interruptable interruptable_task = ^(id obj, k_async_task_interrupt_handler interrupt_handler, k_async_task_callback callback) {
        task(obj, callback);
    };
    k_async_to_sync_interruptable(interruptable_task, callback);
}

void
k_async_to_sync_interruptable(k_async_task_interruptable task, k_async_task_callback callback) {
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    k_async_task_interrupt_handler interrupt_handler = ^{
        dispatch_semaphore_signal(semaphore);
    };
    
    _k_async_to_sync_wait_until_interrupt(task, callback, interrupt_handler, ^{
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    });
}


void
k_async_to_sync_nonblocking(k_async_task task, k_async_task_callback callback) {
    k_async_task_interruptable interruptable_task = ^(id obj, k_async_task_interrupt_handler interrupt_handler, k_async_task_callback callback) {
        task(obj, callback);
    };
    k_async_to_sync_nonblocking_interruptable(interruptable_task, callback);
}

void
k_async_to_sync_nonblocking_interruptable(k_async_task_interruptable task, k_async_task_callback callback) {
    
    CFRunLoopRef runLoop = CFRunLoopGetCurrent();
    CFRunLoopSourceContext sourceContent = {0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL};
    CFRunLoopSourceRef source = CFRunLoopSourceCreate(kCFAllocatorDefault, 0, &sourceContent);
    CFRunLoopAddSource(runLoop, source, kCFRunLoopDefaultMode);
    
    // 标识打断是否完成
    __block BOOL interrupt_finished = NO;
    
    k_async_task_interrupt_handler interrupt_handler = ^{
        interrupt_finished = YES;
        // source 需要标记待处理 & 主动唤醒 RunLoop
        CFRunLoopSourceSignal(source);
        CFRunLoopWakeUp(runLoop);
    };
    _k_async_to_sync_wait_until_interrupt(task, callback, interrupt_handler, ^{
        do {
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
        } while (!interrupt_finished);
    });
    
    CFRunLoopRemoveSource(runLoop, source, kCFRunLoopDefaultMode);
    CFRelease(source);
}
