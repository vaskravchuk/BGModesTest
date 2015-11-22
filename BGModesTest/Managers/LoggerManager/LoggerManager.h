//
//  LoggerManager.h
//  BGModesTest
//
//  Created by Vasiliy Kravchuk on 9/24/15.
//  Copyright © 2015 Lifewaresolutions. All rights reserved.
//

#import <Foundation/Foundation.h>

#define LoggerManagerInstance [LoggerManager instance]

@interface LoggerManager : NSObject

+(instancetype)instance;

-(void)sendLogByMail;
-(void)showLogs;

-(void)addMessage:(NSString*)messageArg;

@end
