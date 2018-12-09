//
//  ViewController.m
//  SogoOnlineTTS
//
//  Created by MaMarx on 2018/11/18.
//  Copyright © 2018年 MaMarx. All rights reserved.
//

#import "ViewController.h"
#import "GenerateToken.h"
#import "SGSpeechOnlineSynthesizer.h"

#error 请使用在搜狗知音官网申请到的appid和key获取token
static NSString* __appid = @"XXX";
static NSString* __appkey = @"XXXX";
#error 可以采用idfv
static NSString* __uuid = @"your device uuid";

@interface ViewController () <SGSpeechOnlineSynthesizerDelegate>
@property (copy, nonatomic) NSString* token;
@property (nonatomic, strong) SGSpeechOnlineSynthesizer *synthesizer;


@property (weak, nonatomic) IBOutlet UIButton *startButton;
@property (weak, nonatomic) IBOutlet UITextField *textFieldSpeed;
@property (weak, nonatomic) IBOutlet UITextField *textFieldVolume;
@property (weak, nonatomic) IBOutlet UITextField *textFieldPitch;
@property (weak, nonatomic) IBOutlet UITextView *textViewUtterance;
@property (weak, nonatomic) IBOutlet UILabel *labelStatus;




- (IBAction)startButtonDown:(id)sender;
- (IBAction)pauseButtonDown:(id)sender;
- (IBAction)resumeButtonDown:(id)sender;
- (IBAction)stopButtonDown:(id)sender;
- (IBAction)cancelButtonDown:(id)sender;

- (IBAction)speedChange:(id)sender;
- (IBAction)volumeChanged:(id)sender;
- (IBAction)pitchChanged:(id)sender;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.textFieldSpeed.text = @"1.0";
    self.textFieldPitch.text = @"1.0";
    self.textFieldVolume.text = @"1.0";
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(keyboardHide:)];
    tapGestureRecognizer.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapGestureRecognizer];
    
    __weak typeof(self) weakSelf = self;
    [GenerateToken requestTokenWithAppid:__appid appkey:__appkey uuid:__uuid durationHours:10 handler:^(NSString *token, NSError *error, BOOL success) {
        __strong typeof(self) strongSelf = weakSelf;
        strongSelf.token = token;
        NSLog(@"token : %@", token);
        NSLog(@"error : %@", error);
        if (success && strongSelf.token) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.labelStatus.text = @"获取token成功";
            });
        }
        else{
            dispatch_async(dispatch_get_main_queue(), ^{
                self.labelStatus.text = @"获取token失败，请重启应用";
            });
        }
    }];
    // Do any additional setup after loading the view, typically from a nib.
}

-(void)keyboardHide:(UITapGestureRecognizer*)tap{
    [self.textFieldSpeed resignFirstResponder];
    [self.textFieldPitch resignFirstResponder];
    [self.textFieldVolume resignFirstResponder];
    [self.textViewUtterance resignFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)startButtonDown:(id)sender {
    NSString *str = self.textViewUtterance.text;
    if (str.length > 0) {
        SogoSpeechUtteranceOnline * utterance = [[SogoSpeechUtteranceOnline alloc] initWithString:str];
        float rate = [self.textFieldSpeed.text floatValue];
        utterance.rate = rate;
        utterance.pitchMultiplier = [self.textFieldPitch.text floatValue];
        utterance.volume = [self.textFieldVolume.text floatValue];
        self.synthesizer = [[SGSpeechOnlineSynthesizer alloc] init];
        [self.synthesizer setDelegate:self];
        [self.synthesizer setAppid:__appid uuid:__uuid token:self.token];
        [self.synthesizer speakUtterance:utterance];
        
        self.labelStatus.text = @"开始合成";
    }
}

- (IBAction)pauseButtonDown:(id)sender {
    [self.synthesizer pauseSpeaking];
}

- (IBAction)resumeButtonDown:(id)sender {
    [self.synthesizer continueSpeaking];
}

- (IBAction)stopButtonDown:(id)sender {
    [self.synthesizer stopSpeaking];
}

- (IBAction)cancelButtonDown:(id)sender {
    [self.synthesizer  cancelSpeaking];
}

- (IBAction)speedChange:(id)sender {
    
}

- (IBAction)volumeChanged:(id)sender {
    
}

- (IBAction)pitchChanged:(id)sender {
    
}


- (void)speechSynthesizer:(SGSpeechOnlineSynthesizer *)synthesizer didFinishSpeechUtterance:(SogoSpeechUtteranceOnline *)utterance{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.labelStatus.text = @"播放完成";
    });
    NSLog(@"%s",__func__);
}
- (void)speechSynthesizer:(SGSpeechOnlineSynthesizer *)synthesizer didPauseSpeechUtterance:(SogoSpeechUtteranceOnline *)utterance{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.labelStatus.text = @"暂停播放";
    });
    NSLog(@"%s",__func__);
}
- (void)speechSynthesizer:(SGSpeechOnlineSynthesizer *)synthesizer didContinueSpeechUtterance:(SogoSpeechUtteranceOnline *)utterance{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.labelStatus.text = @"继续播放";
    });
    NSLog(@"%s",__func__);
}
- (void)speechSynthesizer:(SGSpeechOnlineSynthesizer *)synthesizer didCancelSpeechUtterance:(SogoSpeechUtteranceOnline *)utterance{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.labelStatus.text = @"取消播放";
    });
    NSLog(@"%s",__func__);
}
- (void)speechSynthesizer:(SGSpeechOnlineSynthesizer *)synthesizer errorOccur:(NSError *)error{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.labelStatus.text = [NSString stringWithFormat:@"播放失败：%@",error];
    });
    NSLog(@"%s",__func__);
}


@end
