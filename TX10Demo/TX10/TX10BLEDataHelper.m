//
//  HSDataHelper.m
//  HouseSense
//
//  Created by Waynn on 2018/6/27.
//  Copyright © 2018年 emax. All rights reserved.
//

#import "TX10BLEDataHelper.h"
#import "TX10BytesUtils.h"


typedef enum : NSUInteger {
    HSPT_head = 0xCD,
    HSPT_end = 0xDB,
    HSPT_historyError = 0xFF,
    // 命令类型
    HSPT_orderC = 0x43,         // 控制类
    HSPT_orderV = 0x56,         // 数据类
    HSPT_orderS = 0x53,         // 设置类
    // 控制类二级指令 43
    HSPT_stopHistoryData = 0x01,// 实时数据
    // 数据类二级指令 56
    HSPT_realtimeData = 0x01,   // 实时数据
    HSPT_historyDataHead = 0x04,// 历史数据头
    HSPT_historyData = 0x00,    // 历史数据内容
    // 设置类二级指令 53
    HSPT_setID = 0x0A,          // 更新设备ID
    HSPT_timing = 0x06,         // 授时
    HSPT_setAlarm = 0x07,       // 设置报警
    // 警报
    HSPT_nomarl = 0x30,
    HSPT_temHigh = 0x31,
    HSPT_temLow = 0x32,
    HSPT_humHigh = 0x34,
    HSPT_humLow = 0x38,
    // 电量报警
    HSPT_batteryLow = 0x31,
} HSBLEProtocol;


@interface TX10BLEDataHelper()

@property (nonatomic, strong) NSMutableData *currentData;

@end

@implementation TX10BLEDataHelper {
    BOOL _waitForMore;
    NSUInteger _curDataLength;
    NSInteger _fixNumber;
    NSInteger _realtimeDataID;
}

- (void)notifyUnknow {
    if ([self.delegate respondsToSelector:@selector(receivedUnknowMessage)]) {
        [self.delegate receivedUnknowMessage];
    }
    if (self.receivedUnknowMessageBlock) {
        self.receivedUnknowMessageBlock();
    }
}

- (void)notifyErrorWithMessage:(NSString *)message {
    if ([self.delegate respondsToSelector:@selector(receivedErrorMessage:)]) {
        [self.delegate receivedErrorMessage:message];
    }
    if (self.receivedErrorMessageBlock) {
        self.receivedErrorMessageBlock(message);
    }
}

#pragma mark -
- (void)receivedData:(NSData *)data {

    if (_waitForMore == NO) {
        self.currentData = [NSMutableData dataWithData:data];
        
        u_int8_t *bytes = (u_int8_t *)[data bytes];
        
        if (bytes[0] != HSPT_head) {
            if (bytes[0] != HSPT_historyError && bytes[1] != HSPT_historyError) { // 历史数据返回FF不提示
                [self notifyErrorWithMessage:@"Error message header"];
            }
            return;
        }
        
        if (bytes[4] == HSPT_historyData) { // 历史数据特殊
            _fixNumber = -1;
        } else {
            _fixNumber = 0;
        }
        
        _curDataLength = bytes[6 + _fixNumber];
        
        if (_curDataLength > (data.length - 9 - _fixNumber)) {
            _waitForMore = YES;
        }
    } else {
        [self.currentData appendData:data];
        if (_curDataLength == (self.currentData.length - 9 - _fixNumber)) {
            _waitForMore = NO;
        }
    }
    
    if (_waitForMore == NO) {
        
        NSData *checkData = [self.currentData subdataWithRange:
                             NSMakeRange(0, self.currentData.length - 2)];
        Byte byte = ((Byte *)self.currentData.bytes)[self.currentData.length - 2];
        if ([TX10BytesUtils getCheckSum:checkData] == byte) {
            // 校验和通过
            [self distributeData:self.currentData];
        } else {
            [self notifyErrorWithMessage:@"Wrong checksum"];
        }
    }
}

