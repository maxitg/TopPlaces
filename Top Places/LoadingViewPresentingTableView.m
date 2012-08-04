//
//  LoadingViewPresenter.m
//  Top Places
//
//  Created by Maxim Piskunov on 04.08.2012.
//  Copyright (c) 2012 Maxim Piskunov. All rights reserved.
//

#import "LoadingViewPresentingTableView.h"
#import "LoadingView.h"

@interface LoadingViewPresentingTableView ()

@property (nonatomic, strong) LoadingView *loadingView;

@end

@implementation LoadingViewPresentingTableView

@synthesize loadingView = _loadingView;

- (void)setIsLoading:(BOOL)isLoading
{
    if (isLoading != _isLoading) {
        isLoading ? [self startLoadingIndicator] : [self stopLoadingIndicator];
        _isLoading = isLoading;
    }
}

- (void)startLoadingIndicator
{
    self.loadingView = [[LoadingView alloc] initWithFrame:self.tableView.frame];
    self.tableView.userInteractionEnabled = NO;
    [self.tableView addSubview:self.loadingView];
}

- (void)stopLoadingIndicator
{
    [self.loadingView removeFromSuperview];
    self.tableView.userInteractionEnabled = YES;
    self.loadingView = nil;
}

@end
