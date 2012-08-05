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
#import "Annotation.h"

#define MAX_CACHE_SIZE 10485760

@interface PhotoListViewController () <UITableViewDataSource, UITableViewDelegate, MKMapViewDelegate>

@end

@implementation PhotoListViewController

@synthesize photos = _photos;

#pragma mark - Photo information helpers

- (NSString *)titleForPhoto:(NSDictionary *)photo
{
    NSString *title = [photo objectForKey:FLICKR_PHOTO_TITLE];
    if ([title isEqualToString:@""]) {
        title = [photo valueForKeyPath:FLICKR_PHOTO_DESCRIPTION];
    }
    if ([title isEqualToString:@""]) {
        title = @"Unknown";
    }
    return title;
}

- (NSString *)subtitleForPhoto:(NSDictionary *)photo
{
    NSString *subtitle = [photo valueForKeyPath:FLICKR_PHOTO_DESCRIPTION];
    if ([[photo objectForKey:FLICKR_PHOTO_TITLE] isEqualToString:@""]) {
        subtitle = @"";
    }
    return subtitle;
}

- (CLLocationCoordinate2D)coordinateForPhoto:(NSDictionary *)photo
{
    CLLocationCoordinate2D coordinate;
    coordinate.longitude = [[photo objectForKey:FLICKR_LONGITUDE] doubleValue];
    coordinate.latitude = [[photo objectForKey:FLICKR_LATITUDE] doubleValue];
    return coordinate;
}

- (UIImage *)thumbnailForPhoto:(NSDictionary *)photo
{
    NSURL *thumbnailURL = [FlickrFetcher urlForPhoto:photo format:FlickrPhotoFormatSquare];
    NSLog(@"Queuering %@", thumbnailURL);
    NSData *thumbnailData = [NSData dataWithContentsOfURL:thumbnailURL];
    return [UIImage imageWithData:thumbnailData];
}

#pragma mark - Setters & getters

