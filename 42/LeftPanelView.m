//
//  LeftPanelView.m
//  Navigation
//
//  Created by Ilter Canberk on 5/16/14.
//  Copyright (c) 2014 Tammy L Coron. All rights reserved.
//

#import "LeftPanelView.h"

@implementation LeftPanelView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:CGRectMake(-[[UIScreen mainScreen] applicationFrame].size.width,
                                           0,
                                           [[UIScreen mainScreen] applicationFrame].size.width,
                                           [[UIScreen mainScreen] applicationFrame].size.height)];
    if (self) {
        // Initialization code
        [self setBackgroundColor:[UIColor orangeColor]];

    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    UILabel *label29 = [[UILabel alloc] initWithFrame:CGRectMake(3.0, 304.0, 320.0, 21.0)];
    label29.frame = CGRectMake(3.0, 304.0, 320.0, 21.0);
    label29.adjustsFontSizeToFitWidth = NO;
    label29.alpha = 1.000;
    label29.autoresizesSubviews = YES;
    label29.autoresizingMask = UIViewAutoresizingNone;
    label29.baselineAdjustment = UIBaselineAdjustmentAlignBaselines;
    label29.clearsContextBeforeDrawing = YES;
    label29.clipsToBounds = YES;
    label29.contentMode = UIViewContentModeLeft;
    label29.contentStretch = CGRectFromString(@"{{0, 0}, {1, 1}}");
    label29.enabled = YES;
    label29.hidden = NO;
    label29.lineBreakMode = UILineBreakModeTailTruncation;
    label29.minimumFontSize = 0.000;
    label29.multipleTouchEnabled = NO;
    label29.numberOfLines = 1;
    label29.opaque = NO;
    label29.shadowOffset = CGSizeMake(0.0, -1.0);
    label29.tag = 0;
    label29.text = @"Ilter";
    label29.textAlignment = UITextAlignmentCenter;
    label29.textColor = [UIColor colorWithWhite:0.333 alpha:1.000];
    label29.userInteractionEnabled = NO;

    [self addSubview:label29];
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
