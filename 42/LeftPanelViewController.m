//
//  LeftPanelViewController.m
//  SlideoutNavigation
//
//  Created by Tammy Coron on 1/10/13.
//  Copyright (c) 2013 Tammy L Coron. All rights reserved.
//

#import "LeftPanelViewController.h"
#import "AppDelegate.h"
#import <Parse/Parse.h>
#import "SettingsViewController.h"

@implementation LeftPanelViewController

#pragma mark -
#pragma mark View Did Load/Unload

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(locationSentDidChange)
                                                 name:kLocationSentUpdateNotification
                                               object:nil];

}

- (void)locationSentDidChange
{
    [_tableView reloadData];
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
#pragma mark UITableView Datasource/Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    return [appDelegate.arrayOfLocationSent count];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellMainNibID = @"cellMain";

    _cellMain = [tableView dequeueReusableCellWithIdentifier:cellMainNibID];
    
    if (_cellMain == nil) {
        [[NSBundle mainBundle] loadNibNamed:@"LocationSentCellView" owner:self options:nil];
    }
    
    UILabel *usernameLabel = (UILabel *)[_cellMain viewWithTag:1];
    UILabel *seenLabel = (UILabel *)[_cellMain viewWithTag:2];

    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSMutableArray *arrayOfLocationSent = appDelegate.arrayOfLocationSent;
    if ([arrayOfLocationSent count] > 0)
    {
        PFObject *currentLocationSent = [arrayOfLocationSent objectAtIndex:indexPath.row];
        PFUser* sender = currentLocationSent[@"from"];
        usernameLabel.text = sender.username;
        if (currentLocationSent[@"isSeen"]) {
            seenLabel.text = @"Seen";
        }
        else {
            seenLabel.text = @"Not Seen";
        }

    }
    
    return _cellMain;
}


#pragma mark -
#pragma mark Default System Code

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {

    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)btnSettings:(id)sender {
    SettingsViewController *settingsViewController = [[SettingsViewController alloc] initWithNibName:@"SettingsViewController" bundle:nil];
	[self.navigationController pushViewController:settingsViewController animated:YES];
}

@end
