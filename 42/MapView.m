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
    
    _leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _flagButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _mkMapView = [[MKMapView alloc] init];
    
    _sendToButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    _sendToPanel = [[UIView alloc] init];
    
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    _mkMapView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);

    _rightButton.frame = CGRectMake(self.frame.size.width - 40 - 30, self.frame.size.height - 40 - 20, 40.0, 40.0);
    _rightButton.backgroundColor = [UIColor redColor];
    _rightButton.adjustsImageWhenDisabled = YES;
    _rightButton.adjustsImageWhenHighlighted = YES;
    _rightButton.autoresizesSubviews = YES;
    _rightButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin;
    _rightButton.clearsContextBeforeDrawing = YES;
    _rightButton.clipsToBounds = NO;
    _rightButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    _rightButton.contentMode = UIViewContentModeScaleToFill;
    _rightButton.contentStretch = CGRectFromString(@"{{0, 0}, {1, 1}}");
    _rightButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _rightButton.enabled = YES;
    _rightButton.hidden = NO;
    _rightButton.highlighted = NO;
    _rightButton.multipleTouchEnabled = NO;
    _rightButton.opaque = NO;
    _rightButton.reversesTitleShadowWhenHighlighted = NO;
    _rightButton.selected = NO;
    _rightButton.showsTouchWhenHighlighted = NO;
    _rightButton.tag = 1;
    _rightButton.titleLabel.lineBreakMode = UILineBreakModeMiddleTruncation;
    _rightButton.titleLabel.shadowOffset = CGSizeMake(0.0, 0.0);
    _rightButton.userInteractionEnabled = YES;
    [_rightButton setTitle:@"R" forState:UIControlStateNormal];
    [_rightButton setTitleColor:[UIColor colorWithWhite:1.000 alpha:1.000] forState:UIControlStateHighlighted];
    [_rightButton setTitleShadowColor:[UIColor colorWithWhite:0.500 alpha:1.000] forState:UIControlStateNormal];
    
    
    _leftButton.frame = CGRectMake(30, self.frame.size.height - 40 - 20, 40.0, 40.0);
    _leftButton.adjustsImageWhenDisabled = YES;
    _leftButton.adjustsImageWhenHighlighted = YES;
    _leftButton.backgroundColor = [UIColor redColor];
    _leftButton.autoresizesSubviews = YES;
    _leftButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin;
    _leftButton.clearsContextBeforeDrawing = YES;
    _leftButton.clipsToBounds = NO;
    _leftButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    _leftButton.contentMode = UIViewContentModeScaleToFill;
    _leftButton.contentStretch = CGRectFromString(@"{{0, 0}, {1, 1}}");
    _leftButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _leftButton.enabled = YES;
    _leftButton.hidden = NO;
    _leftButton.highlighted = NO;
    _leftButton.multipleTouchEnabled = NO;
    _leftButton.opaque = NO;
    _leftButton.reversesTitleShadowWhenHighlighted = NO;
    _leftButton.selected = NO;
    _leftButton.showsTouchWhenHighlighted = NO;
    _leftButton.tag = 1;
    _leftButton.titleLabel.lineBreakMode = UILineBreakModeMiddleTruncation;
    _leftButton.titleLabel.shadowOffset = CGSizeMake(0.0, 0.0);
    _leftButton.userInteractionEnabled = YES;
    [_leftButton setTitle:@"L" forState:UIControlStateNormal];
    [_leftButton setTitleColor:[UIColor colorWithWhite:1.000 alpha:1.000] forState:UIControlStateHighlighted];
    [_leftButton setTitleShadowColor:[UIColor colorWithWhite:0.500 alpha:1.000] forState:UIControlStateNormal];
    
    
    
    _flagButton.frame = CGRectMake(self.frame.size.width/2 - 30, self.frame.size.height - 60 - 20, 60.0, 60.0);
    _flagButton.adjustsImageWhenDisabled = YES;
    _flagButton.adjustsImageWhenHighlighted = YES;
    _flagButton.alpha = 1.000;
    _flagButton.autoresizesSubviews = YES;
    _flagButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin;
    _flagButton.clearsContextBeforeDrawing = YES;
    _flagButton.clipsToBounds = NO;
    _flagButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    _flagButton.contentMode = UIViewContentModeScaleToFill;
    _flagButton.contentStretch = CGRectFromString(@"{{0, 0}, {1, 1}}");
    _flagButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _flagButton.enabled = YES;
    _flagButton.hidden = NO;
    _flagButton.highlighted = NO;
    _flagButton.tag = 1;
    _flagButton.titleLabel.lineBreakMode = UILineBreakModeMiddleTruncation;
    _flagButton.titleLabel.shadowOffset = CGSizeMake(0.0, 0.0);
    _flagButton.userInteractionEnabled = YES;
    _flagButton.backgroundColor = [UIColor redColor];
    
    [_flagButton setTitle:@"L" forState:UIControlStateNormal];
    [_flagButton setTitleColor:[UIColor colorWithWhite:1.000 alpha:1.000] forState:UIControlStateHighlighted];
    [_flagButton setTitleShadowColor:[UIColor colorWithWhite:0.500 alpha:1.000] forState:UIControlStateNormal];
    
    
    [self addSubview:_mkMapView];
    [self addSubview:_rightButton];
    [self addSubview:_leftButton];
    [self addSubview:_flagButton];
    
    
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
