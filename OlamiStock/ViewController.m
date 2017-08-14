//
//  ViewController.m
//  OlamiStock
//
//  Created by olami on 2017/8/9.
//  Copyright © 2017年 VIA Technologies, Inc. & OLAMI Team. All rights reserved.
//

#import "ViewController.h"
#import "VoiceView.h"
#import "Macro.h"
#import "NetWorkAction.h"
#import "TFHpple.h"

#define HttpUrl @"http://hq.sinajs.cn/list="

@interface ViewController ()<VoiceViewDelegate> {
    NetWorkAction *networkAction;
    NSMutableDictionary *dicCode;
}
@property (nonatomic, strong) VoiceView       *voiceView;
@property (weak, nonatomic) IBOutlet UIView *voiceBackView;
@property (weak, nonatomic) IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *numberLabel;
@property (weak, nonatomic) IBOutlet UILabel *currentPrice;
@property (weak, nonatomic) IBOutlet UILabel *increasePrice;
@property (weak, nonatomic) IBOutlet UILabel *increasePer;
@property (weak, nonatomic) IBOutlet UILabel *todayPrice;
 
@property (weak, nonatomic) IBOutlet UILabel *traAmount;
@property (weak, nonatomic) IBOutlet UILabel *yesterdayPrice;
@property (weak, nonatomic) IBOutlet UILabel *todayMin;
@property (weak, nonatomic) IBOutlet UILabel *todayMax;
@property (weak, nonatomic) IBOutlet UILabel *traNumber;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self setupData];
    [self setupUI];
}


- (void)setupUI {
    _voiceView = [[VoiceView alloc] initWithFrame:_voiceView.frame];
    _voiceBackView.backgroundColor = COLOR(24, 49, 69, 1);
    _voiceView.delegate = self;
    [_voiceBackView addSubview:_voiceView];
    
    [self initData];
}

- (void)setupData {
    networkAction = [[NetWorkAction alloc] init];
    dicCode = [[NSMutableDictionary alloc] init];
    
    NSString *codeFile = [[NSBundle mainBundle] pathForResource:@"code" ofType:@"json"];
    if (codeFile) {
        NSData *data = [NSData dataWithContentsOfFile:codeFile];
        NSDictionary *rootDic = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
        if (rootDic) {
            NSArray *arry = rootDic[@"datacode"];
            for (NSDictionary *dic in arry) {
                NSString *name = [dic objectForKey:@"name"];
                NSString *code = [dic objectForKey:@"code"];
                [dicCode setObject:code forKey:name];
            }
        }
    }
    
}




//初始化数据
- (void)initData {
    _label.text = @"";
    _nameLabel.text = @"";
    _numberLabel.text = @"";
    _currentPrice.text = @"";
    _increasePer.text = @"";
    _increasePrice.text = @"";
    _todayMax.text = @"";
    _todayMin.text = @"";
    _todayPrice.text = @"";
    _traAmount.text = @"";
    _traNumber.text = @"";
    _yesterdayPrice.text = @"";
    
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)speakAction:(id)sender {
    [UIView animateWithDuration:0.1 animations:^{
        _voiceBackView.frame = CGRectMake(0, 421*nKheight, Kwidth, _voiceBackView.frame.size.height);
    }];
    [_voiceView start];
}

#pragma mark --Voice delegate
- (void)onUpdateVolume:(float)volume {
    
}

- (void)onEndOfSpeech {
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.1 animations:^{
            self.voiceBackView.frame = CGRectMake(0, Kheight, Kwidth, _voiceBackView.frame.size.height);
        }];
        
    });
}

-(void)onBeginningOfSpeech {
    
}

-(void)onCancel {
    
}

- (void)getStockName:(NSString *)name {
    [self stockInformation:name];
}
- (IBAction)buttonAction:(id)sender {
    
}

- (void)stockInformation:(NSString *)stockName {
    NSString *code = [dicCode objectForKey:stockName];
    NSString *url;
    if (code) {
        NSString *str = [code substringWithRange:NSMakeRange(0, 1)];
        if ([str isEqualToString:@"6"]) {//如果是6开头，说明是沪市的股票
            url = [NSString stringWithFormat:@"%@sh%@",HttpUrl,code];
        }else if ([str isEqualToString:@"0"] || [str isEqualToString:@"3"]) {//如果是0或者3开头，说明是深市的股票
            url = [NSString stringWithFormat:@"%@sz%@",HttpUrl,code];
        }
        
        [networkAction getHttp:url complete:^(id result) {
            NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
            NSString *str = [[NSString alloc] initWithData:result encoding:enc];
            NSString *tmp = [str stringByReplacingOccurrencesOfString:@"\"" withString:@""];//去掉引号
            NSArray *arry = [tmp componentsSeparatedByString:@"="];
            NSString *subStr = arry[1];
            NSArray *stockData = [subStr componentsSeparatedByString:@","];//根据,拆分字符串
            //0：”大秦铁路”，股票名字；
            //1：”27.55″，今日开盘价；
            //2：”27.25″，昨日收盘价；
            //3：”26.91″，当前价格；
            //4：”27.55″，今日最高价；
            //5：”26.20″，今日最低价；
            //8：”22114263″，成交的股票数，由于股票交易以一百股为基本单位，所以在使用时，通常把该值除以一百；
            //9：”589824680″，成交金额，单位为“元”，为了一目了然，通常以“万元”为成交金额的单位，所以通常把该值除以一万；
            //30：”2008-01-11″，日期；
            //31：”15:05:32″，时间；
            _nameLabel.text = stockData[0];
            _todayPrice.text = stockData[1];
            _yesterdayPrice.text= stockData[2];
            _currentPrice.text = stockData[3];
            
            float curPrice = [stockData[3] floatValue];
            float yesPrice = [stockData[2] floatValue];
            float min = curPrice - yesPrice;
            _increasePrice.text = [NSString stringWithFormat:@"%0.02f",min];
            
            float perNum = (min/yesPrice)*100;
            _increasePer.text = [NSString stringWithFormat:@"%0.02f%@",perNum,@"%"];
            
            _todayMax.text = stockData[4];
            _todayMin.text = stockData[5];
            long long num = [stockData[8] longLongValue];
            num = num/100;
            _traNumber.text = [NSString stringWithFormat:@"%lld手",num];
            long long num1 = [stockData[9] longLongValue];
            num1 = num1/10000;
            _traAmount.text = [NSString stringWithFormat:@"%lld万元",num1];
            ;
            
            
        } error:^(NSError *error) {
            NSLog(@"error is %@",error.localizedDescription);
        }];
        
    }

}


@end
