//
//  SendToViewController.m
//  42
//
//  Created by Ilter Canberk on 5/24/14.
//  Copyright (c) 2014 Appcubator. All rights reserved.
//

#import "SendToViewController.h"
#import "AppDelegate.h"
#import <Parse/Parse.h>

#define ANIMATION_TIME 0.25

@interface SendToViewController ()

@end

@implementation SendToViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _arrayOfFollowers = [[NSMutableArray alloc] init];
        _arrayOfReceivers = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    PFQuery *query = [PFQuery queryWithClassName:@"Follow"];
    [query includeKey:@"from"];
    [query whereKey:@"to" equalTo: [PFUser currentUser]];
    query.cachePolicy = kPFCachePolicyNetworkElseCache;
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            // The find succeeded.
            _arrayOfFollowers = [NSMutableArray arrayWithArray:objects];
            [_tableView reloadData];
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark UITableView Datasource/Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_arrayOfFollowers count];
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
        [[NSBundle mainBundle] loadNibNamed:@"SendToCellView" owner:self options:nil];
    }
    
    UILabel *contactName = (UILabel *)[_cellMain viewWithTag:1];

    if ([_arrayOfFollowers count] > 0)
    {
        PFObject *currentFollow = [_arrayOfFollowers objectAtIndex:indexPath.row];
        PFUser* follower = currentFollow[@"from"];
        contactName.text = follower.username;
    }
    
    return _cellMain;
}

- (void) tableView: (UITableView *) tableView didSelectRowAtIndexPath: (NSIndexPath *) indexPath {

    UITableViewCell *cell = [self tableView:_tableView cellForRowAtIndexPath:indexPath];
    if ([_arrayOfReceivers containsObject:@(indexPath.row)]) {
        // already there
        [_arrayOfReceivers removeObject:@(indexPath.row)];
        cell.backgroundColor = [UIColor whiteColor];
    }
    else {
        [_arrayOfReceivers addObject:@(indexPath.row)];
        cell.contentView.backgroundColor = [UIColor greenColor];
    }
    
    [self setupListOfReceivers];
}

- (void) setupListOfReceivers
{
    if ([_arrayOfReceivers count] > 0) {
        NSMutableString *labelStr = [NSMutableString stringWithString:@""];

        int nmr = 0;
        for (id ind in _arrayOfReceivers) {
            NSInteger followerInd = [ind integerValue];
            PFObject *currentFollow = [_arrayOfFollowers objectAtIndex:followerInd];
            PFUser* follower = currentFollow[@"from"];
            [labelStr appendString:follower.username];
            nmr++;

            if (nmr < [_arrayOfReceivers count]) {
                [labelStr appendString:@", "];
            }
        }
        _sendToLabel.text = labelStr;
        
        [self displayBottomBar];
    }
    else {
        [self hideBottomBar];
    }
}

- (void)hideBottomBar {
    
    [UIView animateWithDuration:ANIMATION_TIME delay:0 options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         // hide the bottom bar
                         CGRect frame = _bottomBar.frame;
                         frame.origin.y = self.view.frame.size.height;
                         _bottomBar.frame = frame;
                     }
                     completion:^(BOOL finished) { }];
}

- (void)displayBottomBar {
    [UIView animateWithDuration:ANIMATION_TIME delay:0 options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         // display the bottom bar
                         CGRect frame = _bottomBar.frame;
                         frame.origin.y = self.view.frame.size.height - frame.size.height;
                         _bottomBar.frame = frame;
                     }
                     completion:^(BOOL finished) { }];
}

- (IBAction)btnSendTo:(id)sender {
	AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];

    NSMutableArray *listOfReceivers = [[NSMutableArray alloc] init];
    
    for (id ind in _arrayOfReceivers) {
        NSInteger followerInd = [ind integerValue];
        PFObject *currentFollow = [_arrayOfFollowers objectAtIndex:followerInd];
        PFUser* follower = currentFollow[@"from"];
        [listOfReceivers addObject:follower];
    }
    
    [appDelegate sendLocationTo:listOfReceivers withBlock:^(void) {
        [self resetData];
        [self.navigationController popViewControllerAnimated:YES];
    }];
}

- (IBAction)btnBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)resetData
{
    
}


@end
