//
//  TX10Enum.h
//  TX10Demo
//
//  Created by Waynn on 2018/6/29.
//  Copyright © 2018年 waynn. All rights reserved.
//

#ifndef TX10Enum_h
#define TX10Enum_h

typedef enum : NSUInteger {
    ValueType_None,
    ValueType_temperature,
    ValueType_humidity,
    ValueType_atmospheres,
    ValueType_noise,
    ValueType_windAmount,
    ValueType_rainfall,
    ValueType_VOC,
    ValueType_illuminance,
    ValueType_AQI,
} ValueType;

typedef enum : NSUInteger {
    // 警报
    AlarmType_nomarl = (1UL << 1),
    AlarmType_temHigh = (1UL << 2),
    AlarmType_temLow = (1UL << 3),
    AlarmType_humHigh = (1UL << 4),
    AlarmType_humLow = (1UL << 5),
    // 电量报警
    AlarmType_batteryLow = (1UL << 7),
} AlarmType;

#endif /* TX10Enum_h */
