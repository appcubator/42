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
    /*
    [PFCloud callFunctionInBackground:@"sendValidationSMS"
                       withParameters:@{}
                                block:^(NSString *result, NSError *error) {

                                    if (!error) {

                                    }
                                    
                                }];
     */
    
}
- (IBAction)nextButtonPressed:(id)sender {
    NSString *validationKey = self.verificationTextField.text;
    [PFCloud callFunctionInBackground:@"validateSMSKey"
                       withParameters:@{ @"validationKey":validationKey }
                                block:^(NSString *result, NSError *error) {
                                    if ([result isEqualToString:@"1"]) {
                                        // validates
                                        NSLog(@"yes");
                                    } else {
                                        // doesn't validate
                                        NSLog(@"no");
                                        _warningLabel.text = @"Please try again.";
                                    }
                                }];
}

@end
