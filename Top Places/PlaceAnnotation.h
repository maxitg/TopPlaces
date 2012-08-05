//
//  PlaceAnnotation.h
//  Top Places
//
//  Created by Maxim Piskunov on 05.08.2012.
//  Copyright (c) 2012 Maxim Piskunov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface PlaceAnnotation : NSObject <MKAnnotation>

+ (PlaceAnnotation *)annotationForPlace:(NSDictionary *)place;

@property (nonatomic, strong) NSDictionary *place;

@end
