//
//  TopPlacesTableViewController.m
//  Top Places
//
//  Created by Maxim Piskunov on 28.07.2012.
//  Copyright (c) 2012 Maxim Piskunov. All rights reserved.
//

#import "TopPlacesTableViewController.h"
#import "FlickrFetcher.h"
#import "photosInPlaceTableViewController.h"

@interface TopPlacesTableViewController ()

@property (nonatomic, strong) NSArray* topPlaces;

@end

@implementation TopPlacesTableViewController

@synthesize topPlaces = _topPlaces;

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

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Show Photos In Place"]) {
        [segue.destinationViewController setPhotos:[FlickrFetcher photosInPlace:[self.topPlaces objectAtIndex:[self.tableView indexPathForCell:sender].row] maxResults:50]];
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
    
    NSString *placeDescription = [[self.topPlaces objectAtIndex:indexPath.row] valueForKey:@"_content"];
    NSArray *placeComponents = [placeDescription componentsSeparatedByString:@", "];
    cell.textLabel.text = [placeComponents objectAtIndex:0];
    
    NSRange placeDetailesRange;
    placeDetailesRange.location = 1;
    placeDetailesRange.length = [placeComponents count] - 1;
    NSArray *placeDetailes = [placeComponents subarrayWithRange:placeDetailesRange];
    cell.detailTextLabel.text = [placeDetailes componentsJoinedByString:@", "];
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

@end
