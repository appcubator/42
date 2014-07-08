//
//  SettingsViewController.m
//  42
//
//  Created by Ilter Canberk on 5/28/14.
//  Copyright (c) 2014 Appcubator. All rights reserved.
//

#import "SettingsViewController.h"
#import <Parse/Parse.h>
#import "AppDelegate.h"
#import "GenericWebViewController.h"

@interface SettingsViewController ()

@end

@implementation SettingsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        // Custom initialization
        _menuItemsDict = @{ @"My Account": [NSArray arrayWithObjects: @"Username", @"Mobile Number", @"Email", nil],
                            @"More Information": [NSArray arrayWithObjects: @"Support", @"Privacy Policy", nil],
                            @"Account Action":[NSArray arrayWithObjects: @"Log Out", nil] };
        
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)logout {
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    [appDelegate logout];

    // show the welcome view
    [self.navigationController popToRootViewControllerAnimated:NO];
    [appDelegate presentWelcomeViewController];
}

- (IBAction)btnBack:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:NO];
}

#pragma mark -
#pragma mark UITableView Datasource/Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[_menuItemsDict allKeys] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSString *key = [[_menuItemsDict allKeys]objectAtIndex:section];
    NSMutableArray *arr = [_menuItemsDict objectForKey:key];
    return [arr count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellMainNibID = @"cellMain";
    NSString *sectTitle = [self tableView:tableView titleForHeaderInSection:indexPath.section];
    NSString *rowTitle = [[_menuItemsDict objectForKey:sectTitle] objectAtIndex:indexPath.row];

    _cellMain = [tableView dequeueReusableCellWithIdentifier:cellMainNibID];

    if (_cellMain == nil) {
        [[NSBundle mainBundle] loadNibNamed:@"SettingsCellView" owner:self options:nil];
    }
    
    UILabel *optionLabel = (UILabel *)[_cellMain viewWithTag:1];
    UILabel *dataLabel = (UILabel *)[_cellMain viewWithTag:2];
    UILabel *arrowLabel = (UILabel *)[_cellMain viewWithTag:3];

    optionLabel.text = rowTitle;
    
    if ([rowTitle isEqual:@"Username"]) {
        dataLabel.text = [PFUser currentUser].username;
        arrowLabel.hidden = NO;
    }

    if ([rowTitle isEqual:@"Mobile Number"]) {
        dataLabel.text = [PFUser currentUser][@"phone"];
        arrowLabel.hidden = NO;
    }
    
    if ([rowTitle isEqual:@"Email"]) {
        dataLabel.text = [PFUser currentUser].email;
        arrowLabel.hidden = NO;
    }
    
    if ([rowTitle isEqual:@"Support"] || [rowTitle isEqual:@"Privacy Policy"]) {
        dataLabel.text = @"";
    }
    
    if ([rowTitle isEqual:@"Log Out"]) {
        dataLabel.hidden = YES;
        arrowLabel.hidden = YES;
    }
    

    return _cellMain;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [[_menuItemsDict allKeys] objectAtIndex:section];
}

- (void) tableView: (UITableView *) tableView didSelectRowAtIndexPath: (NSIndexPath *) indexPath {
    
    NSString *sectTitle = [self tableView:tableView titleForHeaderInSection:indexPath.section];
    NSString *rowTitle = [[_menuItemsDict objectForKey:sectTitle] objectAtIndex:indexPath.row];
    
    if ([rowTitle isEqual:@"Log Out"]) {
        [self logout];
    }
    
    if ([rowTitle isEqual:@"Support"]) {
        GenericWebViewController *webViewController = [[GenericWebViewController alloc] initWithNibName:@"GenericWebViewController" title:@"Support" url:@"http://fortytwo.parseapp.com/support.html"];
        [self.navigationController pushViewController:webViewController animated:YES];
    }

    if ([rowTitle isEqual:@"Privacy Policy"]) {
        GenericWebViewController *webViewController = [[GenericWebViewController alloc] initWithNibName:@"GenericWebViewController" title:@"Terms of Service" url:@"http://fortytwo.parseapp.com/toc.html"];
        [self.navigationController pushViewController:webViewController animated:YES];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


@end
