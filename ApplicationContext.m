//
//  ApplicationContext.m
//  ImIn
//
//  Created by edbear on 10. 9. 10..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ApplicationContext.h"
#include <sys/types.h>
#include <sys/sysctl.h>

#import "BadgeList.h"
#import "UIPlazaViewController.h"
#import <CommonCrypto/CommonDigest.h>
#import "SnsKeyChain.h"
#import "SnsHelpController.h"
#import <QuartzCore/QuartzCore.h>

#include <pwd.h>
#include <unistd.h>

// 통계관련
#import "NWAppUsageLogger.h"
#import <sqlite3.h>

#import "PostDetailTableViewController.h"

#import "GetDelivery.h"

#import "BadgeAcquisitionViewController.h"
#import "FriendFinderViewController.h"

@interface ApplicationContext() {
@private
    
}
- (id) initWithDefault;
@end

@implementation ApplicationContext

@synthesize documentPath, shouldRotate, theFirstLogin, apiVersion, wagwVersion;
@synthesize lastBadgeUpdate, progressBarView, progressView, updateStatus;
@synthesize preTokenExist;
@synthesize badgeOwnerInfo;
@synthesize jsCallWebVC;
@synthesize lastAppResume;
@synthesize searchBarHidden;


- (void) dealloc
{
	[lastBadgeUpdate release];
	[progressBarView release];
	[progressView release];
	[badgeOwnerInfo release];
    [jsCallWebVC release];
    [lastAppResume release];
    [apiVersion release];
    [wagwVersion release];
	 
	if (connect1 != nil)
	{
		[connect1 stop];
		[connect1 release];
		connect1 = nil;
	}
	
	[super dealloc];
}

//
// singleton stuff
//
static ApplicationContext *_sharedApplicationContext = nil;


+ (ApplicationContext *)sharedApplicationContext
{
    if (_sharedApplicationContext == nil) {
        _sharedApplicationContext = [[super allocWithZone:NULL] init];
        [_sharedApplicationContext initWithDefault];
    }
    return _sharedApplicationContext;    
}

