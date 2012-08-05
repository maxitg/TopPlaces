//
//  PhotoListViewController.m
//  Top Places
//
//  Created by Maxim Piskunov on 05.08.2012.
//  Copyright (c) 2012 Maxim Piskunov. All rights reserved.
//

#import "PhotoListViewController.h"
#import "PhotoViewController.h"
#import "FlickrFetcher.h"

#define MAX_CACHE_SIZE 10485760

@interface PhotoListViewController () <UITableViewDataSource, UITableViewDelegate>

@end

@implementation PhotoListViewController

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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    PhotoViewController *photoViewController = [[[self.splitViewController.viewControllers objectAtIndex:1] viewControllers] objectAtIndex:0];
    NSString *selectedPhotoID = [[self.photos objectAtIndex:self.tableView.indexPathForSelectedRow.row] objectForKey:FLICKR_PHOTO_ID];
    if (![photoViewController.presentedPhotoID isEqualToString:selectedPhotoID] || !self.splitViewController) {
        [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:animated];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //  Setting delegates
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

#pragma mark - Segues

- (NSURL *)photoCacheDirectoryURL
{
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    NSURL *cachesDirectoryURL = [[fileManager URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask] lastObject];
    cachesDirectoryURL = [cachesDirectoryURL URLByAppendingPathComponent:@"photos"];
    if (![fileManager fileExistsAtPath:[cachesDirectoryURL path]]) [fileManager createDirectoryAtPath:[cachesDirectoryURL path] withIntermediateDirectories:NO attributes:nil error:nil];
    return cachesDirectoryURL;
}

- (void)addPhotoToCache:(NSDictionary *) photoDescription withData:(NSData *) photoData
{
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    NSURL *cachesDirectoryURL = [self photoCacheDirectoryURL];
    
    NSURL *photoURL = [cachesDirectoryURL URLByAppendingPathComponent:[photoDescription objectForKey:FLICKR_PHOTO_ID]];
    [photoData writeToURL:photoURL atomically:YES];
    
    NSDirectoryEnumerator *cachesDirectoryEnumerator = [fileManager enumeratorAtPath:[cachesDirectoryURL path]];
    NSString *photoPath;
    
    NSMutableArray *cachesDirectoryContent = [[NSMutableArray alloc] init];
    
    int totalSize = 0;
    
    for (photoPath in cachesDirectoryEnumerator) {
        photoPath = [[cachesDirectoryURL URLByAppendingPathComponent:photoPath] path];
        NSDictionary *photoAttributes = [fileManager attributesOfItemAtPath:photoPath error:nil];
        NSNumber *photoSize = [photoAttributes objectForKey:NSFileSize];
        NSDate *photoDate = [photoAttributes objectForKey:NSFileModificationDate];
        
        [cachesDirectoryContent addObject:[NSDictionary dictionaryWithObjectsAndKeys:photoPath, @"Path", photoSize, @"Size", photoDate, @"Date", nil]];
        totalSize += [photoSize integerValue];
    }
    
    [cachesDirectoryContent sortUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"Date" ascending:NO]]];
    
    while (totalSize > MAX_CACHE_SIZE) {
        [fileManager removeItemAtPath:[[cachesDirectoryContent lastObject] objectForKey:@"Path"] error:nil];
        totalSize -= [[[cachesDirectoryContent lastObject] objectForKey:@"Size"] intValue];
        [cachesDirectoryContent removeLastObject];
    }
    
    NSLog(@"cache size is %gMB", (float)totalSize/1024/1024);
}

- (NSData *) photoFromCache:(NSDictionary *) photoDescription
{
    NSURL *cachesDirectoryURL = [self photoCacheDirectoryURL];
    NSURL *photoURL = [cachesDirectoryURL URLByAppendingPathComponent:[photoDescription objectForKey:FLICKR_PHOTO_ID]];
    NSData *photoData = [[NSData alloc] initWithContentsOfURL:photoURL];
    return photoData;
}

- (void)setUpPhotoViewController:(PhotoViewController*)photoViewController forSelectedCell:(UITableViewCell *)cell
{
    NSDictionary *selectedPhotoDescription = [self.photos objectAtIndex:[self.tableView indexPathForCell:cell].row];
    photoViewController.isLoading = YES;
    photoViewController.presentedPhotoID = [selectedPhotoDescription objectForKey:FLICKR_PHOTO_ID];
    photoViewController.title = cell.textLabel.text;
    
    dispatch_queue_t photoDownloadQueue = dispatch_queue_create("photo downloader", NULL);
    dispatch_async(photoDownloadQueue, ^{
        
        NSData *photoData = [self photoFromCache:selectedPhotoDescription];
        
        if (!photoData) {
            NSURL *photoURL = [FlickrFetcher urlForPhoto:selectedPhotoDescription format:FlickrPhotoFormatLarge];
            photoData = [NSData dataWithContentsOfURL:photoURL];
            [self addPhotoToCache:selectedPhotoDescription withData:photoData];
        }
        UIImage *photo = [UIImage imageWithData:photoData];
        photoData = nil;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([photoViewController.presentedPhotoID isEqualToString:[selectedPhotoDescription objectForKey:FLICKR_PHOTO_ID]]) {    //  caution. causes a bug in recent photos
                [photoViewController setPhoto:photo];
                photoViewController.isLoading = NO;
                
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
    
    if (self.splitViewController) {
        PhotoViewController *photoViewController = (PhotoViewController *)[[[self.splitViewController.viewControllers objectAtIndex:1] viewControllers] objectAtIndex:0];
        [self setUpPhotoViewController:photoViewController forSelectedCell:[self.tableView cellForRowAtIndexPath:indexPath]];
        [[photoViewController splitViewPopoverController] dismissPopoverAnimated:YES];
    }
}

@end
