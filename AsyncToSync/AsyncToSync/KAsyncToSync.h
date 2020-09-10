//
//  KAsyncToSync.h
//  KAsyncToSync
//
//  Created by Key on 2020/9/10.
//  Copyright © 2020 Key. All rights reserved.
//

#import <Foundation/Foundation.h>

/// 具体使用见 -- ViewController

typedef void (^k_async_task_callback)(id, ...);
typedef void (^k_async_task)(id obj, k_async_task_callback callback);

typedef void (^k_async_task_interrupt_handler)(void);
typedef void (^k_async_task_interruptable)(id obj, k_async_task_interrupt_handler interrupt_handler, k_async_task_callback callback);


/// GCD 阻塞当前线程等待
void k_async_to_sync(k_async_task task, k_async_task_callback callback);
void k_async_to_sync_interruptable(k_async_task_interruptable task, k_async_task_callback callback);

/// RunLoop 不阻塞当前线程
void k_async_to_sync_nonblocking(k_async_task task, k_async_task_callback callback);
void k_async_to_sync_nonblocking_interruptable(k_async_task_interruptable task, k_async_task_callback callback);