+ (id)allocWithZone:(NSZone *)zone
{
    return [[self sharedApplicationContext] retain];
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

- (id)retain
{
    return self;
}

- (NSUInteger)retainCount
{
    return NSUIntegerMax;  //denotes an object that cannot be released
}

- (oneway void)release
{
    //do nothing
}

- (id)autorelease
{
    return self;
}


- (id) initWithDefault
{
	self = [super init];
	if (self != nil) {
		NSArray* docdir = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		self.documentPath = [docdir objectAtIndex:0];
		self.shouldRotate = NO;
		self.theFirstLogin = NO;
		self.preTokenExist = NO;
		self.apiVersion = @"1d02";
        self.wagwVersion = @"1.1";
		self.lastBadgeUpdate = [NSDate dateWithTimeIntervalSince1970:0];
        self.lastAppResume = [NSDate dateWithTimeIntervalSince1970:0];
		updateStatus = AUTO_UPDATE_STATUS_PREPARE;
        self.searchBarHidden = NO;
		totalRequestCnt = 0;
		downloadDoneCnt = 0;
		downloadFailCnt = 0;
	}
	return self;
}

- (NSString*) privatePath:(NSString*)snsId
{
	NSArray* docdir = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString* path = [docdir objectAtIndex:0];
	return [path stringByAppendingPathComponent:snsId];
}

+ (NSString *) platform{
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *platform = [NSString stringWithCString:machine encoding:NSASCIIStringEncoding];
    free(machine);
    return platform;
}

+ (NSString *) platformString{
    NSString *platform = [self platform];
    if ([platform isEqualToString:@"iPhone1,1"]) return @"iPhone 1G";
    if ([platform isEqualToString:@"iPhone1,2"]) return @"iPhone 3G";
    if ([platform isEqualToString:@"iPhone2,1"]) return @"iPhone 3GS";
	if ([platform isEqualToString:@"iPhone3,1"]) return @"iPhone 4";
    if ([platform isEqualToString:@"iPod1,1"])   return @"iPod Touch 1G";
    if ([platform isEqualToString:@"iPod2,1"])   return @"iPod Touch 2G";
	if ([platform isEqualToString:@"iPod3,1"])   return @"iPod Touch 3G";
	if ([platform isEqualToString:@"iPod4,1"])   return @"iPod Touch 4G";
    if ([platform isEqualToString:@"i386"])   return @"iPhone Simulator";
	if ([platform rangeOfString:@"iPad"].location != NSNotFound) return @"iPad";
    return platform;
}

+ (NSString *) deviceId {
	NSString *platform = [self platform];
	if ([platform rangeOfString:@"iPad"].location != NSNotFound) {
		return SNS_DEVICE_MOBILE_APP_IPAD;
	} else {
		return SNS_DEVICE_MOBILE_APP_IPHONE;
	}
}

+ (float) osVersion {
	NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
	return [currSysVer floatValue];
}

+ (BOOL) isRetina {
	BOOL hasHighResScreen = NO;
	if ([UIScreen instancesRespondToSelector:@selector(scale)]) {
		CGFloat scale = [[UIScreen mainScreen] scale];
		if (scale > 1.0) {
			hasHighResScreen = YES;
		}
	}
	return hasHighResScreen;
}

#pragma mark -
#pragma mark 뱃지 이미지 다운로드
#pragma mark -
#pragma mark 이미지 요청
- (void) downloadImageWithBaseURL:(NSString*) baseURL withType:(BadgeType) badgeType {
	
	NSString* filename = [[baseURL componentsSeparatedByString:@"/"] lastObject];
	NSArray* filenameComponentArray = [filename componentsSeparatedByString:@"_"];
	
	if ([filenameComponentArray count] != 4) {
		NSAssert(NO, @"파일명이 이상함");
		return;
	}
	
	NSString* badgeId = [filenameComponentArray objectAtIndex:0];
	NSString* ver = [filenameComponentArray lastObject];
	
	NSString* aNewFileName = nil;
	NSString* aNewUrl = nil;
	
	switch (badgeType) {
		case BADGE_TYPE_NORMAL:
			for (int i = 0; i < 3; i++) {
				for (int j = 0; j < 2; j++) {
					NSString* type = nil;
					NSString* size = nil;
					
					switch (i) {
						case 0:
							size = @"53x53";
							break;
						case 1:
							size = @"84x84";
							break;
						case 2:
							size = @"252x252";
							break;
					}
					
					switch (j) {
						case 0:
							type = @"f";
							break;
						case 1:
							if (i == 0 || i == 2) {
								continue;	// 53x53에서와 252x252 사이즈는 n 이미지가 없음
							}
							type = @"n";
							break;
					}
					aNewFileName = [NSString stringWithFormat:@"%@_%@_%@_%@", badgeId, size, type, ver];
					aNewUrl = [baseURL stringByReplacingOccurrencesOfString:filename withString:aNewFileName];
					
					[Utils requestImageCacheWithURL:aNewUrl
										   delegate:self
									   doneSelector:@selector(cacheDone:) 
									  errorSelector:@selector(cacheFailed:) cacheHitSelector:@selector(cacheHitted:)];
				}
			}
			// 상세 이미지 뒷면 이미지 추가 다운로드
			aNewFileName = [NSString stringWithFormat:@"%@_252x252_b_%@", badgeId, ver];
			aNewUrl = [baseURL stringByReplacingOccurrencesOfString:filename withString:aNewFileName];
			[Utils requestImageCacheWithURL:aNewUrl
								   delegate:self
							   doneSelector:@selector(cacheDone:) 
							  errorSelector:@selector(cacheFailed:) cacheHitSelector:@selector(cacheHitted:)];
			
			break;
		case BADGE_TYPE_SET:
			for (int i = 0; i < 4; i++) {
				for (int j = 0; j < 2; j++) {
					NSString* type = nil;
					NSString* size = nil;
					
					switch (i) {
						case 0:
							size = @"53x53";
							break;
						case 1:
							size = @"84x84";
							break;
						case 2:
							size = @"168x168";
							break;
						case 3:
							size = @"252x252";
							break;
					}
					
					switch (j) {
						case 0:
							type = @"f";
							break;
						case 1:
							if (i == 0 || i == 3) {
								continue;	// 252x252 사이즈는 n 이미지가 없음
							}
							type = @"n";
							break;
					}
					aNewFileName = [NSString stringWithFormat:@"%@_%@_%@_%@", badgeId, size, type, ver];
					aNewUrl = [baseURL stringByReplacingOccurrencesOfString:filename withString:aNewFileName];
					
					[Utils requestImageCacheWithURL:aNewUrl
										   delegate:self
									   doneSelector:@selector(cacheDone:) 
									  errorSelector:@selector(cacheFailed:) cacheHitSelector:@selector(cacheHitted:)];
				}
			}
			// 상세 이미지 뒷면 이미지 추가 다운로드
			aNewFileName = [NSString stringWithFormat:@"%@_252x252_b_%@", badgeId, ver];
			aNewUrl = [baseURL stringByReplacingOccurrencesOfString:filename withString:aNewFileName];
			[Utils requestImageCacheWithURL:aNewUrl
								   delegate:self
							   doneSelector:@selector(cacheDone:) 
							  errorSelector:@selector(cacheFailed:) cacheHitSelector:@selector(cacheHitted:)];
			
			// 판 배경 이미지 추가 다운로드
			aNewFileName = [NSString stringWithFormat:@"%@_iph_bg_%@", badgeId, ver];
			aNewUrl = [baseURL stringByReplacingOccurrencesOfString:filename withString:aNewFileName];
			[Utils requestImageCacheWithURL:aNewUrl
								   delegate:self
							   doneSelector:@selector(cacheDone:) 
							  errorSelector:@selector(cacheFailed:) cacheHitSelector:@selector(cacheHitted:)];
			break;
		default:
			break;
	}
	
}	

- (void) downloadBadgeImage {
	updateStatus = AUTO_UPDATE_STATUS_REQUESTED;
	badgeList = [[BadgeList alloc] init];
	badgeList.delegate = self;
	
	NSArray* keys = [NSArray arrayWithObjects:@"snsId", @"scale", @"listType",  nil];
	
	NSArray* values = [NSArray arrayWithObjects:[UserContext sharedUserContext].snsID, @"100", @"0",  nil];
	[badgeList.params addEntriesFromDictionary:[NSDictionary dictionaryWithObjects:values forKeys:keys]];	
	[badgeList requestWithAuth:NO withIndicator:YES];
}

- (void) downloadBadgeImageWithUserInfo:(NSDictionary*) userInfo {
	self.badgeOwnerInfo = userInfo;
	[self downloadBadgeImage];
}

- (void) progressHide:(UIButton*) sender {
	progressView.hidden = YES;
}

- (void) apiDidLoadWithResult:(NSDictionary *)result whichObject:(NSObject *)theObject {
    
	if ([[result objectForKey:@"func"] isEqualToString:@"getDelivery"]) {
        [theObject release];
        UserContext* uc = [UserContext sharedUserContext];
        
        NSArray* resultList = [result objectForKey:@"data"];
        for (NSDictionary* data in resultList) {
            NSString* cpCode = [data objectForKey:@"cpCode"];
            
            if ([cpCode isEqualToString:@"51"]) { // twitter
                uc.cpTwitter = [[[CpData alloc] initWithDictionary:data] autorelease];
            }
            
            if ([cpCode isEqualToString:@"52"]) { // facebook
                uc.cpFacebook = [[[CpData alloc] initWithDictionary:data] autorelease];
            }
            
            if ([cpCode isEqualToString:@"50"]) { // me2day
                uc.cpMe2day = [[[CpData alloc] initWithDictionary:data] autorelease];
            }
        }
        
        if (uc.cpTwitter == nil) {
            uc.cpTwitter = [[[CpData alloc] init] autorelease];
        }
        
        if (uc.cpFacebook == nil) {
            uc.cpFacebook = [[[CpData alloc] init] autorelease];
        }
        
        if (uc.cpMe2day == nil) {
            uc.cpMe2day = [[[CpData alloc] init] autorelease];
        }
        
        [self openMainFrame];
    }
	
	if ([[result objectForKey:@"func"] isEqualToString:@"badgeList"]) {
        [theObject release];
		int badgeCnt = [[result objectForKey:@"totalCnt"] intValue];
		if (badgeCnt > 0) {
			if (progressView == nil) {
				self.progressView = [[[UIView alloc] initWithFrame:CGRectMake(0, 480, 320, 43)] autorelease];
				progressView.backgroundColor = RGB(187, 187, 187);
				progressView.alpha = 1.0f;
				
				UIImageView* bgImageView = [[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 43)] autorelease];
				[bgImageView setImage:[UIImage imageNamed:@"update_bg.png"]];
				[progressView addSubview:bgImageView];
                
				self.progressBarView = [[[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar] autorelease];
				progressBarView.frame = CGRectMake(20, 26, 260, 10);
				progressBarView.progress = 0.0f;
				
				UIButton* aCancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
				aCancelBtn.frame = CGRectMake(289, 9, 26, 26);
				[aCancelBtn setImage:[UIImage imageNamed:@"update_close.png"] forState:UIControlStateNormal];
				[aCancelBtn addTarget:self action:@selector(progressHide:) forControlEvents:UIControlEventTouchUpInside];
				[progressView addSubview:aCancelBtn];
				
				
				[progressView addSubview:progressBarView];
				UILabel* guideMsg = [[[UILabel alloc] initWithFrame:CGRectMake(20, 6, 260, 16)] autorelease];
				guideMsg.backgroundColor = [UIColor clearColor];
				guideMsg.text = @"리소스 업데이트 중입니다. 잠시만 기다려 주세요";
				guideMsg.font = [UIFont systemFontOfSize:12];
				guideMsg.textColor = [UIColor whiteColor];
				[guideMsg setTextAlignment:UITextAlignmentLeft];
				[progressView addSubview:guideMsg];
				
				[[ViewControllers sharedViewControllers].tabBarController.view addSubview:progressView];
			}
			progressBarView.progress = 0.0f;
			progressView.hidden = NO;
			progressView.alpha = 1.0f;
		}
		
		totalRequestCnt = 0;
		downloadDoneCnt = 0;
		downloadFailCnt = 0;
		
		for ( NSDictionary* badge in [result objectForKey:@"data"] )
		{
			if ([[badge objectForKey:@"badgeId"] isEqualToString:[badge objectForKey:@"parentBadgeId"]]) {
				totalRequestCnt += 8;
			} else {
				totalRequestCnt += 5;
			}
		}
        
		for ( NSDictionary* badge in [result objectForKey:@"data"] )
		{
			BadgeType badgeType;
			if ([[badge objectForKey:@"badgeId"] isEqualToString:[badge objectForKey:@"parentBadgeId"]]) {
				badgeType = BADGE_TYPE_SET;
			} else {
				badgeType = BADGE_TYPE_NORMAL;
			}
            
			[self downloadImageWithBaseURL:[badge objectForKey:@"imgUrl"] withType:badgeType];
		}
	}
}

- (void) apiFailedWhichObject:(NSObject *)theObject {
	if (theObject == badgeList) {
		UIAlertView* aInfo = [[[UIAlertView alloc] initWithTitle:@"안내" 
														 message:@"네트워크 상황이 불안합니다.\n다시 시도하시겠습니까?" 
														delegate:self
											   cancelButtonTitle:@"아니요" otherButtonTitles:@"재시도", nil] autorelease];
		aInfo.tag = 1009; // 뱃지 리스트 받기 실패시
		[aInfo show];	
        [theObject release];
	}
    
    if ([NSStringFromClass([theObject class]) isEqualToString:@"GetDelivery"]) {
        [theObject release];
    }
}

- (void)alertView:(UIAlertView*)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (alertView.tag == 1009 && buttonIndex == 1)
	{
		updateStatus = AUTO_UPDATE_STATUS_PREPARE;
		[self downloadBadgeImage];
	}
    
    if (alertView.tag == 1009 && buttonIndex == 0)
	{
        return;
	}
	
	if (alertView.tag == 1010 && buttonIndex == 1)
	{
		NSString* url = alertView.layer.name;
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
	}
}

