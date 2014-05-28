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

#import <Parse/Parse.h>


@implementation AppDelegate

- (void)sendLocationTo:(NSMutableArray *)receivers withBlock:(void (^)(void))callbackBlock
{
    NSLog(@"Loctaion %@", _currentLocation);
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
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	
    
    
	if ([PFUser currentUser]) {
        [self presentMainViewController];
	} else {
		// Go to the welcome screen and have them log in or create an account.
		[self presentWelcomeViewController];
	}
	
	[PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
	
    [self.window makeKeyAndVisible];
    return YES;

}

- (void)application:(UIApplication *)application
didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)newDeviceToken {
    // Store the deviceToken in the current installation and save it to Parse.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:newDeviceToken];
    [currentInstallation setObject:[PFUser currentUser] forKey:@"user"];
    [currentInstallation saveInBackground];

}

- (void)application:(UIApplication *)application
didReceiveRemoteNotification:(NSDictionary *)userInfo {
    // Handle the push here
    [PFPush handlePush:userInfo];
}

- (void)presentMainViewController {
	UINavigationController *navController = nil;
    // Skip straight to the main view.
    MainViewController *mapViewController = [[MainViewController alloc] init];
    
    navController = [[UINavigationController alloc] initWithRootViewController:mapViewController];
    navController.navigationBarHidden = YES;

    self.viewController = navController;
    self.window.rootViewController = self.viewController;
}

- (void)presentWelcomeViewController {
	// Go to the welcome screen and have them log in or create an account.
	WelcomeViewController *welcomeViewController = [[WelcomeViewController alloc] initWithNibName:@"WelcomeView" bundle:nil];
	welcomeViewController.title = @"Welcome to Anywall";
	
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

- (void)updateLocationSent
{
    PFQuery *query = [PFQuery queryWithClassName:@"LocationSent"];
    [query includeKey:@"from"];
    [query includeKey:@"createdAt"];

    [query whereKey:@"to" equalTo: [PFUser currentUser]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            // The find succeeded.
            _arrayOfLocationSent = [NSMutableArray arrayWithArray:objects];
            NSLog(@"%@",_arrayOfLocationSent);
            [[NSNotificationCenter defaultCenter] postNotificationName: kLocationSentUpdateNotification
                                                                object:nil];
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}

@end
