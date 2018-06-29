//
//  TX10DataModel.m
//  HouseSense
//
//  Created by Waynn on 2017/10/19.
//  Copyright © 2017年 emax. All rights reserved.
//

#import "SensorDataModel.h"

@implementation SensorDataModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.temperature =  kEmptyValue;
        self.humidity =     kEmptyValue;
        self.atmospheres =  kEmptyValue;
        self.noise =        kEmptyValue;
        self.AQI =          kEmptyValue;
        
        self.timeItem = [TX10DateTimeModel new];
    }
    return self;
}

- (void)setValueWith:(SensorDataModel *)data {
    self.timeItem = data.timeItem;

    if (data.temperature != kEmptyValue) {
        self.temperature = data.temperature;
    }
    if (data.humidity != kEmptyValue) {
        self.humidity = data.humidity;
    }
    if (data.atmospheres != kEmptyValue) {
        self.atmospheres = data.atmospheres;
    }
    if (data.noise != kEmptyValue) {
        self.noise = data.noise;
    }
    if (data.AQI != kEmptyValue) {
        self.AQI = data.AQI;
    }
}

@end
