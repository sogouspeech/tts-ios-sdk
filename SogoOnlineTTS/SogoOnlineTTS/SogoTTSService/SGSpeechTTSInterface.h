//
//  SGSpeechTTSInterface.h
//  tts-iOS-sdk
//  Speech synthesis interface and callback
//
//  Created by sogou on 2018/12/10.
//  Copyright 2018 Sogou Inc. All rights reserved.
//  Use of this source code is governed by the Apache 2.0
//  license that can be found in the LICENSE file.
//

#import <Foundation/Foundation.h>

@protocol SGSpeechTTSDelegate <NSObject>

- (void)onResults:(id _Nullable)result error:(NSError *_Nullable)error;

@end

@protocol SGSpeechTTSInterface <NSObject>

@property(nonatomic, weak)id<SGSpeechTTSDelegate> delegate;

@required
//必须设置的三个选项，重要！
- (void)setAppid:(NSString *)appid
            uuid:(NSString *)uuid
           token:(NSString *)token;

//可选的，不设置则用默认值
- (void)setConfig:(id)config;

- (void)synthesisUtterance:(NSString *)utterance;

- (BOOL)isStreaming;

@end



