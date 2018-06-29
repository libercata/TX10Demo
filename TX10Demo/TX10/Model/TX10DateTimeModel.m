//
//  SuperBaseModel.m
//  HouseSense
//
//  Created by Waynn on 2017/10/19.
//  Copyright © 2017年 emax. All rights reserved.
//

#import "TX10DateTimeModel.h"
//#import "NSDate+Common.h"

@implementation TX10DateTimeModel

- (NSString *)historyDateString {
    NSMutableString *dateString = [NSMutableString string];
    for (NSNumber *t in self.dateArr) {
        [dateString appendFormat:@"-%02d", t.intValue];
    }
    
    NSMutableString *timeString = [NSMutableString string];
    for (NSNumber *t in self.timeArr) {
        [timeString appendFormat:@":%02d", t.intValue];
    }
    return [NSString stringWithFormat:@"%@ %@", [dateString substringFromIndex:1], [timeString substringFromIndex:1]];
}


@end

