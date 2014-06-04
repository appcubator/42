//
//  AppDelegate.m
//  42
//
//  Created by Ilter Canberk on 5/21/14.
//  Copyright (c) 2014 Appcubator. All rights reserved.
//

static NSString * const defaultsFilterDistanceKey = @"filterDistance";
static NSString * const defaultsLocationKey = @"currentLocation";

#import "AppDelegate.h"
#import "WelcomeViewController.h"
#import "MainViewController.h"
#import "NBPhoneNumberUtil.h"

#import <Parse/Parse.h>
#import <CoreData/CoreData.h>
#import <AddressBook/AddressBook.h>

@implementation AppDelegate

- (void)sendLocationTo:(NSMutableArray *)receivers withBlock:(void (^)(void))callbackBlock
{

    NSMutableArray *locationSentList = [[NSMutableArray alloc] init];
    PFUser *currentUser = [PFUser currentUser];

    PFGeoPoint *currentPoint = [PFGeoPoint geoPointWithLatitude:_currentLocation.coordinate.latitude longitude: _currentLocation.coordinate.longitude];
    
    for (id user in receivers)
    {
        PFUser *sendTo = (PFUser *)user;
        PFObject *locationSentObject = [PFObject objectWithClassName:@"LocationSent"];
        [locationSentObject setObject:currentUser forKey:@"from"];
        [locationSentObject setObject:sendTo forKey:@"to"];
        [locationSentObject setObject:[NSDate date] forKey:@"date"];
        [locationSentObject setObject:currentPoint forKey:@"location"];
        
        [locationSentList addObject:locationSentObject];
    }

    [PFObject saveAllInBackground:[NSArray arrayWithArray:locationSentList] block:^(BOOL succeeded,NSError *error) {
        if (error) {
            NSLog(@"Error saving: %@",error);
        }
        else {
            callbackBlock();
        }
    }];
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [self setUpCoreDataStack];
    // Override point for customization after application launch.
	
	// ****************************************************************************
    // Parse initialization
	[Parse setApplicationId:@"ybAaEabpmAwfz7FlsrQs60VcQroYtSDqBoFMFQlc" clientKey:@"YNDq2AksL9g3XbIN3ELq1G1GDP8BrhvbIQVtXzfk"];
	// ****************************************************************************
    // Register for push notifications
    [application registerForRemoteNotificationTypes:
     UIRemoteNotificationTypeBadge |
     UIRemoteNotificationTypeAlert |
     UIRemoteNotificationTypeSound];
    
	// Grab values from NSUserDefaults:
	// NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
	if ([PFUser currentUser]) {
        [self checkForAddressBookPermissions];
        [self presentMainViewController];
	} else {
		// Go to the welcome screen and have them log in or create an account.
		[self presentWelcomeViewController];
	}
	
	[PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
	
    [self.window makeKeyAndVisible];
    return YES;

}

-(void)setUpCoreDataStack
{
    NSManagedObjectModel *model = [NSManagedObjectModel mergedModelFromBundles:[NSBundle allBundles]];
    NSPersistentStoreCoordinator *psc = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
    
    NSURL *url = [[[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject] URLByAppendingPathComponent:@"db_dev.sqlite"];
    
    NSDictionary *options = @{NSPersistentStoreFileProtectionKey: NSFileProtectionComplete,
                              NSMigratePersistentStoresAutomaticallyOption:@YES};
    NSError *error = nil;
    NSPersistentStore *store = [psc addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:url options:options error:&error];
    if (!store)
    {
        NSLog(@"Error adding persistent store. Error %@",error);
        
        NSError *deleteError = nil;
        if ([[NSFileManager defaultManager] removeItemAtURL:url error:&deleteError])
        {
            error = nil;
            store = [psc addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:url options:options error:&error];
        }
        
        if (!store)
        {
            // Also inform the user...
            NSLog(@"Failed to create persistent store. Error %@. Delete error %@",error,deleteError);
            abort();
        }
    }
    
    self.managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    self.managedObjectContext.persistentStoreCoordinator = psc;
}

- (void)application:(UIApplication *)application
didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)newDeviceToken {
    // Store the deviceToken in the current installation and save it to Parse.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:newDeviceToken];
    if ([PFUser currentUser]) {
        [currentInstallation setObject:[PFUser currentUser] forKey:@"user"];
    }
    [currentInstallation saveInBackground];

}

- (void)application:(UIApplication *)application
didReceiveRemoteNotification:(NSDictionary *)userInfo {
    // Handle the push here
    [PFPush handlePush:userInfo];
    [self updateLocationSent];
}

- (MainViewController *)getMainViewController
{
    if (_mainViewController == nil)
    {
        self.mainViewController = [[MainViewController alloc] init];
    }
    
    return _mainViewController;
}

- (void)presentMainViewController {
	
    UINavigationController *navController = nil;
    navController = [[UINavigationController alloc] initWithRootViewController:[self getMainViewController]];
    navController.navigationBarHidden = YES;
    self.viewController = navController;
    self.window.rootViewController = self.viewController;
}


- (void)presentWelcomeViewController {
	// Go to the welcome screen and have them log in or create an account.
	WelcomeViewController *welcomeViewController = [[WelcomeViewController alloc] initWithNibName:@"WelcomeView" bundle:nil];
	UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:welcomeViewController];
	navController.navigationBarHidden = YES;
    
	self.viewController = navController;
	self.window.rootViewController = self.viewController;
}


							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (NSArray *)getUnregisteredContacts {
    
    NSManagedObjectContext *moc = [self managedObjectContext];
    NSEntityDescription *entityDescription = [NSEntityDescription
                                              entityForName:@"ContactModel" inManagedObjectContext:moc];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    
    // Set example predicate and sort orderings...
    NSPredicate *predicate = [NSPredicate predicateWithFormat:
                              @"username = nil"];
    [request setPredicate:predicate];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]
                                        initWithKey:@"name" ascending:YES];
    [request setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];

    NSError *error = nil;
    NSArray *array = [moc executeFetchRequest:request error:&error];
    if (array == nil)
    {
        NSLog(@"get unregistered %@",error);
    }
    
    return array;
}

