//
//  TX10BytesUtils.m
//  TX10Demo
//
//  Created by Waynn on 2018/6/29.
//  Copyright © 2018年 waynn. All rights reserved.
//

#import "TX10BytesUtils.h"

@implementation TX10BytesUtils

+ (Byte)getCheckSum:(NSData *)data {
    Byte checkSum = 0;
    Byte *bytes = (Byte *)[data bytes];
    for (NSUInteger i = 0; i < [data length]; i++){
        checkSum += bytes[i];
    }
    return checkSum;
}

//int转data
+ (NSData *)ConvertIntToData:(int16_t)i {
    NSData *data = [NSData dataWithBytes:&i length: sizeof(i)];
    return data;
}

// 将十进制转化为十六进制
+ (NSString *)ToHex:(int)tmpid {
    NSString *nLetterValue;
    NSString *str =@"";
    int ttmpig;
    for (int i = 0; i<9; i++) {
        ttmpig=tmpid%16;
        tmpid=tmpid/16;
        switch (ttmpig)
        {
            case 10:
                nLetterValue =@"A";break;
            case 11:
                nLetterValue =@"B";break;
            case 12:
                nLetterValue =@"C";break;
            case 13:
                nLetterValue =@"D";break;
            case 14:
                nLetterValue =@"E";break;
            case 15:
                nLetterValue =@"F";break;
            default:
                nLetterValue = [NSString stringWithFormat:@"%u",ttmpig];
                
        }
        str = [nLetterValue stringByAppendingString:str];
        if (tmpid == 0) {
            break;
        }
    }
    //不够一个字节凑0
    if(str.length == 1){
        return [NSString stringWithFormat:@"0%@",str];
    }else{
        return str;
    }
}
// 字符串转data
+ (NSData*)hexToBytes:(NSString *)str {
    NSMutableData* data = [NSMutableData data];
    int idx;
    for (idx = 0; idx+2 <= str.length; idx+=2) {
        NSRange range = NSMakeRange(idx, 2);
        NSString* hexStr = [str substringWithRange:range];
        NSScanner* scanner = [NSScanner scannerWithString:hexStr];
        unsigned int intValue;
        [scanner scanHexInt:&intValue];
        [data appendBytes:&intValue length:1];
    }
    return data;
}

@end
