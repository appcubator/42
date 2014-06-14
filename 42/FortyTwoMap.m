//
//  FortyTwoMap.m
//  42
//
//  Created by Ilter Canberk on 6/13/14.
//  Copyright (c) 2014 Appcubator. All rights reserved.
//

#import "FortyTwoMap.h"
#import "ComposeCalloutView.h"

@implementation FortyTwoMap

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView *view = [super hitTest:point withEvent:event];
    
    if ([view isKindOfClass:ComposeCalloutView.class]) {
        return nil; // todo: add a new delegate method to the map protocol to handle callout taps
    } else {
        return view;
    }
}

@end
