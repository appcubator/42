//
//  MainViewController.h
//  42
//
//  Created by Ilter Canberk on 5/22/14.
//  Copyright (c) 2014 Appcubator. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CenterViewController.h"

@interface MainViewController : UIViewController <CenterViewControllerDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong) CenterViewController *centerViewController;
@property (nonatomic, strong) LeftPanelViewController *leftPanelViewController;
@property (nonatomic, strong) RightPanelViewController *rightPanelViewController;
@property (nonatomic, assign) BOOL showingRightPanel;
@property (nonatomic, assign) NSInteger centerPanelPosition;
@property (nonatomic, assign) BOOL movePanel;
@property (nonatomic, assign) BOOL slideRight;
@property (nonatomic, assign) CGPoint preVelocity;

- (void)movePanelToOriginalPosition;

@end

