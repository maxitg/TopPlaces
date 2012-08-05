//
//  TableMapViewController.m
//  Top Places
//
//  Created by Maxim Piskunov on 05.08.2012.
//  Copyright (c) 2012 Maxim Piskunov. All rights reserved.
//

#import "TableMapViewController.h"

#define DEFAULTS_PRESENTATION_TYPE @"Presentation Type"

@interface TableMapViewController ()

@end

@implementation TableMapViewController

@synthesize tableView = _tableView;
@synthesize mapView = _mapView;
@synthesize tableMapSegmentedControl = _tableMapSegmentedControl;

#pragma mark - Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //  Loading table or map defaults from userDefaults
    
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] init];
    self.tableMapSegmentedControl.selectedSegmentIndex = [[userDefaults objectForKey:DEFAULTS_PRESENTATION_TYPE] intValue];
    [self tableMapSegmentedControlValueChanged];
}

#pragma mark - Table <-> Map changing methods

- (IBAction)tableMapSegmentedControlValueChanged {
    if (self.tableMapSegmentedControl.selectedSegmentIndex == 0) {
        [self.mapView setHidden:YES];
        [self.tableView setHidden:NO];
    } else {
        [self.tableView setHidden:YES];
        [self.mapView setHidden:NO];
    }
    
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] init];
    [userDefaults setObject:[NSNumber numberWithInt:self.tableMapSegmentedControl.selectedSegmentIndex] forKey:DEFAULTS_PRESENTATION_TYPE];
    [userDefaults synchronize];
}

@end