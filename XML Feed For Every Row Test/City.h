//
//  City.h
//
//  Created by Robert Ryan on 8/13/13.
//  Copyright (c) 2013 Robert Ryan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface City : NSObject

@property (nonatomic, copy) NSString *temperature;
@property (nonatomic, copy) NSString *name;

- (id)initWithName:(NSString *)name temperature:(NSString *)temperature;

@end
