//
//  RecentPhotoListTableViewController.m
//  Top Places
//
//  Created by Maxim Piskunov on 30.07.2012.
//  Copyright (c) 2012 Maxim Piskunov. All rights reserved.
//

#import "RecentPhotoListViewController.h"
#import "PhotoListViewController.h"

@interface RecentPhotoListViewController ()

@property (nonatomic) BOOL isPhotoPresented;

@end

@implementation RecentPhotoListViewController

@synthesize isPhotoPresented = _isPhotoPresented;

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (!self.splitViewController && self.isPhotoPresented) {    //  to prevent non-flashing previous selection in tableView on iPhone
        self.isPhotoPresented = NO;
    } else {
        NSUserDefaults *userDefaults = [[NSUserDefaults alloc] init];
        NSArray *newPhotos = [userDefaults valueForKey:DEFAULTS_RECENT];
        if (![self.photos isEqualToArray:newPhotos]) self.photos = newPhotos;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableArray *updatedPhotos = [self.photos mutableCopy];
    [updatedPhotos removeObjectAtIndex:indexPath.row];
    [updatedPhotos insertObject:[self.photos objectAtIndex:indexPath.row] atIndex:0];
    self.photos = [updatedPhotos copy];
    
    [self.tableView moveRowAtIndexPath:indexPath toIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
    
    self.isPhotoPresented = YES;
    
    [super tableView:tableView didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
}

@end
