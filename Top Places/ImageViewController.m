//
//  ImageViewController.m
//  Top Places
//
//  Created by Maxim Piskunov on 28.07.2012.
//  Copyright (c) 2012 Maxim Piskunov. All rights reserved.
//

#import "ImageViewController.h"

@interface ImageViewController () <UIScrollViewDelegate>

@end

@implementation ImageViewController

@synthesize imageURL = _imageURL;
@synthesize imageView = _imageView;
@synthesize scrollView = _scrollView;

- (void)reloadImage
{
    self.imageView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:self.imageURL]];
    self.scrollView.zoomScale = 1.;
    self.imageView.frame = CGRectMake(0, 0, self.imageView.image.size.width, self.imageView.image.size.height);
    self.scrollView.contentSize = self.imageView.bounds.size;
    
    [self viewWillLayoutSubviews];
    self.scrollView.zoomScale = self.scrollView.minimumZoomScale;
}

- (void)setImageURL:(NSURL *)imageURL
{
    if (imageURL != _imageURL) {
        _imageURL = imageURL;
        [self reloadImage];
    }
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
    self.scrollView.minimumZoomScale = MAX(self.scrollView.bounds.size.width / self.imageView.image.size.width, self.scrollView.bounds.size.height / self.imageView.image.size.height);
    if (self.scrollView.minimumZoomScale >= 1) self.scrollView.maximumZoomScale = self.scrollView.minimumZoomScale;
    else self.scrollView.maximumZoomScale = 1.;
    self.scrollView.zoomScale = MAX(self.scrollView.zoomScale, self.scrollView.minimumZoomScale);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.scrollView.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated
{
    if (!self.imageView.image) [self reloadImage];
}

- (void)viewDidUnload
{
    [self setImageView:nil];
    [self setScrollView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

#pragma mark UIScrollViewDelegate

- (UIView*)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

@end
