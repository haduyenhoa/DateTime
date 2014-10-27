//
//  HDateHelper.h
//
//
//  Created by Duyen Hoa Ha on 24/06/2014.
//  Copyright (c) 2014 Duyen Hoa Ha. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    DayMonthYear,  //dd MM yyyy
    MonthDayYear,  //
    YearMonthDay,
    NotIncludeDate
} RTDateFormat;

typedef enum : NSUInteger {
    HourMinute,
    HourMinuteSecond,
    HourMinuteSecondMilliSecond,
    NotIncludeTime
} TimeFormat;

@interface HDateHelper : NSObject

+(HDateHelper*)shareDateHelper;

/**
 @discussion    Convert a string with given format to a NSDate
 @param     string : source string
 dateFormat: use RTDateFormat
 dateSeparator: -, /,[empty], [a space], ...
 timeFormat: RTTimeFormat
 timeSeparator: -, /,[empty], [a space], ...
 separator: empty, a space, T, 'T', ...
 */
- (NSDate *)dateFromString:(NSString *)string
            withDateFormat:(int)dateFormat
         withDateSeparator:(NSString*)dateSeparator
            withTimeFormat:(int)timeFormat
         withTimeSeparator:(NSString*)timeSeparator
     withDateTimeSeparator:(NSString*)separator;

- (NSString *)getStringFromDate:(NSDate*)aDate
                 withDateFormat:(int)dateFormat
              withDateSeparator:(NSString*)dateSeparator
                 withTimeFormat:(int)timeFormat
              withTimeSeparator:(NSString*)timeSeparator
          withDateTimeSeparator:(NSString*)separator;
@end
