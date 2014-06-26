//
//  MapViewController.m
//  42
//
//  Created by Ilter Canberk on 5/22/14.
//  Copyright (c) 2014 Appcubator. All rights reserved.
//
#define METERS_PER_MILE 1609.344

#import "CenterViewController.h"
#import "MapView.h"
#import <CoreLocation/CoreLocation.h>
#import "PersonalPinAnnotation.h"
#import "FriendPinAnnotation.h"
#import "SendToViewController.h"
#import <Parse/Parse.h>
#import "AppDelegate.h"
#import "ComposeCalloutView.h"
#import "ComposePinAnnotation.h"
#import "UIButtonWithData.h"

@interface CenterViewController ()

- (void)startStandardUpdates;
@property (nonatomic, assign) BOOL mapPannedSinceLocationUpdate;

@end

@implementation CenterViewController

- (id)init
{
    self = [super init];
    
    if (self) {
        _friendPins = [[NSMutableArray alloc] initWithObjects:nil count:0];
    }
    
    return self;
}

- (void)loadView
{
    MapView* mapView = [[MapView alloc] init];
    self.view = mapView;

    
    _mkMapView = mapView.mkMapView;
    _mkMapView.showsUserLocation=YES;
    _mkMapView.delegate = self;

    _composePin = [[ComposePinAnnotation alloc] init];
    
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
    

    [mapView.flagButton addTarget:self action:@selector(btnDropFlag:) forControlEvents:UIControlEventTouchUpInside];
    [mapView.leftButton addTarget:self action:@selector(btnMovePanelRight:) forControlEvents:UIControlEventTouchUpInside];
    [mapView.rightButton addTarget:self action:@selector(btnMovePanelLeft:) forControlEvents:UIControlEventTouchUpInside];
    [mapView.sendToButton addTarget:self action:@selector(btnSendTo:) forControlEvents:UIControlEventTouchUpInside];
    [mapView.cancelButton addTarget:self action:@selector(clearLocation:) forControlEvents:UIControlEventTouchUpInside];

    [mapView.cancelButton addTarget:self action:@selector(clearLocation:) forControlEvents:UIControlEventTouchUpInside];

    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clearLocation:) name:@"locationSent" object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showUpdate:) name:kShowLocationWithId object:nil];
    
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(locationSentDidChange)
                                                 name:kLocationSentUpdatedNotification
                                               object:nil];

    _mkMapView.region = MKCoordinateRegionMake(CLLocationCoordinate2DMake(37.332495f, -122.029095f), MKCoordinateSpanMake(0.008516f, 0.021801f));
	_mapPannedSinceLocationUpdate = NO;
	[self startStandardUpdates];
}

- (void)locationSentDidChange
{
    [self placeFriendPins];
}


- (void)viewDidAppear:(BOOL)animated {
    [_mkMapView setShowsUserLocation:YES];
}


#pragma mark - CLLocationManagerDelegate methods and helpers

- (void)startStandardUpdates {
	if (nil == _locationManager) {
		_locationManager = [[CLLocationManager alloc] init];
	}
    
	_locationManager.delegate = self;
	_locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
	// Set a movement threshold for new events.
	_locationManager.distanceFilter = kCLLocationAccuracyNearestTenMeters;
	[_locationManager startUpdatingLocation];
    
	CLLocation *currentLocation = _locationManager.location;
	if (currentLocation) {
        [self locationDidChange:currentLocation];
	}
}

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation {
}


- (void)locationDidChange:(CLLocation *)currentLocation {
    
	// If they panned the map since our last location update, don't recenter it.
	if (!self.mapPannedSinceLocationUpdate) {
		// Set the map's region centered on their new location at 2x filterDistance
		MKCoordinateRegion newRegion = MKCoordinateRegionMakeWithDistance(currentLocation.coordinate, 10 * 2.0f, 10 * 2.0f);
        
		BOOL oldMapPannedValue = self.mapPannedSinceLocationUpdate;
		[_mkMapView setRegion:newRegion animated:YES];
		self.mapPannedSinceLocationUpdate = oldMapPannedValue;
	}

}

