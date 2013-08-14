//
//  CityWeather.h
//
//  Created by Robert Ryan on 8/13/13.
//  Copyright (c) 2013 Robert Ryan. All rights reserved.
//

#import <Foundation/Foundation.h>

@class City;

typedef void(^CityCompletion)(City *city);

@interface CityOperation : NSOperation

@property (nonatomic, copy) NSString *woeid;
@property (nonatomic, copy) CityCompletion cityCompletion;

- (id)initWithWoeid:(NSString *)woeid successBlock:(CityCompletion)completion;

@end
