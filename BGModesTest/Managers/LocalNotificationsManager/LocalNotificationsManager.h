//
//  LocalNotificationsManager.h
//  BGModesTest
//
//  Created by Vasiliy Kravchuk on 19.11.15.
//  Copyright © 2015 Lifewaresolutions. All rights reserved.
//

#import <UIKit/UIKit.h>

#define LocalNotificationsManagerInstance [LocalNotificationsManager instance]
@interface LocalNotificationsManager : NSObject
-(void)startUpdate;
-(void)stopUpdate;

#pragma mark - init

+(instancetype)instance;

@end