- (void) updateProgress {
	progressBarView.progress = (float)(downloadDoneCnt + downloadFailCnt) / (float)totalRequestCnt;
	
	if (progressBarView.progress > 1.0f) {
		MY_LOG(@"WTF");
	}
	
	if (progressBarView.progress == 1.0f) {	// 완료
		[UIView beginAnimations:@"downloadNoticiation" context:nil];
		[UIView setAnimationDuration:1];
		progressView.frame = CGRectMake(0, 480, 320, 43);
		[UIView commitAnimations];
		
		// 만약 실패한 게 있다면 다시 다운 받을 수 있도록 상태를 초기화 해준다.
		if (downloadFailCnt == 0) {
			updateStatus = AUTO_UPDATE_STATUS_COMPLETE_DOWNLOAD;
		} else {
			updateStatus = AUTO_UPDATE_STATUS_PREPARE;
		}
		
		[[NSNotificationCenter defaultCenter] postNotificationName:@"autoUpdate" object:nil userInfo:badgeOwnerInfo];
	}
	
	if (downloadDoneCnt == 1) {
		[UIView beginAnimations:@"downloadNoticiation" context:nil];
		[UIView setAnimationDuration:1];
		progressView.frame = CGRectMake(0, 480-43, 320, 43);
		[UIView commitAnimations];
		
		updateStatus = AUTO_UPDATE_STATUS_START_DOWNLOAD;
	}
	
}

