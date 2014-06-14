//
//  ComposePinAnnotation.h
//  42
//
//  Created by Ilter Canberk on 6/10/14.
//  Copyright (c) 2014 Appcubator. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "ComposeCalloutView.h"

@interface ComposePinAnnotation : MKPinAnnotationView

@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) ComposeCalloutView *calloutView;
@property (nonatomic) BOOL showCustomCallout;
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;

- (void)setShowCustomCallout:(BOOL)showCustomCallout animated:(BOOL)animated;
- (void)updateLocation:(CLLocation *)loc;
- (void)updateCoordinate:(CLLocationCoordinate2D)coor;

@end