- (void)distributeData:(NSData *)data {
    Byte *bytes = (Byte *)self.currentData.bytes;
    
    if (bytes[4] == HSPT_historyData) { // 历史数据特殊
        [self parseHistoryData:data];
    } else {

        if (bytes[3] == HSPT_orderS) {
            if (bytes[4] == HSPT_setID) {
                [self parseSetIDFeedback:bytes];
            } else if (bytes[4] == HSPT_timing) {
                [self parseTimingFeedback:bytes];
            } else if (bytes[4] == HSPT_setAlarm) {
                [self parseSetAlarmFeedback:bytes];
            }
        } else if (bytes[3] == HSPT_orderV) {
            if (bytes[4] == HSPT_realtimeData) {
                [self parseRealTimeData:data];
            } else if (bytes[4] == HSPT_historyDataHead) {
                [self parseHistoryData:data];
            }
        } else if (bytes[3] == HSPT_orderC) {
            if (bytes[4] == HSPT_stopHistoryData) {
                [self parseStopHistoryDataFeedback:bytes];
            }
        } else {
            [self notifyUnknow];
        }
    }
}

- (void)receivedBroadcastRealtimeData:(NSString *)dataString {
    dataString = [dataString substringFromIndex:5]; // 去除设备名称
    // 报警情况
    NSString *alarmString = [dataString substringWithRange:NSMakeRange(0, 3)];
    Byte *alarmBytes = (Byte *)[alarmString dataUsingEncoding:NSASCIIStringEncoding].bytes;
    
    AlarmType type = AlarmType_nomarl;
    if (_realtimeDataID != alarmBytes[1]) { // 判断是否和前一条数据相同
        if (alarmBytes[2] == HSPT_batteryLow) {
            type |= AlarmType_batteryLow;
        }
        if (alarmBytes[0] != HSPT_nomarl) {
            _realtimeDataID = alarmBytes[1];
            switch (alarmBytes[0]) {
                case HSPT_temHigh: {
                    type |= AlarmType_temHigh;
                    break;
                }
                case HSPT_temLow: {
                    type |= AlarmType_temLow;
                    break;
                }
                case HSPT_humHigh: {
                    type |= AlarmType_humHigh;
                    break;
                }
                case HSPT_humLow: {
                    type |= AlarmType_humLow;
                    break;
                }
                case HSPT_temHigh + HSPT_humHigh: {
                    type |= AlarmType_temHigh | AlarmType_humHigh;
                    break;
                }
                case HSPT_temHigh + HSPT_humLow: {
                    type |= AlarmType_temHigh | AlarmType_humLow;
                    break;
                }
                case HSPT_temLow + HSPT_humHigh: {
                    type |= AlarmType_temLow | AlarmType_humHigh;
                    break;
                }
                case HSPT_temLow + HSPT_humLow: {
                    type |= AlarmType_temLow | AlarmType_humLow;
                    break;
                }
                    
                default:
                    break;
            }
        }

    }
    // 实时数据
    NSString *realtimeString = [dataString substringFromIndex:3];
    
    NSData *data = [[realtimeString substringFromIndex:1] dataUsingEncoding:NSASCIIStringEncoding];
    
    Byte *byte = (Byte *)data.bytes;
    SensorDataModel *model = [SensorDataModel new];
    float temperature = 0;
    temperature += (byte[0] - 0x30 - '0') * 10;
    temperature += (byte[1] - 0x20 - '0');
    temperature += (byte[2] - 0x10 - '0') * 0.1;
    if ([[realtimeString substringToIndex:1] isEqualToString:@"-"] == YES) {
        // 负数
        model.temperature = -temperature;
    } else if ([[realtimeString substringToIndex:1] isEqualToString:@"+"] == NO) {
        // 不等于加号 也不等于减号 = 出错！
    } else {
        model.temperature = temperature;
    }
    
    NSInteger humidity = 0;
    humidity += (byte[3] - 0x20 - '0') * 10;
    humidity += (byte[4] - 0x10 - '0');
    model.humidity = humidity;
    
    NSInteger atmospheres = 0;
    atmospheres += (byte[5] - 0x40 - '0') * 1000;
    atmospheres += (byte[6] - 0x30 - '0') * 100;
    atmospheres += (byte[7] - 0x20 - '0') * 10;
    atmospheres += (byte[8] - 0x10 - '0');
    model.atmospheres = atmospheres;
    
    model.timeItem.date = [NSDate date];
    
    if ([self.delegate respondsToSelector:@selector(receivedBroadcastedRealtimeData:alarmType:)]) {
        [self.delegate receivedBroadcastedRealtimeData:model alarmType:type];
    }
    if (self.receivedBroadcastedRealtimeDataBlock) {
        self.receivedBroadcastedRealtimeDataBlock(model, type);
    }
}

/* ============================================================================== */
                            #pragma mark - Set
/* ============================================================================== */

/*
 Bit0=1 表示温度  Bit1=1 表示湿度 Bit2=1 表示气压  Bit3=1 表示噪声 Bit4=1 表示风量 Bit5=1表示雨量
 Bit6=1 表示VOC  Bit7=1表示PM2.5  Bit8=1 表示PM10  Bit9=1 光照度 */
