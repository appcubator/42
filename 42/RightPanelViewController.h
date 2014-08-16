//
//  RightPanelViewController.h
//  SlideoutNavigation
//
//  Created by Tammy Coron on 1/10/13.
//  Copyright (c) 2013 Tammy L Coron. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

@interface RightPanelViewController : UIViewController <MFMessageComposeViewControllerDelegate,UISearchBarDelegate, UISearchDisplayDelegate>

@property (nonatomic, strong) NSMutableDictionary *dictOfContacts;
@property (nonatomic, strong) NSMutableDictionary *filteredDictOfContacts;

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UITableViewCell *cellMain;
@property (strong, nonatomic) IBOutlet UITableViewCell *cellSearch;

@property (strong, nonatomic) IBOutlet UIView *updatingContactsView;
@property (strong, nonatomic) IBOutlet UISearchBar *searchBarView;

@end
