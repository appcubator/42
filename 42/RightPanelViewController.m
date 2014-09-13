//
//  RightPanelViewController.m
//  SlideoutNavigation
//
//

#import "RightPanelViewController.h"

#import <Parse/Parse.h>
#import <MessageUI/MessageUI.h>
#import <CoreData/CoreData.h>

#import "MainViewController.h"
#import "UIButtonForRow.h"
#import "ActivityView.h"
#import "AppDelegate.h"
#import "SettingsViewController.h"
#import "Store.h"

@implementation RightPanelViewController

static int ROW_HEIGHT = 52;
static int ROW_HEIGHT_SEARCH = 44;
BOOL isShowingSearchTable = NO;
BOOL tempScrollLock = NO;
NSString *searchString = @"";
NSArray *searchResults = nil;

- (NSArray *)getLettersArray
{
    NSArray *letterIndex = @[@"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H", @"I", @"J", @"K", @"L", @"M", @"N", @"O", @"P", @"Q", @"R", @"S", @"T", @"U", @"V", @"W", @"X", @"Y", @"Z"];
    
    return  letterIndex;
}

- (NSArray *)getSectionsArray
{
    NSArray *sectionsArray = @[@"Search", @"Active Users"];
    sectionsArray = [sectionsArray arrayByAddingObjectsFromArray:[NSArray arrayWithArray:[self getLettersArray]]];
    
    if (searchResults != nil) {
        sectionsArray = [sectionsArray arrayByAddingObject:@"Search Results"];
    }

    return sectionsArray;
}

- (NSArray *)getSectionTitlesArray
{
    NSArray *sectionsArray = @[@"+",@"*"];
    sectionsArray = [sectionsArray arrayByAddingObjectsFromArray:[NSArray arrayWithArray:[self getLettersArray]]];
    
    if (searchResults != nil) {
        sectionsArray = [sectionsArray arrayByAddingObject:@"*"];
    }

    return sectionsArray;
}

- (NSMutableDictionary *)getContactsDict {
//    _dictOfContacts = [self getContacts];
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    
    if (isShowingSearchTable) {
        
        for(id key in [_dictOfContacts allKeys]) {
            
            NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"name contains[c] %@", searchString];
            NSArray *filteredResults = [(NSArray *)[_dictOfContacts objectForKey:key] filteredArrayUsingPredicate:resultPredicate];
            
            [dictionary setObject:filteredResults forKey:key];
        }

        [dictionary setObject:[NSArray arrayWithArray:searchResults] forKey:@"Search Results"];
        
    }
    else {
        dictionary = _dictOfContacts;
    }

    return dictionary;
}

#pragma mark -
#pragma mark View Did Load/Unload

- (void)viewDidLoad
{
    [super viewDidLoad];
    _dictOfContacts = [self getContacts];
    _filteredDictOfContacts = [self getContacts];

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updatingContactsBook) name:kUpdatingContactsBook object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updatedContactsBook) name:kUpdatedContactsBook object:nil];
    
    _tableView.sectionIndexBackgroundColor = [UIColor clearColor];
    
    searchResults = [[NSArray alloc] initWithObjects: nil];
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
    _tableView.contentOffset = CGPointMake(0, ROW_HEIGHT_SEARCH);
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
}

- (void)updatedContactsBook {
    _updatingContactsView.hidden = YES;
    _dictOfContacts = [self getContacts];
    [_tableView reloadData];
}

#pragma mark -
#pragma mark UITableView Datasource/Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[self getSectionsArray] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSString *title = [[self getSectionsArray] objectAtIndex:section];
    
    if ([title isEqualToString:@"Search"]) {
        return 1;
    }

    if ([title isEqualToString:@"Search Results"]) {
        if (searchResults == nil) {
            return 1;
        }
        else {
            return 1;//[searchResults count];
        }
    }
    
    NSMutableArray *arr = [[self getContactsDict] objectForKey:title];
    return [arr count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return ROW_HEIGHT_SEARCH;
    }
    return ROW_HEIGHT;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    
    if (isShowingSearchTable) {
        NSString *key = [[self getSectionsArray] objectAtIndex:section];
        NSMutableArray *arr = [[self getContactsDict] objectForKey:key];
        if ([arr count] == 0) {
            return 0;
        }
    }

    return UITableViewAutomaticDimension;
}