- (NSArray *)getRegisteredContacts {
    
    NSManagedObjectContext *moc = [self managedObjectContext];
    NSEntityDescription *entityDescription = [NSEntityDescription
                                              entityForName:@"ContactModel" inManagedObjectContext:moc];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    
    // Set example predicate and sort orderings...
    NSPredicate *predicate = [NSPredicate predicateWithFormat:
                              @"username != nil"];
    [request setPredicate:predicate];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]
                                        initWithKey:@"name" ascending:YES];
    [request setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    
    NSError *error = nil;
    NSArray *array = [moc executeFetchRequest:request error:&error];
    if (array == nil)
    {
        NSLog(@"get registered %@",error);
    }
    
    NSLog(@"%@",array);
    
    return array;
}

- (void)checkForAddressBookPermissions
{
    // Request authorization to Address Book
    ABAddressBookRef addressBookRef = ABAddressBookCreateWithOptions(NULL, NULL);
    
    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined) {
        
        ABAddressBookRequestAccessWithCompletion(addressBookRef, ^(bool granted, CFErrorRef error) {
            if (granted) {
                [self cacheAllContacts];
            } else {
                // User denied access
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"App wont werk!" message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
                [alertView show];
            }
        });
    }
    else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized) {
        // The user has previously given access, add the contact
        [self checkForAddressBookUpdates];
    }
    else {
        // The user has previously denied access
        // Send an alert telling user to change privacy setting in settings app
    }
    
}

- (void)checkForAddressBookUpdates {
    [self cacheAllContacts];
    [self checkForFollowing];
}