- (void)setPhotos:(NSArray *)photos
{
    if (photos != _photos) {
        _photos = photos;
        [self.tableView reloadData];
        
        [self.mapView removeAnnotations:self.mapView.annotations];
        NSMutableArray *annotations = [[NSMutableArray alloc] init];
        for (NSDictionary *photo in self.photos) {
            [annotations addObject:[Annotation annotationWithTitle:[self titleForPhoto:photo] subtitle:[self subtitleForPhoto:photo] coordinate:[self coordinateForPhoto:photo] forObject:photo]];
        }
        [self.mapView addAnnotations:annotations];
        [self updateMapRegion];
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
    self.mapView.delegate = self;
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

- (void)showPhoto:(NSDictionary *)aPhoto sender:(id)sender
{
    if (self.splitViewController) {
        PhotoViewController *photoViewController = [[[[self.splitViewController viewControllers] objectAtIndex:1] viewControllers] objectAtIndex:0];
        [self setUpPhotoViewController:photoViewController forPhoto:aPhoto];
    } else {
        [self performSegueWithIdentifier:@"Show Photo" sender:sender];
    }
}

- (void)setUpPhotoViewController:(PhotoViewController*)photoViewController forPhoto:(NSDictionary *)aPhoto
{
    photoViewController.isLoading = YES;
    photoViewController.presentedPhotoID = [aPhoto objectForKey:FLICKR_PHOTO_ID];
    photoViewController.title = [self titleForPhoto:aPhoto];
    
    dispatch_queue_t photoDownloadQueue = dispatch_queue_create("photo downloader", NULL);
    dispatch_async(photoDownloadQueue, ^{
        
        NSData *photoData = [self photoFromCache:aPhoto];
        
        if (!photoData) {
            NSURL *photoURL = [FlickrFetcher urlForPhoto:aPhoto format:FlickrPhotoFormatLarge];
            NSLog(@"Queuering %@", photoURL);
            photoData = [NSData dataWithContentsOfURL:photoURL];
            [self addPhotoToCache:aPhoto withData:photoData];
        }
        UIImage *photo = [UIImage imageWithData:photoData];
        photoData = nil;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([photoViewController.presentedPhotoID isEqualToString:[aPhoto objectForKey:FLICKR_PHOTO_ID]]) {
                [photoViewController setPhoto:photo];
                photoViewController.isLoading = NO;
                
                NSUserDefaults *userDefaults = [[NSUserDefaults alloc] init];
                NSMutableArray *recentPhotos = [[userDefaults valueForKey:DEFAULTS_RECENT] mutableCopy] ? : [[NSMutableArray alloc] init];
                
                BOOL photoIsNew = YES;
                NSDictionary *oldPhoto;
                for (NSDictionary *photoDescription in recentPhotos) {
                    if ([[photoDescription objectForKey:FLICKR_PHOTO_ID] isEqual:[aPhoto objectForKey:FLICKR_PHOTO_ID]]) {
                        photoIsNew = NO;
                        oldPhoto = photoDescription;
                    }
                }
                
                if (photoIsNew) {
                    [recentPhotos insertObject:aPhoto atIndex:0];
                    if ([recentPhotos count] > 20) [recentPhotos removeLastObject];
                } else {
                    [recentPhotos removeObject:oldPhoto];
                    [recentPhotos insertObject:aPhoto atIndex:0];
                }
                
                [userDefaults setValue:[recentPhotos copy] forKey:DEFAULTS_RECENT];
                [userDefaults synchronize];
            }
        });
        
    });
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    //  Only for iPhone
    
    if ([segue.identifier isEqualToString:@"Show Photo"]) {
        NSDictionary *selectedPhoto;
        if ([sender isKindOfClass:[UITableViewCell class]]) {
            selectedPhoto = [self.photos objectAtIndex:[self.tableView indexPathForCell:sender].row];
        } else if ([sender isKindOfClass:[MKAnnotationView class]]) {
            Annotation *annotation = [sender annotation];
            selectedPhoto = annotation.referenceObject;
        }
        
        [self setUpPhotoViewController:segue.destinationViewController forPhoto:selectedPhoto];
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
    
    NSDictionary *selectedPhoto = [self.photos objectAtIndex:indexPath.row];
    cell.textLabel.text = [self titleForPhoto:selectedPhoto];
    cell.detailTextLabel.text = [self subtitleForPhoto:selectedPhoto];
    
//    cell.imageView.image = [UIImage imageNamed:@"TopPlaces.png"];
    cell.imageView.image = nil;

    dispatch_queue_t thumbnailDownloadQueue = dispatch_queue_create("thumbnail downloader", NULL);
    dispatch_async(thumbnailDownloadQueue, ^{
        UIImage *thumbnail = [self thumbnailForPhoto:selectedPhoto];
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([[tableView indexPathForCell:cell] isEqual:indexPath]) {
                cell.imageView.image = thumbnail;
                [cell layoutSubviews];
            }
        });
    });
    dispatch_release(thumbnailDownloadQueue);
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{    
    [self showPhoto:[self.photos objectAtIndex:indexPath.row] sender:[tableView cellForRowAtIndexPath:indexPath]];
    
    //  Only for iPad
    PhotoViewController *photoViewController = (PhotoViewController *)[[[self.splitViewController.viewControllers objectAtIndex:1] viewControllers] objectAtIndex:0];
    [[photoViewController splitViewPopoverController] dismissPopoverAnimated:YES];
}

#pragma mark - MKMapViewDelegate

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    MKAnnotationView *aView = [mapView dequeueReusableAnnotationViewWithIdentifier:@"Photo Annotation"];
    if (!aView) {
        aView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"Photo Annotation"];
        aView.canShowCallout = YES;
        aView.leftCalloutAccessoryView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        aView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    }
    
    aView.annotation = annotation;
    [(UIImageView *)aView.leftCalloutAccessoryView setImage:nil];
    
    return aView;
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)aView
{
    Annotation *annotation = aView.annotation;
    NSDictionary *photo = annotation.referenceObject;
    
    dispatch_queue_t thumbnailDownloadQueue = dispatch_queue_create("thumbnail downloader", NULL);
    dispatch_async(thumbnailDownloadQueue, ^{
        UIImage *thumbnail = [self thumbnailForPhoto:photo];
        dispatch_async(dispatch_get_main_queue(), ^{
            [(UIImageView *)aView.leftCalloutAccessoryView setImage:thumbnail];
        });
    });
    dispatch_release(thumbnailDownloadQueue);
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    Annotation *annotation = view.annotation;
    [self showPhoto:annotation.referenceObject sender:view];
}

@end
