//
//  ContactViewController.m
//  42
//
//  Created by Ilter Canberk on 5/29/14.
//  Copyright (c) 2014 Appcubator. All rights reserved.
//

#import "ContactViewController.h"
#import "MainViewController.h"

@interface ContactViewController ()

@end

@implementation ContactViewController

- (id)init
{
    // Custom initialization
    self = [super init];
    if (self) {
        self.navigationBar.topItem.title = @"Contacts";
    }
    return self;
}

- (void)navigationController:(UINavigationController*)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if([navigationController isKindOfClass:[ABPeoplePickerNavigationController class]])
    {
        navigationController.topViewController.navigationItem.rightBarButtonItem = nil;
        
        UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"<" style: UIBarButtonItemStyleBordered target:self action:@selector(back)];
        navigationController.topViewController.navigationItem.leftBarButtonItem = backButton;
        
        navigationController.navigationBar.barTintColor = [UIColor colorWithRed:99 / 100.0f
                                                                       green: 49% 100 / 100.0f
                                                                        blue: 30 % 100 / 100.0f
                                                                       alpha:1.0f];
        
    }
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated
{
 
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)back
{
    MainViewController* mainViewController = (MainViewController *) self.parentViewController;
    [mainViewController movePanelToOriginalPosition];
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person{
    
    UIView *view = peoplePicker.topViewController.view;
    UITableView *tableView = nil;
    
    for(UIView *uv in view.subviews)
    {
        if([uv isKindOfClass:[UITableView class]])
        {
            tableView = (UITableView*)uv;
            break;
        }
    }
    if(tableView != nil)
    {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:[tableView indexPathForSelectedRow]];
        UIButton *btnAdd = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [btnAdd setTitle:@"Add" forState:UIControlStateNormal];

        CGRect currentFrame = btnAdd.frame;
        currentFrame.origin.x = cell.frame.size.width - 80;
        btnAdd.frame = currentFrame;

        [cell addSubview:btnAdd];

        if(cell.accessoryType == UITableViewCellAccessoryNone){
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
        else{
            cell.accessoryType = UITableViewCellAccessoryNone;
        }        
        [cell setSelected:NO animated:YES];
    }
    return NO;
}

@end
