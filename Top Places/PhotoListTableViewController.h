//
//  PlaceTopPhotosTableViewController.h
//  Top Places
//
//  Created by Maxim Piskunov on 28.07.2012.
//  Copyright (c) 2012 Maxim Piskunov. All rights reserved.
//

#import <UIKit/UIKit.h>

#define DEFAULTS_RECENT @"Recent Photos"

@interface PhotoListTableViewController : UITableViewController

@property (nonatomic, strong) NSArray *photos;  //  model

@property (nonatomic, strong) UIActivityIndicatorView *spinner;

@end
