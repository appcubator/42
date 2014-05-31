//
//  SettingsViewController.h
//  42
//
//  Created by Ilter Canberk on 5/28/14.
//  Copyright (c) 2014 Appcubator. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsViewController : UIViewController

@property (strong, nonatomic) NSDictionary *menuItemsDict;
@property (strong, nonatomic) IBOutlet UITableViewCell *cellMain;

@property (strong, nonatomic) IBOutlet UILabel *optionLabel;
@property (strong, nonatomic) IBOutlet UILabel *dataLabel;
@property (strong, nonatomic) IBOutlet UILabel *arrowLabel;


@end
