//
//  ImageViewController.m
//  Top Places
//
//  Created by Maxim Piskunov on 28.07.2012.
//  Copyright (c) 2012 Maxim Piskunov. All rights reserved.
//

#import "PhotoViewController.h"

@interface PhotoViewController () <UIScrollViewDelegate, UISplitViewControllerDelegate>

@end

@implementation PhotoViewController

@synthesize photo = _photo;

@synthesize imageView = _imageView;
@synthesize scrollView = _scrollView;
@synthesize toolbar = _toolbar;
@synthesize titleBarButtonItem = _titleBarButtonItem;
@synthesize splitViewBarButtonItem = _splitViewBarButtonItem;

@synthesize splitViewPopoverController = _splitViewPopoverController;

#pragma mark - Setters & getters

- (void)setTitle:(NSString *)title
{
    [super setTitle:title];
    self.titleBarButtonItem.title = title;
}

#define DEFAULTS_RECENT @"Recent Photos"

- (void)setPhoto:(UIImage *)photo
{
    if (photo != _photo) {
        _photo = photo;
        self.imageView.image = photo;
        [self viewWillLayoutSubviews];
        
        NSUserDefaults *userDefaults = [[NSUserDefaults alloc] init];
        NSMutableArray *recentPhotos = [[userDefaults valueForKey:DEFAULTS_RECENT] mutableCopy];
        [recentPhotos insertObject:recentPhotos atIndex:0];
        if ([recentPhotos count] > 20) [recentPhotos removeLastObject];
        [userDefaults synchronize];
    }
}

#pragma mark - Lifecycle

- (void)viewWillLayoutSubviews
{
    if (!self.photo) return;
    else if (!self.imageView.image) self.imageView.image = self.photo;
    self.scrollView.minimumZoomScale = 1.;
    self.scrollView.maximumZoomScale = 1.;
    self.scrollView.zoomScale = 1.;
    self.imageView.frame = CGRectMake(0, 0, self.photo.size.width, self.photo.size.height);
    self.scrollView.contentSize = self.imageView.bounds.size;
    
    CGFloat fullPhotoScale = MIN(self.scrollView.bounds.size.width / self.photo.size.width, self.scrollView.bounds.size.height / self.photo.size.height);
    CGFloat noExtraSpaceScale = MAX(self.scrollView.bounds.size.width / self.photo.size.width, self.scrollView.bounds.size.height / self.photo.size.height);
    
    self.scrollView.minimumZoomScale = fullPhotoScale;
    self.scrollView.maximumZoomScale = MAX(1., noExtraSpaceScale);
    self.scrollView.zoomScale = noExtraSpaceScale;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.scrollView.delegate = self;
    self.splitViewController.delegate = self;
}

- (void)viewDidUnload
{
    [self setImageView:nil];
    [self setScrollView:nil];
    [self setToolbar:nil];
    [self setTitleBarButtonItem:nil];
    [self setSplitViewBarButtonItem:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return ([[UIDevice currentDevice] userInterfaceIdiom] != UIUserInterfaceIdiomPhone || interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

#pragma mark UIScrollViewDelegate

- (UIView*)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

#pragma mark UISplitViewControllerDelegate

- (void)splitViewController:(UISplitViewController *)svc willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)pc
{
    NSMutableArray *toolbarButtons = [[self.toolbar items] mutableCopy];
    barButtonItem.title = @"Top Places";
    [toolbarButtons insertObject:barButtonItem atIndex:0];
    self.toolbar.items = [toolbarButtons copy];
    self.splitViewPopoverController = pc;
}

- (void)splitViewController:(UISplitViewController *)svc willShowViewController:(UIViewController *)aViewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    NSMutableArray *toolbarButtons = [[self.toolbar items] mutableCopy];
    [toolbarButtons removeObject:barButtonItem];
    self.toolbar.items = [toolbarButtons copy];
    self.splitViewPopoverController = nil;
}

@end
