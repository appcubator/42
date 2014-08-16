//
//  MainViewController.m
//  Navigation
//
//  Created by Tammy Coron on 1/19/13.
//  Copyright (c) 2013 Tammy L Coron. All rights reserved.
//

#import "MainViewController.h"
#import "CenterViewController.h"
#import "LeftPanelViewController.h"
#import "RightPanelViewController.h"
#import "AppDelegate.h"

#define CENTER_TAG 1
#define LEFT_PANEL_TAG 2
#define RIGHT_PANEL_TAG 3

#define SLIDE_TIMING .25
#define PANEL_WIDTH 60

@implementation MainViewController

#pragma mark -
#pragma mark View Did Load/Unload

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupView];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}


#pragma mark -
#pragma mark View Will/Did Appear

- (void)viewWillAppear:(BOOL)animated
{
    [self becomeFirstResponder];
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
}

-(BOOL)canBecomeFirstResponder {
    return YES;
}

#pragma mark -
#pragma mark View Will/Did Disappear

- (void)viewWillDisappear:(BOOL)animated
{
    [self resignFirstResponder];
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}


#pragma mark -
#pragma mark Setup View

- (void)setupView
{
    
    [self getLeftView];
    [self getRightView];
    
    self.centerViewController = [[CenterViewController alloc] init];
    self.centerViewController.view.tag = CENTER_TAG;
    self.centerViewController.delegate = self;
    
    [self.view addSubview:self.centerViewController.view];
    [self addChildViewController:_centerViewController];
    
    [_centerViewController didMoveToParentViewController:self];
    
    [self setupGestures];
    
}

- (UIView *)getLeftView
{
    // init view if it doesn't already exist
    if (_leftPanelViewController == nil)
    {
        // this is where you define the view for the left panel
        self.leftPanelViewController = [[LeftPanelViewController alloc] initWithNibName:@"LeftPanelView" bundle:nil];

        self.leftPanelViewController.view.tag = LEFT_PANEL_TAG;
        
        [self.view addSubview:self.leftPanelViewController.view];
        
        [self addChildViewController:_leftPanelViewController];
        [_leftPanelViewController didMoveToParentViewController:self];
    }
    
    UIView *view = self.leftPanelViewController.view;
    return view;
}

- (UIView *)getRightView
{
    // init view if it doesn't already exist
    if (_rightPanelViewController == nil)
    {
        // this is where you define the view for the right panel
        self.rightPanelViewController = [[RightPanelViewController alloc] initWithNibName:@"RightPanelView" bundle:nil];
        self.rightPanelViewController.view.tag = RIGHT_PANEL_TAG;
//        self.rightPanelViewController.delegate = _centerViewController;
        
        [self.view addSubview:self.rightPanelViewController.view];
        
        [self addChildViewController:self.rightPanelViewController];
        [_rightPanelViewController didMoveToParentViewController:self];
    }
    
//    self.showingRightPanel = YES;
    
    UIView *view = self.rightPanelViewController.view;
    return view;
    
}

#pragma mark -
#pragma mark Swipe Gesture Setup/Actions

- (void)setupGestures
{
    UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(movePanel:)];
    [panRecognizer setMinimumNumberOfTouches:1];
    [panRecognizer setMaximumNumberOfTouches:1];
    [panRecognizer setDelegate:self];
    
    [_centerViewController.view addGestureRecognizer:panRecognizer];
    
    UIPanGestureRecognizer *panRecognizerLeft = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(movePanel:)];
    [panRecognizer setMinimumNumberOfTouches:1];
    [panRecognizer setMaximumNumberOfTouches:1];
    [panRecognizer setDelegate:self];
    [_leftPanelViewController.view addGestureRecognizer:panRecognizerLeft];
    
    UIPanGestureRecognizer *panRecognizerRight = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(movePanel:)];
    [panRecognizer setMinimumNumberOfTouches:1];
    [panRecognizer setMaximumNumberOfTouches:1];
    [panRecognizer setDelegate:self];
    [_rightPanelViewController.view addGestureRecognizer:panRecognizerRight];
    
}

