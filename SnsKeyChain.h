//
//  SnsKeyChain.h
//  ImIn
//
//  Created by mandolin on 09. 04. 13.
//  Copyright 2009 KTH(주). All rights reserved.
//
#import <UIKit/UIKit.h>
#import <Security/Security.h>
#import "ImInProtocol.h"

@class HttpConnect;
@class RegisterDevice;

#define PASSFIELD_TAG		999

/**
 @brief Paran로그인 정보 저장
 */
@interface SnsKeyChain : NSObject <ImInProtocolDelegate>{
	HttpConnect* connect;
    RegisterDevice* registerDevice;
}

@property (nonatomic, retain) RegisterDevice* registerDevice;

+ (SnsKeyChain *) sharedInstance;
- (void) setPassword: (NSString *) password;
- (NSString *) fetchPassword;

- (bool) setParanId:(NSString*) theId;
- (NSString*) fetchParanId;

- (void) sendDeviceTokenInfo:(BOOL)bEnable; ///< DeviceToken

- (bool) setSearchKM:(NSString*) theId;
- (NSString*) fetchSearchKM;

- (bool) setFirstVisit:(NSString*) theId; ///< 처음 설치한 경우의 값 -> 아임인도움말 뜨고 나서 시작하기 눌렀을때 처음 설치가 아니라고 판단하고 값 변경
- (NSString*) fetchFirstVisit;

- (bool) setToken:(NSString*) authToken;  ///< 로그인 토큰정보
- (NSString*) fetchToken;

- (bool) setoAuth:(NSString*) oauth;  ///< 로그인 oauth정보 
- (NSString*) fetchoAuth;

//- (void) TransDone:(HttpConnect*)up;
//- (void) TransFail:(HttpConnect*)up;
@end
