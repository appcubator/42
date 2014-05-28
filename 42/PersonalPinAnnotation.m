//
//  PersonalPinAnnotation.m
//  42
//
//  Created by Ilter Canberk on 5/22/14.
//  Copyright (c) 2014 Appcubator. All rights reserved.
//

#import "PersonalPinAnnotation.h"

@implementation PersonalPinAnnotation

- (id)initWithCoordinate:(CLLocationCoordinate2D)coord
{
    self = [super init];
    if(self) {
        _coordinate = coord;
        [self setTitle:@"ME"];
    }
    
    return self;
}

- (id)initWithLocation:(CLLocation *)location
{
    self = [super init];
    if(self) {
        _coordinate = location.coordinate;
        [self setTitle:@"ME"];
    }
    
    return self;
}

- (id)init {
    return [self initWithCoordinate:CLLocationCoordinate2DMake(39.281516, -76.580806)];
}

- (void)updateLocation:(CLLocation *)loc {
    _coordinate = loc.coordinate;
}

- (void)updateCoordinate:(CLLocationCoordinate2D)coor {
    _coordinate = coor;
}


@end
