//
//  CityCell.h
//
//  Created by Robert Ryan on 8/13/13.
//  Copyright (c) 2013 Robert Ryan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CityCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *cityNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *cityTemperatureLabel;

- (void)updateWithKey:(NSString *)key tableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath;

@end
