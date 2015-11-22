//
//  ServerManager.m
//  BGModesTest
//
//  Created by Vasiliy Kravchuk on 22.11.15.
//  Copyright © 2015 LWS. All rights reserved.
//

#import "ServerManager.h"
#import <CoreLocation/CoreLocation.h>
#import "LoggerManager.h"
#import "BackgroundTaskManager.h"
#import "LocationManager.h"

#define kIsAvailableState @"kIsAvailableState"
#define kSendingTimeInterval 30.0

@interface ServerManager () {
    NSTimer* timer;
    CLLocation* lastSendedLocation;
    NSDate* lastSendingCoordinateDate;
}
@property (nonatomic) BackgroundTaskManager * bgTask;

@end

@implementation ServerManager

#pragma mark - properties

-(BOOL)isAvailable {
    return [[NSUserDefaults standardUserDefaults] boolForKey:kIsAvailableState];
}

-(void)setIsAvailable:(BOOL)isAvailable {
    [[NSUserDefaults standardUserDefaults] setBool:isAvailable forKey:kIsAvailableState];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kServerAvailabilityChanged object:nil];
    [self updateState];
}

#pragma mark - logic

-(void)sendCoordinateMessage {
    if (LocationManagerInstance.userLocaton) {
        [LoggerManagerInstance addMessage:[NSString stringWithFormat:@"ServerManager sendCoordinateMessage LocationManagerInstance.userLocaton %@",LocationManagerInstance.userLocaton]];
    }
    else {
        [LoggerManagerInstance addMessage:@"ServerManager sendCoordinateMessage LocationManagerInstance.userLocaton is null"];
    }
}
-(void)locationChanged {
    if (LocationManagerInstance.userLocaton) {
        double locationInterval = 0;
        if (lastSendingCoordinateDate) {
            locationInterval = [[NSDate date] timeIntervalSinceDate:lastSendingCoordinateDate];
        }
        if (!lastSendedLocation || !lastSendingCoordinateDate || fabs(locationInterval) > kSendingTimeInterval) {
            if (timer) {
                [LoggerManagerInstance addMessage:[NSString stringWithFormat:@"ServerManager locationChanged and [timer fire] locationInterval: %f",locationInterval]];
                [self resetTimer];
            }
        }
    }
}
-(void)setTimer {
    if (!timer) {
        [LoggerManagerInstance addMessage:[NSString stringWithFormat:@"ServerManager setTimer timerInterval-%f",kSendingTimeInterval]];
        
        self.bgTask = [BackgroundTaskManager sharedBackgroundTaskManager];
        [self.bgTask beginNewBackgroundTask];
        timer = [NSTimer timerWithTimeInterval:kSendingTimeInterval target:self selector:@selector(sendCoordinateMessage) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
        [timer fire];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationChanged) name:kLocationManagerLocationChanged object:nil];
    }
}
-(void)removeTimer {
    if (timer) {
        [LoggerManagerInstance addMessage:[NSString stringWithFormat:@"ServerManager removeTimer timerInterval-%f",kSendingTimeInterval]];
        lastSendedLocation = nil;
        [self.bgTask endAllBackgroundTasks];
        [timer invalidate];
        timer = nil;
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kLocationManagerLocationChanged object:nil];
    }
}
-(void)resetTimer {
    [LoggerManagerInstance addMessage:@"ServerManager resetTimer"];
    [self removeTimer];
    if (self.isAvailable) {
        [self setTimer];
    }
}
-(void)updateState {
    [self resetTimer];
}

#pragma mark - init

+(instancetype)instance{
    static ServerManager *instance;
    
    @synchronized(self) {
        if(!instance) {
            instance = [[ServerManager alloc] init];
        }
    }
    
    return instance;
}

@end
