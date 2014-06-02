//
//  RightPanelViewController.m
//  SlideoutNavigation
//
//  Created by Tammy Coron on 1/10/13.
//  Copyright (c) 2013 Tammy L Coron. All rights reserved.
//

#import "RightPanelViewController.h"
#import <Parse/Parse.h>
#import "MainViewController.h"
#import "NBPhoneNumberUtil.h"
#import "UIButtonForRow.h"
#import "AppDelegate.h"


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
    _dictOfContacts = [self getContacts];

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
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSArray *usersArray = [appDelegate getUnregisteredContacts];
    NSLog(@"%d", [usersArray count]);

    NSMutableDictionary *contactDict= [self createEmptyDictionaryWithSectionKeys];
    NSInteger nPeople = [usersArray count];

    for (int i=0;i < nPeople; i++) {
        
        NSMutableDictionary *dOfPerson=usersArray[i];
    
        NSString *firstLetter = [[usersArray[i] valueForKey:@"name"] substringToIndex:1];
        if (firstLetter && [contactDict objectForKey:firstLetter])
        {
            NSMutableArray *arr = [contactDict objectForKey:firstLetter];
            [arr addObject:dOfPerson];
            [contactDict setObject:arr forKey:firstLetter];
        }

    }

    return contactDict;
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
    contactName.text = [currentContact valueForKey:@"name"];
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
    
    NSString *sectionTitle = [[self getSectionsArray] objectAtIndex:indexPath.section];
    NSMutableArray *sectionForKey = [_dictOfContacts objectForKey:sectionTitle];
    NSMutableDictionary *currentContact = [sectionForKey objectAtIndex:indexPath.row];
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
