//
//  AppDelegate.m
//  42
//
//  Created by Ilter Canberk on 5/21/14.
//  Copyright (c) 2014 Appcubator. All rights reserved.
//

static NSString * const defaultsFilterDistanceKey = @"filterDistance";
static NSString * const defaultsLocationKey = @"currentLocation";

#import <Parse/Parse.h>
#import <CoreData/CoreData.h>
#import <AddressBook/AddressBook.h>
#import "Store.h"

#import "ImportContactsOperation.h"
//#import "Crittercism.h"
#import "AppDelegate.h"
#import "WelcomeViewController.h"
#import "MainViewController.h"
#import "NBPhoneNumberUtil.h"
#import "UserVerificationViewController.h"

@implementation AppDelegate

- (id)init
{
    
    self = [super init];
    if (self) {
        self.operationQueue = [[NSOperationQueue alloc] init];
        self.store = [[Store alloc] init];
    }
    return self;
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    backgroundQueue = dispatch_queue_create("com.contacts", NULL);
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber: 0];

    // Override point for customization after application launch.
	
	// ****************************************************************************
    // Parse initialization
    
#ifdef DEBUG
    // Development App
    [Parse setApplicationId:@"Kk5rpiC6gCU1Wn0pgTvG6JjCzhCuH9wpjw7H5W04" clientKey:@"xYH9fJ8DDbVEBf6jTcyn1VDwlofAuFLgiYaJmQjX"];
#else
    // Production App
    [Parse setApplicationId:@"ybAaEabpmAwfz7FlsrQs60VcQroYtSDqBoFMFQlc" clientKey:@"YNDq2AksL9g3XbIN3ELq1G1GDP8BrhvbIQVtXzfk"];
#endif
	
    // ****************************************************************************
    // Register for push notifications
    // 1
    
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert |
        UIUserNotificationTypeBadge |
        UIUserNotificationTypeSound categories:nil];
    [application registerUserNotificationSettings:settings];
    
    // ****************************************************************************
    // Parse initialization
//    [Crittercism enableWithAppID: @"53cfd85907229a440e000002"];
    

    
    
	if ([PFUser currentUser]) {
        
        
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        NSString *usrString = [NSString stringWithFormat:@"isVerified-%@", [PFUser currentUser].username];
        NSString *isVerified = [prefs stringForKey:usrString];
        BOOL boolValue = [[PFUser currentUser][@"validatedPhone"] boolValue];
        
        if ([isVerified isEqualToString:@"YES"] || boolValue == YES) {
            
            [self updateLocationSent];
            [self presentMainViewController];
            
        }
        else {
            UserVerificationViewController *loginViewController = [[UserVerificationViewController alloc] initWithNibName:nil bundle:nil];
            UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:loginViewController];
            navController.navigationBarHidden = YES;
            
            self.viewController = navController;
            self.window.rootViewController = self.viewController;
        }
        
	} else {
		// Go to the welcome screen and have them log in or create an account.
		[self presentWelcomeViewController];
	}
	
	[PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
	
    [self.window makeKeyAndVisible];
    return YES;
    
}

- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings {
    // 3
    if (notificationSettings.types != UIUserNotificationTypeNone) {
        // 4
        [application registerForRemoteNotifications];
    }
}


- (NSManagedObjectContext *) managedObjectContext {
    return self.store.mainManagedObjectContext;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)newDeviceToken {
    // Store the deviceToken in the current installation and save it to Parse.
    if ([PFUser currentUser]) {
        
        PFInstallation *currentInstallation = [PFInstallation currentInstallation];
        [currentInstallation setDeviceTokenFromData:newDeviceToken];
        if ([PFUser currentUser]) {
            [currentInstallation setObject:[PFUser currentUser] forKey:@"user"];
        }
        [currentInstallation saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (error) {
                NSLog(@"%@",error);
            }
        }];
    }
    
}

