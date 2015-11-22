//
//  RecordingTrack.h
//  Track Kit - Augmented Reality, Measurements and GPS Tracking
//
//  Created by Artem Drozd on 03.09.13.
//  Copyright (c) 2013 Lifewaresolutions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#define LocationManagerInstance [LocationManager instance]
#define kLocationManagerLocationChanged @"kLocationManagerLocationChanged"
@interface LocationManager : NSObject
@property (nonatomic,assign)BOOL background;
@property (nonatomic,assign)BOOL startFromSagnificantLocation;

-(void)restartLocationUpdates;
-(void)startUpdateLocation;
-(void)stopUpdateLocation;

- (void)appTerminated;

-(CLLocation*)userLocaton;

#pragma mark - init

+(instancetype)instance;

@end