- (void) cacheDone:(NSString*) url {
	self.lastBadgeUpdate = [NSDate date];
	downloadDoneCnt++;
//	MY_LOG(@"cacheDone: %3d/%3d %@", downloadDoneCnt, totalRequestCnt, url);
	[self updateProgress];
}

- (void) cacheFailed:(NSString*) url {
//	MY_LOG(@"cacheFailed: %@", url);
	downloadFailCnt++;
}

- (void) cacheHitted:(NSString*) url {
	downloadDoneCnt++;
//	MY_LOG(@"캐시히트: %3d/%3d %@", downloadDoneCnt, totalRequestCnt, url);
	[self updateProgress];
}

- (void) resetUpdateStatus {
	updateStatus = AUTO_UPDATE_STATUS_PREPARE;
}

#pragma mark -
#pragma mark Twitter Setting Value

-(void) getDeliverySettingStatus
{
    GetDelivery* getDelivery = [[GetDelivery alloc] init];
    getDelivery.delegate = self;
    [getDelivery request];
}

#pragma mark -
#pragma mark plaza setting

- (void) openMainFrame
{	
	//로그인 성공했을 때
	
	UIPlazaViewController* plazaVC = (UIPlazaViewController*)[ViewControllers sharedViewControllers].plazaViewController;
	plazaVC.isLogin = YES;
	[UserContext sharedUserContext].isLogin = YES;
	
	//로그인 완성 단계에서 keychain에 토큰값을 저장한다.
	[[SnsKeyChain sharedInstance] setToken:[UserContext sharedUserContext].token];
	[[SnsKeyChain sharedInstance] setoAuth:[UserContext sharedUserContext].oAuth];
	
	[plazaVC.navigationController popToRootViewControllerAnimated:NO];
	
}

