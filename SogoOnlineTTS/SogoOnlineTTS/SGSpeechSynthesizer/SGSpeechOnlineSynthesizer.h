//
//  SGSpeechOnlineSynthesizer.h
//  tts-iOS-sdk
//  Synthetic class methods and property declarations
//
//  Created by sogou on 2018/12/10.
//  Copyright 2018 Sogou Inc. All rights reserved.
//  Use of this source code is governed by the Apache 2.0
//  license that can be found in the LICENSE file.
//

#import <Foundation/Foundation.h>


/**
 设置语言和发音人，默认中文，男声。
 */
@interface SogoSpeechSynthesisVoiceOnline : NSObject

+ (SogoSpeechSynthesisVoiceOnline *)defaultVoice;
+ (SogoSpeechSynthesisVoiceOnline *)voiceWithLanguage:(NSString *)language speaker:(NSString*) character;
/**
 * The language (and optionally also the region) of the voice expressed as a
 * [BCP-47](https://www.rfc-editor.org/rfc/bcp/bcp47.txt) language tag, e.g.
 * "en-US". Required. The TTS service
 * will use this parameter to help choose an appropriate voice.  Note that
 * the TTS service may choose a voice with a slightly different language code
 * than the one selected; it may substitute a different region
 * (e.g. using en-US rather than en-CA if there isn't a Canadian voice
 * available), or even a different language, e.g. using "nb" (Norwegian
 * Bokmal) instead of "no" (Norwegian)".
 **/
@property(nonatomic, copy) NSString *language;
/**
 * The name of the speaker. Optional; if not set, the service will choose a
 * voice based on the other parameters such as language_code.
 * Current availabe speakers:
 * language of zh-cmn-Hans-CN: [Male, Female]
 * language of en-US: [Male, Female]
 **/
@property(nonatomic, copy) NSString *speaker;

@end

/**
 合成的语句
 */
@interface SogoSpeechUtteranceOnline : NSObject
+ (instancetype)speechUtteranceWithString:(NSString *)string;
- (instancetype)initWithString:(NSString *)string;

/* If no voice is specified, the system's default will be used. */
@property(nonatomic, retain, nullable) SogoSpeechSynthesisVoiceOnline *voice;
/* the text to be synthesisd */
@property(nonatomic, strong) NSString *speechString;

/* Setting these values after a speech utterance has been enqueued will have no effect. */
/**
 * Optional speaking rate/speed, in the range [0.7, 1.3]. 1.0 is the normal
 * native speed supported by the specific voice.
 * If unset(0.0), defaults to the native 1.0 speed. Any
 * other values < 0.7 or > 1.3 will return an error.
 **/
@property(nonatomic) float rate;
/** Optional speaking pitch, in the range [0.8, 1.2]. 1.0 is the default pitch. */
@property(nonatomic) float pitchMultiplier;
/** Optional audio volume, in the range [0.7, 1.3]. 1.0 is the default volume. */
@property(nonatomic) float volume;

@end

@class SGSpeechOnlineSynthesizer;

/**
 合成回调
 */
@protocol SGSpeechOnlineSynthesizerDelegate <NSObject>

/**
 含义请参见消息签名
 */
@optional
- (void)speechSynthesizer:(SGSpeechOnlineSynthesizer *)synthesizer didFinishSpeechUtterance:(SogoSpeechUtteranceOnline *)utterance;
- (void)speechSynthesizer:(SGSpeechOnlineSynthesizer *)synthesizer didPauseSpeechUtterance:(SogoSpeechUtteranceOnline *)utterance;
- (void)speechSynthesizer:(SGSpeechOnlineSynthesizer *)synthesizer didContinueSpeechUtterance:(SogoSpeechUtteranceOnline *)utterance;
- (void)speechSynthesizer:(SGSpeechOnlineSynthesizer *)synthesizer didCancelSpeechUtterance:(SogoSpeechUtteranceOnline *)utterance;
- (void)speechSynthesizer:(SGSpeechOnlineSynthesizer *)synthesizer errorOccur:(NSError *)error;
@end


/**
 合成控制
 */
@interface SGSpeechOnlineSynthesizer : NSObject

@property(nonatomic, weak) id <SGSpeechOnlineSynthesizerDelegate> delegate;

//必须设置的三个选项，重要！
/**
 设置鉴权信息
 
 @param appid appid
 @param uuid uuid
 @param token 从鉴权服务获取的token，具体获取方式，请参考GenerateToken类
 */
- (void)setAppid:(NSString*)appid uuid:(NSString *)uuid token:(NSString *)token;

/**
 开始合成
 
 @param utterance 配置后的文本
 */
- (void)speakUtterance:(SogoSpeechUtteranceOnline *)utterance;

/**
 停止合成
 
 @return 是否停止成功
 */
- (BOOL)stopSpeaking;

/**
 暂停播放
 */
- (BOOL)pauseSpeaking;

/**
 继续播放
 */
- (BOOL)continueSpeaking;

/**
 取消合成
 */
- (BOOL)cancelSpeaking;

@end
