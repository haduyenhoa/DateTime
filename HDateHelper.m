//
//  HDateHelper.m
//
//
//  Created by Duyen Hoa Ha on 24/06/2014.
//  Copyright (c) 2014 Duyen Hoa Ha. All rights reserved.
//  Use this class to replace NSDateFormatter to improve application speed
//  Ref: http://www.cplusplus.com/reference/ctime/strftime/

/**
 strftime
 size_t strftime (char* ptr, size_t maxsize, const char* format,
 const struct tm* timeptr );
 Format time as string
 Copies into ptr the content of format, expanding its format specifiers into the corresponding values that represent the time described in timeptr, with a limit of maxsize characters.
 
 Parameters
 ptr
 Pointer to the destination array where the resulting C string is copied.
 maxsize
 Maximum number of characters to be copied to ptr, including the terminating null-character.
 format
 C string containing any combination of regular characters and special format specifiers. These format specifiers are replaced by the function to the corresponding values to represent the time specified in timeptr. They all begin with a percentage (%) sign, and are:
 specifier	Replaced by	Example
 %a	Abbreviated weekday name *	Thu
 %A	Full weekday name *	Thursday
 %b	Abbreviated month name *	Aug
 %B	Full month name *	August
 %c	Date and time representation *	Thu Aug 23 14:55:02 2001
 %C	Year divided by 100 and truncated to integer (00-99)	20
 %d	Day of the month, zero-padded (01-31)	23
 %D	Short MM/DD/YY date, equivalent to %m/%d/%y	08/23/01
 %e	Day of the month, space-padded ( 1-31)	23
 %F	Short YYYY-MM-DD date, equivalent to %Y-%m-%d	2001-08-23
 %g	Week-based year, last two digits (00-99)	01
 %G	Week-based year	2001
 %h	Abbreviated month name * (same as %b)	Aug
 %H	Hour in 24h format (00-23)	14
 %I	Hour in 12h format (01-12)	02
 %j	Day of the year (001-366)	235
 %m	Month as a decimal number (01-12)	08
 %M	Minute (00-59)	55
 %n	New-line character ('\n')
 %p	AM or PM designation	PM
 %r	12-hour clock time *	02:55:02 pm
 %R	24-hour HH:MM time, equivalent to %H:%M	14:55
 %S	Second (00-61)	02
 %t	Horizontal-tab character ('\t')
 %T	ISO 8601 time format (HH:MM:SS), equivalent to %H:%M:%S	14:55:02
 %u	ISO 8601 weekday as number with Monday as 1 (1-7)	4
 %U	Week number with the first Sunday as the first day of week one (00-53)	33
 %V	ISO 8601 week number (00-53)	34
 %w	Weekday as a decimal number with Sunday as 0 (0-6)	4
 %W	Week number with the first Monday as the first day of week one (00-53)	34
 %x	Date representation *	08/23/01
 %X	Time representation *	14:55:02
 %y	Year, last two digits (00-99)	01
 %Y	Year	2001
 %z	ISO 8601 offset from UTC in timezone (1 minute=1, 1 hour=100)
 If timezone cannot be termined, no characters	+100
 %Z	Timezone name or abbreviation *
 If timezone cannot be termined, no characters	CDT
 %%	A % sign	%
 * The specifiers marked with an asterisk (*) are locale-dependent.
 Note: Yellow rows indicate specifiers and sub-specifiers introduced by C99. Since C99, two locale-specific modifiers can also be inserted between the percentage sign (%) and the specifier proper to request an alternative format, where applicable:
 Modifier	Meaning	Applies to
 E	Uses the locale's alternative representation	%Ec %EC %Ex %EX %Ey %EY
 O	Uses the locale's alternative numeric symbols	%Od %Oe %OH %OI %Om %OM %OS %Ou %OU %OV %Ow %OW %Oy
 timeptr
 Pointer to a tm structure that contains a calendar time broken down into its components (see struct tm).
 
 Return Value
 If the length of the resulting C string, including the terminating null-character, doesn't exceed maxsize, the function returns the total number of characters copied to ptr (not including the terminating null-character).
 Otherwise, it returns zero, and the contents of the array pointed by ptr are indeterminate.
 
 Compatibility
 Particular library implementations may support additional specifiers or combinations.
 Those listed here are supported by the latest C and C++ standards (both published in 2011), but those in yellow were introduced in C99 (only required for C++ implementations since C++11), and may not be supported by libraries that comply with older standards.

 */

#include <time.h>
#import "HDateHelper.h"

static HDateHelper *_shareDateHelper = nil;
@implementation HDateHelper

+(HDateHelper*)shareDateHelper {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _shareDateHelper = [[HDateHelper alloc] init];
    });
    return _shareDateHelper;
}

