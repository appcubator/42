//
//  SendToViewController.h
//  42
//
//  Created by Ilter Canberk on 5/24/14.
//  Copyright (c) 2014 Appcubator. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SendToViewController : UIViewController

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIView *bottomBar;
@property (strong, nonatomic) IBOutlet UIButton *sendToButton;
@property (strong, nonatomic) IBOutlet UILabel *sendToLabel;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *navBackButton;

@property (strong, nonatomic) IBOutlet UITableViewCell *cellMain;

@property (nonatomic, strong) NSMutableArray *arrayOfFollowers;
@property (nonatomic, strong) NSMutableArray *arrayOfReceivers;

@end
