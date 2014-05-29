//
//  SettingsViewController.m
//  42
//
//  Created by Ilter Canberk on 5/28/14.
//  Copyright (c) 2014 Appcubator. All rights reserved.
//

#import "SettingsViewController.h"
#import <Parse/Parse.h>
#import "AppDelegate.h"

@interface SettingsViewController ()

@end

@implementation SettingsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)btnLogout:(id)sender {
    [PFUser logOut];
    [self.navigationController popToRootViewControllerAnimated:NO];
    
    // show the welcome view
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    [appDelegate presentWelcomeViewController];
}

- (IBAction)btnBack:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:NO];
}


@end
