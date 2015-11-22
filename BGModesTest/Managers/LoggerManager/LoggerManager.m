//
//  LoggerManager.m
//  BGModesTest
//
//  Created by Vasiliy Kravchuk on 9/24/15.
//  Copyright © 2015 Lifewaresolutions. All rights reserved.
//

#import "LoggerManager.h"
#import <CocoaLumberjack/CocoaLumberjack.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "CustomLoggerFormatter.h"
#import "LogsViewController.h"
#import <sys/utsname.h>


static const DDLogLevel ddLogLevel = DDLogLevelVerbose;

@interface LoggerManager () <MFMailComposeViewControllerDelegate,LogsViewControllerDelegate> {
    DDFileLogger *fileLogger;
    LogsViewController* logsViewController;
}

@end
@implementation LoggerManager

#pragma mark - LogsViewController
-(void)logsViewControllerDone {
    logsViewController = nil;
}
-(void)showLogs {
    if (!logsViewController) {
        logsViewController = [[LogsViewController alloc] initWithNibName:@"LogsViewController" bundle:[NSBundle mainBundle]];
        logsViewController.delegate = self;
        UIWindow *window = [[UIApplication sharedApplication] windows][0];
        UIViewController*viewController=window.rootViewController;
        [viewController presentViewController:logsViewController animated:YES completion:^{}];
        
        NSMutableData *errorLogData = [NSMutableData data];
        for (NSData *errorLogFileData in [self errorLogData]) {
            [errorLogData appendData:errorLogFileData];
        }
        NSString* errorLogString = [[NSString alloc] initWithData:errorLogData encoding:NSUTF8StringEncoding];
        [logsViewController addNewString:errorLogString];
    }
}

#pragma mark - email
- (NSMutableArray *)errorLogData
{
    NSUInteger maximumLogFilesToReturn = MIN(fileLogger.logFileManager.maximumNumberOfLogFiles, 10);
    NSMutableArray *errorLogFiles = [NSMutableArray arrayWithCapacity:maximumLogFilesToReturn];
    NSArray *sortedLogFileInfos = [fileLogger.logFileManager sortedLogFileInfos];
    for (int i = 0; i < MIN(sortedLogFileInfos.count, maximumLogFilesToReturn); i++) {
        DDLogFileInfo *logFileInfo = [sortedLogFileInfos objectAtIndex:i];
        NSData *fileData = [NSData dataWithContentsOfFile:logFileInfo.filePath];
        [errorLogFiles addObject:fileData];
    }
    return errorLogFiles;
}

- (void)composeEmailWithDebugAttachment
{
    if ([MFMailComposeViewController canSendMail]) {
        
        MFMailComposeViewController *mailViewController = [[MFMailComposeViewController alloc] init];
        mailViewController.mailComposeDelegate = self;
        NSMutableData *errorLogData = [NSMutableData data];
        for (NSData *errorLogFileData in [self errorLogData]) {
            [errorLogData appendData:errorLogFileData];
        }
        [mailViewController addAttachmentData:errorLogData mimeType:@"text/plain" fileName:[NSString stringWithFormat:@"log%ld.txt",(long)[[NSDate date] timeIntervalSince1970]]];
        [mailViewController setSubject:NSLocalizedString(@"logs", @"")];
        
        UIWindow *window = [[UIApplication sharedApplication] windows][0];
        UIViewController*viewController=window.rootViewController;
        [viewController presentViewController:mailViewController animated:YES completion:^{}];
    }
    
    else {
        NSString *message = NSLocalizedString(@"Sorry, your issue can't be reported right now. This is most likely because no mail accounts are set up on your mobile device.", @"");
        [[[UIAlertView alloc] initWithTitle:nil message:message delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"") otherButtonTitles: nil] show];
    }
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    [controller dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark - interaction
-(void)sendLogByMail {
    [self composeEmailWithDebugAttachment];
}

-(void)addMessage:(NSString*)messageArg {
    DDLogVerbose(@"%@", messageArg);
    if (logsViewController) {
        [logsViewController addNewString:[@"\n" stringByAppendingString:messageArg]];
    }
}

-(void)initLogger {
    [DDLog addLogger:[DDASLLogger sharedInstance]];
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    
    fileLogger = [[DDFileLogger alloc] init];
    fileLogger.logFormatter = [[CustomLoggerFormatter alloc] init];
    fileLogger.rollingFrequency = 0;
    fileLogger.maximumFileSize = (1024 * 1024 * 15);
    fileLogger.logFileManager.maximumNumberOfLogFiles = 1;
    [DDLog addLogger:fileLogger];
    
    struct utsname systemInfo;
    uname(&systemInfo);
    [self addMessage:[NSString stringWithFormat:@"initLogger %@ %@%@(%@)",
                      [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding],
                      [[[NSBundle mainBundle] localizedInfoDictionary] objectForKey:@"CFBundleDisplayName"],
                      [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"],
                      [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]]];
}
#pragma mark - init

+(instancetype)instance{
    static LoggerManager *instance;
    
    @synchronized(self) {
        if(!instance) {
            instance = [[LoggerManager alloc] init];
        }
    }
    
    return instance;
}
-(void)dealloc {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(id)init{
    self=[super init];
    if(self){
        [self initLogger];
    }
    return self;
}

@end
