//
//  AppDelegate.m
//  BGModesTest
//
//  Created by Vasiliy Kravchuk on 22.11.15.
//  Copyright © 2015 LWS. All rights reserved.
//

#import "AppDelegate.h"
#import "LocationManager.h"
#import "ServerManager.h"
#import "LoggerManager.h"
#import "LocalNotificationsManager.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [LoggerManagerInstance addMessage:[NSString stringWithFormat:@"AppDelegate application didFinishLaunchingWithOptions %@",launchOptions.description]];
    //remove icon badge number
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    
    [ServerManagerInstance updateState];
    
    if([launchOptions valueForKey:@"UIApplicationLaunchOptionsLocationKey"]){
        //useSignificantLocationChangesChanged or region monitoring
        [LoggerManagerInstance addMessage:@"AppDelegate application didFinishLaunchingWithOptions launchOptions has key 'UIApplicationLaunchOptionsLocationKey'"];
        if(ServerManagerInstance.isAvailable) {
            [LocationManagerInstance startUpdateLocation];
            [LocationManagerInstance setBackground:YES];
            LocationManagerInstance.startFromSagnificantLocation = YES;
            [LocalNotificationsManagerInstance startUpdate];
        }
    }
    else {
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateAvailibility) name:kServerAvailabilityChanged object:nil];
    return YES;
}
-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
-(void)updateAvailibility {
    if (!ServerManagerInstance.isAvailable) {
        [LocationManagerInstance stopUpdateLocation];
        [LocalNotificationsManagerInstance stopUpdate];
    }
    else {
        [self tryStartUpdateLocation];
    }
}
-(void)tryStartUpdateLocation {
    [LoggerManagerInstance addMessage:[NSString stringWithFormat:@"AppDelegate tryStartUpdateLocation %d",ServerManagerInstance.isAvailable]];
    if(ServerManagerInstance.isAvailable) {
        [LocationManagerInstance startUpdateLocation];
        [LocationManagerInstance setBackground:([[UIApplication sharedApplication] applicationState] == UIApplicationStateBackground)];
        [LocalNotificationsManagerInstance startUpdate];
    }
}
- (void)applicationWillResignActive:(UIApplication *)application {
    [LoggerManagerInstance addMessage:@"AppDelegate applicationWillResignActive"];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    [LoggerManagerInstance addMessage:@"AppDelegate applicationDidEnterBackground"];
    [LocationManagerInstance setBackground:YES];
    
    [[UIApplication sharedApplication] setKeepAliveTimeout:600 handler:^(){
        [LoggerManagerInstance addMessage:@"AppDelegate setKeepAliveTimeout"];
    }];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    [LoggerManagerInstance addMessage:@"AppDelegate applicationWillEnterForeground"];
    [[UIApplication sharedApplication] clearKeepAliveTimeout];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    [self tryStartUpdateLocation];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [LoggerManagerInstance addMessage:@"AppDelegate applicationDidBecomeActive"];
    [self tryStartUpdateLocation];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    [LoggerManagerInstance addMessage:@"AppDelegate applicationWillTerminate"];
    
    if(ServerManagerInstance.isAvailable) {
        [LocationManagerInstance appTerminated];
    }
}

@end
