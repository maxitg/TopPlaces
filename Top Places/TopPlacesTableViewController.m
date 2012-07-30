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

@property (nonatomic, strong) NSArray* topPlaces;

@end

@implementation TopPlacesTableViewController

@synthesize topPlaces = _topPlaces;

#pragma mark - Setters & getters

- (NSArray*)topPlaces
{
    if (!_topPlaces) {
        NSArray *unsortedPlaces = [FlickrFetcher topPlaces];
        _topPlaces = [unsortedPlaces sortedArrayUsingComparator: ^(id obj1, id obj2) {
            return [[obj1 objectForKey:@"_content"] compare:[obj2 objectForKey:@"_content"] options:NSCaseInsensitiveSearch];
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
        NSDictionary *chosenPlace = [self.topPlaces objectAtIndex:[self.tableView indexPathForCell:sender].row];
        [segue.destinationViewController setPhotos:[FlickrFetcher photosInPlace:chosenPlace maxResults:50]];
        [segue.destinationViewController setTitle:[[sender textLabel] text]];
    }
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.topPlaces count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Place Description"];
        
    NSString *placeDescription = [[self.topPlaces objectAtIndex:indexPath.row] valueForKey:FLICKR_PLACE_NAME];
    NSArray *placeComponents = [placeDescription componentsSeparatedByString:@", "];
    cell.textLabel.text = [placeComponents objectAtIndex:0];
    
    NSRange placeDetailesRange;
    placeDetailesRange.location = 1;
    placeDetailesRange.length = [placeComponents count] - 1;
    NSArray *placeDetailes = [placeComponents subarrayWithRange:placeDetailesRange];
    cell.detailTextLabel.text = [placeDetailes componentsJoinedByString:@", "];
    
    return cell;
}

@end
