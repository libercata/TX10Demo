//
//  SuperBaseModel.h
//  HouseSense
//
//  Created by Waynn on 2017/10/19.
//  Copyright © 2017年 emax. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TX10DateTimeModel : NSObject

/**
 [时区,年,月,日]  [timeZone,year,month,day]*/
@property (nonatomic, strong) NSArray *dateArr;
/**
 [时,分,秒]  [hour,minute,second] */
@property (nonatomic, strong) NSArray *timeArr;


- (NSString *)historyDateString;

// 广播实时数据
@property (nonatomic, strong) NSDate *date;

@end
