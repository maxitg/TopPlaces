//
//  LoadingView.m
//  Top Places
//
//  Created by Maxim Piskunov on 03.08.2012.
//  Copyright (c) 2012 Maxim Piskunov. All rights reserved.
//

#import "LoadingView.h"

@implementation LoadingView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UIActivityIndicatorView *activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [activity startAnimating];
        
        UILabel *loadingLabel = [[UILabel alloc] init];
        loadingLabel.text = @"Loading...";
        [loadingLabel sizeToFit];
        
        CGFloat totalSize = activity.frame.size.width + 8 + loadingLabel.frame.size.width;
        activity.frame = CGRectMake(self.center.x - totalSize/2, self.center.y, activity.frame.size.width, activity.frame.size.height);
        loadingLabel.frame = CGRectMake(self.center.x - totalSize/2 + activity.frame.size.width + 4, self.center.y, loadingLabel.frame.size.width, loadingLabel.frame.size.height);
        
        [self addSubview:loadingLabel];
        [self addSubview:activity];
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

@end
