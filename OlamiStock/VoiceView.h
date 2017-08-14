//
//  VoiceView.h
//  RemoteControl
//
//  Created by olami on 2017/7/20.
//  Copyright © 2017年 VIA Technologies, Inc. & OLAMI Team. All rights reserved.
//


//这个页面定义了 语音输入的页面
#import <UIKit/UIKit.h>

@protocol VoiceViewDelegate <NSObject>

//返回结果
//- (void)onResult:(NSData*)result;

//取消本次会话
- (void)onCancel;

//识别失败
//- (void)onError:(NSError *)error;

//音量的大小 音频强度范围时0到100
//- (void)onUpdateVolume:(float) volume;

- (void)getStockName:(NSString *)name;//获得当前股票的名称

//开始录音
- (void)onBeginningOfSpeech;

//结束录音
- (void)onEndOfSpeech;

@end

typedef void (^CloseViewBlock)(void);

@interface VoiceView : UIView
@property (nonatomic, strong) CloseViewBlock block;
@property (nonatomic, weak) id<VoiceViewDelegate> delegate;
- (void)start;
- (void)stop;
@end
