//
//  TX10BLECommands.h
//  HouseSense
//
//  Created by Waynn on 2018/6/27.
//  Copyright © 2018年 emax. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TX10Enum.h"

@interface TX10BLECommands : NSObject

/**
 更新设备ID 当绑定设备完成后发送此指令
 send this command after binding peripheral
 
 @param uuid eg. peripheral.identifier.UUIDString
 @return 指令
 */
+ (NSData *)setUUIDCommandWithUUID:(NSString *)uuid;

/**
 授时设备指令
 
 @param date 时间
 @return 指令
 */
+ (NSData *)peripheralTimingCommandWithDate:(NSDate *)date;

/**
 请求设备历史数据指令
 
 @param sn 上一条数据序列号(没有则为0)
 previous HistoryData‘s serial number(0 when none)
 @param startDate 起始时间
 @return 指令
 */
+ (NSData *)requestHistoryDataCommandWithSerialNumber:(NSInteger)sn
                                            startDate:(NSDate *)startDate;

/**
 停止发送历史数据指令
 
 @return 指令
 */
+ (NSData *)stopSendingHistoryDataCommand;


/**
 设置报警
 
 @param high 上限值
 @param low 下限值
 @param type 类型（暂仅支持温湿度报警设置 en. only support temperature & humidity for now）
 @return 指令
 */
+ (NSData *)setAlarmCommandWithHighValue:(NSInteger)high
                                lowValue:(NSInteger)low
                               valueType:(ValueType)type;

@end
