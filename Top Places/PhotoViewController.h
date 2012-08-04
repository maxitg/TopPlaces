//
//  ImageViewController.h
//  Top Places
//
//  Created by Maxim Piskunov on 28.07.2012.
//  Copyright (c) 2012 Maxim Piskunov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhotoViewController : UIViewController

@property (nonatomic, strong) UIImage *photo;   //  model

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *titleBarButtonItem;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *splitViewBarButtonItem;

@property (nonatomic, weak) UIPopoverController *splitViewPopoverController;

@property (nonatomic, strong) UIActivityIndicatorView *spinner;

@end
