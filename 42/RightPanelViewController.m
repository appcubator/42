//
//  RightPanelViewController.m
//  SlideoutNavigation
//
//  Created by Tammy Coron on 1/10/13.
//  Copyright (c) 2013 Tammy L Coron. All rights reserved.
//

#import "RightPanelViewController.h"
#import <Parse/Parse.h>
#import <MessageUI/MessageUI.h>
#import "MainViewController.h"
#import "UIButtonForRow.h"
#import "AppDelegate.h"
#import <CoreData/CoreData.h>
#import "SettingsViewController.h"
#import "Store.h"

@implementation RightPanelViewController

- (NSArray *)getLettersArray
{
    NSArray *letterIndex = @[@"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H", @"I", @"J", @"K", @"L", @"M", @"N", @"O", @"P", @"Q", @"R", @"S", @"T", @"U", @"V", @"W", @"X", @"Y", @"Z"];
    
    return  letterIndex;
}

- (NSArray *)getSectionsArray
{
    NSArray *sectionsArray = @[@"Active Users"];
    sectionsArray = [sectionsArray arrayByAddingObjectsFromArray:[NSArray arrayWithArray:[self getLettersArray]]];
    return sectionsArray;
}

- (NSArray *)getSectionTitlesArray
{
    NSArray *sectionsArray = @[@"*"];
    sectionsArray = [sectionsArray arrayByAddingObjectsFromArray:[NSArray arrayWithArray:[self getLettersArray]]];
    return sectionsArray;
}

#pragma mark -
#pragma mark View Did Load/Unload

- (void)viewDidLoad
{
    [super viewDidLoad];
    _dictOfContacts = [self getContacts];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updatingContactsBook) name:kUpdatingContactsBook object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updatedContactsBook) name:kUpdatedContactsBook object:nil];
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
    NSLog(@"Number of unregistered contacts: %lu", (unsigned long)[usersArray count]);

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

    NSArray *activeUsersArray = [appDelegate getRegisteredContacts];
    [contactDict setObject:activeUsersArray forKey:@"Active Users"];

    return contactDict;
}

- (void)updatingContactsBook {
    _updatingContactsView.hidden = NO;
    NSLog(@"Started updating");
}

- (void)updatedContactsBook {
    _updatingContactsView.hidden = YES;
    _dictOfContacts = [self getContacts];
    [_tableView reloadData];
    NSLog(@"Done updating");
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
    return 52;
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
    UIButtonForRow *textAddButton = (UIButtonForRow *)[_cellMain viewWithTag:3];


    NSString *sectionTitle = [[self getSectionsArray] objectAtIndex:indexPath.section];
    NSMutableArray *sectionForKey = [_dictOfContacts objectForKey:sectionTitle];
    NSMutableDictionary *currentContact = [sectionForKey objectAtIndex:indexPath.row];
    contactName.text = [currentContact valueForKey:@"name"];
    
    if ([currentContact valueForKey:@"isFollowed"])
    {
        addButton.hidden = YES;
        textAddButton.hidden = YES;
    }
    else {
        if (indexPath.section == 0) {
            // registered user
            [addButton setIndexPath:indexPath];
            [addButton addTarget:self action:@selector(btnAdd:) forControlEvents:UIControlEventTouchUpInside];
            addButton.hidden = NO;
            textAddButton.hidden = YES;
        }
        else {
            // unregistered user
            [textAddButton setIndexPath:indexPath];
            [textAddButton addTarget:self action:@selector(btnMessage:) forControlEvents:UIControlEventTouchUpInside];
            textAddButton.hidden = NO;
            addButton.hidden = YES;
        }
    }

    return _cellMain;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
     return [[self getSectionTitlesArray] indexOfObject:title];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return [self getSectionTitlesArray];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [[self getSectionsArray] objectAtIndex:section];
}


# pragma mark -
# pragma mark Button Methods


