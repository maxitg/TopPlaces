//
//  LoadingViewPresenterViewController.m
//  Top Places
//
//  Created by Maxim Piskunov on 05.08.2012.
//  Copyright (c) 2012 Maxim Piskunov. All rights reserved.
//

#import "LoadingViewPresenterViewController.h"

@interface LoadingViewPresenterViewController ()

@end

@implementation LoadingViewPresenterViewController

@synthesize loadingView = _loadingView;
@synthesize activityIndicator = _activityIndicator;
@synthesize loadingLabel = _loadingLabel;

@synthesize isLoading = _isLoading;

- (void)setIsLoading:(BOOL)isLoading
{
    [self.loadingView setHidden:!isLoading];
    self.view.userInteractionEnabled = !isLoading;
    _isLoading = isLoading;
}

- (BOOL)isLoading
{
    return _isLoading;
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.loadingView setHidden:!self.isLoading];
}

- (void)viewWillLayoutSubviews
{
    CGSize totalSize;
    totalSize.width = self.activityIndicator.bounds.size.width + 8 + self.loadingLabel.bounds.size.width;
    totalSize.height = MAX(self.activityIndicator.bounds.size.height, self.loadingLabel.bounds.size.height);
    
    self.activityIndicator.frame = CGRectMake(self.loadingView.bounds.size.width/2 - totalSize.width/2, self.loadingView.bounds.size.height/2 - totalSize.height/2, self.activityIndicator.bounds.size.width, self.activityIndicator.bounds.size.height);
    self.loadingLabel.frame = CGRectMake(self.loadingView.bounds.size.width/2 - totalSize.width/2 + self.activityIndicator.bounds.size.width + 8, self.loadingView.bounds.size.height/2 - totalSize.height/2, self.loadingLabel.bounds.size.width, self.loadingLabel.bounds.size.height);
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return ([[UIDevice currentDevice] userInterfaceIdiom] != UIUserInterfaceIdiomPhone || interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (void)viewDidUnload {
    [self setLoadingView:nil];
    [super viewDidUnload];
}
@end
