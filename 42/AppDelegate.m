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

#import "ImportContactsOperation.h"
#import "Crittercism.h"
#import "AppDelegate.h"
#import "WelcomeViewController.h"
#import "MainViewController.h"
#import "NBPhoneNumberUtil.h"
#import "UserVerificationViewController.h"

@implementation AppDelegate

- (id)init
{

    if (![super init]) return nil;
    self.operationQueue = [[NSOperationQueue alloc] init];
    return self;
}

- (void)sendLocationTo:(NSMutableArray *)receivers withBlock:(void (^)(void))callbackBlock
{

    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"locationSent" object:self];

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
        
        if (_currentMessage != nil) {
            [locationSentObject setObject:_currentMessage forKey:@"message"];
        }

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
    backgroundQueue = dispatch_queue_create("com.contacts", NULL);

    // [self setUpCoreDataStack];
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

    // ****************************************************************************
    // Parse initialization
    [Crittercism enableWithAppID: @"53cfd85907229a440e000002"];
    
    
	if ([PFUser currentUser]) {
        
        
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        NSString *usrString = [NSString stringWithFormat:@"isVerified-%@", [PFUser currentUser].username];
        NSString *isVerified = [prefs stringForKey:usrString];
        BOOL boolValue = [[PFUser currentUser][@"validatedPhone"] boolValue];
        
        if ([isVerified isEqualToString:@"YES"] || boolValue == YES) {

            [self checkForAddressBookPermissions];
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

- (NSManagedObjectContext *) managedObjectContext {
    return self.store.mainManagedObjectContext;
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
    NSLog(@"%@",userInfo);
    
    if ( application.applicationState == UIApplicationStateActive ) {
        // already on the foreground
    }
    else {
        
        NSString *objectId = [userInfo valueForKey:@"objectId"];
        
        if (objectId != nil) {
            [self updateLocationSentWithBlock: ^() {
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
    
    return @[];
    
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

- (NSObject *)getUserWithId: (NSString *)objectId {
    
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
    
    return @[];

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
    //[self checkForFollowing];
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
    
    ImportContactsOperation* operation = [[ImportContactsOperation alloc] initWithStore:self.store];
    operation.progressCallback = ^(float progress) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^
         {
             NSLog(@"%f",progress);
         }];
    };
    [self.operationQueue addOperation:operation];
    
//    NSLog(@"Queue operations count = %lu",(unsigned long)[self.operationQueue isExecuting]);
//    NSLog(@"Queue isSuspended = %d",[self.operationQueue isSuspended]);
//    NSLog(@"Operation isCancelled? = %d",[self.operationQueue isCancelled]);
//    NSLog(@"Operation isConcurrent? = %d",[self.operationQueue isConcurrent]);
//    NSLog(@"Operation isFinished? = %d",[self.operationQueue isFinished]);
//    NSLog(@"Operation isExecuted? = %d",[self.operationQueue isExecuting]);
//    NSLog(@"Operation isReady? = %d",[self.operationQueue isReady]);
//    NSLog(@"Operation dependencies? = %d",[[self.operationQueue dependencies] count]);

    

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
    
    for (PFUser *user in array) {
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
            [userObject setValue:user.objectId forKey:@"user_id"];
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
    [ self updateLocationSentWithBlock:nil];
}

- (void)updateLocationSentWithBlock:(void (^)(void))callBackBlock
{
    
    [[NSNotificationCenter defaultCenter] postNotificationName: kLocationSentUpdatingNotification
                                                        object:nil];
    
    PFQuery *query = [PFQuery queryWithClassName:@"LocationSent"];
    [query includeKey:@"from"];
    [query whereKey:@"to" equalTo: [PFUser currentUser]];
    [query orderByDescending:@"date"];
    query.limit = 40;
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            
            _arrayOfLocationSent = [NSMutableArray arrayWithArray:objects];
            [[NSNotificationCenter defaultCenter] postNotificationName: kLocationSentUpdatedNotification
                                                                object:nil];
            if (callBackBlock) {
                callBackBlock();
            }
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
