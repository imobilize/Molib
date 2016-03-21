//
//  NSDate+Formatter.h
//  OnIt
//
//  Created by Andre Barrett on 07/09/2012.
//  Copyright (c) 2012 imobilize. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString* const kJQTimeAgoAllowFutureKey;
extern NSString* const kJQTimeAgoStringsPrefixAgoKey;
extern NSString* const kJQTimeAgoStringsPrefixFromNowKey;
extern NSString* const kJQTimeAgoStringsSuffixAgoKey;
extern NSString* const kJQTimeAgoStringsSuffixFromNowKey;
extern NSString* const kJQTimeAgoStringsSecondsKey;
extern NSString* const kJQTimeAgoStringsMinuteKey;
extern NSString* const kJQTimeAgoStringsMinutesKey;
extern NSString* const kJQTimeAgoStringsHourKey;
extern NSString* const kJQTimeAgoStringsHoursKey;
extern NSString* const kJQTimeAgoStringsDayKey;
extern NSString* const kJQTimeAgoStringsDaysKey;
extern NSString* const kJQTimeAgoStringsMonthKey;
extern NSString* const kJQTimeAgoStringsMonthsKey;
extern NSString* const kJQTimeAgoStringsYearKey;
extern NSString* const kJQTimeAgoStringsYearsKey;
extern NSString* const kJQTimeAgoStringsNumbersKey;

@interface NSDate (Formatter)

- (NSString*)niceFormat;

- (NSString*)timeAgo;

@end
