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
    _refreshControl = [[UIRefreshControl alloc] init];
    [_refreshControl addTarget:self action:@selector(refreshInvoked:forState:) forControlEvents:UIControlEventValueChanged];
    _refreshControl.tintColor = [UIColor magentaColor];

    [self setRefreshControl:_refreshControl];
}

- (void)locationSentDidChange
{
    [_tableView reloadData];
    [_refreshControl endRefreshing];
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
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSMutableArray *arrayOfLocationSent = appDelegate.arrayOfLocationSent;
    PFObject *currentLocationSent = [arrayOfLocationSent objectAtIndex:indexPath.row];
    [[appDelegate getMainViewController].centerViewController showLocationSent:currentLocationSent];
    [[appDelegate getMainViewController] movePanelToOriginalPosition];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellMainNibID = @"cellMain";

    _cellMain = [tableView dequeueReusableCellWithIdentifier:cellMainNibID];

    if (_cellMain == nil) {
        [[NSBundle mainBundle] loadNibNamed:@"LocationSentCellView" owner:self options:nil];
    }
    
    UILabel *usernameLabel = (UILabel *)[_cellMain viewWithTag:1];
    UIImageView *locationStatusView = (UIImageView *)[_cellMain viewWithTag:2];
    UILabel *timeLabel = (UILabel *)[_cellMain viewWithTag:3];

    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSMutableArray *arrayOfLocationSent = appDelegate.arrayOfLocationSent;
    if ([arrayOfLocationSent count] > 0)
    {
        PFObject *currentLocationSent = [arrayOfLocationSent objectAtIndex:indexPath.row];
        PFUser* sender = currentLocationSent[@"from"];
        usernameLabel.text = sender.username;
        NSDate *when = currentLocationSent[@"date"];
        NSDate *now = [NSDate date];
        NSTimeInterval interval = [now timeIntervalSinceDate:when];
        double rawMinutes = interval / (60);
        
        if (rawMinutes < 42) {
            locationStatusView.backgroundColor = [UIColor blueColor];
        }
        else {
            locationStatusView.backgroundColor = [UIColor clearColor];
            locationStatusView.layer.borderColor = [UIColor blueColor].CGColor;
            locationStatusView.layer.borderWidth = 2.0f;
        }
        
        int second = 1;
        int minute = second*60;
        int hour = minute*60;
        int day = hour*24;
        // interval can be before (negative) or after (positive)
        int num = abs(interval);
        NSString *unit = @"day";
        
        if (num >= day) {
            num /= day;
            if (num > 1) unit = @"days";
        } else if (num >= hour) {
            num /= hour;
            unit = (num > 1) ? @"hours" : @"hour";
        } else if (num >= minute) {
            num /= minute;
            unit = (num > 1) ? @"minutes" : @"minute";
        } else if (num >= second) {
            num /= second;
            unit = (num > 1) ? @"seconds" : @"second";
        }

        timeLabel.text = [NSString stringWithFormat:@"%d %@", num, unit];
        
    }
    
    return _cellMain;
}

-(void) refreshInvoked:(id)sender forState:(UIControlState)state {
    // Refresh table here...
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    [appDelegate updateLocationSent];
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

- (IBAction)btnGoRight:(id)sender {
    MainViewController* mainViewController = (MainViewController *) self.parentViewController;
    [mainViewController movePanelToOriginalPosition];
}


- (IBAction)btnSettings:(id)sender {
    SettingsViewController *settingsViewController = [[SettingsViewController alloc] initWithNibName:@"SettingsViewController" bundle:nil];
	[self.navigationController pushViewController:settingsViewController animated:YES];
}

@end
