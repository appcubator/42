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
#define ANIMATION_TIME 0.25

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

    _mkMapView.frame = CGRectMake(0, 0, self.superview.frame.size.width, self.superview.frame.size.height);

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

    
    _flagButton.frame = CGRectMake(self.frame.size.width/2 - 20, self.frame.size.height - 60 - 10, 60.0, 60.0);
    _flagButton.alpha = 0.900;
    _flagButton.tag = 1;
    _flagButton.backgroundColor = [UIColor whiteColor];
    [_flagButton setTitle:@"C" forState:UIControlStateNormal];
    
    [self addSubview:_mkMapView];
    [self addSubview:_rightButton];
    [self addSubview:_leftButton];
    [self addSubview:_flagButton];
    [self addSubview:_cancelButton];
    
    
    _sendToPanel.backgroundColor = [UIColor colorWithRed:1.0 green:0.49 blue:0.27 alpha:1.00];
    _sendToPanel.frame = CGRectMake(0, self.superview.frame.size.height, self.superview.frame.size.height, 90);

    [_sendToButton setTitle:@"Send >>" forState:UIControlStateNormal];
    _sendToButton.frame = CGRectMake(0, 0, self.frame.size.width, 90);
    _sendToButton.backgroundColor = [UIColor clearColor];
    _sendToButton.tintColor = [UIColor whiteColor];
    [_sendToPanel addSubview:_sendToButton];

    [self addSubview:_sendToPanel];
}

- (void)showSendPanel {
    
    CGRect newRect = CGRectMake(0, self.superview.frame.size.height - _sendToPanel.frame.size.height, _sendToPanel.frame.size.width, _sendToPanel.frame.size.height);
    
    [UIView animateWithDuration:ANIMATION_TIME delay:0 options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         _sendToPanel.frame = newRect;
                     }
                     completion:^(BOOL finished) { }];

}

- (void)hideSendPanel {
    
    CGRect newRect = CGRectMake(0, self.superview.frame.size.height, _sendToPanel.frame.size.width, _sendToPanel.frame.size.height);
    
    [UIView animateWithDuration:ANIMATION_TIME delay:0 options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         _sendToPanel.frame = newRect;
                     }
                     completion:^(BOOL finished) { }];

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
