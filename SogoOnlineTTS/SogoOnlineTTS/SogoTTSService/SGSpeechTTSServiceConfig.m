//
//  SGSpeechTTSServiceConfig.m
//  SogoOnlineTTS
//
//  Created by MaMarx on 2018/11/19.
//  Copyright © 2018年 MaMarx. All rights reserved.
//

#import "SGSpeechTTSServiceConfig.h"
#import <SogouSpeech/sogou/speech/tts/v1/Tts.pbrpc.h>

@implementation SGSpeechTTSServiceConfig

- (id) init {
    if (self = [super init]) {
        _volume = 1.0;
        _speakingRate = 1.0;
        _pitch = 1.0;
        _languageCode = @"zh-cmn-Hans-CN";
        _speaker = @"Male";
        _audioEncoding = SPBAudioConfig_AudioEncoding_Linear16;
    }
    return self;
}

+(instancetype)defaultConfig {
    return [[self alloc] init];
}

@end
