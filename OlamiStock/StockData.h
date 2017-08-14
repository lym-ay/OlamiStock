//
//  StockData.h
//  OlamiStock
//
//  Created by olami on 2017/8/9.
//  Copyright © 2017年 VIA Technologies, Inc. & OLAMI Team. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface StockData : NSObject
@property (nonatomic,strong) NSString                   *gid;//股票编号
@property (nonatomic,strong) NSString                   *increPer;//涨跌百分比
@property (nonatomic,strong) NSString                   *increase;//涨跌额
@property (nonatomic,strong) NSString                   *todayStartPri;//今日开盘价
@property (nonatomic,strong) NSString                   *yestodEndPri;//昨日收盘价
@property (nonatomic,strong) NSString                   *nowPri;//现在的价格
@property (nonatomic,strong) NSString                   *todayMax;//今日最高价
@property (nonatomic,strong) NSString                   *todayMin;//今日最低价
@property (nonatomic,strong) NSString                   *traNumber;//成交量
@property (nonatomic,strong) NSString                   *traAmount;//成交金额
@property (nonatomic,strong) NSString                   *data;//日期


@end
