//
//  RecordingTrack.m
//  Track Kit - Augmented Reality, Measurements and GPS Tracking
//
//  Created by Artem Drozd on 03.09.13.
//  Copyright (c) 2013 Lifewaresolutions. All rights reserved.
//

#import "LocationManager.h"
#import "LoggerManager.h"
#import "BackgroundTaskManager.h"

@interface LocationManager()<CLLocationManagerDelegate>{
    CLLocationManager*locationManager;
    
    UIAlertView *alertView;
    
    CLLocation* userLocaton;
}
@property (nonatomic) BackgroundTaskManager * bgTask;

@end

@implementation LocationManager

#pragma mark - init

+(instancetype)instance{
    static LocationManager *instance;
    
    @synchronized(self) {
        if(!instance) {
            instance = [[LocationManager alloc] init];
        }
    }
    
    return instance;
}
-(void)dealloc {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}
-(id)init{
    self=[super init];
    if(self){
    }
    return self;
}

#pragma mark -

-(CLLocation*)userLocaton {
    return userLocaton;
}
- (void)requestAlwaysAuthorization
{
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    
    if ([locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
        // If the status is denied or only granted for when in use, display an alert
        if (status == kCLAuthorizationStatusAuthorizedWhenInUse || status == kCLAuthorizationStatusDenied) {
            if (!alertView) {
                NSString *title;
                title = (status == kCLAuthorizationStatusDenied) ? NSLocalizedString(@"Location services are off",nil) : NSLocalizedString(@"Background location is not enabled",nil);
                NSString *message = NSLocalizedString(@"To use background location you must turn on 'Always' in the Location Services Settings",nil);
                
                alertView = [[UIAlertView alloc] initWithTitle:title
                                                       message:message
                                                      delegate:self
                                             cancelButtonTitle:NSLocalizedString(@"Cancel",nil)
                                             otherButtonTitles:NSLocalizedString(@"Options",nil), nil];
                [alertView show];
            }
        }
        // The user has not enabled any location services. Request background authorization.
        else if (status == kCLAuthorizationStatusNotDetermined) {
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(performRequestAlwaysAuthorization) object:nil];
            [self performSelector:@selector(performRequestAlwaysAuthorization) withObject:nil afterDelay:1];
        }
    }
    else {
        // If the status is denied or only granted for when in use, display an alert
        if (status == kCLAuthorizationStatusDenied) {
            if (!alertView) {
                NSString *title;
                title = NSLocalizedString(@"Location services are off",nil);
                
                NSString *message = NSLocalizedString(@"Please turn on Location services for 'Maestro' in the Location Services Settings",nil);
                
                alertView = [[UIAlertView alloc] initWithTitle:title
                                                       message:message
                                                      delegate:nil
                                             cancelButtonTitle:@"OK"
                                             otherButtonTitles:nil];
                [alertView show];
            }
        }
        // The user has not enabled any location services. Request background authorization.
        else if (status == kCLAuthorizationStatusNotDetermined) {
        }
    }
}
-(void)performRequestAlwaysAuthorization {
    [locationManager requestAlwaysAuthorization];
}

