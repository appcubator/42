//
//  MapView.h
//  42
//
//  Created by Ilter Canberk on 5/22/14.
//  Copyright (c) 2014 Appcubator. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/Mapkit.h>
#import "FortyTwoMap.h"

@interface MapView : UIView

@property (nonatomic, strong) UIButton* leftButton;
@property (nonatomic, strong) UIButton* rightButton;
@property (nonatomic, strong) UIButton* flagButton;
@property (nonatomic, strong) UIButton* cancelButton;

@property (nonatomic, strong) FortyTwoMap *mkMapView;
@property (nonatomic, strong) UIView* sendToPanel;
@property (nonatomic, strong) UIButton* sendToButton;

- (void)showSendPanel;
- (void)hideSendPanel;

@end
