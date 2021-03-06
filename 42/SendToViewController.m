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
#import <CoreData/CoreData.h>

#define ANIMATION_TIME 0.25

@interface SendToViewController ()

@end

@implementation SendToViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    _arrayOfReceivers = [[NSMutableArray alloc] init];

    NSManagedObjectContext *context = [[Store alloc] init].mainManagedObjectContext;
    NSEntityDescription *entityDescription = [NSEntityDescription
                                              entityForName:@"ContactModel" inManagedObjectContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:
                              @"isFollowed = %@",[NSNumber numberWithBool: YES]];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]
                                        initWithKey:@"rank" ascending:NO];
    

    [request setPredicate:predicate];
    [request setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];

    
    NSError *error = nil;
    NSArray *array = [context executeFetchRequest:request error:&error];
    if (array != nil)
    {
        _arrayOfFollowers = [NSMutableArray arrayWithArray:array];
    }

    

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
    
    if ([_arrayOfFollowers count] == 0) {
        _tableView.hidden = YES;
        _explanationPanelView.hidden = NO;
    }
    else {
        _tableView.hidden = NO;
        _explanationPanelView.hidden = YES;
    }
    
    return [_arrayOfFollowers count];
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
        [[NSBundle mainBundle] loadNibNamed:@"SendToCellView" owner:self options:nil];
    }
    
    UILabel *contactName = (UILabel *)[_cellMain viewWithTag:1];

    if ([_arrayOfFollowers count] > 0)
    {
        NSManagedObject *follower = [_arrayOfFollowers objectAtIndex:indexPath.row];
        contactName.text = [follower valueForKey:@"username"];
    }
    
    return _cellMain;
}

- (void) tableView: (UITableView *) tableView didSelectRowAtIndexPath: (NSIndexPath *) indexPath {

    UITableViewCell *cell = [self tableView:_tableView cellForRowAtIndexPath:indexPath];
    if ([_arrayOfReceivers containsObject:@(indexPath.row)]) {
        // already there
        [_arrayOfReceivers removeObject:@(indexPath.row)];
        cell.backgroundColor = [UIColor whiteColor];
        [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryNone;

    }
    else {
        // new user selected
        [_arrayOfReceivers addObject:@(indexPath.row)];
        cell.contentView.backgroundColor = [UIColor greenColor];
        [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryCheckmark;

    }

    [self setupListOfReceivers];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void) setupListOfReceivers
{
    if ([_arrayOfReceivers count] > 0) {
        NSMutableString *labelStr = [NSMutableString stringWithString:@""];

        int nmr = 0;
        for (id ind in _arrayOfReceivers) {
            NSInteger followerInd = [ind integerValue];
            NSManagedObject *currentFolloweer = [_arrayOfFollowers objectAtIndex:followerInd];
            [labelStr appendString:[currentFolloweer valueForKey:@"username"]];
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

    CGRect tempTableFrame = _tableView.frame;
    tempTableFrame.size.height = tempTableFrame.size.height + _bottomBar.frame.size.height;

    CGRect tempBottombarFrame = _bottomBar.frame;
    tempBottombarFrame.origin.y = self.view.frame.size.height;

    [UIView animateWithDuration:ANIMATION_TIME delay:0 options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         // hide the bottom bar
                         _bottomBar.frame = tempBottombarFrame;
                         _tableView.frame = tempTableFrame;
                     }
                     completion:^(BOOL finished) { }];
}

- (void)displayBottomBar {
    
    CGRect tempTableFrame = _tableView.frame;
    tempTableFrame.size.height = tempTableFrame.size.height - _bottomBar.frame.size.height;

    CGRect tempBottombarFrame = _bottomBar.frame;
    tempBottombarFrame.origin.y = self.view.frame.size.height - tempBottombarFrame.size.height;

    [UIView animateWithDuration:ANIMATION_TIME delay:0 options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         _bottomBar.frame = tempBottombarFrame;
                         _tableView.frame = tempTableFrame;
                     }
                     completion:^(BOOL finished) { }];
}

- (IBAction)btnSendTo:(id)sender {
	AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];

    NSMutableArray *listOfReceivers = [[NSMutableArray alloc] init];
    
    for (id ind in _arrayOfReceivers) {
        NSInteger followerInd = [ind integerValue];
        NSManagedObject *follower = [_arrayOfFollowers objectAtIndex:followerInd];
        NSString *followerUsername = [follower valueForKey:@"username"];
        [listOfReceivers addObject:followerUsername];
    }
    
    [appDelegate sendLocationTo:listOfReceivers withBlock:^(void) {
        [self resetData];
    }];
    
    [self.navigationController popViewControllerAnimated:YES];
    
}

- (IBAction)btnBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)resetData
{
    _arrayOfReceivers = [[NSMutableArray alloc] init];
}


@end