- (NSString *)sectionTitleForIndexPath:(NSIndexPath *)indexPath
{
    return [[self getSectionsArray] objectAtIndex:indexPath.section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    if ([[self sectionTitleForIndexPath:indexPath] isEqualToString:@"Search"]) {
        if (_cellSearch == nil) {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"SearchCellView" owner:self options:nil];
            _cellSearch = (UITableViewCell *)[nib objectAtIndex:0];
        }
        return _cellSearch;
    }
    

    static NSString *cellMainNibID = @"cellMain";
    
    _cellMain = [tableView dequeueReusableCellWithIdentifier:cellMainNibID];
    if (_cellMain == nil) {
        [[NSBundle mainBundle] loadNibNamed:@"ContactCellView" owner:self options:nil];
    }

    
    UILabel *contactName = (UILabel *)[_cellMain viewWithTag:1];
    UIButtonForRow *addButton = (UIButtonForRow *)[_cellMain viewWithTag:2];
    UIButtonForRow *textAddButton = (UIButtonForRow *)[_cellMain viewWithTag:3];

    if ([[self sectionTitleForIndexPath:indexPath] isEqualToString:@"Search Results"] && [searchResults count] == 0) {
        contactName.text = @"No users found";
        textAddButton.hidden = YES;
        addButton.hidden = YES;
        return _cellMain;
    }

    NSString *sectionTitle = [self sectionTitleForIndexPath:indexPath];
    NSMutableArray *sectionForKey = [[self getContactsDict] objectForKey:sectionTitle];
    NSMutableDictionary *currentContact = [sectionForKey objectAtIndex:indexPath.row];
    contactName.text = [currentContact valueForKey:@"name"];
    if (![currentContact valueForKey:@"name"]) {
        contactName.text = [currentContact valueForKey:@"username"];
    }

    if ([currentContact valueForKey:@"isFollowed"])
    {
        addButton.hidden = YES;
        textAddButton.hidden = YES;
    }
    else {
        if (indexPath.section == 1 || [[self sectionTitleForIndexPath:indexPath] isEqualToString:@"Search Results"]) {
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
    if (section == 0) {
        return nil;
    }

    return [[self getSectionsArray] objectAtIndex:section];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGPoint offset = scrollView.contentOffset;
    float y = offset.y;
    if (y < 1 ) {
        [_searchBarView becomeFirstResponder];
    }

    if (y > ROW_HEIGHT_SEARCH-5) {
        if ([_searchBarView isFirstResponder] &&
            ([searchString isEqualToString:@""] || searchString == nil)) {
            [self cancelSearch];
        }
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    
    CGPoint offset = scrollView.contentOffset;
    float y = offset.y;
    
    if (y > 5 && y < ROW_HEIGHT_SEARCH) {
        CGPoint pt = scrollView.contentOffset;
        pt.y = ROW_HEIGHT_SEARCH;
        [scrollView setContentOffset:pt animated:YES];
    }
    else if (y <= 5) {
        CGPoint pt = scrollView.contentOffset;
        pt.y = 0;
        [scrollView setContentOffset:pt animated:YES];
    }

}

#pragma mark -
#pragma mark UISearchDisplayController Datasource/Delegate


- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    isShowingSearchTable = YES;
    searchString = searchText;
//    [_tableView reloadData];

    [PFCloud callFunctionInBackground:@"searchUsers"
                       withParameters:@{@"searchQuery": searchString}
                                block:^(NSArray *results, NSError *error) {
                                    if (!error) {
                                        // this is where you handle the results and change the UI.
                                        searchResults = results;
                                        NSIndexSet *section = [NSIndexSet indexSetWithIndex:[[self getSectionsArray] count]-1];
                                        [self.tableView reloadSections:section withRowAnimation:UITableViewRowAnimationNone];
                                    }
                                }];
    
    
    NSRange range = NSMakeRange(1, [[self getSectionsArray] count]-1);
    NSIndexSet *section = [NSIndexSet indexSetWithIndexesInRange:range];
    [self.tableView reloadSections:section withRowAnimation:UITableViewRowAnimationNone];
    
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [self cancelSearch];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self cancelSearch];
}

- (void)cancelSearch {
    isShowingSearchTable = NO;
    searchString = nil;
    [_searchBarView resignFirstResponder];
    [_searchBarView setText:@""];
    [_tableView reloadData];
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar
{
    return YES;
}


# pragma mark -
# pragma mark Button Methods


- (void)btnAdd:(id)sender {
    
    UIButtonForRow *btn = (UIButtonForRow *)sender;
    NSIndexPath *indexPath = btn.indexPath;
    
    NSString *sectionTitle = [[self getSectionsArray] objectAtIndex:indexPath.section];
    NSMutableArray *sectionForKey = [[self getContactsDict] objectForKey:sectionTitle];
    NSManagedObject *currentContact = [sectionForKey objectAtIndex:indexPath.row];
    NSString *mobileNumber = [currentContact valueForKey:@"phone"];
    
    if (!mobileNumber) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Wait" message:@"User could not be added." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:@"OK", nil];
        [alert show];
        return;
    }

    PFQuery *query = [PFUser query];
    [query whereKey:@"phone" equalTo:mobileNumber];
    [query findObjectsInBackgroundWithBlock:^(NSArray *users, NSError *error) {
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
                    ActivityView *activityView = [[ActivityView alloc] initWithFrame:CGRectMake(0.f, 0.f, self.view.frame.size.width, self.view.frame.size.height)];
                    [activityView setText:msg];
                    [activityView layoutSubviews];
                    [activityView.activityIndicator startAnimating];
                    [self.view addSubview:activityView];
                    [activityView disappearInSeconds:1];
                    
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
    }];
    
}

-(void)btnMessage:(id)sender
{
    UIButtonForRow *btn = (UIButtonForRow *)sender;
    NSIndexPath *indexPath = btn.indexPath;
    
    NSString *sectionTitle = [[self getSectionsArray] objectAtIndex:indexPath.section];
    NSMutableArray *sectionForKey = [[self getContactsDict] objectForKey:sectionTitle];
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
    [self.navigationController popViewControllerAnimated:YES];

}

#pragma mark -
#pragma mark Default System Code

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