- (void)btnAdd:(id)sender {
    
    UIButtonForRow *btn = (UIButtonForRow *)sender;
    NSIndexPath *indexPath = btn.indexPath;
    
    NSString *sectionTitle = [[self getSectionsArray] objectAtIndex:indexPath.section];
    NSMutableArray *sectionForKey = [_dictOfContacts objectForKey:sectionTitle];
    NSManagedObject *currentContact = [sectionForKey objectAtIndex:indexPath.row];
    NSString *mobileNumber = [currentContact valueForKey:@"phone"];
    
    PFQuery *query = [PFUser query];
    [query whereKey:@"phone" equalTo:mobileNumber];
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
                NSString *msg = [NSString stringWithFormat:@"You are following %@ now", [otherUser username]];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Great" message:msg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:@"OK", nil];
                [alert show];
                
                NSManagedObjectContext *context = [[Store alloc] init].mainManagedObjectContext;
                NSEntityDescription *entityDescription = [NSEntityDescription
                                                          entityForName:@"ContactModel" inManagedObjectContext:context];
                NSFetchRequest *request = [[NSFetchRequest alloc] init];
                [request setEntity:entityDescription];
                
                NSPredicate *predicate = [NSPredicate predicateWithFormat:
                                          @"phone = %@",otherUser[@"phone"]];
                
                [request setPredicate:predicate];
                
                NSError *error = nil;
                NSArray *array = [context executeFetchRequest:request error:&error];
                if ([array count] > 0) {
                    NSManagedObject* userObject = [array objectAtIndex:0];
                    [userObject setValue:[NSNumber numberWithBool:YES] forKey:@"isFollowed"];
                }
                
                [context save:&error];
                
                if (error != nil) {
                    NSLog(@"%@",error);
                }
                
                [_tableView reloadData];
                
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

-(void)btnMessage:(id)sender
{
    UIButtonForRow *btn = (UIButtonForRow *)sender;
    NSIndexPath *indexPath = btn.indexPath;
    
    NSString *sectionTitle = [[self getSectionsArray] objectAtIndex:indexPath.section];
    NSMutableArray *sectionForKey = [_dictOfContacts objectForKey:sectionTitle];
    NSManagedObject *currentContact = [sectionForKey objectAtIndex:indexPath.row];
    NSString *mobileNumber = [currentContact valueForKey:@"phone"];

    if(![MFMessageComposeViewController canSendText]) {
        UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Your device doesn't support SMS!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [warningAlert show];
        return;
    }
    
    if ([mobileNumber isEqual:nil]) {
        UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"This user does not have a number!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [warningAlert show];
        return;
    }

    NSArray *recipents = @[mobileNumber];
    NSString *message = [NSString stringWithFormat:@"Add me on Wave? It's a fun way to catch up with friends: https://itunes.apple.com/us/app/42/id894342485"];
    
    MFMessageComposeViewController *messageController = [[MFMessageComposeViewController alloc] init];
    messageController.messageComposeDelegate = self;
    [messageController setRecipients:recipents];
    [messageController setBody:message];
    
    // Present message view controller on screen
    [self presentViewController:messageController animated:YES completion:nil];
    
}


- (IBAction)btnBackPressed:(id)sender {
    MainViewController* mainViewController = (MainViewController *) self.parentViewController;
    [mainViewController movePanelToOriginalPosition];
}


- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult) result
{
    switch (result) {
        case MessageComposeResultCancelled:
            break;
            
        case MessageComposeResultFailed:
        {
            UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Failed to send SMS!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [warningAlert show];
            break;
        }
            
        case MessageComposeResultSent:
            break;
            
        default:
            break;
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)btnSettings:(id)sender {
    SettingsViewController *settingsViewController = [[SettingsViewController alloc] initWithNibName:@"SettingsViewController" bundle:nil];
	[self.navigationController pushViewController:settingsViewController animated:YES];
}

#pragma mark -
#pragma mark Default System Code

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
