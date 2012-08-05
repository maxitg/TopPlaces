//
//  PlaceAnnotation.m
//  Top Places
//
//  Created by Maxim Piskunov on 05.08.2012.
//  Copyright (c) 2012 Maxim Piskunov. All rights reserved.
//

#import "PlaceAnnotation.h"
#import "FlickrFetcher.h"

@implementation PlaceAnnotation

@synthesize place = _place;

+ (PlaceAnnotation *)annotationForPlace:(NSDictionary *)place
{
    PlaceAnnotation *annotation = [[PlaceAnnotation alloc] init];
    annotation.place = place;
    return annotation;
}

#pragma mark - MKAnnotation

- (NSString *)title
{
    return [[[self.place objectForKey:FLICKR_PLACE_NAME] componentsSeparatedByString:@", "] objectAtIndex:0];
}

- (NSString *)subtitle
{
    NSArray *placeComponents = [[self.place objectForKey:FLICKR_PLACE_NAME] componentsSeparatedByString:@", "];
    return [[placeComponents subarrayWithRange:NSRangeFromString([NSString stringWithFormat:@"1 %d", [placeComponents count] - 1])] componentsJoinedByString:@", "];
}

- (CLLocationCoordinate2D)coordinate
{
    CLLocationCoordinate2D coordinate;
    coordinate.latitude = [[self.place objectForKey:FLICKR_LATITUDE] doubleValue];
    coordinate.longitude = [[self.place objectForKey:FLICKR_LONGITUDE] doubleValue];
    return coordinate;
}

@end