typedef enum : NSUInteger {
    AVH_temperature =   1 << 0,
    AVH_humidity =      1 << 1,
    AVH_atmospheres =   1 << 2,
    AVH_noise =         1 << 3,
    AVH_windAmount =    1 << 4,
    AVH_rainfall =      1 << 5,
    AVH_VOC =           1 << 6,
    AVH_AQI_25 =        1 << 7,
    AVH_AQI_10 =        1 << 0,
    AVH_illuminance =   1 << 1,
} AvailableValueHEX;

- (void)parseSetIDFeedback:(Byte *)bytes {
    NSMutableArray *arr = [NSMutableArray array];
    if (bytes[7] & AVH_temperature) {
        [arr addObject:@(ValueType_temperature)];
    }
    if (bytes[7] & AVH_humidity) {
        [arr addObject:@(ValueType_humidity)];
    }
    if (bytes[7] & AVH_atmospheres) {
        [arr addObject:@(ValueType_atmospheres)];
    }
    if (bytes[7] & AVH_noise) {
        [arr addObject:@(ValueType_noise)];
    }
    if (bytes[7] & AVH_windAmount) {
        [arr addObject:@(ValueType_windAmount)];
    }
    if (bytes[7] & AVH_rainfall) {
        [arr addObject:@(ValueType_rainfall)];
    }
    if (bytes[7] & AVH_VOC) {
        [arr addObject:@(ValueType_VOC)];
    }
    if (bytes[7] & AVH_AQI_25 ) { // pm2.5 pm10
        [arr addObject:@(ValueType_AQI)];
    }
    if (bytes[8] & AVH_AQI_10 ) { // pm2.5 pm10
        [arr addObject:@(ValueType_AQI)];
    }
    if (bytes[8] & AVH_illuminance) {
        [arr addObject:@(ValueType_illuminance)];
    }
    
    if ([self.delegate respondsToSelector:@selector(didSetPeripheralID:)]) {
        [self.delegate didSetPeripheralID:arr];
    }
    if (self.didSetPeripheralIDBlock) {
        self.didSetPeripheralIDBlock(arr);
    }
}

- (void)parseTimingFeedback:(Byte *)bytes {
    if (bytes[5] == 0x02) {
        
        if ([self.delegate respondsToSelector:@selector(didTimingPeripheral)]) {
            [self.delegate didTimingPeripheral];
        }
        if (self.didTimingPeripheralBlock) {
            self.didTimingPeripheralBlock();
        }
    } else {
        [self notifyErrorWithMessage:@"Timing error"];
    }
}

- (void)parseSetAlarmFeedback:(Byte *)bytes {
    if (bytes[5] == 0x02) {
        if ([self.delegate respondsToSelector:@selector(didSetAlarm)]) {
            [self.delegate didSetAlarm];
        }
        if (self.didSetAlarmBlock) {
            self.didSetAlarmBlock();
        }
    } else {
        [self notifyErrorWithMessage:@"Set alarm error"];
    }
}


/* ============================================================================== */
                            #pragma mark - Data
/* ============================================================================== */
- (void)parseRealTimeData:(NSData *)data {
    data = [data subdataWithRange:NSMakeRange(7, data.length - 2 - 7)];

    SensorDataModel *model = [self sensorDataWithData:data];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    if ([self.delegate respondsToSelector:@selector(receivedRealtimeData:)]) {
        [self.delegate receivedRealtimeData:model];
    }
    if (self.receivedRealtimeDataBlock) {
        self.receivedRealtimeDataBlock(model);
    }
#pragma clang diagnostic pop
}

- (void)parseStopHistoryDataFeedback:(Byte *)bytes {
    if (bytes[5] == 0x02) {
        if ([self.delegate respondsToSelector:@selector(didStopSendingHistoryData)]) {
            [self.delegate didStopSendingHistoryData];
        }
        if (self.didStopSendingHistoryDataBlock) {
            self.didStopSendingHistoryDataBlock();
        }
    } else {
        [self notifyErrorWithMessage:@"Stop sending history data error"];
    }
}

