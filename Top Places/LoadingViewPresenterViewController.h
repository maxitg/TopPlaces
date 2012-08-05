//
//  LoadingViewPresenterViewController.h
//  Top Places
//
//  Created by Maxim Piskunov on 05.08.2012.
//  Copyright (c) 2012 Maxim Piskunov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoadingViewPresenterViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIView *loadingView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UILabel *loadingLabel;

@property (nonatomic) BOOL isLoading;

@end
