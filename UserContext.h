//
//  UserContext.h
//  ImIn
//
//  Created by choipd on 10. 4. 13..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "ImInProtocol.h"

@class CpData;
@class FeedCounter;
@class HttpConnect;
@class ProfileInfo;
@class FeedCount;
@class CookSnsCookie;
@class ScrapSync;
@class KissMetrics;
@class FeedList;
/**
 @brief 로그인 유저의 정보를 담고 있는 자료구조
 */

@interface UserContext: NSObject<ImInProtocolDelegate>  {
	
	BOOL isLogin;
	BOOL isFirstStart;
	NSString* userId;
	NSString* userPassword;
	NSString* userToken;
	NSString* nickName;
	NSString* userNo;
	NSString* userProfile;
	NSString* userPhoneNumber;
	NSString* snsID;
    NSString* bizType;
    NSString* userType;
	NSString* deviceToken;
    BOOL deviceTokenSent;
	NSString* token;
	NSString* oAuth;

	//중부 원점 좌표
//	int tmX;
//	int tmY;
		
	CpData* cpTwitter;
	CpData* cpFacebook;
	CpData* cpMe2day;
	CpData* cpPhone;
	
	// 중복체크해서 막을 마지막 에러 메시지
	NSString* lastMsg;
	
	// 로그아웃시에 뷰별로 초기화 하기 위한 변수 (별로 하고 싶진 않았지만...ㅜ.ㅜ)
	BOOL bFirstMyhome;
	BOOL bFirstColumbus;
	BOOL bFirstBadge;
	
	NSString* lastViewControllerClassName;
	NSMutableArray* vcCallStack;
	
	NSDate* phoneBookUpdateTime; // 전화번호 가져오는 주기 확인을 위해서
	NSDictionary* phoneBookDictionary;
	
	BOOL needMyHomeToRefresh;
	
	// feed 정보
	FeedCounter* feedCounter;
	
	// PNS메시지 관련
	NSString* pnsStr;
	
	NSMutableDictionary* setting;
	
	ProfileInfo* profileInfo;
	
	FeedCount* feedCount;
    FeedList* feedList;
    CookSnsCookie* cookSnsCookie;
    NSDictionary* snsCookie;
    ScrapSync* scrapSync;
    NSMutableArray* snsCookieArray;
    
    NSString* regDateString;
    NSDate* regDate;
    NSTimer *feedTimer;
}

@property (readwrite) BOOL isLogin;
@property (readwrite) BOOL isFirstStart;
@property (readwrite) BOOL deviceTokenSent;
@property (nonatomic, retain) NSString* userId;
@property (nonatomic, retain) NSString* userPassword;
@property (nonatomic, retain) NSString* userToken;
@property (nonatomic, retain) NSString* nickName;
@property (nonatomic, retain) NSString* userProfile;
@property (nonatomic, retain) NSString* userNo;
@property (nonatomic, retain) NSString* userPhoneNumber;
@property (nonatomic, retain) NSString* snsID;
@property (nonatomic, retain) NSString* deviceToken;
@property (nonatomic, retain) NSString* bizType;
@property (nonatomic, retain) NSString* userType;
@property (nonatomic, retain) NSString* token;
@property (nonatomic, retain) NSString* oAuth;
@property (nonatomic, retain) CpData* cpTwitter;
@property (nonatomic, retain) CpData* cpFacebook;
@property (nonatomic, retain) CpData* cpMe2day;
@property (nonatomic, retain) CpData* cpPhone;
@property (nonatomic, retain) NSString* lastMsg;
@property (nonatomic, retain) NSString* lastViewControllerClassName;
@property (nonatomic, retain) NSMutableArray* vcCallStack;
@property (nonatomic, retain) NSDate* phoneBookUpdateTime;
@property (nonatomic, retain) NSDictionary* phoneBookDictionary;
@property (readwrite) 	BOOL needMyHomeToRefresh;
@property (nonatomic, retain) FeedCounter* feedCounter;
@property (nonatomic, retain) NSMutableDictionary* setting;
@property (nonatomic, retain) NSString* pnsStr;
@property (nonatomic, retain) ProfileInfo* profileInfo;
@property (nonatomic, retain) FeedCount* feedCount;
@property (nonatomic, retain) FeedList* feedList;
@property (nonatomic, retain) CookSnsCookie* cookSnsCookie;
@property (nonatomic, retain) NSDictionary* snsCookie;
@property (nonatomic, retain) ScrapSync* scrapSync;
@property (nonatomic, retain) NSMutableArray* snsCookieArray;
@property (nonatomic, retain) NSDate* regDate;
@property (nonatomic, retain) NSString* regDateString;
@property (nonatomic, retain) KissMetrics *km;

+(UserContext *)sharedUserContext;
+(void) updateCurrentLocation;
- (id) initWithDefault;
- (NSDictionary*) getPhoneBook;
//- (void) requestFeedCount;
- (void) requestFeedList;
- (void) readSettingFromFile;
- (void) saveSettingToFile;
- (void) updateAddress;
- (void) updateDeliveryWithDictionary:(NSDictionary*) deliveryData;
- (void) updateProfileInfoWithDictionary:(NSDictionary*) profileInfoData;
- (void) loginProcess:(NSDictionary*) data;
- (void) requestSnsCookie;
- (void) syncScrap;
- (NSMutableDictionary*) setCookie : (NSString*)cookie;
- (void) recordKissMetricsWithEvent:(NSString*) eventName withInfo:(NSDictionary*) info;
- (BOOL) isBrandUser;
- (void) logoutProcess;
- (NSString*) lastFeedDateReg;
- (void) feedTimerStarter;
- (void) feedTimerStop;
- (void) requestFeedListWithTimer;
@end