#pragma mark -
#pragma mark UDID
// i-Phone Device로부터 장치 고유 아이디(UDID) 획득
- (NSString *)getDeviceUniqueIdentifier {
	UIDevice *device = [UIDevice currentDevice];
	NSString *deviceId = [device uniqueIdentifier];
	//Base64 Encoding 수행
	//NSData *srcData = [deviceId dataUsingEncoding:NSUTF8StringEncoding];
	//NSString *encData = [srcData base64Encoding];
	
	// 해쉬함수 알고리즘(MD5) 적용
	NSString *encData = [self encryptMD5:deviceId];
	
	return encData;
}

// MD5 해쉬함수 알고리즘 적용
- (NSString *) encryptMD5:(NSString *)str {
	const char *cStr = [str UTF8String];	
	unsigned char result[CC_MD5_DIGEST_LENGTH];
	CC_MD5( cStr, strlen(cStr), result );
	return [NSString stringWithFormat: @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
			result[0], result[1], result[2], result[3], result[4], result[5], result[6], result[7],
			result[8], result[9], result[10], result[11], result[12], result[13], result[14], result[15] ];	
}

#pragma mark -
#pragma mark 현재 버전 체크 
- (void) checkCurAppVer:(NSString*)curAppVer returnUrl:(NSString*)updateUrl {
    [self checkCurAppVer:curAppVer returnUrl: updateUrl withMsg:nil];
}

