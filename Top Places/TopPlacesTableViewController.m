//
//  TopPlacesTableViewController.m
//  Top Places
//
//  Created by Maxim Piskunov on 28.07.2012.
//  Copyright (c) 2012 Maxim Piskunov. All rights reserved.
//

#import "TopPlacesTableViewController.h"
#import "FlickrFetcher.h"
#import "PhotoListTableViewController.h"

@interface TopPlacesTableViewController ()

@property (nonatomic, strong) NSArray* topPlaces;   //  of (arrays of pairs {location components, place description}), sorted by country

@end

@implementation TopPlacesTableViewController

@synthesize topPlaces = _topPlaces;

#pragma mark - Setters & getters

- (NSArray*)topPlaces
{
    if (!_topPlaces) {
        NSArray *rawPlaces = [FlickrFetcher topPlaces];
        
        //  building NSMutableDictionary of arrays of pairs {location components, place description}
        
        NSMutableDictionary *countries = [[NSMutableDictionary alloc] init];
        for (NSDictionary *placeDescription in rawPlaces) {
            NSString *name = [placeDescription objectForKey:FLICKR_PLACE_NAME];
            NSArray *nameComponents = [name componentsSeparatedByString:@", "];
            NSString *countryName = [nameComponents lastObject];
            if (![countries objectForKey:countryName]) [countries setObject:[[NSMutableArray alloc] init] forKey:countryName];
            [[countries objectForKey:countryName] addObject:[NSArray arrayWithObjects:nameComponents, placeDescription, nil]];
        }
        
        //  building NSMutableArray of (arrays of pairs {location components, place description}, sorted by place name)
        
        NSMutableArray *topPlacesMutable = [[NSMutableArray alloc] init];
        for (NSString *countryName in [countries allKeys]) {
            [topPlacesMutable addObject:[[countries objectForKey:countryName] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                return [[obj1 componentsJoinedByString:@", "] compare:[obj2 componentsJoinedByString:@", "]];
            }]];
        }
        
        //  building NSArray of (arrays of pairs {location components, place description}, sorted by place name), sorted by country
        
        _topPlaces = [topPlacesMutable sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            return [[[[obj1 firstObject] firstObject] lastObject] compare:[[[obj2 firstObject] firstObject] lastObject]];
        }];
    }
    return _topPlaces;
}

#pragma mark - Lifecycle

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return ([[UIDevice currentDevice] userInterfaceIdiom] != UIUserInterfaceIdiomPhone || interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Show Photos In Place"]) {
        NSIndexPath *senderIndexPath = [self.tableView indexPathForCell:sender];
        NSDictionary *chosenPlace = [[[self.topPlaces objectAtIndex:senderIndexPath.section] objectAtIndex:senderIndexPath.row] lastObject];
        [segue.destinationViewController setPhotos:[FlickrFetcher photosInPlace:chosenPlace maxResults:50]];
        [segue.destinationViewController setTitle:[[sender textLabel] text]];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.topPlaces count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self.topPlaces objectAtIndex:section] count];
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [[[[self.topPlaces objectAtIndex:section] firstObject] firstObject] lastObject];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Place Description"];
    
    NSArray *placeComponents = [[[self.topPlaces objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] firstObject];
    cell.textLabel.text = [placeComponents objectAtIndex:0];
    
    NSRange placeDetailesRange;
    placeDetailesRange.location = 1;
    placeDetailesRange.length = [placeComponents count] - 1;
    NSArray *placeDetailes = [placeComponents subarrayWithRange:placeDetailesRange];
    cell.detailTextLabel.text = [placeDetailes componentsJoinedByString:@", "];
    
    return cell;
}

@end
