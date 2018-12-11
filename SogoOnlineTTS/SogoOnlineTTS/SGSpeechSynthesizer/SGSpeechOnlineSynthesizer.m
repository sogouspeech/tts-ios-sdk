//
//  SGSpeechOnlineSynthesizer.m
//  tts-iOS-sdk
//  Synthetic class methods and property declarations
//
//  Created by sogou on 2018/12/10.
//  Copyright 2018 Sogou Inc. All rights reserved.
//  Use of this source code is governed by the Apache 2.0
//  license that can be found in the LICENSE file.
//

#import "SGSpeechOnlineSynthesizer.h"
#import "SGSpeechTTSService.h"
#import <AVFoundation/AVFoundation.h>
#import "SGSpeechTTSServiceConfig.h"

@interface SGSpeechOnlineSynthesizer()<SGSpeechTTSDelegate, AVAudioPlayerDelegate>
@property (nonatomic, strong) SGSpeechTTSService *ttsService;
@property (nonatomic, copy)   NSString *appid;
@property (nonatomic, copy)   NSString *uuid;
@property (nonatomic, copy)   NSString *token;

@property (nonatomic, strong) SogoSpeechUtteranceOnline *utteranceOnline;
@property (nonatomic, strong) AVAudioPlayer *player;
@end

@implementation SGSpeechOnlineSynthesizer

- (id)init{
    if (self = [super init]) {
        _ttsService = [[SGSpeechTTSService alloc] init];
        _ttsService.delegate = self;
    }
    return self;
}

- (void)setAppid:(NSString *)appid uuid:(NSString *)uuid token:(NSString *)token {
    _appid = appid;
    _uuid = uuid;
    _token = token;
}

- (void)speakUtterance:(SogoSpeechUtteranceOnline *)utterance{
    self.utteranceOnline = utterance;
    SGSpeechTTSServiceConfig *config = [[SGSpeechTTSServiceConfig alloc] init];
    config.pitch = utterance.pitchMultiplier;
    config.volume = utterance.volume;
    config.speakingRate = utterance.rate;
    config.languageCode = utterance.voice.language;
    config.speaker = utterance.voice.speaker;
    
    [self.ttsService setConfig:config];
    [self.ttsService setAppid:_appid uuid:_uuid token:_token];
    [self.ttsService synthesisUtterance:utterance.speechString];
}

- (BOOL)stopSpeaking{
    if (self.player && self.player.isPlaying) {
        [self.player stop];
    }
    self.player = nil;
    self.ttsService = nil;
    if (self.delegate && [self.delegate respondsToSelector:@selector(speechSynthesizer:didCancelSpeechUtterance:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate speechSynthesizer:self didFinishSpeechUtterance:self.utteranceOnline];
        });
    }
    return YES;
    return YES;
}

- (BOOL)pauseSpeaking{
    if (self.player && self.player.isPlaying) {
        [self.player pause];
        if (self.delegate && [self.delegate respondsToSelector:@selector(speechSynthesizer:didPauseSpeechUtterance:)]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.delegate speechSynthesizer:self didPauseSpeechUtterance:self.utteranceOnline];
            });
        }
    }
    return YES;
}

- (BOOL)continueSpeaking{
    if (self.player && !self.player.isPlaying) {
        [self.player play];
        if (self.delegate && [self.delegate respondsToSelector:@selector(speechSynthesizer:didContinueSpeechUtterance:)]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.delegate speechSynthesizer:self didContinueSpeechUtterance:self.utteranceOnline];
            });
        }
    }
    return YES;
}

- (BOOL)cancelSpeaking{
    if (self.player && self.player.isPlaying) {
        [self.player stop];
    }
    self.player = nil;
    self.ttsService = nil;
    if (self.delegate && [self.delegate respondsToSelector:@selector(speechSynthesizer:didCancelSpeechUtterance:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate speechSynthesizer:self didCancelSpeechUtterance:self.utteranceOnline];
        });
    }
    return YES;
}