- (void) checkCurAppVer:(NSString*)curAppVer returnUrl:(NSString*)updateUrl withMsg:(NSString*) msg {
    
	NSString *exeVersion = [ApplicationContext appVersion];
	
	NSArray* myAppVersionFields = [exeVersion componentsSeparatedByString:@"."];
	NSArray* serverAppVersionFields = [curAppVer componentsSeparatedByString:@"."];
	
	// 앱의 버전을 체크한다.
	BOOL isNewer = NO;
	for (int i = 0; i < 3; i++) {
		int server = [[serverAppVersionFields objectAtIndex:i] intValue];
		int local = [[myAppVersionFields objectAtIndex:i] intValue];
		
		if (server == local) {
			continue;
		} else  {
			isNewer = server > local;
			break;
		}
	}
	
	if (isNewer) {
		if (![updateUrl isEqualToString:@""]) {
            if (msg != nil && ![msg isEqualToString:@""]) {
                [self alertWithTitle:@"안내" message:msg returnUrl:updateUrl];
            } else {
                [self alertWithTitle:@"안내" message:@"설치하지 않은 최신 버전이 있습니다. 업그레이드 하시겠습니까?" returnUrl:updateUrl];
            }
		}
	}	
}
		 
- (void) alertWithTitle:(NSString*)title message:(NSString*)msg returnUrl:(NSString*) url {
	
	if (msg == nil || title == nil || url == nil) return;

	UIAlertView* alertView = [[[UIAlertView alloc] initWithTitle:title
													  message:msg 
													 delegate:self 
											cancelButtonTitle:@"취소"
											otherButtonTitles:@"확인", nil] autorelease];
	alertView.tag = 1010;
	alertView.layer.name = url;

	[alertView show];
}

+ (BOOL) isHacked
{
	NSString *filePath = @"/Applications/Cydia.app";
	
	if ([[NSFileManager defaultManager] fileExistsAtPath:filePath])
	{
		MY_LOG(@"해킹폰이닷");
		return YES;
	} else {
		MY_LOG(@"정상폰이닷");
		return NO;
	}
}

+ (BOOL) isFakeLocationInstalled
{
	NSString *filePath = @"/Applications/FakeLocation_FrontEnd.app";
	if ([[NSFileManager defaultManager] fileExistsAtPath:filePath])
	{
		MY_LOG(@"FakeLocation이 깔렸다.");
		return YES;
	} else {
		MY_LOG(@"FaceLocation이 깔리지 않았다");
		return NO;
	}	
}

+ (void) sendAppStart
{
	// 시작 정보 통계 처리
	NSString *exeVersion = [ApplicationContext appVersion];
	NSString* eventDesc = [NSString stringWithFormat:@"%@|%@|%@", [ApplicationContext platformString], [[UIDevice currentDevice] systemVersion], exeVersion];
	MY_LOG(@"모바일통계용 APP_START: %@",  eventDesc);
	NWAppUsageLogger *logger = [NWAppUsageLogger logger];
	[logger fireUsageLog:@"APP_START" andEventDesc:eventDesc andCategoryId:nil];
    
    NSInteger appStartCount = [[[NSUserDefaults standardUserDefaults] objectForKey:@"APP_START_COUNT"] intValue];
    appStartCount++;
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:appStartCount] forKey:@"APP_START_COUNT"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void) sendAppResume
{
	// 시작 정보 통계 처리
	NSString *exeVersion = [ApplicationContext appVersion];
	NSString* eventDesc = [NSString stringWithFormat:@"%@|%@|%@", [ApplicationContext platformString], [[UIDevice currentDevice] systemVersion], exeVersion];
	MY_LOG(@"모바일통계용 APP_RESUME: %@",  eventDesc);
	NWAppUsageLogger *logger = [NWAppUsageLogger logger];
	[logger fireUsageLog:@"APP_RESUME" andEventDesc:eventDesc andCategoryId:nil];

    if ([UserContext sharedUserContext].isLogin) {
        [[UserContext sharedUserContext] recordKissMetricsWithEvent:@"Visits" withInfo:nil];
    }
}

- (void) closeWebViewAndOpenPostWithData:(NSMutableDictionary*) postData
{
    PostDetailTableViewController* vc = [[PostDetailTableViewController alloc] 
                                         initWithNibName:@"PostDetailTableViewController" 
                                         bundle:nil];
    vc.postData = postData;
    [(UINavigationController*)[ViewControllers sharedViewControllers].tabBarController.selectedViewController pushViewController:vc animated:YES];
    [vc release];
}