- (void)alertView:(UIAlertView *)alertViewArg clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        // Send the user to the Settings for this app
        if (&UIApplicationOpenSettingsURLString != NULL) {
            NSURL *settingsURL = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
            [[UIApplication sharedApplication] openURL:settingsURL];
        }
    }
    alertView = nil;
}
-(void)startPausesLocationUpdatesAutomatically {
    if ([locationManager respondsToSelector:@selector(pausesLocationUpdatesAutomatically)]) {
        locationManager.pausesLocationUpdatesAutomatically = YES;
    }
}
-(void)stopPausesLocationUpdatesAutomatically {
    if ([locationManager respondsToSelector:@selector(pausesLocationUpdatesAutomatically)]) {
        //if not disable iOS can terminate app in bg
        locationManager.pausesLocationUpdatesAutomatically = NO;
    }
}
-(void)setBackground:(BOOL)background {
    self.startFromSagnificantLocation = NO;
    _background = background;
    [self checkPausesLocation];
    [self checkMonitoringSignificantLocation];
}
-(void)checkPausesLocation {
    if (self.background) {
        [self stopPausesLocationUpdatesAutomatically];
    }
    else {
        [self startPausesLocationUpdatesAutomatically];
    }
}
-(void)checkMonitoringSignificantLocation {
    if (self.background) {
        self.bgTask = [BackgroundTaskManager sharedBackgroundTaskManager];
        [self.bgTask beginNewBackgroundTask];
    }
    else {
        [self.bgTask endAllBackgroundTasks];
    }
}
-(void)startUpdateLocation{
    @try {
        if (!locationManager) {
            [LoggerManagerInstance addMessage:@"LocationManager startUpdateLocation"];
            locationManager=[CLLocationManager new];
            locationManager.desiredAccuracy=kCLLocationAccuracyBestForNavigation;
            locationManager.delegate=self;
            [self checkPausesLocation];
            
            [self requestAlwaysAuthorization];
            if ([locationManager respondsToSelector:@selector(setAllowsBackgroundLocationUpdates:)]) {
                [locationManager setAllowsBackgroundLocationUpdates:YES];
            }
            
            [locationManager startUpdatingLocation];
            [locationManager startMonitoringSignificantLocationChanges];
            
            [self removeMonitors];
        }
    }
    @catch (NSException *exception) {
    }
}
-(void)removeMonitors{
    
    for(CLRegion *geofence in locationManager.monitoredRegions){
        [locationManager stopMonitoringForRegion:geofence];
    }
}
-(void)stopUpdateLocation{
    @try {
        if (locationManager) {
            [LoggerManagerInstance addMessage:@"LocationManager stopUpdateLocation"];
            [self removeMonitors];
            locationManager.delegate=nil;
            [locationManager stopUpdatingLocation];
            [locationManager stopMonitoringSignificantLocationChanges];
            locationManager = nil;
        }
    }
    @catch (NSException *exception) {
    }
}

- (void)restartLocationUpdates{
    [LoggerManagerInstance addMessage:@"LocationManager restartLocationUpdates"];
    if (locationManager) {
        [self stopUpdateLocation];
    }
    
    [self startUpdateLocation];
}

- (void)appTerminated {
    [LoggerManagerInstance addMessage:@"LocationManager appTerminated"];

    if (userLocaton) {
        CLCircularRegion* region = [[CLCircularRegion alloc] initWithCenter:userLocaton.coordinate radius:5 identifier:@"wakeupinbg"];
        region.notifyOnEntry = YES;
        region.notifyOnExit = YES;
        [locationManager startMonitoringForRegion:region];
    }
}
- (void)locationManager:(CLLocationManager *)manager
         didEnterRegion:(CLRegion *)region  {
    [LoggerManagerInstance addMessage:[NSString stringWithFormat:@"locationManager didEnterRegion: %@",region]];
}

- (void)locationManager:(CLLocationManager *)manager
          didExitRegion:(CLRegion *)region {
    [LoggerManagerInstance addMessage:[NSString stringWithFormat:@"locationManager didExitRegion: %@",region]];
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    @try {
        CLLocation* oldLocation = userLocaton;
        userLocaton=[locations lastObject];
        if (!oldLocation || fabs([oldLocation distanceFromLocation:userLocaton]) > 70) {
            [LoggerManagerInstance addMessage:[NSString stringWithFormat:@"locationManager didUpdateLocations: %@",userLocaton]];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:kLocationManagerLocationChanged object:nil];
    }
    @catch (NSException *exception) {
    }
}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    @try {
        [LoggerManagerInstance addMessage:[NSString stringWithFormat:@"locationManager didFailWithError: %@",error]];
    }
    @catch (NSException *exception) {
    }
}

@end