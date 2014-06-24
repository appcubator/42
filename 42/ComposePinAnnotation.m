//
//  ComposePinAnnotation.m
//  42
//
//  Created by Ilter Canberk on 6/10/14.
//  Copyright (c) 2014 Appcubator. All rights reserved.
//

#import "ComposePinAnnotation.h"

@implementation ComposePinAnnotation

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        // Initialization code
        _title = @"H";
        
        _calloutView = (ComposeCalloutView *)[[[NSBundle mainBundle] loadNibNamed:@"CalloutView" owner:self options:nil] objectAtIndex:0];
        _showCustomCallout = NO;
        CGRect calloutViewFrame = _calloutView.frame;
        
        calloutViewFrame.origin = CGPointMake(-_calloutView.frame.size.width / 2 - 8, -_calloutView.frame.size.height - 18);
        _calloutView.frame = calloutViewFrame;
        
        MKPinAnnotationView *pinView = [[MKPinAnnotationView alloc] initWithAnnotation:self.annotation reuseIdentifier:@"compose-pin"];

        [self addSubview:pinView];
        self.canShowCallout = NO;

    }
    return self;
}

- (id)initWithMapView:(FortyTwoMap *)mapView {
    self.mapView = mapView;
    self = [super init];
    return  self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/
- (void)setShowCustomCallout:(BOOL)showCustomCallout
{
    [self setShowCustomCallout:showCustomCallout animated:NO];
}

- (void)setShowCustomCallout:(BOOL)showCustomCallout animated:(BOOL)animated
{
    if (_showCustomCallout == showCustomCallout) return;
    
    _showCustomCallout = showCustomCallout;
    
    void (^animationBlock)(void) = nil;
    void (^completionBlock)(BOOL finished) = nil;
    
    if (_showCustomCallout) {
        self.calloutView.alpha = 0.0f;
        
        animationBlock = ^{
            self.calloutView.alpha = 1.0f;
            [self addSubview:self.calloutView];
            [self bringSubviewToFront:self.calloutView];
        };
        
    } else {
        animationBlock = ^{ self.calloutView.alpha = 0.0f; };
        completionBlock = ^(BOOL finished) { [self.calloutView removeFromSuperview]; };
    }
    
    if (animated) {
        [UIView animateWithDuration:0.2f animations:animationBlock completion:completionBlock];
        
    } else {
        animationBlock();
        completionBlock(YES);
    }
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    if (self.showCustomCallout && CGRectContainsPoint(self.calloutView.frame, point)) {
        [_calloutView.textField becomeFirstResponder];
        return self.calloutView;
        
    } else {
        [_calloutView.textField  resignFirstResponder];
        return nil;
    }
}

- (void)updateLocation:(CLLocation *)loc {
    _coordinate = loc.coordinate;
}

- (void)updateCoordinate:(CLLocationCoordinate2D)coor {
    _coordinate = coor;
}


@end
