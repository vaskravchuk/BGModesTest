//
//  CustomLoggerFormatter.m
//  BGModesTest
//
//  Created by Vasiliy Kravchuk on 9/24/15.
//  Copyright © 2015 Lifewaresolutions. All rights reserved.
//

#import "CustomLoggerFormatter.h"

@interface CustomLoggerFormatter () {
    NSDateFormatter *dateFormatter;
}

@end
@implementation CustomLoggerFormatter
- (id)init {
    if((self = [super init])) {
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
        [dateFormatter setLocale:[NSLocale localeWithLocaleIdentifier:@"en_US"]];
        [dateFormatter setDateFormat:@"yyyy/MM/dd HH:mm:ss:SSS Z"];
    }
    return self;
}

- (NSString *)formatLogMessage:(DDLogMessage *)logMessage {
    NSString *dateAndTime = [dateFormatter stringFromDate:(logMessage->_timestamp)];
    NSString *logMsg = logMessage->_message;
    
    return [NSString stringWithFormat:@"%@ | %@\n", dateAndTime, logMsg];
}
@end
