//
//  PlaceTopPhotosTableViewController.m
//  Top Places
//
//  Created by Maxim Piskunov on 28.07.2012.
//  Copyright (c) 2012 Maxim Piskunov. All rights reserved.
//

#import "PhotoListTableViewController.h"
#import "PhotoViewController.h"
#import "FlickrFetcher.h"

@interface PhotoListTableViewController ()

@end

@implementation PhotoListTableViewController

@synthesize photos = _photos;

#pragma mark - Setters & getters

- (void)setPhotos:(NSArray *)photos
{
    if (photos != _photos) {
        _photos = photos;
        [self.tableView reloadData];
    }
}

#pragma mark - Lifecycle

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return ([[UIDevice currentDevice] userInterfaceIdiom] != UIUserInterfaceIdiomPhone || interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

#pragma mark - Segues

- (void)setUpPhotoViewController:(PhotoViewController*)photoViewController forSelectedCell:(UITableViewCell *)cell
{
    NSDictionary *selectedPhotoDescription = [self.photos objectAtIndex:[self.tableView indexPathForCell:cell].row];
    
    dispatch_queue_t photoDownloadQueue = dispatch_queue_create("photo downloader", NULL);
    dispatch_async(photoDownloadQueue, ^{
        NSURL *photoURL = [FlickrFetcher urlForPhoto:selectedPhotoDescription format:FlickrPhotoFormatLarge];
        NSData *photoData = [NSData dataWithContentsOfURL:photoURL];
        UIImage *photo = [UIImage imageWithData:photoData];
    
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([cell isSelected]) {    //  otherwise we don't need that image anymore
                [photoViewController setPhoto:photo];
                
                NSUserDefaults *userDefaults = [[NSUserDefaults alloc] init];
                NSMutableArray *recentPhotos = [[userDefaults valueForKey:DEFAULTS_RECENT] mutableCopy] ? : [[NSMutableArray alloc] init];
                
                BOOL photoIsNew = YES;
                NSDictionary *oldPhoto;
                for (NSDictionary *photoDescription in recentPhotos) {
                    if ([[photoDescription objectForKey:FLICKR_PHOTO_ID] isEqual:[selectedPhotoDescription objectForKey:FLICKR_PHOTO_ID]]) {
                        photoIsNew = NO;
                        oldPhoto = photoDescription;
                    }
                }
                
                if (photoIsNew) {
                    [recentPhotos insertObject:selectedPhotoDescription atIndex:0];
                    if ([recentPhotos count] > 20) [recentPhotos removeLastObject];
                } else {
                    [recentPhotos removeObject:oldPhoto];
                    [recentPhotos insertObject:selectedPhotoDescription atIndex:0];
                }
                
                [userDefaults setValue:[recentPhotos copy] forKey:DEFAULTS_RECENT];
                [userDefaults synchronize];
            }
        });
        
    });
    
    [photoViewController setTitle:[[cell textLabel] text]];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    //  Only for iPhone
    
    if ([segue.identifier isEqualToString:@"Show Photo"]) {
        [self setUpPhotoViewController:segue.destinationViewController forSelectedCell:sender];
    }
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.photos count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Photo Description"];
    
    cell.textLabel.text = [[self.photos objectAtIndex:indexPath.row] objectForKey:FLICKR_PHOTO_TITLE];
    cell.detailTextLabel.text = [[self.photos objectAtIndex:indexPath.row] valueForKeyPath:FLICKR_PHOTO_DESCRIPTION];
    
        //  If no title
    
    if ([cell.textLabel.text isEqualToString:@""]) {
        cell.textLabel.text = cell.detailTextLabel.text;
        cell.detailTextLabel.text = @"";
    }
    
        //  If no description
    
    if ([cell.textLabel.text isEqualToString:@""]) {
        cell.textLabel.text = @"Unknown";
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //  Only for iPad
    
    [self setUpPhotoViewController:[self.splitViewController.viewControllers objectAtIndex:1] forSelectedCell:[self.tableView cellForRowAtIndexPath:indexPath]];
    [[[self.splitViewController.viewControllers objectAtIndex:1] splitViewPopoverController] dismissPopoverAnimated:YES];
}

@end