- (void)checkForFollowing {
    PFQuery *query = [PFQuery queryWithClassName:@"Follow"];
    [query includeKey:@"to"];
    [query whereKey:@"from" equalTo: [PFUser currentUser]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *arr, NSError *error) {
        if (!error) {
            // The find succeeded.
            for (PFObject *obj in arr) {
                PFUser *user = obj[@"to"];
                
                NSManagedObjectContext *context = [self managedObjectContext];
                NSEntityDescription *entityDescription = [NSEntityDescription
                                                          entityForName:@"ContactModel" inManagedObjectContext:context];
                NSFetchRequest *request = [[NSFetchRequest alloc] init];
                [request setEntity:entityDescription];
                
                // Set example predicate and sort orderings ...
                NSPredicate *predicate = [NSPredicate predicateWithFormat:
                                          @"username = %@",[user username]];
                [request setPredicate:predicate];
                
                NSError *error = nil;
                NSArray *array = [context executeFetchRequest:request error:&error];
                if ([array count] > 0) {
                    NSManagedObject* userObject = [array objectAtIndex:0];
                    [userObject setValue:[NSNumber numberWithBool:YES] forKey:@"isFollowed"];
                    [userObject setValue:[NSNumber numberWithBool:YES] forKey:@"is42user"];
                }
                
                [context save:&error];
                
                if (error != nil) {
                    NSLog(@"%@",error);
                }
            }

        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}

- (void)cacheAllContacts
{
    
    NSManagedObjectContext *context =
    [self managedObjectContext];
    
    ABAddressBookRef m_addressbook = ABAddressBookCreateWithOptions(NULL, NULL);
    
    if (!m_addressbook) {
        NSLog(@"Problem opening address book");
    }
    
    CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople(m_addressbook);
    CFIndex nPeople = ABAddressBookGetPersonCount(m_addressbook);
    
    for (int i=0;i < nPeople; i++) {
        
        ABRecordRef ref = CFArrayGetValueAtIndex(allPeople,i);
        NSInteger recordID = ABRecordGetRecordID(ref);
        NSString *recordIDStr = [NSString stringWithFormat:@"%d", recordID];
        
        if (![self isUserUnique:recordIDStr]) {
            continue;
        }

        NSManagedObject *dOfPerson;
        dOfPerson = [NSEntityDescription
                     insertNewObjectForEntityForName:@"ContactModel"
                     inManagedObjectContext:context];
        
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
        
        [dOfPerson setValue:fullName forKey:@"name"];
        [dOfPerson setValue:recordIDStr forKey:@"ab_id"];

        //For Email ids
        ABMutableMultiValueRef eMail  = ABRecordCopyValue(ref, kABPersonEmailProperty);
        
        CFStringRef emailRef = ABMultiValueCopyValueAtIndex(eMail, 0);
        NSString *email = (NSString *) CFBridgingRelease(emailRef);
        if (email != nil) {
            [dOfPerson setValue:email forKey:@"email"];
        }
        
        NBPhoneNumberUtil *phoneUtil = [NBPhoneNumberUtil sharedInstance];
        NSError *aError = nil;

        //For Phone number
        for(CFIndex i = 0; i < ABMultiValueGetCount(phones); i++) {
            CFStringRef mobileLabelref = ABMultiValueCopyLabelAtIndex(phones, i);
            CFStringRef mobileNumberref = ABMultiValueCopyValueAtIndex(phones, i);
            
            NSString *mobileLabel = (NSString *) CFBridgingRelease(mobileLabelref);
            NSString *mobileNumber = (NSString *) CFBridgingRelease(mobileNumberref);
            NBPhoneNumber *userNumber = [phoneUtil parse:mobileNumber
                                           defaultRegion:@"US" error:&aError];

            if ([phoneUtil isValidNumber:userNumber]) {
                mobileNumber = [phoneUtil format:userNumber
                                numberFormat:NBEPhoneNumberFormatE164
                                           error:&aError];
            }

            if([mobileLabel isEqualToString:(NSString *)kABPersonPhoneMobileLabel])
            {
                [dOfPerson setValue:mobileNumber forKey:@"phone"];
                break;
            }
            else if ([mobileLabel isEqualToString:(NSString*)kABPersonPhoneIPhoneLabel])
            {
                [dOfPerson setValue:mobileNumber forKey:@"phone"];
                break;
            }
            else {
                [dOfPerson setValue:mobileNumber forKey:@"phone"];
            }
            
        }
        
        CFRelease(ref);
        if (firstName != nil) { CFRelease(firstName); }
        if (lastName != nil) { CFRelease(lastName); }
        
    }
    

    NSError *error;
    [context save:&error];
    
    if (error != nil) {
        NSLog(@"yolo1 %@",error);
    }
    
    [self queryAllNumbersFor42activity];
}

- (void)queryAllNumbersFor42activity
{
    NSManagedObjectContext *moc = [self managedObjectContext];
    NSEntityDescription *entityDescription = [NSEntityDescription
                                              entityForName:@"ContactModel" inManagedObjectContext:moc];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    
    NSError *error = nil;
    NSArray *array = [moc executeFetchRequest:request error:&error];
    if (array == nil)
    {
        NSLog(@"%@",error);
    }
    
    NSMutableArray *contactNumbers = [array valueForKey:@"phone"];

    PFQuery *query = [PFUser query];
    [query whereKey:@"phone" containedIn:contactNumbers];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        [self updateContactsWithUsers: objects];
    }];
}