+ (void) runActivity
{
    UIWindow* mainWindow = [[UIApplication sharedApplication] keyWindow];
    UIView* hudView = [mainWindow viewWithTag:8080];
    if (hudView == nil) {
        hudView = [[[UIView alloc] initWithFrame:CGRectMake(mainWindow.frame.size.width/2-30, mainWindow.frame.size.height/2-30,60,60)] autorelease];
        hudView.tag = 8080;
    #ifdef APP_STORE_FINAL
        hudView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
    #else
        hudView.backgroundColor = [UIColor colorWithRed:255 green:0 blue:0 alpha:0.3];
    #endif
        hudView.clipsToBounds = YES;
        hudView.layer.cornerRadius = 10.0;
        
        [mainWindow addSubview:hudView];
    }
    
    UIActivityIndicatorView* actView = (UIActivityIndicatorView*)[hudView viewWithTag:8081];
    if (actView == nil) {
        actView = [[[UIActivityIndicatorView alloc] 
                    initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge] autorelease];
        actView.tag = 8081;
        [actView setCenter:CGPointMake(hudView.frame.size.width/2, hudView.frame.size.height/2)];
        [hudView addSubview:actView];
    }
    
    [actView startAnimating];        
}


+ (void) stopActivity
{
    UIWindow* mainWindow = [[UIApplication sharedApplication] keyWindow];
    UIView* hudView = [mainWindow viewWithTag:8080];
    if (hudView != nil) {
        UIActivityIndicatorView* actView = (UIActivityIndicatorView*)[hudView viewWithTag:8081];
        if (actView != nil) {
            [actView stopAnimating];
            [actView removeFromSuperview];
        }
        [hudView removeFromSuperview];
    }
}


- (void) pushVC:(UIViewController*) vc
{
    [(UINavigationController*)[ViewControllers sharedViewControllers].tabBarController.selectedViewController pushViewController:vc animated:NO];
}

- (void) presentVC:(UIViewController*) vc
{
    [(UINavigationController*)[ViewControllers sharedViewControllers].tabBarController.selectedViewController presentModalViewController:vc animated:YES];
}

- (void) badgeAcquisitionViewShow :(NSArray*)newBadgeList
{	
	BadgeAcquisitionViewController* badgeAcquisitionVC = [[[BadgeAcquisitionViewController alloc] 
                                                           initWithNibName:@"BadgeAcquisitionViewController" bundle:nil] autorelease];
	badgeAcquisitionVC.badgeList = newBadgeList;
	
	badgeAcquisitionVC.hidesBottomBarWhenPushed = YES;
	
	UINavigationController *navController = [[[UINavigationController alloc] initWithRootViewController:badgeAcquisitionVC] autorelease];
	[navController setNavigationBarHidden:YES] ;
	
	[[ViewControllers sharedViewControllers].tabBarController.selectedViewController presentModalViewController:navController animated:YES];
}

- (void) openFriendFinder
{
    FriendFinderViewController* vc = [[[FriendFinderViewController alloc] initWithNibName:@"FriendFinderViewController" bundle:nil] autorelease];
    UINavigationController* nav = [[[UINavigationController alloc] initWithRootViewController:vc] autorelease];
    [[ViewControllers sharedViewControllers].tabBarController.selectedViewController presentModalViewController:nav animated:YES];

}

- (void) selectTabWithIndex:(int)tabIndex
{
    NSAssert(tabIndex > -1 && tabIndex < 5, @"tabIndex 범위가 벗어났습니다.");
    [[ViewControllers sharedViewControllers].tabBarController setSelectedIndex:tabIndex];
}

+ (NSString*) appVersion
{
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
}

+ (void)gotoReview
{
    NSString *str = @"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa";
    str = [NSString stringWithFormat:@"%@/wa/viewContentsUserReviews?", str]; 
    str = [NSString stringWithFormat:@"%@type=Purple+Software&id=", str];
    
    // Here is the app id from itunesconnect
    str = [NSString stringWithFormat:@"%@378485209", str]; 
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
}
@end
