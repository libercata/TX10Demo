//
//  TX10DataModel.h
//  HouseSense
//
//  Created by Waynn on 2017/10/19.
//  Copyright © 2017年 emax. All rights reserved.
//

#import "TX10DateTimeModel.h"

// init value. if 0, will be some trouble
#define kEmptyValue 65535

@interface SensorDataModel : NSObject

@property (nonatomic, strong) TX10DateTimeModel *timeItem;

@property (nonatomic, assign) float         temperature;

@property (nonatomic, assign) NSInteger     humidity;

@property (nonatomic, assign) float         atmospheres;

@property (nonatomic, assign) NSInteger     noise;

@property (nonatomic, assign) float         windAmount;

@property (nonatomic, assign) float         rainfall;

@property (nonatomic, assign) float         VOC;

@property (nonatomic, assign) float         illuminance;

@property (nonatomic, assign) NSInteger     AQI;

@property (nonatomic, assign) NSInteger     serial;



- (void)setValueWith:(SensorDataModel *)data;

@end
