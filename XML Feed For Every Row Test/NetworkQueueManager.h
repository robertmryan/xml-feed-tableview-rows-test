//
//  NetworkQueueManager.h
//
//  Created by Robert Ryan on 8/14/13.
//  Copyright (c) 2013 Robert Ryan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NetworkQueueManager : NSObject

@property (nonatomic, strong) NSOperationQueue *queue;

+ (instancetype)sharedManager;
+ (NSThread *)networkRequestThread;

@end