- (void)application:(UIApplication *)application
didReceiveRemoteNotification:(NSDictionary *)userInfo {
    
    if ( application.applicationState == UIApplicationStateActive ) {
        // already on the foreground
    }
    else {
        
        NSString *objectId = [userInfo valueForKey:@"objectId"];
        
        if (objectId != nil) {
            [self updateLocationSentWithBlock: ^() {
                [[self getMainViewController] movePanelToOriginalPosition];
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"objectId==%@", objectId];
                PFObject *locationSent = (PFObject *)[[_arrayOfLocationSent filteredArrayUsingPredicate:predicate] firstObject];
                
                if (locationSent) {
                    [[self getMainViewController].centerViewController showLocationSent:locationSent];
                }
            }];
        }
        else {
            [self updateLocationSent];
        }
        
    }
    
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
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber: 0];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


# pragma mark -
# pragma mark Application Startup Flow

- (void)presentMainViewController {
	
    [self checkForAddressBookPermissions];
    
    UINavigationController *navController = nil;
    [self getMainViewController].navController = navController;
    navController = [[UINavigationController alloc] initWithRootViewController:[self getMainViewController]];
    navController.navigationBarHidden = YES;
    
    self.viewController = navController;
    self.window.rootViewController = self.viewController;
    
    // ****************************************************************************
    // Register for push notifications
    
//    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
//     UIRemoteNotificationTypeBadge |
//     UIRemoteNotificationTypeAlert |
//     UIRemoteNotificationTypeSound];
    
}


- (void)presentWelcomeViewController {
	// Go to the welcome screen and have them log in or create an account.
	WelcomeViewController *welcomeViewController = [[WelcomeViewController alloc] initWithNibName:@"WelcomeView" bundle:nil];
	UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:welcomeViewController];
	navController.navigationBarHidden = YES;
    
	self.viewController = navController;
	self.window.rootViewController = self.viewController;
}


- (MainViewController *)getMainViewController
{
    if (_mainViewController == nil)
    {
        self.mainViewController = [[MainViewController alloc] init];
    }
    
    return _mainViewController;
}


// receivers is an NSString array of usernames

- (void)sendLocationTo:(NSMutableArray *)receivers withBlock:(void (^)(void))callbackBlock
{

    PFGeoPoint *currentPoint = [PFGeoPoint geoPointWithLatitude:_currentLocation.coordinate.latitude longitude: _currentLocation.coordinate.longitude];
    
    NSLog(@"%@",receivers);
    
    if (!_currentMessage) {
        _currentMessage = [NSNull null];
    }

    [PFCloud callFunctionInBackground:@"sendLocationToUsers"
                       withParameters:@{@"receivers":receivers,
                                        @"location": currentPoint,
                                        @"message": _currentMessage}
                                block:^(NSArray *objects, NSError *error) {
                                    
                                    if (!error) {
                                        [[NSNotificationCenter defaultCenter] postNotificationName: kLocationSentUpdatedNotification
                                                                                            object:nil];
                                        
                                        if(callbackBlock) {
                                            callbackBlock();
                                        }
                                    }
                                    else {
                                        NSLog(@"Error: %@ %@", error, [error userInfo]);
                                    }
                                }];
    
    [self updateRanksForUsers:receivers];

    
//    for (id user in receivers)
//    {
//        PFUser *sendTo = (PFUser *)user;
//        PFObject *locationSentObject = [PFObject objectWithClassName:@"LocationSent"];
//        [locationSentObject setObject:currentUser forKey:@"from"];
//        [locationSentObject setObject:sendTo forKey:@"to"];
//        [locationSentObject setObject:[NSDate date] forKey:@"date"];
//        [locationSentObject setObject:currentPoint forKey:@"location"];
//        
//        if (_currentMessage != nil) {
//            [locationSentObject setObject:_currentMessage forKey:@"message"];
//        }
//        
//        [locationSentList addObject:locationSentObject];
//        
//    }
    
//
//    [PFObject saveAllInBackground:[NSArray arrayWithArray:locationSentList] block:^(BOOL succeeded,NSError *error) {
//        if (error) {
//            NSLog(@"Error saving: %@",error);
//        }
//        else {
//            callbackBlock();
//        }
//    }];
//    
   
    [[NSNotificationCenter defaultCenter] postNotificationName:@"locationSent" object:self];
}

