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
@synthesize splitViewBarButtonItem = _splitViewBarButtonItem;

@synthesize splitViewPopoverController = _splitViewPopoverController;

#pragma mark - Setters & getters

- (void)setPhoto:(UIImage *)photo
{
    if (photo != _photo) {
        _photo = photo;
        self.imageView.image = photo;
        [self viewWillLayoutSubviews];
    }
}

#pragma mark - Lifecycle

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (!self.imageView.image) self.imageView.image = self.photo;
}

- (void)viewWillLayoutSubviews
{
    self.loadingView.center = self.view.center;
    
    [super viewWillLayoutSubviews];
    
    if (!self.photo) return;
    
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
    [self setSplitViewBarButtonItem:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

#pragma mark UIScrollViewDelegate

- (UIView*)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

#pragma mark UISplitViewControllerDelegate

- (void)splitViewController:(UISplitViewController *)svc willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)pc
{
    barButtonItem.title = @"Top Places";
    self.navigationItem.leftBarButtonItem = barButtonItem;
    self.splitViewPopoverController = pc;
}

- (void)splitViewController:(UISplitViewController *)svc willShowViewController:(UIViewController *)aViewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    self.navigationItem.leftBarButtonItem = nil;
    self.splitViewPopoverController = nil;
}

@end
