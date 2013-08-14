//
//  NetworkQueueManager.m
//
//  Created by Robert Ryan on 8/14/13.
//  Copyright (c) 2013 Robert Ryan. All rights reserved.
//

#import "NetworkQueueManager.h"

@interface NetworkQueueManager ()

@end

@implementation NetworkQueueManager

+ (instancetype)sharedManager
{
    static id sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

- (id)init
{
    self = [super init];
    if (self) {
        _queue = [[NSOperationQueue alloc] init];
        _queue.name = [[[NSBundle mainBundle] bundleIdentifier] stringByAppendingString:@".NetworkOperationQueue"];
        _queue.maxConcurrentOperationCount = 5;
    }
    return self;
}

#pragma mark - NSThread methods

+ (void)networkRequestThreadEntryPoint:(id __unused)object
{
    @autoreleasepool {
        [[NSThread currentThread] setName:[[[NSBundle mainBundle] bundleIdentifier] stringByAppendingString:@".NetworkThread"]];

        NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
        [runLoop addPort:[NSMachPort port] forMode:NSDefaultRunLoopMode];
        [runLoop run];
    }
}

+ (NSThread *)networkRequestThread
{
    static NSThread *_networkRequestThread = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _networkRequestThread = [[NSThread alloc] initWithTarget:self selector:@selector(networkRequestThreadEntryPoint:) object:nil];
        [_networkRequestThread start];
    });

    return _networkRequestThread;
}

@end
