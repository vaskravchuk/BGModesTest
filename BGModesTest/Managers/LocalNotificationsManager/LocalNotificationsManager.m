//
//  LocalNotificationsManager.m
//  BGModesTest
//
//  Created by Vasiliy Kravchuk on 19.11.15.
//  Copyright © 2015 Lifewaresolutions. All rights reserved.
//

#import "LocalNotificationsManager.h"
#import "BackgroundTaskManager.h"
#import "LoggerManager.h"

//#define TIMER_LocalNotificationsManager_INTERVAL 5.0
//#define LOCALNOTIFICATION_FIRE_DELAY 20.0
//#define LOCALNOTIFICATION_FIRE_OFFSET 11.0
#define TIMER_LocalNotificationsManager_INTERVAL 180.0
#define LOCALNOTIFICATION_FIRE_DELAY 600.0
#define LOCALNOTIFICATION_FIRE_OFFSET 242.0

@interface LocalNotificationsManager () {
    NSTimer* timer;
}
@property (nonatomic) BackgroundTaskManager * bgTask;

@end
@implementation LocalNotificationsManager
-(void)startUpdate {
    [LoggerManagerInstance addMessage:@"LocalNotificationsManager startUpdate"];
    [self setTimer];
}
-(void)stopUpdate {
    [LoggerManagerInstance addMessage:@"LocalNotificationsManager stopUpdate"];
    [self removeTimer];
}


-(void)timerFired {
    [LoggerManagerInstance addMessage:@"LocalNotificationsManager timerFired"];
    
    UILocalNotification* existLocalNotification = self.getExistLocalNotification;
    [LoggerManagerInstance addMessage:[NSString stringWithFormat:@"LocalNotificationsManager timerFired existLocalNotification:%@",existLocalNotification]];
    if (!existLocalNotification) {
        [[UIApplication sharedApplication] scheduleLocalNotification:self.getNewLocalNotification];
    }
    else if ([existLocalNotification.fireDate timeIntervalSinceNow] <= LOCALNOTIFICATION_FIRE_OFFSET) {
        [[UIApplication sharedApplication] cancelLocalNotification:existLocalNotification];
        [[UIApplication sharedApplication] scheduleLocalNotification:self.getNewLocalNotification];
    }
}
-(void)setTimer {
    if (!timer) {
        [LoggerManagerInstance addMessage:[NSString stringWithFormat:@"LocalNotificationsManager setTimer timerInterval-%f",TIMER_LocalNotificationsManager_INTERVAL]];
        
        self.bgTask = [BackgroundTaskManager sharedBackgroundTaskManager];
        [self.bgTask beginNewBackgroundTask];
        timer = [NSTimer timerWithTimeInterval:TIMER_LocalNotificationsManager_INTERVAL target:self selector:@selector(timerFired) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
        [timer fire];
    }
}
-(void)removeTimer {
    if (timer) {
        [self.bgTask endAllBackgroundTasks];
        [timer invalidate];
        timer = nil;
        [[UIApplication sharedApplication] cancelAllLocalNotifications];
    }
}

#pragma mark - init

+(instancetype)instance{
    static LocalNotificationsManager *instance;
    
    @synchronized(self) {
        if(!instance) {
            instance = [[LocalNotificationsManager alloc] init];
        }
    }
    
    return instance;
}

-(UILocalNotification*)getExistLocalNotification {
    NSArray<UILocalNotification *> *scheduledLocalNotifications = [[UIApplication sharedApplication] scheduledLocalNotifications];
    for (UILocalNotification* item in scheduledLocalNotifications) {
        if (item.userInfo) {
            NSString* identifier = [item.userInfo objectForKey:@"identifier"];
            if (identifier && [identifier isKindOfClass:[NSString class]]) {
                if ([identifier isEqualToString:@"LocalNotificationsManager"]) {
                    return item;
                }
            }
        }
    }
    return nil;
}
-(UILocalNotification*)getNewLocalNotification {
    [LoggerManagerInstance addMessage:@"LocalNotificationsManager createNotification"];
    UILocalNotification *myNotification = [[UILocalNotification alloc] init];
    myNotification.alertBody = @"Maestro should remain running. Please open app.";
    myNotification.alertAction = @"Open";
    myNotification.soundName = UILocalNotificationDefaultSoundName;
    myNotification.applicationIconBadgeNumber = 1;
    myNotification.timeZone = [NSTimeZone defaultTimeZone];
    myNotification.repeatInterval = NSMinuteCalendarUnit;
    myNotification.fireDate = [[NSDate date] dateByAddingTimeInterval:LOCALNOTIFICATION_FIRE_DELAY];
    myNotification.userInfo = @{@"identifier":@"LocalNotificationsManager"};
    return myNotification;
    
}
@end