-(void)movePanel:(id)sender
{
    [[[(UITapGestureRecognizer*)sender view] layer] removeAllAnimations];
    
    CGPoint translatedPoint = [(UIPanGestureRecognizer*)sender translationInView:self.view];
    CGPoint velocity = [(UIPanGestureRecognizer*)sender velocityInView:[sender view]];
    
    if([(UIPanGestureRecognizer*)sender state] == UIGestureRecognizerStateEnded) {
        
        if(velocity.x > 0) {
            // NSLog(@"gesture went right");
        } else {
            // NSLog(@"gesture went left");
        }
        
        if (!_movePanel) {
            //[self movePanelToOriginalPosition];
            
            if (_centerPanelPosition == 1) {
                [self movePanelLeft];
            }
            else if (_centerPanelPosition == -1) {
                [self movePanelRight];
            }
            else {
                [self movePanelToOriginalPosition];
            }
            
        } else {
            if (_slideRight) {
                
                if(_centerPanelPosition == 0) {
                    [self movePanelRight];
                }
                
                if (_centerPanelPosition == 1) {
                    [self movePanelToOriginalPosition];
                }
            }
            else {
                if(_centerPanelPosition == 0) {
                    [self movePanelLeft];
                }
                
                if (_centerPanelPosition == -1) {
                    [self movePanelToOriginalPosition];
                }
            }
            
        }
    }
    
    if([(UIPanGestureRecognizer*)sender state] == UIGestureRecognizerStateChanged) {
        if(velocity.x > 0) {
            if (_leftPanelViewController.view.center.x == _centerViewController.view.frame.size.width / 2) {
                return;
            }
        } else { // went left
            if (_rightPanelViewController.view.center.x == _centerViewController.view.frame.size.width / 2) {
                return;
            }
        }
        
        // Are you more than halfway? If so, show the panel when done dragging by setting this value to YES (1).
        _movePanel = abs([sender view].center.x - _centerViewController.view.frame.size.width/2) > _centerViewController.view.frame.size.width/4;

        _slideRight = [sender view].center.x > _centerViewController.view.frame.size.width/2;
        
        // Allow dragging only in x-coordinates by only updating the x-coordinate with translation position.
        _leftPanelViewController.view.center = CGPointMake(_leftPanelViewController.view.center.x + translatedPoint.x, _leftPanelViewController.view.center.y);
        _rightPanelViewController.view.center = CGPointMake(_rightPanelViewController.view.center.x + translatedPoint.x, _rightPanelViewController.view.center.y);
        _centerViewController.view.center = CGPointMake(_centerViewController.view.center.x + translatedPoint.x, _centerViewController.view.center.y);
        
        [(UIPanGestureRecognizer*)sender setTranslation:CGPointMake(0,0) inView:self.view];
        
        // If you needed to check for a change in direction, you could use this code to do so.
        if(velocity.x*_preVelocity.x + velocity.y*_preVelocity.y > 0) {
            // NSLog(@"same direction");
        } else {
            // NSLog(@"opposite direction");
        }
        
        _preVelocity = velocity;
    }
}

#pragma mark -
#pragma mark Delegate Actions

- (void)movePanelLeft // to show right panel
{
    //    UIView *childView = [self getRightView];
    //    [self.view sendSubviewToBack:childView];
    
    [UIView animateWithDuration:SLIDE_TIMING delay:0 options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         _centerViewController.view.frame = CGRectMake(-self.view.frame.size.width, 0, self.view.frame.size.width, self.view.frame.size.height);
                         _rightPanelViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
                         _leftPanelViewController.view.frame = CGRectMake(-2 * self.view.frame.size.width, 0, self.view.frame.size.width, self.view.frame.size.height);
                     }
                     completion:^(BOOL finished) {
                         if (finished) {
                             _centerViewController.rightButton.tag = 0;
                         }
                     }];
    
    _centerPanelPosition = 1;
}

- (void)movePanelRight // to show left panel
{
    
    [UIView animateWithDuration:SLIDE_TIMING delay:0 options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         _centerViewController.view.frame = CGRectMake(self.view.frame.size.width, 0, self.view.frame.size.width, self.view.frame.size.height);
                         _leftPanelViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
                         _rightPanelViewController.view.frame = CGRectMake(2 * self.view.frame.size.width, 0, self.view.frame.size.width, self.view.frame.size.height);
                     }
                     completion:^(BOOL finished) {
                         if (finished) {
                             
                             _centerViewController.leftButton.tag = 0;
                         }
                     }];
    
    _centerPanelPosition = -1;
    
}

- (void)movePanelToOriginalPosition
{
    [UIView animateWithDuration:SLIDE_TIMING delay:0 options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         _centerViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
                         _leftPanelViewController.view.frame = CGRectMake(-self.view.frame.size.width , 0, self.view.frame.size.width, self.view.frame.size.height);
                         _rightPanelViewController.view.frame = CGRectMake(self.view.frame.size.width, 0, self.view.frame.size.width, self.view.frame.size.height);
                     }
                     completion:^(BOOL finished) {
                         if (finished) {
                             
                         }
                     }];
    
    _centerPanelPosition = 0;
}

#pragma mark -
#pragma mark Shake Handler

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{

    if (motion == UIEventSubtypeMotionShake )
    {
        NSData *data = [@"{\"objectId\":\"YcYCSbMOrL\", \"alert\":\"icanb sent you notif.\"}" dataUsingEncoding:NSUTF8StringEncoding];

        NSError *e;
        NSDictionary *testNotification = [NSJSONSerialization
                                          JSONObjectWithData:data
                                          options:NSJSONReadingMutableContainers
                                          error:&e];
        NSLog(@"%@",e);
        [[[UIApplication sharedApplication] delegate]
         application:[UIApplication sharedApplication]
         didReceiveRemoteNotification:testNotification];
        
        // User was shaking the device. Post a notification named "shake".
        [[NSNotificationCenter defaultCenter] postNotificationName:@"shake" object:self];
    }
}

#pragma mark -
#pragma mark Default System Code

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