- (void)updateRanksForUsers:(NSMutableArray *)receivers {

    NSManagedObjectContext *moc = [self.store mainManagedObjectContext];
    NSEntityDescription *entityDescription = [NSEntityDescription
                                              entityForName:@"ContactModel" inManagedObjectContext:moc];
    
    for (NSString *username in receivers)
    {
        
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        [request setEntity:entityDescription];
        
        // Set example predicate and sort orderings...
        NSPredicate *predicate = [NSPredicate predicateWithFormat:
                                  @"username = %@", username];
        [request setPredicate:predicate];
        NSError *error = nil;
        NSArray *array = [moc executeFetchRequest:request error:&error];
        
        if ([array count] > 0)
        {
            NSManagedObject *userRecord = [array objectAtIndex:0];
            int count = [[userRecord valueForKey:@"rank"] intValue];
            if (!count) { count = 0; }
            count = count + 1;
            [userRecord setValue:[NSNumber numberWithInt:count] forKey:@"rank"];

        }
    }
    
    NSError *error = nil;
    [moc save:&error];

}

- (NSArray *)getUnregisteredContacts {
    
    
    NSManagedObjectContext *moc = [self.store mainManagedObjectContext];
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

- (NSManagedObject *)getUserWithId: (NSString *)objectId {
    
    NSLog(@"%@",objectId);
    
    NSManagedObjectContext *moc = [self managedObjectContext];
    NSEntityDescription *entityDescription = [NSEntityDescription
                                              entityForName:@"ContactModel" inManagedObjectContext:moc];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    
    // Set example predicate and sort orderings...
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"user_id == %@", objectId];
    [request setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *array = [moc executeFetchRequest:request error:&error];
    
    
    if (array == nil || [array count] == 0)
    {
        NSLog(@"Error: %@",error);
        return nil;
    }
    else {
        return [array firstObject];
    }
    
}

- (NSArray *)getRegisteredContacts {
    
    
    NSManagedObjectContext *moc = [self.store mainManagedObjectContext];
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
    
    
    return array;
}

- (void)checkForAddressBookPermissions
{
    // Request authorization to Address Book
    ABAddressBookRef addressBookRef = ABAddressBookCreateWithOptions(NULL, NULL);
    
    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined) {
        
        ABAddressBookRequestAccessWithCompletion(addressBookRef, ^(bool granted, CFErrorRef error) {
            if (granted) {
                [self updateCachedContacts];
            } else {
                // User denied access
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"App wont werk!" message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
                [alertView show];
            }
        });
    }
    else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized) {
        // The user has previously given access, add the contact
        [self updateCachedContacts];
    }
    else {
        // The user has previously denied access
        // Send an alert telling user to change privacy setting in settings app
    }
    
}

- (void)updateCachedContacts
{
    
//    [[NSNotificationCenter defaultCenter] postNotificationName: kUpdatingContactsBook object:nil];
//    
//    ImportContactsOperation* operation = [[ImportContactsOperation alloc] initWithStore:self.store];
//    operation.progressCallback = ^(float progress) {
//        [[NSOperationQueue mainQueue] addOperationWithBlock:^
//         {
//             NSLog(@"%f",progress);
//             if (progress == 1 || progress == 2 || progress == 3) {
//                 [[NSNotificationCenter defaultCenter] postNotificationName: kUpdatedContactsBook
//                                                                     object:nil];
//             }
//             
//         }];
//    };
//    
//    [self.operationQueue addOperation:operation];
    
}

- (void)updateLocationSent
{
    [ self updateLocationSentWithBlock:nil];
}

- (void)updateLocationSentWithBlock:(void (^)(void))callBackBlock
{
    
    [[NSNotificationCenter defaultCenter] postNotificationName: kLocationSentUpdatingNotification
                                                        object:nil];
    
    [PFCloud callFunctionInBackground:@"getLocationReceived"
                       withParameters:@{}
                                block:^(NSArray *objects, NSError *error) {
                                    if (!error) {
                                        // this is where you handle the results and change the UI.
                                        _arrayOfLocationSent = [NSMutableArray arrayWithArray:objects];
                                        [[NSNotificationCenter defaultCenter] postNotificationName: kLocationSentUpdatedNotification
                                                                                            object:nil];
                                        if (callBackBlock) {
                                            callBackBlock();
                                        }
                                        
                                    }
                                    else {
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