- (void)updateContactsWithUsers:(NSArray *)array {
    
    for (NSObject *user in array) {
        NSManagedObjectContext *context = [self managedObjectContext];
        NSEntityDescription *entityDescription = [NSEntityDescription
                                                  entityForName:@"ContactModel" inManagedObjectContext:context];
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        [request setEntity:entityDescription];
        
        // Set example predicate and sort orderings ...
        NSPredicate *predicate = [NSPredicate predicateWithFormat:
                                  @"phone = %@",[user valueForKey:@"phone"]];
        [request setPredicate:predicate];
        
        NSError *error = nil;
        NSArray *array = [context executeFetchRequest:request error:&error];
        if ([array count] > 0) {
            NSManagedObject* userObject = [array objectAtIndex:0];
            [userObject setValue:[user valueForKey:@"username"] forKey:@"username"];
            [userObject setValue:[NSNumber numberWithBool:YES] forKey:@"is42user"];
        }
        
        [context save:&error];
        
        if (error != nil) {
            NSLog(@"%@",error);
        }
    }
}

- (BOOL)isUserUnique:(NSString *)ab_id
{
    
    NSManagedObjectContext *moc = [self managedObjectContext];
    NSEntityDescription *entityDescription = [NSEntityDescription
                                              entityForName:@"ContactModel" inManagedObjectContext:moc];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    
    // Set example predicate and sort orderings ...
    NSPredicate *predicate = [NSPredicate predicateWithFormat:
                              @"ab_id = %@",ab_id];
    [request setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *array = [moc executeFetchRequest:request error:&error];

    return [array count] < 1;
}

- (void)updateLocationSent
{
    PFQuery *query = [PFQuery queryWithClassName:@"LocationSent"];
    [query includeKey:@"from"];
    [query whereKey:@"to" equalTo: [PFUser currentUser]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            // The find succeeded.
            NSArray *sortedLocations = [objects sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
                    PFObject *firstObj = (PFObject *)a;
                    PFObject *secondObj = (PFObject *)b;

                    NSDate *first =  firstObj[@"date"];
                    NSDate *second = secondObj[@"date"];
                
                    if (first == nil) return NSOrderedDescending;
                    if (second == nil) return NSOrderedAscending;

                    return [second compare:first];
            }];

            _arrayOfLocationSent = [NSMutableArray arrayWithArray:sortedLocations];

            [[NSNotificationCenter defaultCenter] postNotificationName: kLocationSentUpdateNotification
                                                                object:nil];
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}

- (void)logout
{
    [PFUser logOut];
    _arrayOfLocationSent = nil;
}

@end
