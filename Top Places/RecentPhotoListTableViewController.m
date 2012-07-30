//
//  RecentPhotoListTableViewController.m
//  Top Places
//
//  Created by Maxim Piskunov on 30.07.2012.
//  Copyright (c) 2012 Maxim Piskunov. All rights reserved.
//

#import "RecentPhotoListTableViewController.h"
#import "PhotoListTableViewController.h"

@interface RecentPhotoListTableViewController ()

@end

@implementation RecentPhotoListTableViewController

- (void)viewWillAppear:(BOOL)animated
{
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] init];
    self.photos = [userDefaults valueForKey:DEFAULTS_RECENT];
}

@end
