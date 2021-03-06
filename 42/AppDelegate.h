//
//  AppDelegate.h
//  42
//
//  Created by Ilter Canberk on 5/21/14.
//  Copyright (c) 2014 Appcubator. All rights reserved.
//

#define PAWLocationAccuracy double

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "MainViewController.h"
#import <dispatch/dispatch.h>
#import "Store.h"

dispatch_queue_t backgroundQueue;

// In the app delegate we create a constant string to be used as an event name
static NSString* const kLocationSentUpdatedNotification= @"kLocationSentUpdateNotification";
static NSString* const kLocationSentUpdatingNotification= @"kLocationSentUpdatingNotification";
static NSString* const kShowLocationWithId= @"kShowLocationWithId";
static NSString* const kUpdatingContactsBook=@"kUpdatingContactsBook";
static NSString* const kUpdatedContactsBook=@"kUpdatedContactsBook";

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UIViewController *viewController;
@property (nonatomic, strong) MainViewController *mainViewController;

@property (nonatomic, strong) CLLocation *currentLocation;
@property (nonatomic, strong) NSString *currentMessage;
@property (nonatomic, strong) NSMutableArray *arrayOfLocationSent;

//@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;

@property (nonatomic, strong) NSOperationQueue* operationQueue;

@property (nonatomic, strong) Store* store;

- (void)presentWelcomeViewController;
- (void)presentMainViewController;
- (void)sendLocationTo:(NSMutableArray *)receivers withBlock:(void (^)(void))callbackBlock;
- (void)updateLocationSent;
- (void)logout;
- (MainViewController *)getMainViewController;
- (NSArray *)getUnregisteredContacts;
- (NSArray *)getRegisteredContacts;
- (NSString *)getUserWithId: (NSString *)objectId;

@end