- (void) centerMap {
    MKCoordinateRegion region = _mkMapView.region;
    region.center = _locationManager.location.coordinate;
    [_mkMapView setRegion:region animated:YES];
}

- (void)btnDropFlag:(id)sender {

    MapView *view = (MapView *)self.view;
    
    // show "Send" button
    [view showSendLocationMode];
    
    [self centerMap];


    CLLocationCoordinate2D currentCoordinate = _locationManager.location.coordinate;

    [_composePin updateCoordinate:currentCoordinate];
    [_mkMapView addAnnotation:_composePin];
    [_mkMapView selectAnnotation:_composePin animated:YES];

	PFGeoPoint *currentPoint = [PFGeoPoint geoPointWithLatitude:currentCoordinate.latitude longitude:currentCoordinate.longitude];
	PFUser *user = [PFUser currentUser];


    // update the propery on AppDelegat
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    [appDelegate setCurrentLocation: _locationManager.location];
    
	// Stitch together a postObject and send this async to Parse
	PFObject *postObject = [PFObject objectWithClassName:@"Checkin"];
	[postObject setObject:user forKey:@"user"];
	[postObject setObject:currentPoint forKey:@"location"];
	// Use PFACL to restrict future modifications to this object.
	
    PFACL *readOnlyACL = [PFACL ACL];
	[readOnlyACL setPublicReadAccess:YES];
	[readOnlyACL setPublicWriteAccess:NO];
	[postObject setACL:readOnlyACL];
	[postObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
		if (error) {
			NSLog(@"Couldn't save!");
			UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[[error userInfo] objectForKey:@"error"] message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
			[alertView show];
			return;
		}
		if (succeeded) {
			NSLog(@"Successfully saved!");
		} else {
			NSLog(@"Failed to save.");
		}
	}];

}

- (void)btnMovePanelRight:(id)sender
{
    [_delegate movePanelRight];
}

- (void)btnMovePanelLeft:(id)sender
{
    [_delegate movePanelLeft];
}

- (void)btnSendTo:(id)sender
{
    SendToViewController *sendToViewController = [[SendToViewController alloc] initWithNibName:@"SendToViewController" bundle:nil];
    
    NSString *message = _composePin.calloutView.textField.text;
    
    // update the propery on AppDelegate
    if (message != nil && ![message  isEqual: @""]) {
        AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        [appDelegate setCurrentMessage: message];
    }

	[self.navigationController pushViewController:sendToViewController animated:YES];

}

- (void)clearLocation:(id)sender
{
    MapView *view = (MapView *)self.view;
    
    [view hideSendLocationMode];

    // show "X" button
    UIButton *cancelButton = view.cancelButton;
    cancelButton.hidden = YES;
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    [appDelegate setCurrentMessage: nil];
    [appDelegate setCurrentLocation: nil];

    [_composePin.calloutView.textField setText:@""];
    [_composePin setShowCustomCallout:NO animated:YES];
    [_mkMapView removeAnnotation:_composePin];


}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark -
#pragma mark Pins

- (void)placeFriendPins {

    [self removeFriendPins];
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSMutableArray *arrayOfLocationSent = appDelegate.arrayOfLocationSent;
    
    for (PFObject *locationSent in arrayOfLocationSent) {
        
        PFUser *user = locationSent[@"from"];
        PFGeoPoint *location =  locationSent[@"location"];
        NSDate *when = locationSent[@"date"];
        NSDate *now = [NSDate date];
        NSTimeInterval interval = [now timeIntervalSinceDate:when];
        double rawMinutes = interval / (60);
        NSString *message = locationSent[@"message"];

        if (rawMinutes < 42) {
            CLLocationCoordinate2D newCoordinate = CLLocationCoordinate2DMake(location.latitude, location.longitude);
        
            FriendPinAnnotation *newPin = [[FriendPinAnnotation alloc] initWithCoordinate:newCoordinate name:user.username u_id:locationSent.objectId when:when message:message];
        
            [_friendPins insertObject:newPin atIndex:0];
            [_mkMapView addAnnotation:(id)newPin];
        }
    }

}