- (NSDate *)dateFromString:(NSString *)string
            withDateFormat:(int)dateFormat
         withDateSeparator:(NSString*)dateSeparator
            withTimeFormat:(int)timeFormat
         withTimeSeparator:(NSString*)timeSeparator
     withDateTimeSeparator:(NSString*)separator {
    
    if (!string) {
        return nil;
    }
    
    struct tm tm;
    time_t t;
    
    NSString *format = [self getFormatWithDateFormat:dateFormat withDateSeparator:dateSeparator withTimeFormat:timeFormat withTimeSeparator:timeSeparator withDateTimeSeparator:separator];
    
    strptime([string cStringUsingEncoding:NSUTF8StringEncoding], format.UTF8String, &tm);
    tm.tm_isdst = -1;
    
    if (dateFormat == NotIncludeDate) {
        //not possible
        return nil;
    } else if (timeFormat == NotIncludeTime) {
        tm.tm_hour = 0;
        tm.tm_min = 0;
        tm.tm_sec = 0;
    }
    
    t = mktime(&tm);
    
    return [NSDate dateWithTimeIntervalSince1970:t + [[NSTimeZone localTimeZone] secondsFromGMT]]; //get local date
}

- (NSString *)getStringFromDate:(NSDate*)aDate
                 withDateFormat:(int)dateFormat
              withDateSeparator:(NSString*)dateSeparator
                 withTimeFormat:(int)timeFormat
              withTimeSeparator:(NSString*)timeSeparator
          withDateTimeSeparator:(NSString*)separator {

    if (!aDate) {
        return nil;
    }
    
    struct tm *timeinfo;
    char buffer[80];
    
    time_t rawtime = [aDate timeIntervalSince1970] - [[NSTimeZone localTimeZone] secondsFromGMT];
    timeinfo = localtime(&rawtime);
    
    NSString *format = [self getFormatWithDateFormat:dateFormat withDateSeparator:dateSeparator withTimeFormat:timeFormat withTimeSeparator:timeSeparator withDateTimeSeparator:separator];
    
    strftime(buffer, 80, format.UTF8String, timeinfo);
    return [NSString stringWithCString:buffer encoding:NSUTF8StringEncoding];
}

-(NSString*)getFormatWithDateFormat:(int)dateFormat
                  withDateSeparator:(NSString*)dateSeparator
                     withTimeFormat:(int)timeFormat
                  withTimeSeparator:(NSString*)timeSeparator
              withDateTimeSeparator:(NSString*)separator {
    
    if (dateFormat == NotIncludeDate
        && timeFormat == NotIncludeTime
        ) {
        return nil;
    }
    
    NSString *myDateFormat = @"";
    NSString *myTimeFormat = @"";
    
    if (!dateSeparator) {
        dateSeparator = @"";
    }
    
    if (!timeSeparator) {
        timeSeparator = @"";
    }
    
    if (!separator) {
        separator = @"";
    }
    
    BOOL includeDate = YES;
    switch (dateFormat) {
        case DayMonthYear:
            myDateFormat = [NSString stringWithFormat:@"%%d%@%%m%@%%Y",dateSeparator,dateSeparator];
            break;
        case MonthDayYear:
            myDateFormat = [NSString stringWithFormat:@"%%m%@%%d%@%%Y",dateSeparator,dateSeparator];
            break;
        case YearMonthDay:
            myDateFormat = [NSString stringWithFormat:@"%%Y%@%%m%@%%d",dateSeparator,dateSeparator];
            break;
        case NotIncludeDate:
            includeDate = NO;
            break;
        default: //use day-month-year
            myDateFormat = [NSString stringWithFormat:@"%%d%@%%m%@%%Y",dateSeparator,dateSeparator];
            break;
    }
    
    BOOL includeTime = YES;
    switch (timeFormat) {
        case HourMinute:
            myTimeFormat = [NSString stringWithFormat:@"%%H%@%%M",timeSeparator];
            break;
        case HourMinuteSecond:
            myTimeFormat = [NSString stringWithFormat:@"%%H%@%%M%@%%S",timeSeparator,timeSeparator];
            break;
        case HourMinuteSecondMilliSecond:
            myTimeFormat = [NSString stringWithFormat:@"%%H%@%%M%@%%S%%z",timeSeparator,timeSeparator];
            break;
        case NotIncludeTime:
            includeTime = NO;
            break;
        default: //use HourMinuteSecond
            myTimeFormat = [NSString stringWithFormat:@"%%H%@%%M%@%%S",timeSeparator,timeSeparator];
            break;
    }
    
    if (!includeTime) {
        return myDateFormat;
    } else if (!includeDate) {
        return myTimeFormat;
    } else {
        return [NSString stringWithFormat:@"%@%@%@",myDateFormat,separator,myTimeFormat];
    }
}

@end
