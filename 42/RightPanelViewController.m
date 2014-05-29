//
//  RightPanelViewController.m
//  SlideoutNavigation
//
//  Created by Tammy Coron on 1/10/13.
//  Copyright (c) 2013 Tammy L Coron. All rights reserved.
//

#import "RightPanelViewController.h"
#import "RightPanelView.h"
#import <AddressBook/AddressBook.h>
#import <Parse/Parse.h>
#import <AddressBookUI/AddressBookUI.h>
#import "MainViewController.h"
#import "NBPhoneNumberUtil.h"
#import "UIButtonForRow.h"

@implementation RightPanelViewController

- (NSArray *)getSectionsArray
{
    NSArray *letterIndex = @[@"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H", @"I", @"J", @"K", @"L", @"M", @"N", @"O", @"P", @"Q", @"R", @"S", @"T", @"U", @"V", @"W", @"X", @"Y", @"Z"];
    
    return  letterIndex;
}

#pragma mark -
#pragma mark View Did Load/Unload

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

#pragma mark -
#pragma mark View Will/Did Appear

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
}

#pragma mark -
#pragma mark View Will/Did Disappear

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

#pragma mark -
#pragma mark Array Setup

- (void)panelActivated
{
    
    // Request authorization to Address Book
    ABAddressBookRef addressBookRef = ABAddressBookCreateWithOptions(NULL, NULL);

    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined) {
        
        ABAddressBookRequestAccessWithCompletion(addressBookRef, ^(bool granted, CFErrorRef error) {
            if (granted) {
                [self panelActivated];

            } else {
                // User denied access
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"App wont werk!" message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
                [alertView show];
            }
        });
    }
    else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized) {
        // The user has previously given access, add the contact
        
        NSMutableDictionary *contacts = [self getContacts];
        _dictOfContacts = contacts;
        [_tableView reloadData];
    }
    else {
        // The user has previously denied access
        // Send an alert telling user to change privacy setting in settings app
    }

    
}

- (NSMutableDictionary *) createEmptyDictionaryWithSectionKeys
{
    NSMutableDictionary *emptyDict = [[NSMutableDictionary alloc] init];
    
    NSArray *sections = [self getSectionsArray];
    
    for (NSString *section in sections) {
        [emptyDict setObject:[[NSMutableArray alloc] initWithArray:@[]] forKey:section];
    }
    
    return emptyDict;
}

- (NSMutableDictionary *) getContacts {
    
    NSMutableDictionary *contactDict= [self createEmptyDictionaryWithSectionKeys];
    
    ABAddressBookRef m_addressbook = ABAddressBookCreateWithOptions(NULL, NULL);
    
    if (!m_addressbook) {
        NSLog(@"opening address book");
    }
    
    CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople(m_addressbook);
    CFIndex nPeople = ABAddressBookGetPersonCount(m_addressbook);
    
    for (int i=0;i < nPeople; i++) {
        NSMutableDictionary *dOfPerson=[NSMutableDictionary dictionary];
        
        ABRecordRef ref = CFArrayGetValueAtIndex(allPeople,i);
        
        //For username and surname
        ABMultiValueRef phones = ABRecordCopyValue(ref, kABPersonPhoneProperty);
        CFStringRef firstName, lastName;
        firstName = ABRecordCopyValue(ref, kABPersonFirstNameProperty);
        lastName  = ABRecordCopyValue(ref, kABPersonLastNameProperty);
        NSString *firstNameStr, *lastNameStr;
        firstNameStr = (__bridge NSString *)firstName;
        lastNameStr = (__bridge NSString *)lastName;

        NSString *fullName = [NSString stringWithFormat:@"%@ %@", firstNameStr ?:@"", lastNameStr ?:@""];
        fullName = [fullName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

        if (!fullName || [fullName isEqual:@""]) {
            fullName = @"Unnamed";
        }

        [dOfPerson setObject:fullName forKey:@"name"];
        
        //For Email ids
        ABMutableMultiValueRef eMail  = ABRecordCopyValue(ref, kABPersonEmailProperty);
        
        CFStringRef emailRef = ABMultiValueCopyValueAtIndex(eMail, 0);
        NSString *email = (NSString *) CFBridgingRelease(emailRef);
        if (email != nil) {
            [dOfPerson setObject:email forKey:@"email"];
        }
    
        //For Phone number
        for(CFIndex i = 0; i < ABMultiValueGetCount(phones); i++) {
            CFStringRef mobileLabelref = ABMultiValueCopyLabelAtIndex(phones, i);
            CFStringRef mobileNumberref = ABMultiValueCopyValueAtIndex(phones, i);

            NSString *mobileLabel = (NSString *) CFBridgingRelease(mobileLabelref);
            NSString *mobileNumber = (NSString *) CFBridgingRelease(mobileNumberref);
            
            if([mobileLabel isEqualToString:(NSString *)kABPersonPhoneMobileLabel])
            {
                [dOfPerson setObject:mobileNumber forKey:@"Phone"];
                break;
            }
            else if ([mobileLabel isEqualToString:(NSString*)kABPersonPhoneIPhoneLabel])
            {
                [dOfPerson setObject:mobileNumber forKey:@"Phone"];
                break;
            }
            else {
                [dOfPerson setObject:mobileNumber forKey:@"Phone"];
            }

        }

        CFRelease(ref);
        if (firstName != nil) { CFRelease(firstName); }
        if (lastName != nil) { CFRelease(lastName); }
        
        NSString *firstLetter = [fullName substringToIndex:1];
        
        if (firstLetter && [contactDict objectForKey:firstLetter])
        {
            NSMutableArray *arr = [contactDict objectForKey:firstLetter];
            [arr addObject:dOfPerson];
            [contactDict setObject:arr forKey:firstLetter];
        }

    }
    
    
    // sort each sections
    NSMutableDictionary *sortedContactDict = [[NSMutableDictionary alloc] init];
    for(NSString *key in contactDict) {
        NSMutableArray *contactstArr = [contactDict objectForKey:key];
        NSArray *sortedArr = [contactstArr sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
            NSMutableDictionary *person1 = (NSMutableDictionary *)a;
            NSMutableDictionary *person2 = (NSMutableDictionary *)b;
            NSString *person1Name = [person1 objectForKey:@"name"];
            NSString *person2Name = [person2 objectForKey:@"name"];
            return [person1Name compare: person2Name];
        }];
        [sortedContactDict setObject:[NSMutableArray arrayWithArray:sortedArr] forKey:key];
    }

    return sortedContactDict;
}

