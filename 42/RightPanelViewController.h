//
//  RightPanelViewController.h
//  SlideoutNavigation
//
//  Created by Tammy Coron on 1/10/13.
//  Copyright (c) 2013 Tammy L Coron. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RightPanelViewController : UIViewController

@property (nonatomic, strong) NSMutableArray *arrayOfContacts;

- (void)panelActivated;

@end
