//
//  ViewController.m
//  XML Feed For Every Row Test
//
//  Created by Robert Ryan on 8/14/13.
//  Copyright (c) 2013 Robert Ryan. All rights reserved.
//

#import "ViewController.h"
#import "CityCell.h"

@interface ViewController ()

@property (nonatomic, strong) NSArray *objects;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.objects = @[@"2502265", @"2369745", @"2459115", @"2391585", @"2389628", @"615702", @"650272", @"2379574"];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.objects count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"CityCell";
    CityCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];

    NSString *key = self.objects[indexPath.row];
    [cell updateWithKey:key tableView:tableView indexPath:indexPath];

    return cell;
}

@end
