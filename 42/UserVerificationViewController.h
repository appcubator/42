//
//  UserVerificationViewController.h
//  42
//
//  Created by Ilter Canberk on 6/26/14.
//  Copyright (c) 2014 Appcubator. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserVerificationViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *verificationTextField;
@property (strong, nonatomic) IBOutlet UILabel *warningLabel;

@end
