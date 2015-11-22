//
//  BackgroundTaskManager.h
//
//  Created by Puru Shukla on 20/02/13.
//  Copyright (c) 2013 Puru Shukla. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BackgroundTaskManager : NSObject

+(instancetype)sharedBackgroundTaskManager;

-(UIBackgroundTaskIdentifier)beginNewBackgroundTask;
-(void)endAllBackgroundTasks;

@end
