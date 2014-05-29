//
//  MapView.m
//  42
//
//  Created by Ilter Canberk on 5/22/14.
//  Copyright (c) 2014 Appcubator. All rights reserved.
//

#import "MapView.h"
#import <UIKit/UIKit.h>
#import <MapKit/Mapkit.h>

@implementation MapView

- (id)init
{
    self = [super initWithFrame:CGRectMake(0,
                                           0,
                                           [[UIScreen mainScreen] applicationFrame].size.width,
                                           [[UIScreen mainScreen] applicationFrame].size.height)];
    if (self) {
        // Initialization code
    }
    
    _leftButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    _rightButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    _flagButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    _cancelButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    _mkMapView = [[MKMapView alloc] init];
    
    _sendToButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    _sendToPanel = [[UIView alloc] init];
    
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    _mkMapView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);

    _rightButton.frame = CGRectMake(self.frame.size.width - 40 - 30, self.frame.size.height - 40 - 20, 40.0, 40.0);
    _rightButton.backgroundColor = [UIColor whiteColor];
    _rightButton.tag = 1;
    [_rightButton setTitle:@"R" forState:UIControlStateNormal];


    _leftButton.frame = CGRectMake(30, self.frame.size.height - 40 - 20, 40.0, 40.0);
    _leftButton.backgroundColor = [UIColor whiteColor];
    _leftButton.tag = 1;
    [_leftButton setTitle:@"L" forState:UIControlStateNormal];


    _cancelButton.frame = CGRectMake(30, 40 - 20, 40.0, 40.0);
    _cancelButton.tag = 1;
    _cancelButton.hidden = YES;
    [_cancelButton setTitle:@"x" forState:UIControlStateNormal];

    
    _flagButton.frame = CGRectMake(self.frame.size.width/2 - 30, self.frame.size.height - 60 - 20, 60.0, 60.0);
    _flagButton.alpha = 0.900;
    _flagButton.tag = 1;
    _flagButton.backgroundColor = [UIColor whiteColor];
    [_flagButton setTitle:@"C" forState:UIControlStateNormal];
    
    [self addSubview:_mkMapView];
    [self addSubview:_rightButton];
    [self addSubview:_leftButton];
    [self addSubview:_flagButton];
    [self addSubview:_cancelButton];
    
    
    _sendToPanel.backgroundColor = [UIColor purpleColor];
    _sendToPanel.frame = CGRectMake(0, self.frame.size.height, self.frame.size.width, 90);

    [_sendToButton setTitle:@"Send" forState:UIControlStateNormal];
    _sendToButton.frame = CGRectMake(0, 0, self.frame.size.width, 90);
    _sendToButton.backgroundColor = [UIColor yellowColor];
    [_sendToPanel addSubview:_sendToButton];

    [self addSubview:_sendToPanel];
    
    self.autoresizesSubviews = YES;
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.backgroundColor = [UIColor colorWithWhite:0.333 alpha:1.000];
    self.clearsContextBeforeDrawing = YES;
    self.clipsToBounds = NO;
    self.contentMode = UIViewContentModeScaleToFill;
    self.contentStretch = CGRectFromString(@"{{0, 0}, {1, 1}}");
    self.hidden = NO;
    self.multipleTouchEnabled = NO;
    self.opaque = YES;
    self.tag = 0;
    self.userInteractionEnabled = YES;
    
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
