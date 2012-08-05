//
//  PhotoListViewController.h
//  Top Places
//
//  Created by Maxim Piskunov on 05.08.2012.
//  Copyright (c) 2012 Maxim Piskunov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TableMapViewController.h"

#define DEFAULTS_RECENT @"Recent Photos"

@interface PhotoListViewController : TableMapViewController

@property (nonatomic, strong) NSArray *photos;

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;

@end
