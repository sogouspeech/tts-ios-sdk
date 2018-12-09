//
//  SGSpeechTTSInterface.h
//  SogoOnlineTTS
//
//  Created by MaMarx on 2018/11/18.
//  Copyright © 2018年 MaMarx. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SGSpeechTTSDelegate <NSObject>

-(void)onResults:(id _Nullable)result error:(NSError* _Nullable)error;

@end

@protocol SGSpeechTTSInterface <NSObject>

@property(nonatomic, weak)id<SGSpeechTTSDelegate> delegate;

@required
//必须设置的三个选项，重要！
-(void)setAppid:(NSString*)appid uuid:(NSString*)uuid token:(NSString*)token;

//可选的，不设置则用默认值
-(void)setConfig:(id)config;

-(void)synthesisUtterance:(NSString*)utterance;

-(BOOL)isStreaming;

@end



