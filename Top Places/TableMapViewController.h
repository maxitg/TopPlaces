//
//  TableMapViewController.h
//  Top Places
//
//  Created by Maxim Piskunov on 05.08.2012.
//  Copyright (c) 2012 Maxim Piskunov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "LoadingViewPresenterViewController.h"

@interface TableMapViewController : LoadingViewPresenterViewController

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *tableMapSegmentedControl;

@end
