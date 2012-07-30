//
//  ImageViewController.m
//  Top Places
//
//  Created by Maxim Piskunov on 28.07.2012.
//  Copyright (c) 2012 Maxim Piskunov. All rights reserved.
//

#import "ImageViewController.h"

@interface ImageViewController () <UIScrollViewDelegate, UISplitViewControllerDelegate>

@end

@implementation ImageViewController

@synthesize imageURL = _imageURL;
@synthesize imageView = _imageView;
@synthesize scrollView = _scrollView;
@synthesize toolbar = _toolbar;
@synthesize titleBarButtonItem = _titleBarButtonItem;
@synthesize splitViewBarButtonItem = _splitViewBarButtonItem;
@synthesize splitViewPopoverController = _splitViewPopoverController;

- (void)reloadImage
{
    self.imageView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:self.imageURL]];
}

- (void)setImageURL:(NSURL *)imageURL
{
    if (imageURL != _imageURL) {
        _imageURL = imageURL;
        self.imageView.image = nil;
        [self viewWillLayoutSubviews];
    }
}

- (void)setTitle:(NSString *)title
{
    [super setTitle:title];
    self.titleBarButtonItem.title = title;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillLayoutSubviews
{
    if (!self.imageURL) return;
    CGFloat initialScale = self.scrollView.zoomScale;
    if (!self.imageView.image) {
        [self reloadImage];
        initialScale = 0.;
    }
    
    self.scrollView.minimumZoomScale = 1.;
    self.scrollView.maximumZoomScale = 1.;
    self.scrollView.zoomScale = 1.;
    self.imageView.frame = CGRectMake(0, 0, self.imageView.image.size.width, self.imageView.image.size.height);
    self.scrollView.contentSize = self.imageView.bounds.size;
    
    CGFloat fullPhotoScale = MIN(self.scrollView.bounds.size.width / self.imageView.image.size.width, self.scrollView.bounds.size.height / self.imageView.image.size.height);
    CGFloat noExtraSpaceScale = MAX(self.scrollView.bounds.size.width / self.imageView.image.size.width, self.scrollView.bounds.size.height / self.imageView.image.size.height);
    
    self.scrollView.minimumZoomScale = fullPhotoScale;
    self.scrollView.maximumZoomScale = MAX(1., noExtraSpaceScale);
    if (!initialScale) self.scrollView.zoomScale = noExtraSpaceScale;
    else self.scrollView.zoomScale = MIN(MAX(self.scrollView.minimumZoomScale, initialScale),self.scrollView.maximumZoomScale);
    
    self.titleBarButtonItem.title = self.title;
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
