//
//  TableMapViewController.m
//  Top Places
//
//  Created by Maxim Piskunov on 05.08.2012.
//  Copyright (c) 2012 Maxim Piskunov. All rights reserved.
//

#import "TableMapViewController.h"
#import "Annotation.h"

#define DEFAULTS_PRESENTATION_TYPE_PREFIX @"Presentation Type "

@interface TableMapViewController ()

@end

@implementation TableMapViewController

@synthesize tableView = _tableView;
@synthesize mapView = _mapView;
@synthesize tableMapSegmentedControl = _tableMapSegmentedControl;
@synthesize mapTypeSegmentedControl = _mapTypeSegmentedControl;

- (NSString *)defaultsPresentationTypeKey
{
    return [DEFAULTS_PRESENTATION_TYPE_PREFIX stringByAppendingString:[[self class] description]];
}

- (void)updateMapRegion
{
    double minLatitude, maxLatitude, minLongitude, maxLongitude;
    minLatitude = minLongitude = +720.;
    maxLatitude = maxLongitude = -720.;
    for (Annotation *annotation in self.mapView.annotations) {
        if (minLatitude > annotation.coordinate.latitude) minLatitude = annotation.coordinate.latitude;
        if (maxLatitude < annotation.coordinate.latitude) maxLatitude = annotation.coordinate.latitude;
        if (minLongitude > annotation.coordinate.longitude) minLongitude = annotation.coordinate.longitude;
        if (maxLongitude < annotation.coordinate.longitude) maxLongitude = annotation.coordinate.longitude;
    }
    MKCoordinateRegion annotationsRegion;
    annotationsRegion.center.latitude = (minLatitude + maxLatitude) / 2;
    annotationsRegion.center.longitude = (minLongitude + maxLongitude) / 2;
    annotationsRegion.span.latitudeDelta = MIN(180, (maxLatitude - minLatitude) * 1.2);
    annotationsRegion.span.longitudeDelta = MIN(360, (maxLongitude - minLongitude) * 1.2);
    
    self.mapView.region = annotationsRegion;
}

#pragma mark - Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //  Loading table or map defaults from userDefaults
    
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] init];
    self.tableMapSegmentedControl.selectedSegmentIndex = [[userDefaults objectForKey:[self defaultsPresentationTypeKey]] intValue];
    [self tableMapSegmentedControlValueChanged];
}

#pragma mark - Table <-> Map changing methods

- (IBAction)tableMapSegmentedControlValueChanged
{
    if (self.tableMapSegmentedControl.selectedSegmentIndex == 0) {
        [self.mapView setHidden:YES];
        [self.mapTypeSegmentedControl setHidden:YES];
        [self.tableView setHidden:NO];
    } else {
        [self.tableView setHidden:YES];
        [self.mapView setHidden:NO];
        [self.mapTypeSegmentedControl setHidden:NO];
    }
    
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] init];
    [userDefaults setObject:[NSNumber numberWithInt:self.tableMapSegmentedControl.selectedSegmentIndex] forKey:[self defaultsPresentationTypeKey]];
    [userDefaults synchronize];
}

- (IBAction)mapTypeSegmentedControlValueChanged:(UISegmentedControl *)sender
{
    if (sender.selectedSegmentIndex == 0) self.mapView.mapType = MKMapTypeStandard;
    else if (sender.selectedSegmentIndex == 1) self.mapView.mapType = MKMapTypeSatellite;
    else if (sender.selectedSegmentIndex == 2) self.mapView.mapType = MKMapTypeHybrid;
}


- (void)viewDidUnload {
    [self setMapTypeSegmentedControl:nil];
    [super viewDidUnload];
}
@end
