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
    [super viewWillAppear:YES];
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] init];
    self.photos = [userDefaults valueForKey:DEFAULTS_RECENT];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    
    NSMutableArray *updatedPhotos = [self.photos mutableCopy];
    [updatedPhotos removeObjectAtIndex:indexPath.row];
    [updatedPhotos insertObject:[self.photos objectAtIndex:indexPath.row] atIndex:0];
    self.photos = [updatedPhotos copy];
    
    [self.tableView moveRowAtIndexPath:indexPath toIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionTop];
    [self.tableView deselectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:NO];
}

@end
