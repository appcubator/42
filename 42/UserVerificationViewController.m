//
//  UserVerificationViewController.m
//  42
//
//  Created by Ilter Canberk on 6/26/14.
//  Copyright (c) 2014 Appcubator. All rights reserved.
//

#import "UserVerificationViewController.h"
#import "AppDelegate.h"

@interface UserVerificationViewController ()

@end

@implementation UserVerificationViewController

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



- (IBAction)btnSkip:(id)sender {

    [self.navigationController popToRootViewControllerAnimated:YES];
    // show the welcome view
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    [appDelegate presentMainViewController];

}

@end
