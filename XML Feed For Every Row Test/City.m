//
//  City.m
//
//  Created by Robert Ryan on 8/13/13.
//  Copyright (c) 2013 Robert Ryan. All rights reserved.
//

#import "City.h"
#import "CityOperation.h"

@implementation City

- (id)initWithName:(NSString *)name temperature:(NSString *)temperature
{
    self = [super init];
    if (self) {
        _name = [name copy];
        _temperature = [temperature copy];
    }
    return self;
}

@end
