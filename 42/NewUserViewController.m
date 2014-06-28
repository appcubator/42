//
//  NewUserViewController.m
//  42
//
//  Created by Ilter Canberk on 5/22/14.
//  Copyright (c) 2014 Appcubator. All rights reserved.
//

#import "NewUserViewController.h"
#import <Parse/Parse.h>
#import "ActivityView.h"
#import "NBPhoneNumberUtil.h"
#import "AppDelegate.h"
#import "UserVerificationViewController.h"

@interface NewUserViewController ()

@end

@implementation NewUserViewController

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
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textInputChanged:) name:UITextFieldTextDidChangeNotification object:_userNameField];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textInputChanged:) name:UITextFieldTextDidChangeNotification object:_passwordField];
    
    _doneButton.enabled = NO;

}

- (void)viewWillAppear:(BOOL)animated {
	[_userNameField becomeFirstResponder];
	[super viewWillAppear:animated];
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	
    if (textField == _userNameField) {
		[_passwordField becomeFirstResponder];
	}
    
	return YES;
}


- (BOOL)shouldEnableDoneButton {
	BOOL enableDoneButton = NO;
	if (_userNameField.text != nil &&
		_userNameField.text.length > 0 &&
		_passwordField.text != nil &&
		_passwordField.text.length > 0) {
		enableDoneButton = YES;
	}
	return enableDoneButton;
}


- (void)textInputChanged:(NSNotification *)note {
	_doneButton.enabled = [self shouldEnableDoneButton];
}

- (void)processFieldEntries {
	// Check that we have a non-zero username and passwords.
	// Compare password and passwordAgain for equality
	// Throw up a dialog that tells them what they did wrong if they did it wrong.
    
    NBPhoneNumberUtil *phoneUtil = [NBPhoneNumberUtil sharedInstance];
    NSError *aError = nil;
    NSLog(@"%@",_phoneNumberField.text);
    NBPhoneNumber *userNumber = [phoneUtil parse:_phoneNumberField.text
                                 defaultRegion:@"US" error:&aError];
    
    NSLog(@"%@", aError);
    NSLog(@"%hhd", [phoneUtil isValidNumber:userNumber]);
    
	NSString *username = _userNameField.text;
	NSString *password = _passwordField.text;
    NSString *phoneNumber = _phoneNumberField.text;
	NSString *errorText = @"Please ";
	NSString *usernameBlankText = @"enter a username";
	NSString *passwordBlankText = @"enter a password";
	NSString *joinText = @", and ";
	NSString *passwordMismatchText = @"enter the same password twice";
    
	BOOL textError = NO;
    
	// Messaging nil will return 0, so these checks implicitly check for nil text.
	if (username.length == 0 || password.length == 0 || phoneNumber.length == 0) {
		textError = YES;
        
		// Set up the keyboard for the first field missing input:
        if (phoneNumber.length == 0) {
            [_phoneNumberField becomeFirstResponder];
        }
		if (password.length == 0) {
			[_passwordField becomeFirstResponder];
		}
		if (username.length == 0) {
			[_userNameField becomeFirstResponder];
		}
        
		if (username.length == 0) {
			errorText = [errorText stringByAppendingString:usernameBlankText];
		}
        
		if (password.length == 0) {
			if (username.length == 0) { // We need some joining text in the error:
				errorText = [errorText stringByAppendingString:joinText];
			}
			errorText = [errorText stringByAppendingString:passwordBlankText];
		}


    
	} else if (![phoneUtil isValidNumber:userNumber]) {
        textError = YES;
        errorText = [errorText stringByAppendingString:@"Invalid phone number."];
    }
    
	if (textError) {
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:errorText message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
		[alertView show];
		return;
	}
    
    // END VALIDATION CLIENT CODE
    
	// Everything looks good; try to log in.
	// Disable the done button for now.
	_doneButton.enabled = NO;
	ActivityView *activityView = [[ActivityView alloc] initWithFrame:CGRectMake(0.f, 0.f, self.view.frame.size.width, self.view.frame.size.height)];
	UILabel *label = activityView.label;
	label.text = @"Signing You Up";
	label.font = [UIFont boldSystemFontOfSize:20.f];
	[activityView.activityIndicator startAnimating];
	[activityView layoutSubviews];
    
	[self.view addSubview:activityView];
    
	// Call into an object somewhere that has code for setting up a user.
	// The app delegate cares about this, but so do a lot of other objects.
	// For now, do this inline.
    
	PFUser *user = [PFUser user];
	user.username = username;
	user.password = password;
    user[@"phone"] = [phoneUtil format:userNumber
                          numberFormat:NBEPhoneNumberFormatE164
                                 error:&aError];

	[user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
		
        if (error) {
			UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[[error userInfo] objectForKey:@"error"] message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
			[alertView show];
			_doneButton.enabled = [self shouldEnableDoneButton];
			[activityView.activityIndicator stopAnimating];
			[activityView removeFromSuperview];
			// Bring the keyboard back up, because they'll probably need to change something.
			[_userNameField becomeFirstResponder];
			return;
		}
        
        // BEGIN VALIDATION CLIENT CODE
        [PFCloud callFunctionInBackground:@"sendValidationSMS"
                           withParameters:@{ phoneNumber:phoneNumber }
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
    
		// Success!
		[activityView.activityIndicator stopAnimating];
		[activityView removeFromSuperview];

        UserVerificationViewController *loginViewController = [[UserVerificationViewController alloc] initWithNibName:nil bundle:nil];
        [self.navigationController pushViewController:loginViewController animated:YES];

	}];
}


- (IBAction)done:(id)sender {
	[_userNameField resignFirstResponder];
	[_passwordField resignFirstResponder];
	[self processFieldEntries];
}

- (IBAction)btnBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
