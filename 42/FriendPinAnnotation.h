//
//  FriendPinAnnotation.h
//  42
//
//  Created by Ilter Canberk on 5/25/14.
//  Copyright (c) 2014 Appcubator. All rights reserved.
//

#import <MapKit/MapKit.h>
#import <Parse/Parse.h>

@interface FriendPinAnnotation : MKPinAnnotationView <MKAnnotation>

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) NSString *title;
@property (assign) NSString* ID;
@property (nonatomic, retain) NSDate *when;
@property (nonatomic, strong) NSString *message;
@property (nonatomic, strong) NSString *name;

// add an init method so you can set the coordinate property on startup
- (id)initWithCoordinate:(CLLocationCoordinate2D)coord name:(NSString *)name u_id:(NSString *)u_id when:(NSDate *)time message:(NSString *)message;
- (id)initWithLocation:(CLLocation *)location;
- (void)updateLocation:(CLLocation *)loc;
- (void)updateTime:(NSDate *)time;


@end
