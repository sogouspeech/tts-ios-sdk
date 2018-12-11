//
//  SGSpeechTTSServiceConfig.m
//  tts-iOS-sdk
//  Speech synthesis parameter configuration
//
//  Created by sogou on 2018/12/10.
//  Copyright 2018 Sogou Inc. All rights reserved.
//  Use of this source code is governed by the Apache 2.0
//  license that can be found in the LICENSE file.
//

#import "SGSpeechTTSServiceConfig.h"
#import <SogouSpeech/sogou/speech/tts/v1/Tts.pbrpc.h>

@implementation SGSpeechTTSServiceConfig

- (id)init {
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

+ (instancetype)defaultConfig {
    return [[self alloc] init];
}

@end
