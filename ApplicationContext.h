//
//  ApplicationContext.h
//  ImIn
//
//  Created by edbear on 10. 9. 10..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "const.h"
#import "ImInProtocol.h"
/**
 @brief 앱 구동부터 앱이 종료될 때까지 필요한 데이터
 */

@class BadgeList;
@class HttpConnect;


@interface ApplicationContext : NSObject<ImInProtocolDelegate, UIAlertViewDelegate> {
	NSString* documentPath;
	BOOL shouldRotate;
	BOOL theFirstLogin;
	NSString* apiVersion;
    NSString* wagwVersion;
	BadgeList* badgeList;
	NSDate* lastBadgeUpdate;
    NSDate* lastAppResume;
	
	int totalRequestCnt;
	int downloadDoneCnt;
	int downloadFailCnt;
	
	UIView* progressView;
	UIProgressView* progressBarView;
	
	AutoUpdateStatus updateStatus;
	BOOL updateCompleted;
	
	HttpConnect* connect1;

	BOOL preTokenExist;
	
	NSDictionary* badgeOwnerInfo;
    UIViewController *jsCallWebVC;
    
    BOOL searchBarHidden; // 이웃 찾기 검색창 hidden 여부
}

@property (nonatomic, retain) NSString* documentPath;
@property (readwrite) BOOL shouldRotate;
@property (readwrite) BOOL theFirstLogin;
@property (readwrite) BOOL preTokenExist;
@property (nonatomic, retain) NSString* apiVersion;
@property (nonatomic, retain) NSString* wagwVersion;
@property (nonatomic, retain) NSDate* lastBadgeUpdate;
@property (nonatomic, retain) NSDate* lastAppResume;
@property (nonatomic, retain) UIView* progressView;
@property (nonatomic, retain) UIProgressView* progressBarView;
@property (readonly) AutoUpdateStatus updateStatus;;
@property (nonatomic, retain) NSDictionary* badgeOwnerInfo;
@property (nonatomic, assign) UIViewController *jsCallWebVC;
@property (readwrite) BOOL searchBarHidden;


+(ApplicationContext *)sharedApplicationContext;
- (NSString*) privatePath:(NSString*)snsId;

+ (NSString *) platform;
+ (NSString *) platformString;
+ (NSString *) deviceId;
+ (float) osVersion;
+ (BOOL) isRetina;

- (void) downloadBadgeImage;
- (void) downloadBadgeImageWithUserInfo:(NSDictionary*) userInfo;
- (void) resetUpdateStatus;

// i-Phone Device로부터 장치 고유 아이디(UDID) 획득
- (NSString *)getDeviceUniqueIdentifier;
// MD5 해쉬함수 알고리즘 적용
- (NSString *) encryptMD5:(NSString *)str;
-(void) getDeliverySettingStatus;
- (void) openMainFrame;
- (void) checkCurAppVer:(NSString*)curAppVer returnUrl:(NSString*)updateUrl;
- (void) checkCurAppVer:(NSString*)curAppVer returnUrl:(NSString*)updateUrl withMsg:(NSString*) msg;

- (void) alertWithTitle:(NSString*)title message:(NSString*)msg returnUrl:(NSString*) url;
+ (BOOL) isHacked;
+ (BOOL) isFakeLocationInstalled;
+ (void) sendAppStart;
+ (void) sendAppResume;
- (void) closeWebViewAndOpenPostWithData:(NSMutableDictionary*) postData;
+ (void) runActivity;
+ (void) stopActivity;
- (void) pushVC:(UIViewController*) vc; // 현재 선택된 탭바의 navigation controller에 VC를 push 한다.
- (void) presentVC:(UIViewController*) vc;
- (void) badgeAcquisitionViewShow :(NSArray*)newBadgeList;
- (void) openFriendFinder;
+ (NSString*) appVersion;

- (void) selectTabWithIndex:(int)tabIndex;
+ (void)gotoReview;
@end
