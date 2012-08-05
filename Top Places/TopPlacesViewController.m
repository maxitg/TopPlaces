//
//  TopPlacesViewController.m
//  Top Places
//
//  Created by Maxim Piskunov on 04.08.2012.
//  Copyright (c) 2012 Maxim Piskunov. All rights reserved.
//

#import "TopPlacesViewController.h"
#import "FlickrFetcher.h"
#import "PhotoListViewController.h"
#import "PlaceAnnotation.h"

@interface TopPlacesViewController () <UITableViewDataSource>

@property (nonatomic, strong) NSArray* topPlaces;   //  of dictionaries for each country

@end

@implementation TopPlacesViewController

@synthesize tableView = _tableView;
@synthesize mapView = _mapView;
@synthesize tableMapSegmentedControl = _tableMapSegmentedControl;

@synthesize topPlaces = _topPlaces;

#pragma mark - Setters & getters

- (void)setTopPlaces:(NSArray *)topPlaces
{
    if (_topPlaces != topPlaces) {
        _topPlaces = topPlaces;
        [self.tableView reloadData];
        
        [self.mapView removeAnnotations:self.mapView.annotations];
        NSMutableArray *annotations = [[NSMutableArray alloc] init];
        for (int i = 0; i < [topPlaces count]; i++) {
            for (NSDictionary *place in [[topPlaces objectAtIndex:i] objectForKey:@"Places"]) {
                [annotations addObject:[PlaceAnnotation annotationForPlace:place]];
            }
        }
        [self.mapView addAnnotations:annotations];
    }
}

#pragma mark - Place description helpers

- (NSArray *)placeNameComponentsForPlace:(NSDictionary *)aPlace
{
    NSString *placeName = [aPlace objectForKey:FLICKR_PLACE_NAME];
    return [placeName componentsSeparatedByString:@", "];
}

- (NSString *)countryForPlace:(NSDictionary *)aPlace
{
    return [[self placeNameComponentsForPlace:aPlace] lastObject];
}

- (NSString *)cityForPlace:(NSDictionary *)aPlace
{
    return [[self placeNameComponentsForPlace:aPlace] objectAtIndex:0];
}

- (NSString *)placeDetailsForPlace:(NSDictionary *)aPlace
{
    NSArray *placeComponents = [self placeNameComponentsForPlace:aPlace];
    NSRange detailsRange;
    detailsRange.location = 1;
    detailsRange.length = [placeComponents count] - 1;
    return [[placeComponents subarrayWithRange:detailsRange] componentsJoinedByString:@", "];
}

#pragma mark - Lifecycle

- (void)viewWillAppear:(BOOL)animated
{
    [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //  Setting delegates
    
    self.tableView.dataSource = self;
    
    //  Loading topPlaces from Flickr
    
    self.isLoading = YES;
    dispatch_queue_t topPlacesDownloadQueue = dispatch_queue_create("top places downloader", NULL);
    dispatch_async(topPlacesDownloadQueue, ^{
        NSArray *rawPlaces = [FlickrFetcher topPlaces];
        
        //  building dictionary of countries
        
        NSMutableDictionary *countriesDictionary = [[NSMutableDictionary alloc] init];
        for (NSDictionary *place in rawPlaces) {
            NSString *countryName = [self countryForPlace:place];
            if (![countriesDictionary objectForKey:countryName]) [countriesDictionary setObject:[[NSMutableArray alloc] init] forKey:countryName];
            [[countriesDictionary objectForKey:countryName] addObject:place];
        }
        
        //  building array of countries
        
        NSMutableArray *countriesArray = [[NSMutableArray alloc] init];
        for (NSString *countryName in [countriesDictionary allKeys]) {
            
            NSSortDescriptor *placesSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:FLICKR_PLACE_NAME ascending:YES];
            NSArray *places = [[countriesDictionary objectForKey:countryName] sortedArrayUsingDescriptors:[NSArray arrayWithObject:placesSortDescriptor]];
            
            [countriesArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:countryName, @"Country Name", places, @"Places", nil]];
            
        }
        
        //  building sorted array of countries
        
        NSSortDescriptor *countriesSortDesciptor = [NSSortDescriptor sortDescriptorWithKey:@"Country Name" ascending:YES];
        NSArray *sortedCountriesArray = [countriesArray sortedArrayUsingDescriptors:[NSArray arrayWithObject:countriesSortDesciptor]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.topPlaces = sortedCountriesArray;
            self.isLoading = NO;
        });
        
    });
    dispatch_release(topPlacesDownloadQueue);
}

- (void)viewDidUnload
{
    [self setTableView:nil];
    [self setMapView:nil];
    [self setTableMapSegmentedControl:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.topPlaces count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[[self.topPlaces objectAtIndex:section] objectForKey:@"Places"] count];
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [[self.topPlaces objectAtIndex:section] objectForKey:@"Country Name"];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Place Description"];
    
    NSDictionary *selectedPlace = [[[self.topPlaces objectAtIndex:indexPath.section] objectForKey:@"Places"] objectAtIndex:indexPath.row];
    cell.textLabel.text = [self cityForPlace:selectedPlace];
    cell.detailTextLabel.text = [self placeDetailsForPlace:selectedPlace];
    
    return cell;
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Show Photos In Place"]) {
        NSIndexPath *senderIndexPath = [self.tableView indexPathForCell:sender];
        NSDictionary *selectedPlace = [[[self.topPlaces objectAtIndex:senderIndexPath.section] objectForKey:@"Places"] objectAtIndex:senderIndexPath.row];
        
        [segue.destinationViewController setIsLoading:YES];
        dispatch_queue_t photoListDownloadQueue = dispatch_queue_create("photo list downloder", NULL);
        dispatch_async(photoListDownloadQueue, ^{
            NSArray *photos = [FlickrFetcher photosInPlace:selectedPlace maxResults:50];
            dispatch_async(dispatch_get_main_queue(), ^{
                [segue.destinationViewController setPhotos:photos];
                [segue.destinationViewController setIsLoading:NO];
            });
        });
        dispatch_release(photoListDownloadQueue);
        
        [segue.destinationViewController setTitle:[[sender textLabel] text]];
    }
}

@end
