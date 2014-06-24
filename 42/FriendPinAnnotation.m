//
//  FriendPinAnnotation.m
//  42
//
//  Created by Ilter Canberk on 5/25/14.
//  Copyright (c) 2014 Appcubator. All rights reserved.
//

#import "FriendPinAnnotation.h"

@implementation FriendPinAnnotation

- (id)initWithCoordinate:(CLLocationCoordinate2D)coord name:(NSString *)name u_id:(NSString *)u_id when:(NSDate *)time message:(NSString *)message
{
    self = [super init];
    if(self) {
        _coordinate = coord;
        _name = name;
        _ID = u_id;
        _when = time;
        _message = message;
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
    return [self initWithCoordinate:CLLocationCoordinate2DMake(0, 0) name:@"Unknown" u_id:0 when:[NSDate date] message:@""];
}

- (void)updateLocation:(CLLocation *)loc {
    _coordinate = loc.coordinate;
}

- (void)updateTime:(NSDate *)time {
    _when = time;
}

- (NSString *)title {
    if (_message) {
        return _message;
    }
    else {
        return _name;
    }
}

- (NSString *)subtitle {

    NSDate *now = [NSDate date];
    NSTimeInterval interval = [now timeIntervalSinceDate:_when];
    double rawHours = interval / (60 * 60);
    double hours = floor(rawHours);
    double minutes = round((rawHours - hours) * 60);
    
    
    if (_message) {
        return [NSString stringWithFormat:@"%@ - %.0fm ago", _name, minutes];

    }
    else {
        return [NSString stringWithFormat:@"%.0fm ago", minutes];
    }
    
}


@end