#pragma mark SGSpeechTTSDelegate
- (void)onResults:(id _Nullable)result error:(NSError * _Nullable)error {
    
    if (result) {
        NSError* err = nil;
        self.player = [[AVAudioPlayer alloc] initWithData:result error:&err];
        self.player.delegate = self;
        if (err) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(speechSynthesizer:errorOccur:)]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.delegate speechSynthesizer:self errorOccur:error];
                });
            }
            return;
        }
        else{
            [self.player prepareToPlay];
            [self.player play];
        }
    }
    
    if (error) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(speechSynthesizer:errorOccur:)]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.delegate speechSynthesizer:self errorOccur:error];
            });
        }
    }
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    if (self.delegate && [self.delegate respondsToSelector:@selector(speechSynthesizer:didFinishSpeechUtterance:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate speechSynthesizer:self didFinishSpeechUtterance:self.utteranceOnline];
        });
    }
}

@end


@implementation SogoSpeechSynthesisVoiceOnline

+ (SogoSpeechSynthesisVoiceOnline*) voiceWithLanguage:(NSString *)language speaker:(NSString *)speaker {
    SogoSpeechSynthesisVoiceOnline * voiceOnline = [[SogoSpeechSynthesisVoiceOnline alloc] init];
    voiceOnline.speaker = speaker;
    voiceOnline.language = language;
    return voiceOnline;
}

+ (SogoSpeechSynthesisVoiceOnline*) defaultVoice {
    SogoSpeechSynthesisVoiceOnline *voice = [[SogoSpeechSynthesisVoiceOnline alloc] init];
    voice.language = @"zh-cmn-Hans-CN";
    voice.speaker = @"Male";
    return voice;
}

@end

@interface SogoSpeechUtteranceOnline ()
@property int ilinecnt;
@end
@implementation SogoSpeechUtteranceOnline
static int static_ilinecnt = 0;

- (id)init{
    self = [super init];
    if (self) {
        _ilinecnt = static_ilinecnt++;
        _volume = 1.0;
        _rate = 1.0;
        _pitchMultiplier = 1.0;
        _voice = [SogoSpeechSynthesisVoiceOnline defaultVoice];
    }
    return self;
}

- (int)tag{
    return _ilinecnt;
}

+ (SogoSpeechUtteranceOnline *)speechUtteranceWithString:(NSString *)string{
    return [[self alloc] initWithString:string];
}

- (SogoSpeechUtteranceOnline *)initWithString:(NSString *)string{
    self = [super init];
    if (self) {
        self.speechString = string;
        _ilinecnt = static_ilinecnt++;
        _volume = 1.0;
        _rate = 1.0;
        _pitchMultiplier = 1.0;
        _voice = [SogoSpeechSynthesisVoiceOnline defaultVoice];
    }
    return self;
}

- (void)dealloc{
    self.speechString = nil;
}

/**
 * Optional speaking rate/speed, in the range [0.7, 1.3]. 1.0 is the normal
 * native speed supported by the specific voice.
 * If unset(0.0), defaults to the native 1.0 speed. Any
 * other values < 0.7 or > 1.3 will return an error.
 **/
/** Optional speaking pitch, in the range [0.8, 1.2]. 1.0 is the default pitch. */
/** Optional audio volume, in the range [0.7, 1.3]. 1.0 is the default volume. */
- (void)setRate:(float)value{
    float defaultRate = 1.0;
    if (fabs(value - 1.3) < 1e-6) {
        defaultRate = 1.299999;
    }
    if (fabs(value - 0.7) < 1e-6) {
        defaultRate = 0.700001;
    }
    if (value < 1.3 && value > 0.7) {
        defaultRate = value;
    }
    _rate = defaultRate;
}

- (void)setVolume:(float)volume{
    float defaultValue = 1.0;
    if (fabs(volume - 1.3) < 1e-6) {
        defaultValue = 1.299999;
    }
    if (fabs(volume - 0.7) < 1e-6) {
        defaultValue = 0.700001;;
    }
    if (volume < 1.3 && volume > 0.7) {
        defaultValue = volume;
    }
    _volume = defaultValue;
}

- (void)setPitchMultiplier:(float)pitchMultiplier{
    float defaultPitch = 1.0;
    if (fabs(pitchMultiplier - 1.2) < 1e-6) {
        defaultPitch = 1.199999;
    }
    if (fabs(pitchMultiplier - 0.8) < 1e-6) {
        defaultPitch = 0.800001;
    }
    if (pitchMultiplier < 1.2 && pitchMultiplier > 0.8) {
        defaultPitch = pitchMultiplier;
    }
    _pitchMultiplier = defaultPitch;
}

@end
