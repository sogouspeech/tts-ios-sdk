//
//  SGSpeechTTSServiceConfig.h
//  tts-iOS-sdk
//  Speech synthesis parameter configuration
//
//  Created by sogou on 2018/12/10.
//  Copyright 2018 Sogou Inc. All rights reserved.
//  Use of this source code is governed by the Apache 2.0
//  license that can be found in the LICENSE file.
//

#import <Foundation/Foundation.h>

@interface SGSpeechTTSServiceConfig : NSObject

@property (nonatomic, copy) NSString *languageCode;
@property (nonatomic, copy) NSString *speaker;
@property (nonatomic, assign) float speakingRate;
@property (nonatomic, assign) float pitch;
@property (nonatomic, assign) float volume;
@property (nonatomic, assign) int32_t audioEncoding;

+ (instancetype)defaultConfig;

@end
