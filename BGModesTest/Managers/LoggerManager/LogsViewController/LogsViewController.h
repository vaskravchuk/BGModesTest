//
//  LogsViewController.h
//  BGModesTest
//
//  Created by Vasiliy Kravchuk on 9/28/15.
//  Copyright © 2015 Lifewaresolutions. All rights reserved.
//

#import <UIKit/UIKit.h> 

@protocol LogsViewControllerDelegate <NSObject>

-(void)logsViewControllerDone;

@end

@interface LogsViewController : UIViewController
@property (nonatomic,weak)id<LogsViewControllerDelegate> delegate;
-(void)addNewString:(NSString*)str;
@end
