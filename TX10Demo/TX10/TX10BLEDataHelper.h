//
//  HSDataHelper.h
//  HouseSense
//
//  Created by Waynn on 2018/6/27.
//  Copyright © 2018年 emax. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SensorDataModel.h"
#import "TX10Enum.h"

@protocol TX10BLEDataHelperDelegate <NSObject>

/**
 接收到了实时数据

 @param model 实时数据模型
 */
- (void)receivedRealtimeData:(SensorDataModel *)model DEPRECATED_MSG_ATTRIBUTE("use BLE Broadcast to get RealtimeData");
// @param alarmType eg. AlarmType_temHigh|AlarmType_humLow|AlarmType_batteryLow
- (void)receivedBroadcastedRealtimeData:(SensorDataModel *)model alarmType:(AlarmType)alarmType uuid:(NSString *)uuid;

/**
 接收到了历史数据

 @param model 历史数据模型 (第一次回调时为空 en. model == nil at the first callback)
 @param totalCount 本次传输的历史数据总数（第一次回调时有值 en. available at the first callback）
 */
- (void)receivedHistoryData:(SensorDataModel *)model totalCount:(NSInteger)totalCount;

/**
 收到了停止获取历史数据指令反馈
 en. did receive the 'stop sending history data' command's correct feedback
 */
- (void)didStopSendingHistoryData;

/**
 设置好了设备ID

 @param availableValueTypes 设备检测返回的数据类型
 */
- (void)didSetPeripheralID:(NSArray *)availableValueTypes;

/**
 收到了设备授时指令反馈
 */
- (void)didTimingPeripheral;

/**
 收到了设置报警值指令的反馈
 */
- (void)didSetAlarm;

/**
 收到了未知消息
 */
- (void)receivedUnknowMessage;

/**
 收到了错误消息
 */
- (void)receivedErrorMessage:(NSString *)message;

@end


/* ============================================================================== */
                                #pragma mark -
/* ============================================================================== */

@interface TX10BLEDataHelper : NSObject

/**
 接收从蓝牙设备来的数据
 received data from 'didUpdateValueForCharacteristic:'

 @param data 数据
 */
- (void)receivedData:(NSData *)data;

/**
 接收从蓝牙设备广播的实时数据
 received data from 'advertisementData[@"kCBAdvDataLocalName"]'
 
 @param dataString 实时数据
 @param uuid 设备uuid 用于判断是哪一个设备
 */
- (void)receivedBroadcastRealtimeData:(NSString *)dataString peripheralUUID:(NSString *)uuid;

@property (nonatomic, weak) id<TX10BLEDataHelperDelegate> delegate;


/* ============================================================================== */
                              #pragma mark - Block
/* ============================================================================== */

/**
 接收到了实时数据 */
@property (nonatomic, copy) void(^receivedRealtimeDataBlock)(SensorDataModel *model) DEPRECATED_MSG_ATTRIBUTE("use BLE Broadcast to get RealtimeData");
@property (nonatomic, copy) void(^receivedBroadcastedRealtimeDataBlock)(SensorDataModel *model, AlarmType alarmType, NSString *uuid);

/**
 接收到了历史数据 */
@property (nonatomic, copy) void(^receivedHistoryDataBlock)(SensorDataModel *model, NSInteger totalCount);

/**
 收到了停止获取历史数据指令反馈
 en. did receive the 'stop sending history data' command's correct feedback  */
@property (nonatomic, copy) void(^didStopSendingHistoryDataBlock)(void);

/**
 设置好了设备ID */
@property (nonatomic, copy) void(^didSetPeripheralIDBlock)(NSArray *availableValueTypes);

/**
 收到了设备授时指令反馈 */
@property (nonatomic, copy) void(^didTimingPeripheralBlock)(void);

/**
 收到了设置报警值指令的反馈 */
@property (nonatomic, copy) void(^didSetAlarmBlock)(void);

/**
 收到了未知消息 */
@property (nonatomic, copy) void(^receivedUnknowMessageBlock)(void);

/**
 收到了错误消息 */
@property (nonatomic, copy) void(^receivedErrorMessageBlock)(NSString *message);

@end
