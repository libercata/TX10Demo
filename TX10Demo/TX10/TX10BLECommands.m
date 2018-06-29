//
//  TX10BLECommands.m
//  HouseSense
//
//  Created by Waynn on 2018/6/27.
//  Copyright © 2018年 emax. All rights reserved.
//

#import "TX10BLECommands.h"
#import "TX10BytesUtils.h"

@implementation TX10BLECommands

static NSString * const kSetPeripheralIDHeaderHex = @"CD5501530A01036150";
+ (NSData *)setUUIDCommandWithUUID:(NSString *)uuid {
    
    NSMutableData *data = [NSMutableData dataWithData:[TX10BytesUtils hexToBytes:kSetPeripheralIDHeaderHex]];
    
    [data appendBytes:[TX10BytesUtils hexToBytes:uuid].bytes length:1];
    
    Byte bytes[] = {[TX10BytesUtils getCheckSum:data], 0xDB};
    [data appendBytes:bytes length:2];
    
    return data;
}

static NSString * const kSetCurrentTimeHexHeader = @"CD55015306010A2438";
+ (NSData *)peripheralTimingCommandWithDate:(NSDate *)date {
    
    NSTimeZone *t = [NSTimeZone systemTimeZone];
    int tz = (int)t.secondsFromGMT / 3600;
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute fromDate:date];
    
    int y = (int)[components year] % 100;
    int M = (int)[components month];
    int d = (int)[components day];
    
    int h = (int)[components hour];
    int m = (int)[components minute];
    
    NSMutableString *hexString = [NSMutableString stringWithString:kSetCurrentTimeHexHeader];
    [hexString appendString:[TX10BytesUtils ToHex:tz]];
    [hexString appendString:[TX10BytesUtils ToHex:y]];
    [hexString appendString:[TX10BytesUtils ToHex:M]];
    [hexString appendString:[TX10BytesUtils ToHex:d]];
    [hexString appendString:@"2A40"]; // 时分的 数据类型、长度:2A; 单位、小数点位数:40
    [hexString appendString:[TX10BytesUtils ToHex:h]];
    [hexString appendString:[TX10BytesUtils ToHex:m]];
    
    NSMutableData *data = [NSMutableData dataWithData:[TX10BytesUtils hexToBytes:hexString]];
    Byte bytes[] = {[TX10BytesUtils getCheckSum:data], 0xDB};
    [data appendBytes:bytes length:2];
    
    return data;
}

static NSString * const kGetHistoryHexHeader = @"CD550156040108";
+ (NSData *)requestHistoryDataCommandWithSerialNumber:(NSInteger)sn
                                            startDate:(NSDate *)startDate {
    
    int tz = (int)[NSTimeZone systemTimeZone].secondsFromGMT / 3600;
    
    NSMutableData *data = [NSMutableData dataWithData:[TX10BytesUtils hexToBytes:kGetHistoryHexHeader]];
    
    NSMutableString *hexString = [NSMutableString string];
    
    
    [data appendData:[TX10BytesUtils ConvertIntToData:(int16_t)sn]];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *cmpt = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute
                                         fromDate:startDate];
    
    [hexString appendString:[TX10BytesUtils ToHex:tz]];
    [hexString appendString:[TX10BytesUtils ToHex:((int)cmpt.year - 2000)]]; // 年
    [hexString appendString:[TX10BytesUtils ToHex:(int)cmpt.month]]; // 月
    [hexString appendString:[TX10BytesUtils ToHex:(int)cmpt.day]]; // 日
    [hexString appendString:[TX10BytesUtils ToHex:(int)cmpt.hour]]; // 时
    [hexString appendString:[TX10BytesUtils ToHex:(int)cmpt.minute]]; // 分
    
    [data appendData:[TX10BytesUtils hexToBytes:hexString]];
    
    Byte bytes[] = {[TX10BytesUtils getCheckSum:data], 0xDB};
    [data appendBytes:bytes length:2];
    
    return data;
}

static NSString * const kStopHistoryHex = @"CD55014301010201016CDB";
+ (NSData *)stopSendingHistoryDataCommand {
    return [TX10BytesUtils hexToBytes:kStopHistoryHex];
}

static NSString * const kSetAlarmHexHeader = @"CD550153";
+ (NSData *)setAlarmCommandWithHighValue:(NSInteger)high
                                lowValue:(NSInteger)low
                               valueType:(ValueType)type {
    NSMutableData *data = [NSMutableData dataWithData:[TX10BytesUtils hexToBytes:kSetAlarmHexHeader]];
    switch (type) {
        case ValueType_temperature: {
            [data appendData:[TX10BytesUtils hexToBytes:@"0701080201"]]; // 07:设置温度 08:数据长度 02:温度0位数2 00:单位0小数点位0
            NSData *highData = [TX10BytesUtils ConvertIntToData:(int16_t)(labs(high * 10))];
            if (high < 0) {
                Byte *byte = (Byte *)highData.bytes;
                byte[1] = byte[1] | 0x80;
                highData = [NSData dataWithBytes:byte length:2];
            }
            [data appendData:highData];
            
            [data appendBytes:(Byte[]){0x02, 0x01} length:2];
            
            NSData *lowData = [TX10BytesUtils ConvertIntToData:(int16_t)(labs(low * 10))];
            if (low < 0) {
                Byte *byte = (Byte *)lowData.bytes;
                byte[1] = byte[1] | 0x80;
                lowData = [NSData dataWithBytes:byte length:2];
            }
            [data appendData:lowData];
            break;
        }
        case ValueType_humidity: {
            [data appendData:[TX10BytesUtils hexToBytes:@"0801060948"]]; // 08:设置湿度 06:数据长度 11:湿度1位数1
            [data appendData:[TX10BytesUtils ConvertIntToData:(int8_t)high]];
            [data appendBytes:(Byte[]){0x09, 0x48} length:2];
            [data appendData:[TX10BytesUtils ConvertIntToData:(int8_t)low]];
            break;
        }
        default:
            break;
    }
    Byte bytes[] = {[TX10BytesUtils getCheckSum:data], 0xDB};
    [data appendBytes:bytes length:2];
    
    return data;
}

@end
