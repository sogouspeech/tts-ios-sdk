# 搜狗知音iOS TTS SDK/Sample

此程序是iOS平台如何调用搜狗知音服务的示例程序，基于Xcode构建。
程序的目录结构如下：
```
SogoOnlineTTS.xcworkspace
├─SogoOnlineTTS.xcodeproj                    # SDK工程文件
│
├─SogouSpeech.podspec                        # 安装gRPÇ的本地配置信息
├─Podfile                                    # Cocoapods安装文件
├─Pods                                       # Cocoapods安装目录，存放gRPC相关资源
│
├─protos                                    # 识别协议/接口
│
├─SogoOnlineTTS                                # SDK
│      └─SogoTTSService                         # 搜狗在线合成服务
│      └─SGSpeechSynthesizer                    # 合成播放逻辑抽象
│
├─GenerateToken                             # 鉴权示例
│
└─ViewController/..                         # 示例程序
```

## SDK兼容性

|在线语音合成                              |  
| --------------------------------    |
|支持iOS 7.0及以上系统                  | 
|支持armv7、armv7s、arm64、i386、x86_64 |   
|支持移动网络、WIFI等网络环境             |  


## 集成

1. 安装CocoaPods   
由于搜狗语音识别服务采用gRPC协议通信，而gRPC协议在objective-c语言中，使用CocoaPods构建依赖。关于CocoaPods安装和使用，请参见官网[CocoaPods](https://cocoapods.org/)。
2. 添加gRPC相关资源  
有关gRPC的详细内容，请参见gRPC官网[gRRP](https://grpc.io/)。
* 将SogouSpeech.podspec、protos文件夹(三个proto文件)拷贝到工程中；
* 编辑Podfile文件，添加本地引用路径，并使用pod install命令安装；
``` 
pod 'SogouSpeech', :path => '.'
```
3. 添加相关封装源码到工程中

如果工程中还包含openssl并且在编译过程中遇到boringSSL与openSSL冲突，请参见[解决方案](https://chromium.googlesource.com/external/github.com/grpc/grpc/+/HEAD/src/objective-c/README.md#use)。


### 使用流程：
```
0.向搜狗获取appid和key，并通过鉴权请求得到token
1.初始化SGSpeechOnlineSynthesizer并设置授权信息
2.设置SogoSpeechUtteranceOnline
3.指定SGSpeechOnlineSynthesizer的委托类，用于回调信息
4.SGSpeechOnlineSynthesizer实例对象开启合成控制
```
### 接口说明：
语音引擎的控制类
```C
/**
设置鉴权信息

@param appid appid
@param uuid uuid
@param token 从鉴权服务获取的token，具体获取方式，请参考GenerateToken类
*/
- (void)setAppid:(NSString*)appid uuid:(NSString*)uuid token:(NSString*)token;

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
```

语音监听类
```objective-c
@protocol SGSpeechOnlineSynthesizerDelegate <NSObject>
/**
对应含义请参见消息签名
*/
@optional
- (void)speechSynthesizer:(SGSpeechOnlineSynthesizer *)synthesizer didFinishSpeechUtterance:(SogoSpeechUtteranceOnline *)utterance;
- (void)speechSynthesizer:(SGSpeechOnlineSynthesizer *)synthesizer didPauseSpeechUtterance:(SogoSpeechUtteranceOnline *)utterance;
- (void)speechSynthesizer:(SGSpeechOnlineSynthesizer *)synthesizer didContinueSpeechUtterance:(SogoSpeechUtteranceOnline *)utterance;
- (void)speechSynthesizer:(SGSpeechOnlineSynthesizer *)synthesizer didCancelSpeechUtterance:(SogoSpeechUtteranceOnline *)utterance;
- (void)speechSynthesizer:(SGSpeechOnlineSynthesizer *)synthesizer errorOccur:(NSError *)error;
@end
```

语音个性化设置
```c
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
```


## 贡献您的一份力量

如果您发现代码中存在bug，或者不足。还请您及时与我们联系。


## 附录
gRPC error code:
```c
/** Domain of NSError objects produced by gRPC. */
extern NSString *const kGRPCErrorDomain;

/**
* gRPC error codes.
* Note that a few of these are never produced by the gRPC libraries, but are of general utility for
* server applications to produce.
*/
typedef NS_ENUM(NSUInteger, GRPCErrorCode) {
/** The operation was cancelled (typically by the caller). */
GRPCErrorCodeCancelled = 1,

/**
* Unknown error. Errors raised by APIs that do not return enough error information may be
* converted to this error.
*/
GRPCErrorCodeUnknown = 2,

/**
* The client specified an invalid argument. Note that this differs from FAILED_PRECONDITION.
* INVALID_ARGUMENT indicates arguments that are problematic regardless of the state of the
* server (e.g., a malformed file name).
*/
GRPCErrorCodeInvalidArgument = 3,

/**
* Deadline expired before operation could complete. For operations that change the state of the
* server, this error may be returned even if the operation has completed successfully. For
* example, a successful response from the server could have been delayed long enough for the
* deadline to expire.
*/
GRPCErrorCodeDeadlineExceeded = 4,

/** Some requested entity (e.g., file or directory) was not found. */
GRPCErrorCodeNotFound = 5,

/** Some entity that we attempted to create (e.g., file or directory) already exists. */
GRPCErrorCodeAlreadyExists = 6,

/**
* The caller does not have permission to execute the specified operation. PERMISSION_DENIED isn't
* used for rejections caused by exhausting some resource (RESOURCE_EXHAUSTED is used instead for
* those errors). PERMISSION_DENIED doesn't indicate a failure to identify the caller
* (UNAUTHENTICATED is used instead for those errors).
*/
GRPCErrorCodePermissionDenied = 7,

/**
* The request does not have valid authentication credentials for the operation (e.g. the caller's
* identity can't be verified).
*/
GRPCErrorCodeUnauthenticated = 16,

/** Some resource has been exhausted, perhaps a per-user quota. */
GRPCErrorCodeResourceExhausted = 8,

/**
* The RPC was rejected because the server is not in a state required for the procedure's
* execution. For example, a directory to be deleted may be non-empty, etc.
* The client should not retry until the server state has been explicitly fixed (e.g. by
* performing another RPC). The details depend on the service being called, and should be found in
* the NSError's userInfo.
*/
GRPCErrorCodeFailedPrecondition = 9,

/**
* The RPC was aborted, typically due to a concurrency issue like sequencer check failures,
* transaction aborts, etc. The client should retry at a higher-level (e.g., restarting a read-
* modify-write sequence).
*/
GRPCErrorCodeAborted = 10,

/**
* The RPC was attempted past the valid range. E.g., enumerating past the end of a list.
* Unlike INVALID_ARGUMENT, this error indicates a problem that may be fixed if the system state
* changes. For example, an RPC to get elements of a list will generate INVALID_ARGUMENT if asked
* to return the element at a negative index, but it will generate OUT_OF_RANGE if asked to return
* the element at an index past the current size of the list.
*/
GRPCErrorCodeOutOfRange = 11,

/** The procedure is not implemented or not supported/enabled in this server. */
GRPCErrorCodeUnimplemented = 12,

/**
* Internal error. Means some invariant expected by the server application or the gRPC library has
* been broken.
*/
GRPCErrorCodeInternal = 13,

/**
* The server is currently unavailable. This is most likely a transient condition and may be
* corrected by retrying with a backoff.
*/
GRPCErrorCodeUnavailable = 14,

/** Unrecoverable data loss or corruption. */
GRPCErrorCodeDataLoss = 15,
};

```