- (void)parseHistoryData:(NSData *)data {
    
    NSData *dataT = [data subdataWithRange:NSMakeRange(7, 2)];
    Byte *bytes = (Byte *)data.bytes;
    if ([dataT isEqualToData:[NSData dataWithBytes:(Byte[2]){0x6a,0x58} length:2]]) { // 历史数据第一个包
        NSInteger totalCount = ((bytes[9] & 0xff) | (bytes[10] & 0xff) << 8);
        
        if ([self.delegate respondsToSelector:@selector(receivedHistoryData:totalCount:)]) {
            [self.delegate receivedHistoryData:nil totalCount:totalCount];
        }
        if (self.receivedHistoryDataBlock) {
            self.receivedHistoryDataBlock(nil, totalCount);
        }
    } else {
        data = [data subdataWithRange:NSMakeRange(6, data.length - 2 - 6)];
        
        SensorDataModel *model = [self sensorDataWithData:data];
        model.serial = ((bytes[2] & 0xff) | (bytes[3] & 0xff) << 8);
        
        if ([self.delegate respondsToSelector:@selector(receivedHistoryData:totalCount:)]) {
            [self.delegate receivedHistoryData:model totalCount:-1];
        }
        if (self.receivedHistoryDataBlock) {
            self.receivedHistoryDataBlock(model, -1);
        }
    }
}

- (SensorDataModel *)sensorDataWithData:(NSData *)data {
    /** eg.
     |-------------时间------10个--||---温度--
     recived 1: cd 55 01 56 01 00 16    24 38 0c 11 08 0c 2a 40 0b 08 02 01 da
     --||-湿度--||-----气压-----|
     recived 2: 0b 09 48 36 13 1a da 8a 01 *> 75 db */
    
    SensorDataModel *model = [SensorDataModel new];
    model.timeItem = [TX10DateTimeModel new];
    
    Byte *bytes = (Byte *)[data bytes];
    
    // 解析时间数据
    int idx = [TX10BLEDataHelper parseDateTimeData:bytes time:model.timeItem];

    for (int i = idx; i < data.length; ) {
        int high5 = (bytes[i] & 0xf8) >> 3;
        //        int low3 = getLow(bytes[i]);
        switch (high5) {
            case 0: { //温度 2
                // wyntemp TODO:单位
                
                i += 2; // 类型长度位 + 单位小数点位
                
                int t = ((bytes[i] & 0xff) | (bytes[i + 1] & 0xff) << 8);
                NSLog(@"温度: %d", t);
                int y = (bytes[i-1] & 0x07); // 小数点
                model.temperature = t / 10 / pow(10, y);
                
                i += 2; // 数值长度2
                break;
            }
            case 1: { // 湿度 2
                i += 2;
                
                NSLog(@"湿度: %d", bytes[i]);
                model.humidity = bytes[i];
                i += 1;
                
                break;
            }
            case 2: { // 气压 3
                i += 2;
                
                int a = ((bytes[i] & 0xff)| (bytes[i +1] & 0xff) << 8 | (bytes[i + 2] & 0xff) << 16);
                NSLog(@"气压: %d", a);
                // 四舍五入2位
                model.atmospheres = round(a / 100);
                
                i += 3;
                break;
            }
            default:
                i = 99999; // break
                break;
        }
    }
    
    return model;
}
/**
 时间数据解析
 
 @param bytes 时间
 @return 解析后bytes数组的idx
 */
+ (int)parseDateTimeData:(u_int8_t *)bytes time:(TX10DateTimeModel *)time{
    int timeDataLength = 1;
    for (int i = 0; i <= timeDataLength; ) {
        int high5 = (bytes[i] & 0xf8) >> 3;
        if (high5 != 4 && high5 != 5) {
            return i;
            break;
        } else {
            int low3 = (bytes[i] & 0x07);
            //            NSDateComponents *cpnts = [NSDateComponents new];
            
            NSMutableArray *dateArr = [NSMutableArray array];
            NSMutableArray *timeArr = [NSMutableArray array];
            for (int j = 2; j <= low3 + 1; j++) {
                int z = bytes[(i + j)];
                if (high5 == 4) { // 日期解析
                    [dateArr addObject:@(z)];
                } else if (high5 == 5) { // 时间解析
                    [timeArr addObject:@(z)];
                }
            }
            // 跳过本次数据 2: 类型长度位 + 单位小数点位
            i += low3 + 2;
            timeDataLength += low3 + 2;
            
            if (dateArr.count > 0) {
                dateArr[1] = @([dateArr[1] integerValue] + 2000);
                time.dateArr = [NSArray arrayWithArray:dateArr];
            }
            if (timeArr.count > 0) {
                time.timeArr = [NSArray arrayWithArray:timeArr];
            }
        }
    }
    
    return 0;
}

@end
