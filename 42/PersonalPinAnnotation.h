//
//  PersonalPinAnnotation.h
//  42
//
//  Created by Ilter Canberk on 5/22/14.
//  Copyright (c) 2014 Appcubator. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface PersonalPinAnnotation : MKPinAnnotationView <MKAnnotation>

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) NSString *title;

// add an init method so you can set the coordinate property on startup
- (id)initWithCoordinate:(CLLocationCoordinate2D)coord;
- (id)initWithLocation:(CLLocation *)location;
- (void)updateLocation:(CLLocation *)loc;
- (void)updateCoordinate:(CLLocationCoordinate2D)coor;

@end
