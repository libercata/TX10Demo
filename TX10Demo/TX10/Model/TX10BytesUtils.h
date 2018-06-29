//
//  TX10BytesUtils.h
//  TX10Demo
//
//  Created by Waynn on 2018/6/29.
//  Copyright © 2018年 waynn. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TX10BytesUtils : NSObject

// 校验和
+ (Byte)getCheckSum:(NSData *)data;
// 将十进制转化为十六进制
+ (NSString *)ToHex:(int)tmpid;
//字符串转data
+ (NSData*)hexToBytes:(NSString *)str;

+ (NSData *)ConvertIntToData:(int16_t)i;

@end
