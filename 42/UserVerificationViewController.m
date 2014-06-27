//
//  UserVerificationViewController.m
//  42
//
//  Created by Ilter Canberk on 6/26/14.
//  Copyright (c) 2014 Appcubator. All rights reserved.
//

#import "UserVerificationViewController.h"
#import "AppDelegate.h"
#import <Parse/Parse.h>

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

- (IBAction)btnSendAgain:(id)sender {
    
    // BEGIN VALIDATION CLIENT CODE
    [PFCloud callFunctionInBackground:@"sendValidationSMS"
                       withParameters:@{}
                                block:^(NSString *result, NSError *error) {

                                    if (!error) {
                                        // ask user for verication code
                                        // when they press enter in that view, execute the following code
                                        // BEGIN BLOCK
                                        //             [PFCloud callFunctionInBackground:@"checkSMSValidationCode"
                                        //                      withParameters:@{ phoneNumber:userNumber }
                                        //                      block:^(NSString *result, NSError *error) {
                                        //                 if (!error) {
                                        //                     // put the rest of the code of the function (below the VALIDATION CLIENT CODE) here instead.
                                        //                 }
                                        //             }];
                                        // END BLOCK
                                    }
                                    
                                }];
    
}

@end
