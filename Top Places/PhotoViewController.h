//
//  ImageViewController.h
//  Top Places
//
//  Created by Maxim Piskunov on 28.07.2012.
//  Copyright (c) 2012 Maxim Piskunov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoadingViewPresenterViewController.h"

@interface PhotoViewController : LoadingViewPresenterViewController

@property (nonatomic, strong) UIImage *photo;
@property (nonatomic, strong) NSString *presentedPhotoID;

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *splitViewBarButtonItem;

@property (nonatomic, weak) UIPopoverController *splitViewPopoverController;

@end
