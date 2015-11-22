//
//  ServerManager.h
//  BGModesTest
//
//  Created by Vasiliy Kravchuk on 22.11.15.
//  Copyright © 2015 LWS. All rights reserved.
//

#import <Foundation/Foundation.h>
#define kServerAvailabilityChanged @"kServerAvailabilityChanged"
#define ServerManagerInstance [ServerManager instance]

@interface ServerManager : NSObject
@property BOOL isAvailable;
-(void)updateState;

#pragma mark - init

+(instancetype)instance;
@end
