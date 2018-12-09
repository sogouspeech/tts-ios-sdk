//
//  SGSpeechTTSService.m
//  SogoOnlineTTS
//
//  Created by MaMarx on 2018/11/18.
//  Copyright © 2018年 MaMarx. All rights reserved.
//

#import "SGSpeechTTSService.h"
#import "SGSpeechTTSServiceConfig.h"
#import <SogouSpeech/sogou/speech/tts/v1/Tts.pbrpc.h>
#import <SogouSpeech/sogou/speech/tts/v1/Tts.pbobjc.h>
#import <SogouSpeech/google/rpc/Status.pbobjc.h>
#import <gRPC-ProtoRPC/ProtoRPC/ProtoRPC.h>
#import <gRPC-RxLibrary/RxLibrary/GRXWriter.h>
#import <gRPC-RxLibrary/RxLibrary/GRXBufferedPipe.h>

#error 请更换线上域名
static NSString *const kHostAddress = @"canary.speech.sogou.com:443";

@interface SGSpeechTTSService ()
@property (nonatomic, strong) SPBtts *ttsService;
@property (nonatomic, assign) BOOL streaming;
@property (nonatomic, strong) GRPCProtoCall *call;
@property (nonatomic, strong) GRXBufferedPipe *writer;

@property (nonatomic, copy) NSString* appid;
@property (nonatomic, copy) NSString* uuid;
@property (nonatomic, copy) NSString* token;

@property (nonatomic, strong) SGSpeechTTSServiceConfig * config;
@end

@implementation SGSpeechTTSService

-(id)init {
    if (self = [super init]) {
        _appid = nil;
        _uuid = nil;
        _token = nil;
        _config = [SGSpeechTTSServiceConfig defaultConfig];
    }
    return self;
}

-(void)setAppid:(NSString *)appid uuid:(NSString *)uuid token:(NSString *)token{
    self.appid = appid;
    self.uuid = uuid;
    self.token = token;
}

-(void)setConfig:(id)config{
    _config = (SGSpeechTTSServiceConfig*)config;
}

-(void)synthesisUtterance:(NSString *)utterance{
    self.ttsService = [[SPBtts alloc]initWithHost:kHostAddress];
    SPBSynthesizeRequest * request = [[SPBSynthesizeRequest alloc] init];
    
    SPBSynthesisInput* input = [[SPBSynthesisInput alloc] init];
    input.text = utterance;
    request.input = input;
    
    SPBSynthesizeConfig * config = [[SPBSynthesizeConfig alloc] init];
    SPBVoiceConfig* voiceConf = [[SPBVoiceConfig alloc] init];
    voiceConf.languageCode = self.config.languageCode;
    voiceConf.speaker = self.config.speaker;
    config.voiceConfig = voiceConf;
    
    SPBAudioConfig * audioConf = [[SPBAudioConfig alloc] init];
    audioConf.audioEncoding = self.config.audioEncoding;
    audioConf.speakingRate = self.config.speakingRate;
    audioConf.pitch = self.config.pitch;
    audioConf.volume = self.config.volume;
    config.audioConfig = audioConf;
    
    request.config = config;
    
    __weak typeof(self) weakSelf = self;
    self.call = [self.ttsService RPCToSynthesizeWithRequest:request handler:^(SPBSynthesizeResponse * _Nullable response, NSError * _Nullable error) {
        __strong typeof(self) strongSelf = weakSelf;
        [strongSelf.delegate onResults:response.audioContent error:error];
        if (response.audioContent) {
            [self debugWaveDataToFile:response.audioContent newFile:YES];
        }
        NSLog(@"err = %@",error);
        NSLog(@"response length = %zd", response.audioContent.length);
    }];
    
    self.call.timeout = 10.0;
    self.call.requestHeaders[@"appid"] = self.appid;
    self.call.requestHeaders[@"uuid"] = self.uuid;
    self.call.requestHeaders[@"Authorization"] = [NSString stringWithFormat:@"Bearer %@",self.token];
    [self.call start];
    NSLog(@"send request");
}

- (BOOL) isStreaming {
    return _streaming;
}

-(void)debugWaveDataToFile:(NSData*)data newFile:(BOOL)create
{
    static dispatch_queue_t save_wave_queue;
    static NSString *filePath = nil;
    if(save_wave_queue == nil){
        save_wave_queue = dispatch_queue_create("com.sogou.save_wave_queue", NULL);
    }
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    //        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //        [dateFormatter setDateFormat:@"yyyy-MM-dd_HH:mm:ss"];
    //        NSString *destDateString = [dateFormatter stringFromDate:[NSDate date]];
    //        NSString *fileName = [NSString stringWithFormat:@"wave_%@.pcm",destDateString];
    //        filePath = [documentsDirectory stringByAppendingPathComponent:fileName];
    
    filePath = [documentsDirectory stringByAppendingPathComponent:@"tts_wav.wav"];
    if (create) {
        if ([[NSFileManager defaultManager]fileExistsAtPath:filePath]) {
            [[NSFileManager defaultManager]removeItemAtPath:filePath error:nil];
        }
        [[NSFileManager defaultManager] createFileAtPath:filePath contents:nil attributes:nil] ;
        if (![[NSFileManager defaultManager]fileExistsAtPath:filePath]) {
            NSLog(@"@create file for saving data failed. please ensure the file path right");
            return;
        }
        NSLog(@"save file to disk %@",filePath);
    }
    
    if (![[NSFileManager defaultManager]fileExistsAtPath:filePath]) {
        NSLog(@"please ensure the file path right");
        return;
    }
    
    dispatch_async(save_wave_queue, ^{
        if (data && [data length] > 0) {
            NSFileHandle *fileHandle = [NSFileHandle fileHandleForUpdatingAtPath:filePath];
            [fileHandle seekToEndOfFile];
            [fileHandle writeData:data];
            [fileHandle closeFile];
        }
    });
}

@synthesize delegate;

@end
