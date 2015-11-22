//
//  ViewController.m
//  BGModesTest
//
//  Created by Vasiliy Kravchuk on 22.11.15.
//  Copyright © 2015 LWS. All rights reserved.
//

#import "ViewController.h"
#import "ServerManager.h"
#import "LoggerManager.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UISegmentedControl *availabilitySegmentControl;

@end

@implementation ViewController
-(void)updateAvailabilitySegmentController {
    if (ServerManagerInstance.isAvailable) {
        self.availabilitySegmentControl.tintColor = [UIColor greenColor];
    }
    else {
        self.availabilitySegmentControl.tintColor = [UIColor redColor];
    }
}
- (IBAction)availabilitySegmanetControlValueChanged:(id)sender {
    ServerManagerInstance.isAvailable = self.availabilitySegmentControl.selectedSegmentIndex == 0;
    [self updateAvailabilitySegmentController];
}
- (IBAction)showLogsButtonClicked:(id)sender {
    [LoggerManagerInstance showLogs];
}
- (IBAction)sendLogsButtonClicked:(id)sender {
    [LoggerManagerInstance sendLogByMail];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.availabilitySegmentControl.selectedSegmentIndex = ServerManagerInstance.isAvailable ? 0 : 1;
    [self updateAvailabilitySegmentController];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
