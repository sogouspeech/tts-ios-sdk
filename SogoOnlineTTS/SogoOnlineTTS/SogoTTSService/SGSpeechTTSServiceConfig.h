//
//  SGSpeechTTSServiceConfig.h
//  SogoOnlineTTS
//
//  Created by MaMarx on 2018/11/19.
//  Copyright © 2018年 MaMarx. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SGSpeechTTSServiceConfig : NSObject

@property (nonatomic, copy) NSString* languageCode;
@property (nonatomic, copy) NSString* speaker;
@property (nonatomic, assign) float speakingRate;
@property (nonatomic, assign) float pitch;
@property (nonatomic, assign) float volume;
@property (nonatomic, assign) int32_t audioEncoding;

+(instancetype)defaultConfig;

@end