- (void)removeFriendPins {
    for(FriendPinAnnotation *pin in _friendPins) {
        [_mkMapView removeAnnotation:(id)pin];
    }
    [_friendPins removeAllObjects];
}

- (void)showLocationSent:(PFObject *)locationSent {
   
    PFGeoPoint *location =  locationSent[@"location"];

    [self goToCoordinate:CLLocationCoordinate2DMake(location.latitude, location.longitude)];
    for (FriendPinAnnotation *pin in _friendPins) {
        if (pin.ID == locationSent.objectId) {
            [_mkMapView selectAnnotation:pin animated:YES];
        }
    }

}

- (void) goToCoordinate: (CLLocationCoordinate2D)coordinate{
    MKCoordinateRegion region = _mkMapView.region;
    region.center = coordinate;
    [_mkMapView setRegion:region animated:YES];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id) annotation
{
    
    if ([annotation isKindOfClass:ComposePinAnnotation.class])
    {
        ComposePinAnnotation *newAnnotation = (ComposePinAnnotation *)annotation;
        return newAnnotation;
    }

    
    if ([annotation isKindOfClass:FriendPinAnnotation.class])
    {
        FriendPinAnnotation *newAnnotation = (FriendPinAnnotation *)annotation;
        MKAnnotationView *annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"loc"];
        annotationView.canShowCallout = YES;
        UIButtonWithData *msgButton = [UIButtonWithData buttonWithType:UIButtonTypeInfoLight];
        msgButton.extraData = newAnnotation.phoneNumber;
        [msgButton setImage:[UIImage imageNamed:@"text-button"] forState:UIControlStateNormal];
        [msgButton addTarget:self action:@selector(sendMessageToFriend:) forControlEvents:UIControlEventTouchUpInside];
        annotationView.rightCalloutAccessoryView = msgButton;
        
        return annotationView;
    }

    return nil;
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    
    if ([view.annotation isKindOfClass:ComposePinAnnotation.class]) {
        ComposePinAnnotation *annotationView = (ComposePinAnnotation *)view.annotation;
        [annotationView setShowCustomCallout:YES animated:YES];
    }
    
}

-(void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view {
    

}


- (void)sendMessageToFriend:(id)sender
{
    UIButtonWithData *msgButton = (UIButtonWithData *)sender;

    NSString *mobileNumber = msgButton.extraData;

    if(![MFMessageComposeViewController canSendText]) {
        UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Your device doesn't support SMS!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [warningAlert show];
        return;
    }
    
    if ([mobileNumber isEqual:nil]) {
        UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"This user does not have a number!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [warningAlert show];
        return;
    }
    
    NSLog(@"%@",mobileNumber);
    
    NSArray *recipents = @[mobileNumber];
    NSString *message = [NSString stringWithFormat:@"I'd love you to use this app called 42, but you're not cool enough. Sorry."];
    
    MFMessageComposeViewController *messageController = [[MFMessageComposeViewController alloc] init];
    messageController.messageComposeDelegate = self;
    [messageController setRecipients:recipents];
    [messageController setBody:message];
    
    // Present message view controller on screen
    [self presentViewController:messageController animated:YES completion:nil];
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult) result
{
    switch (result) {
        case MessageComposeResultCancelled:
            break;
            
        case MessageComposeResultFailed:
        {
            UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Failed to send SMS!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [warningAlert show];
            break;
        }
            
        case MessageComposeResultSent:
            break;
            
        default:
            break;
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
