//
//  VoiceView.m
//  RemoteControl
//
//  Created by olami on 2017/7/20.
//  Copyright © 2017年 VIA Technologies, Inc. & OLAMI Team. All rights reserved.
//

#import "VoiceView.h"
#import "Macro.h"
#import "OlamiRecognizer.h"
#import "YSCVolumeQueue.h"
#import "YSCVoiceWaveView.h"

#define OLACUSID   @"c66d7ecc-8133-49d2-8683-9aad6f1c7c16"

@interface VoiceView () <OlamiRecognizerDelegate> {
    OlamiRecognizer *olamiRecognizer;
}

@property (strong, nonatomic) NSMutableArray *slotValue;//保存slot的值
@property (strong, nonatomic) NSString *api;

@property (nonatomic, strong) YSCVoiceWaveView *voiceWaveView;
@property (nonatomic,strong)  UIView *voiceWaveParentView;

@end

@implementation VoiceView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupData];
        [self setupUI];
    }
    
    return self;
}




- (void)setupData {
    olamiRecognizer= [[OlamiRecognizer alloc] init];
    olamiRecognizer.delegate = self;
    [olamiRecognizer setAuthorization:@"bfa4bf68257b41f7af088c41f3a8e44d"
                                  api:@"asr" appSecret:@"2e7d788632f142e48cd1b7c19414a73d" cusid:OLACUSID];
    
    [olamiRecognizer setLocalization:LANGUAGE_SIMPLIFIED_CHINESE];//设置语系，这个必须在录音使用之前初始化
    
    
    
    _slotValue = [[NSMutableArray alloc] init];
}


- (void)setupUI {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 32, Kwidth, 20)];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = COLOR(255, 255, 255, 1);
    label.font = [UIFont fontWithName:FONTFAMILY size:18];
    label.text = @"说出你想要搜索的股票的名称或者代码";
    [self addSubview:label];
    
    
    [self insertSubview:self.voiceWaveParentView atIndex:0];
    [self.voiceWaveView showInParentView:self.voiceWaveParentView];
    [self.voiceWaveView startVoiceWave];

    
    
}


- (void)backAction:(UIButton *)button {
    self.block();
}

- (void)okAction:(UIButton *)button {
    
}

- (void)start {
    [olamiRecognizer start];
}

- (void)stop {
    if (olamiRecognizer.isRecording) {
        [olamiRecognizer stop];
    }
}


- (void)onResult:(NSData *)result {
    NSError *error;
    __weak typeof(self) weakSelf = self;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:result
                                                        options:NSJSONReadingMutableContainers
                                                          error:&error];
    if (error) {
        NSLog(@"error is %@",error.localizedDescription);
    }else{
        NSString *jsonStr=[[NSString alloc]initWithData:result
                                               encoding:NSUTF8StringEncoding];
        NSLog(@"jsonStr is %@",jsonStr);
        NSString *ok = [dic objectForKey:@"status"];
        if ([ok isEqualToString:@"ok"]) {
            NSDictionary *dicData = [dic objectForKey:@"data"];
            NSDictionary *asr = [dicData objectForKey:@"asr"];
            if (asr) {//如果asr不为空，说明目前是语音输入
                [weakSelf processASR:asr];
            }
            NSDictionary *nli = [[dicData objectForKey:@"nli"] objectAtIndex:0];
            NSDictionary *desc = [nli objectForKey:@"desc_obj"];
            int status = [[desc objectForKey:@"status"] intValue];
            if (status != 0) {// 0 说明状态正常,非零为状态不正常
                NSString *result  = [desc objectForKey:@"result"];
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                });
                
            }else{
                NSDictionary *semantic = [[nli objectForKey:@"semantic"]
                                          objectAtIndex:0];
                [weakSelf processSemantic:semantic];
                
            }
            
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                
            });
        }
    }
    
    
    
}

- (void)onBeginningOfSpeech {
    [self.delegate onBeginningOfSpeech];
}

- (void)onEndOfSpeech {
    [self.delegate onEndOfSpeech];
    
}


- (void)onError:(NSError *)error {
    if (error) {
        NSLog(@"error is %@",error.localizedDescription);
    }
    
}

-(void)onCancel {
    [self.delegate onCancel];
}


#pragma mark -- 处理语音和语义的结果

//处理modify
- (void)processModify:(NSString*) str {
    if ([str isEqualToString:@"query"]) {//查询股票
        NSString *name = _slotValue[0];
        if (name) {
            [self.delegate getStockName:name];
        }
        
    }
}

//处理ASR节点
- (void)processASR:(NSDictionary*)asrDic {
    NSString *result  = [asrDic objectForKey:@"result"];
    if (result.length == 0) { //如果结果为空，则弹出警告框
        
    }else{
        
    }
    
}

//处理Semantic节点
- (void)processSemantic:(NSDictionary*)semanticDic {
    NSArray *slot = [semanticDic objectForKey:@"slots"];
    [_slotValue removeAllObjects];
    if (slot.count != 0) {
        for (NSDictionary *dic in slot) {
            NSString *name = [dic objectForKey:@"name"];
            if ([name isEqualToString:@"name"]) {//获得当前股票的名称
                NSString* val = [dic objectForKey:@"value"];
                [_slotValue addObject:val];

            }
        }
        
    }
    
    NSArray *modify = [semanticDic objectForKey:@"modifier"];
    if (modify.count != 0) {
        for (NSString *s in modify) {
            [self processModify:s];
            
        }
        
    }
    
}

//调节声音
- (void)onUpdateVolume:(float)volume {
     CGFloat normalizedValue = volume/100;
    [_voiceWaveView changeVolume:normalizedValue];

}


//#############################################
- (YSCVoiceWaveView *)voiceWaveView {
    if (!_voiceWaveView) {
        self.voiceWaveView = [[YSCVoiceWaveView alloc] init];
    }
    
    return _voiceWaveView;
}

- (UIView *)voiceWaveParentView {
    if (!_voiceWaveParentView) {
        self.voiceWaveParentView = [[UIView alloc] init];
        CGSize screenSize = [UIScreen mainScreen].bounds.size;
        _voiceWaveParentView.frame = CGRectMake(0, 0, screenSize.width, 230*nKheight);
       
    }
    
    return _voiceWaveParentView;
}




@end
