//
//  FriendPinAnnotation.m
//  42
//
//  Created by Ilter Canberk on 5/25/14.
//  Copyright (c) 2014 Appcubator. All rights reserved.
//

#import "FriendPinAnnotation.h"

@implementation FriendPinAnnotation

- (id)initWithCoordinate:(CLLocationCoordinate2D)coord name:(NSString *)name u_id:(NSString *)u_id when:(NSDate *)time
{
    self = [super init];
    if(self) {
        _coordinate = coord;
        [self setTitle:name];
        _ID = u_id;
        _when = time;
    }
    
    return self;
}

- (id)initWithLocation:(CLLocation *)location
{
    self = [super init];
    if(self) {
        _coordinate = location.coordinate;
        [self setTitle:@"FRIEND"];
    }
    
    return self;
}

- (id)init {
    return [self initWithCoordinate:CLLocationCoordinate2DMake(0, 0) name:@"Unknown" u_id:0 when:[NSDate date]];
}

- (void)updateLocation:(CLLocation *)loc {
    _coordinate = loc.coordinate;
}

- (void)updateTime:(NSDate *)time {
    _when = time;
}

- (NSString *)subtitle {

    NSDate *now = [NSDate date];
    NSTimeInterval interval = [now timeIntervalSinceDate:_when];
    double rawHours = interval / (60 * 60);
    double hours = floor(rawHours);
    double minutes = round((rawHours - hours) * 60);
    
    return [NSString stringWithFormat:@"%.0fh %.0fm ago", hours, minutes];
}


@end