#pragma mark -
#pragma mark UITableView Datasource/Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[self getSectionsArray] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSString *key = [[self getSectionsArray] objectAtIndex:section];
    NSMutableArray *arr = [_dictOfContacts objectForKey:key];
    return [arr count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 54;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellMainNibID = @"cellMain";
    
    _cellMain = [tableView dequeueReusableCellWithIdentifier:cellMainNibID];
    if (_cellMain == nil) {
        [[NSBundle mainBundle] loadNibNamed:@"ContactCellView" owner:self options:nil];
    }
    
    UILabel *contactName = (UILabel *)[_cellMain viewWithTag:1];
    UIButtonForRow *addButton = (UIButtonForRow *)[_cellMain viewWithTag:2];
    [addButton setIndexPath:indexPath];

    NSString *sectionTitle = [[self getSectionsArray] objectAtIndex:indexPath.section];
    NSMutableArray *sectionForKey = [_dictOfContacts objectForKey:sectionTitle];
    NSMutableDictionary *currentContact = [sectionForKey objectAtIndex:indexPath.row];
    contactName.text = [currentContact objectForKey:@"name"];
    [addButton addTarget:self action:@selector(btnAdd:) forControlEvents:UIControlEventTouchUpInside];

    return _cellMain;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
     return [[self getSectionsArray] indexOfObject:title];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return [self getSectionsArray];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [[self getSectionsArray] objectAtIndex:section];
}


# pragma mark -
# pragma mark Button Methods


- (void) btnAdd:(id)sender {
    
    UIButtonForRow *btn = (UIButtonForRow *)sender;
    NSIndexPath *indexPath = btn.indexPath;

    NSLog(@"%@",indexPath);
    NSLog(@"%d",indexPath.section);
    NSLog(@"%d", indexPath.row);
    
    NSString *sectionTitle = [[self getSectionsArray] objectAtIndex:indexPath.section];
    NSMutableArray *sectionForKey = [_dictOfContacts objectForKey:sectionTitle];
    NSMutableDictionary *currentContact = [sectionForKey objectAtIndex:indexPath.row];

    NSLog(@"%@",sectionTitle);
    NSLog(@"%@",sectionForKey);
    NSLog(@"%@",currentContact);

    NSString *mobileNumber = [currentContact objectForKey:@"Phone"];

    NBPhoneNumberUtil *phoneUtil = [NBPhoneNumberUtil sharedInstance];
    NSError *aError = nil;
    NBPhoneNumber *userNumber = [phoneUtil parse:mobileNumber
                                   defaultRegion:@"US" error:&aError];

    
    if ([phoneUtil isValidNumber:userNumber]) {
        
        PFQuery *query = [PFUser query];
        [query whereKey:@"phone" equalTo:[phoneUtil format:userNumber
                                              numberFormat:NBEPhoneNumberFormatE164
                                                     error:&aError]];
        NSArray *users = [query findObjects];
    
        // See if the user with phone number is there
        if (users.count > 0) {
            PFUser *otherUser = [users objectAtIndex:0];
        
            // create an entry in the Follow table
            PFObject *follow = [PFObject objectWithClassName:@"Follow"];
            [follow setObject:[PFUser currentUser]  forKey:@"from"];
            [follow setObject:otherUser forKey:@"to"];
            [follow setObject:[NSDate date] forKey:@"date"];
            [follow saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (succeeded) {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Great" message:@"User is added." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:@"OK", nil];
                    [alert show];
                }
                else {
                    
                }
            }];

        }
        else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Wait" message:@"User is not yet on 42." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:@"OK", nil];
            [alert show];
        }
        
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Wait" message:@"Could not find valid phone number." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:@"OK", nil];
        [alert show];
    }
    
}


- (IBAction)btnBackPressed:(id)sender {
    MainViewController* mainViewController = (MainViewController *) self.parentViewController;
    [mainViewController movePanelToOriginalPosition];
}

#pragma mark -
#pragma mark Default System Code

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
