//
//  ViewController.m
//  TX10Demo
//
//  Created by Waynn on 2018/6/29.
//  Copyright © 2018年 waynn. All rights reserved.
//

#import "ViewController.h"
#import "TX10BLEDataHelper.h"
#import "TX10BytesUtils.h"

@interface ViewController ()

@property (nonatomic, strong) TX10BLEDataHelper *helper;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    _helper = TX10BLEDataHelper.new;
    
    _helper.receivedBroadcastedRealtimeDataBlock = ^(SensorDataModel *model, AlarmType alarmType) {
        NSLog(@"*=*=%s=*=* :\nreceivedBroadcastedRealtimeDataBlock", __func__);
    };
    
    _helper.didTimingPeripheralBlock = ^{
        NSLog(@"*=*=%s=*=* :\ndidTimingPeripheralBlock", __func__);
    };
    
    _helper.didSetPeripheralIDBlock = ^(NSArray *availableValueTypes) {
        NSLog(@"*=*=%s=*=* :\ndidSetPeripheralIDBlock\n%@", __func__, availableValueTypes);
    };
    
    _helper.receivedHistoryDataBlock = ^(SensorDataModel *model, NSInteger totalCount) {
        NSLog(@"*=*=%s=*=* :\nreceivedHistoryDataBlock\n%@\n%ld", __func__, model, totalCount);
    };
    
    _helper.didStopSendingHistoryDataBlock = ^{
        NSLog(@"*=*=%s=*=* :\ndidStopSendingHistoryDataBlock", __func__);
    };
    
    _helper.didSetAlarmBlock = ^{
        NSLog(@"*=*=%s=*=* :\ndidSetAlarmBlock", __func__);
    };
    
}

- (IBAction)action1:(id)sender {
//    实时广播数据 dataString
//    Tx0xx0+0+bYBU@piYI
    [_helper receivedBroadcastRealtimeData:@"Tx0xx0+0+bYBU@piYI"];

}
- (IBAction)action2:(id)sender {
//    授时
//    <cd550153 0602007e db>
    NSData *data = [TX10BytesUtils hexToBytes:@"cd5501530602007edb"];
    [_helper receivedData:data];
}
- (IBAction)action3:(id)sender {
//    更新id
//    <cd550153 0a020207 008bdb>
    NSData *data = [TX10BytesUtils hexToBytes:@"cd5501530a020207008bdb"];
    [_helper receivedData:data];
}
- (IBAction)action4:(id)sender {
//    历史数据头
//    <cd550156 0402046a 58000045 db>
    NSData *data = [TX10BytesUtils hexToBytes:@"cd5501560402046a58000045db"];
    [_helper receivedData:data];
}
- (IBAction)action5:(id)sender {
//    历史数据
//    <cd55cd03 00162438 0812061d 2a400b00 0201cb0a 09483313 1aad8701 d4db>
//    <cd55ce03 00162438 0812061d 2a400b1e 0201bb0a 09482f13 1a928701 c4db>
    NSData *data = [TX10BytesUtils hexToBytes:@"cd55cd03001624380812061d2a400b000201cb0a094833131aad8701d4db"];
    [_helper receivedData:data];
}
- (IBAction)action6:(id)sender {
//    请求停止获取历史数据
//    <cd550143 01020069 db>
    NSData *data = [TX10BytesUtils hexToBytes:@"cd55014301020069db"];
    [_helper receivedData:data];
}
- (IBAction)action7:(id)sender {
//    设置报警温度
//    <cd550153 0702007f db>
    NSData *data = [TX10BytesUtils hexToBytes:@"cd5501530702007fdb"];
    [_helper receivedData:data];
}

@end
