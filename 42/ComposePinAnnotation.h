//
//  ComposePinAnnotation.h
//  42
//
//  Created by Ilter Canberk on 6/10/14.
//  Copyright (c) 2014 Appcubator. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "ComposeCalloutView.h"
#import "FortyTwoMap.h"

@interface ComposePinAnnotation : MKPinAnnotationView <MKAnnotation>

@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) FortyTwoMap *mapView;
@property (nonatomic, strong) ComposeCalloutView *calloutView;
@property (nonatomic) BOOL showCustomCallout;
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
//@property (nonatomic, strong) MKAnnotationView *view;

- (id)initWithMapView:(FortyTwoMap *)mapView;
- (void)setShowCustomCallout:(BOOL)showCustomCallout animated:(BOOL)animated;
- (void)updateLocation:(CLLocation *)loc;
- (void)updateCoordinate:(CLLocationCoordinate2D)coor;

@end
