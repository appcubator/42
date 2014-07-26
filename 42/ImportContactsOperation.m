//
//  ImportContactsOperation.m
//  42
//
//  Created by Ilter Canberk on 7/24/14.
//  Copyright (c) 2014 Appcubator. All rights reserved.
//

#import "ImportContactsOperation.h"
#import "Store.h"
#import <CoreData/CoreData.h>
#import <AddressBook/AddressBook.h>
#import "NBPhoneNumberUtil.h"
#import <Parse/Parse.h>


@interface ImportContactsOperation ()
@property (nonatomic, strong) Store* store;
@property (nonatomic, strong) NSManagedObjectContext* context;
@end

static const int ImportBatchSize = 200;

@implementation ImportContactsOperation
{
    
}

- (id)initWithStore:(Store*)store
{
    self = [super init];
    if(self) {
        self.store = store;
    }
    return self;
}


- (void)main
{
    // TODO: can we use new in the name? I think it's bad style, any ideas for a better name?
    self.context = [self.store newPrivateContext];
    self.context.undoManager = nil;
    
    [self.context performBlockAndWait:^
     {
        [self import];
     }];
}

- (void)import
{
    
    ABAddressBookRef m_addressbook = ABAddressBookCreateWithOptions(NULL, NULL);
    
    if (!m_addressbook) {
        NSLog(@"Problem opening address book");
    }
    
    CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople(m_addressbook);
    CFIndex nPeople = ABAddressBookGetPersonCount(m_addressbook);
    NSInteger progressGranularity = nPeople/100;

    NSMutableArray *newContacts = [[NSMutableArray alloc] init];

    for (int i=0;i < nPeople; i++) {
        
        // get the record from address book
        ABRecordRef ref = CFArrayGetValueAtIndex(allPeople,i);
        NSInteger recordID = ABRecordGetRecordID(ref);
        // create a unique string for identification
        NSString *recordIDStr = [NSString stringWithFormat:@"%ld", (long)recordID];
        
        // check if the user already exists
        if (![self isUserUnique:recordIDStr]) {
            continue;
        }
        
        NSManagedObject *dOfPerson;
        dOfPerson = [NSEntityDescription
                     insertNewObjectForEntityForName:@"ContactModel"
                     inManagedObjectContext:self.context];


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
        
        NSString *mobileNumber;
        //For Phone number
        for(CFIndex i = 0; i < ABMultiValueGetCount(phones); i++) {
            CFStringRef mobileLabelref = ABMultiValueCopyLabelAtIndex(phones, i);
            CFStringRef mobileNumberref = ABMultiValueCopyValueAtIndex(phones, i);
            
            NSString *mobileLabel = (NSString *) CFBridgingRelease(mobileLabelref);
            mobileNumber = (NSString *) CFBridgingRelease(mobileNumberref);
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
        if (mobileNumber) {
            [newContacts addObject:mobileNumber];
        }
        
        CFRelease(ref);
        if (firstName != nil) { CFRelease(firstName); }
        if (lastName != nil) { CFRelease(lastName); }
        
        if (i % progressGranularity == 0) {
            self.progressCallback(i / (float) nPeople);
        }
        if (i % ImportBatchSize == 0) {
            [self.context save:NULL];
        }
        
    }
    
    NSError *error;
    [self.context save:&error];
    
    if (error != nil) {
        NSLog(@"Error %@",error);
    }
    
    [self queryNewContactsFor42Activity: newContacts];
    [self queryAllNumbersFor42activity];
    [self queryUsersForFollowing];
    //queryusersforfollowed

    self.progressCallback(1);
    
}

- (BOOL)isUserUnique:(NSString *)ab_id
{

    NSManagedObjectContext *moc = self.context;
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

// newContactNumbers is an array of phone numbers
- (void)queryNewContactsFor42Activity:(NSMutableArray *)newContactNumbers {
    PFQuery *query = [PFUser query];
    [query whereKey:@"phone" containedIn:newContactNumbers];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        [self updateContactsWithUsers: objects];
    }];
}

- (void)queryAllNumbersFor42activity
{
    /* NEED TO PERIODICALLY DO THIS (once every 2 days?) */
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSDate *currentDate = [NSDate date];
    NSDate *previousCheck = [prefs objectForKey:@"previousQueryAllNumbersFor42activity"];
    
    NSTimeInterval interval = [currentDate timeIntervalSinceDate:previousCheck];
    int second = 1;
    int minute = second*60;
    int hour = minute*60;
    int day = hour*24;
    // interval can be before (negative) or after (positive)
    int num = abs(interval);
    num /= day;
    
    if (previousCheck == nil || num >= 2) {

        NSManagedObjectContext *moc = self.context;
        NSEntityDescription *entityDescription = [NSEntityDescription
                                                  entityForName:@"ContactModel" inManagedObjectContext:moc];
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        [request setEntity:entityDescription];
        
        NSError *error = nil;
        NSArray *array = [moc executeFetchRequest:request error:&error];
        if (array == nil) { NSLog(@"%@",error); }
        
        NSMutableArray *contactNumbers = [array valueForKey:@"phone"];
        
        PFQuery *query = [PFUser query];
        [query whereKey:@"phone" containedIn:contactNumbers];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            [self updateContactsWithUsers: objects];
        }];
        
        [prefs setObject:currentDate forKey:@"previousQueryAllNumbersFor42activity"];
        [prefs synchronize];

    }
    
}

- (void)queryUsersForFollowing {
    
    // Do any additional setup after loading the view from its nib.
    PFQuery *query = [PFQuery queryWithClassName:@"Follow"];
    [query includeKey:@"to"];
    [query whereKey:@"from" equalTo: [PFUser currentUser]];
    query.cachePolicy = kPFCachePolicyNetworkElseCache;
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            // The find succeeded.
            [self updateContactsWithIsFollowed:objects];
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];

}

- (void)updateContactsWithIsFollowed:(NSArray *)array {
    
    for (PFObject *obj in array) {
        PFUser *user = obj[@"to"];
        NSManagedObjectContext *context = self.context;
        NSEntityDescription *entityDescription = [NSEntityDescription
                                                  entityForName:@"ContactModel" inManagedObjectContext:context];
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        [request setEntity:entityDescription];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:
                                  @"phone = %@",user[@"phone"]];

        [request setPredicate:predicate];
        
        NSError *error = nil;
        NSArray *array = [context executeFetchRequest:request error:&error];
        if ([array count] > 0) {
            NSManagedObject* userObject = [array objectAtIndex:0];
            [userObject setValue:user.objectId forKey:@"user_id"];
            [userObject setValue:[NSNumber numberWithBool:YES] forKey:@"isFollowed"];
            [userObject setValue:[NSNumber numberWithBool:YES] forKey:@"is42user"];
        }
        
        [context save:&error];
        
        if (error != nil) {
            NSLog(@"%@",error);
        }
    }

    self.progressCallback(3);
}

- (void)updateContactsWithUsers:(NSArray *)array {
    
    for (PFUser *user in array) {
        NSManagedObjectContext *context = self.context;
        NSEntityDescription *entityDescription = [NSEntityDescription
                                                  entityForName:@"ContactModel" inManagedObjectContext:context];
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        [request setEntity:entityDescription];
        
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

    self.progressCallback(2);
}

@end
