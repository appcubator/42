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


@implementation RightPanelViewController

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
        
        NSMutableArray *contacts = [self getContacts];
        _arrayOfContacts = contacts;
        [_contactsTableView reloadData];
    }
    else {
        // The user has previously denied access
        // Send an alert telling user to change privacy setting in settings app
    }

    
}

- (NSMutableArray*) getContacts {
    
    NSMutableArray *contactList=[[NSMutableArray alloc] init];
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
        [dOfPerson setObject:[NSString stringWithFormat:@"%@ %@", firstName, lastName] forKey:@"name"];
        
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
        [contactList addObject:dOfPerson];

    }
    
    return contactList;
}

#pragma mark -
#pragma mark UITableView Datasource/Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_arrayOfContacts count];
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
    UIButton *addButton = (UIButton *)[_cellMain viewWithTag:2];
    
    if ([_arrayOfContacts count] > 0)
    {
        NSMutableDictionary *currentContact = [_arrayOfContacts objectAtIndex:indexPath.row];
        contactName.text = [currentContact objectForKey:@"name"];
        
        addButton.tag = 1000 + indexPath.row;
        [addButton addTarget:self action:@selector(btnAdd:) forControlEvents:UIControlEventTouchUpInside];
        //mainImage.image = currentRecord.image;
        //imageTitle.text = [NSString stringWithFormat:@"%@", currentRecord.title];
        //creator.text = [NSString stringWithFormat:@"%@", currentRecord.creator];
    }
    
    return _cellMain;
}

# pragma mark -
# pragma mark Button Methods


- (void) btnAdd:(id)sender {
    UIButton *b = (UIButton *)sender;
    NSInteger row = b.tag - 1000;
    NSMutableDictionary *currentContact = [_arrayOfContacts objectAtIndex:row];
    NSString *mobileNumber = [currentContact objectForKey:@"Phone"];

    PFQuery *query = [PFUser query];
    [query whereKey:@"phone" equalTo:mobileNumber]; // find all the women
    NSArray *users = [query findObjects];
    
    // See if the user with phone number is there
    if (users.count > 0) {
        PFUser *otherUser = [users objectAtIndex:0];
        
        // create an entry in the Follow table
        PFObject *follow = [PFObject objectWithClassName:@"Follow"];
        [follow setObject:[PFUser currentUser]  forKey:@"from"];
        [follow setObject:otherUser forKey:@"to"];
        [follow setObject:[NSDate date] forKey:@"date"];
        [follow saveInBackground];
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Wait" message:@"User is not yet on 42." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:@"OK", nil];
        [alert show];
    }
    
}


#pragma mark -
#pragma mark Default System Code

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
