//
//  PlaceAnnotation.m
//  Top Places
//
//  Created by Maxim Piskunov on 05.08.2012.
//  Copyright (c) 2012 Maxim Piskunov. All rights reserved.
//

#import "Annotation.h"
#import "FlickrFetcher.h"

@implementation Annotation

@synthesize title = _title;
@synthesize subtitle = _subtitle;
@synthesize coordinate = _coordinate;

+ (Annotation *)annotationWithTitle:(NSString *)title subtitle:(NSString *)subtitle coordinate:(CLLocationCoordinate2D)coordinate
{
    Annotation *annotation = [[Annotation alloc] init];
    annotation.title = title;
    annotation.subtitle = subtitle;
    annotation.coordinate = coordinate;
    return annotation;
}

@end
