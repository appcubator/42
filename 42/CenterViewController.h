//
//  MapViewController.h
//  42
//
//  Created by Ilter Canberk on 5/22/14.
//  Copyright (c) 2014 Appcubator. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "PersonalPinAnnotation.h"
#import "RightPanelViewController.h"
#import "LeftPanelViewController.h"
#import <Parse/Parse.h>
#import "ComposePinAnnotation.h"
#import "FortyTwoMap.h"

@protocol CenterViewControllerDelegate <NSObject>

@optional
- (void)movePanelLeft;
- (void)movePanelRight;
@required
- (void)movePanelToOriginalPosition;
@end

@interface CenterViewController : UIViewController<CLLocationManagerDelegate, MKMapViewDelegate>

@property (nonatomic, assign) id<CenterViewControllerDelegate> delegate;
@property (nonatomic, weak) UIButton *leftButton;
@property (nonatomic, weak) UIButton *rightButton;
@property (strong, nonatomic) FortyTwoMap *mkMapView;

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) PersonalPinAnnotation *selfPin;
@property (strong, nonatomic) ComposePinAnnotation *composePin;


@property (strong, nonatomic) NSMutableArray *friendPins;


- (void)showLocationSent:(PFObject *)locationSent;
    
@end
