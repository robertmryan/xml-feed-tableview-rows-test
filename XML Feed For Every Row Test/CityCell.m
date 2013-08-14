//
//  CityCell.m
//
//  Created by Robert Ryan on 8/13/13.
//  Copyright (c) 2013 Robert Ryan. All rights reserved.
//

#import "CityCell.h"
#import "City.h"
#import "CityOperation.h"
#import "NetworkQueueManager.h"

@interface CityCell ()
@property (nonatomic, weak) NSOperation *operation;
@end

@implementation CityCell

- (NSCache *)cache
{
    static NSCache *sharedCache = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedCache = [[NSCache alloc] init];
        sharedCache.name = [[[NSBundle mainBundle] bundleIdentifier] stringByAppendingString:@".CityCell"];
    });
    return sharedCache;
}

- (void)updateWithKey:(NSString *)key tableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath
{
    // try to retrieve the cell from the cache

    City *cityFromCache = [self.cache objectForKey:key];
    if (cityFromCache)
    {
        // if successful, use the data from the cache

        self.cityNameLabel.text = cityFromCache.name;
        self.cityTemperatureLabel.text = cityFromCache.temperature;
    }
    else
    {
        // if we have a prior operation going for this cell (i.e. for a row that has
        // since scrolled off the screen), cancel it so the display of the current row
        // is not delayed waiting for data for rows that are no longer visible

        [self.operation cancel];

        // re-initialize the cell (so we don't see old data while retrieving new data

        self.cityNameLabel.text = nil;
        self.cityTemperatureLabel.text = nil;

        // initiate a network request for the new data; when it comes in, update the cell

        CityOperation *operation = [[CityOperation alloc] initWithWoeid:key successBlock:^(City *city) {

            typeof(self) updateCell = (id)[tableView cellForRowAtIndexPath:indexPath];

            // if the cell for this row is still visible, update it

            if (updateCell)
            {
                // fade in the results to make it a little less jarring

                [UIView transitionWithView:updateCell
                                  duration:0.1
                                   options:UIViewAnimationOptionTransitionCrossDissolve
                                animations:^{
                                    updateCell.cityTemperatureLabel.text = city.temperature;
                                    updateCell.cityNameLabel.text = city.name;
                                    [updateCell setNeedsLayout];
                                }
                                completion:NULL];
            }

            // let's save the data in our cache, too

            [self.cache setObject:city forKey:key];
        }];

        // in our custom cell subclass, I'll keep a weak reference to this operation so
        // we can cancel it if I need to

        self.operation = operation;
        
        // initiate the request
        
        [[[NetworkQueueManager sharedManager] queue] addOperation:operation];
    }
}

@end
