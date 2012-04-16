//
//  UserContext.m
//  ImIn
//
//  Created by choipd on 10. 4. 13..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "UserContext.h"
#import "GeoContext.h"
#import "Utils.h"
#import "ViewControllers.h"
#import "ApplicationContext.h"
#import "FeedCount.h"
#import "FeedList.h"
#import "TFeedList.h"
#import "ProfileInfo.h"
#import "CookSnsCookie.h"
#import "SnsKeyChain.h"
#import "ScrapSync.h"
#import "TScrap.h"
#import "BrandHomeViewController.h"
#import "KissMetrics.h"

#define KISS_CODE @"1450cfd8939d7c92891915f79ffa56835c21ac42"

@implementation UserContext

@synthesize isLogin, isFirstStart, userId, userPassword, userToken, nickName, userNo, userProfile, userPhoneNumber;
@synthesize snsID, deviceToken, cpTwitter, cpFacebook, cpMe2day, cpPhone, userType, bizType;
@synthesize lastMsg, lastViewControllerClassName, vcCallStack;
@synthesize phoneBookUpdateTime, phoneBookDictionary;
@synthesize needMyHomeToRefresh, feedCounter;
@synthesize setting, pnsStr, profileInfo, feedCount;
@synthesize token, oAuth, cookSnsCookie, snsCookie, deviceTokenSent;
@synthesize scrapSync;
@synthesize snsCookieArray;
@synthesize regDate, regDateString;
@synthesize km;
@synthesize feedList;
//
// singleton stuff
//
static UserContext *_sharedUserContext = nil;

+ (UserContext *)sharedUserContext
{
    if (_sharedUserContext == nil) {
        _sharedUserContext = [[super allocWithZone:NULL] init];
        [_sharedUserContext initWithDefault];
    }
    return _sharedUserContext;    
}

+ (id)allocWithZone:(NSZone *)zone
{
    return [[self sharedUserContext] retain];
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
//    if (feedTimer != nil)
//    {
//        [feedTimer invalidate];
//        [feedTimer release];
//    }

}

- (id)autorelease
{
    return self;
}


+(void) updateCurrentLocation
{
	GeoContext* clDelegate = [GeoContext sharedGeoContext];
	if( clDelegate.locationManager != nil) {
		[clDelegate.locationManager startUpdatingLocation];
	} else {
		[clDelegate initLocationManager];
	}
}

- (NSDictionary*) getPhoneBook {
	if ([phoneBookUpdateTime timeIntervalSinceNow] > 60*60) {
		self.phoneBookUpdateTime = [NSDate date];
		self.phoneBookDictionary = [Utils getPhoneBook];
	}	
	return phoneBookDictionary;
}

- (void) requestSnsCookie {
    if (snsCookieArray == nil || [snsCookieArray count] < 2) {
        self.cookSnsCookie = [[[CookSnsCookie alloc] init] autorelease];
        cookSnsCookie.delegate = self;
        [cookSnsCookie request];        
    }
}

- (id) initWithDefault {
	self = [super init];
	if (self != nil) {
		vcCallStack = [[NSMutableArray alloc] initWithCapacity:20];
		self.feedCounter = [[[FeedCounter alloc] init] autorelease];
		// PNS메시지 관련
		pnsStr = nil;
		self.deviceToken = @"invalid_device_token";
        self.deviceTokenSent = NO;
        self.snsCookie = nil;
        self.snsCookieArray = nil;
        feedTimer = nil;
	}
	return self;
}

- (void) updateAddress {
	self.phoneBookUpdateTime = [NSDate date];
	self.phoneBookDictionary = [Utils getPhoneBook];
}


#pragma mark -
#pragma mark 새소식 갯수 요청
- (void) feedTimerStarter {
    if (feedTimer != nil) {
        [feedTimer invalidate];
        feedTimer = nil;
    }    
    if (feedTimer == nil){
        feedTimer = [NSTimer scheduledTimerWithTimeInterval:60.0 target:self selector:@selector(requestFeedListWithTimer) userInfo:nil repeats:YES];
    } 
}

- (void) requestFeedListWithTimer {
    [self requestFeedList];
    
    return;
}

- (void) feedTimerStop {
    if (feedTimer != nil) {
        [feedTimer invalidate];
        feedTimer = nil;
    }    
}

- (NSString*) lastFeedDateReg {
    NSString* lastFeedDateSave = [[UserContext sharedUserContext].setting objectForKey:@"lastFeedDateSave"];
    if (lastFeedDateSave == nil || [lastFeedDateSave isEqualToString:@""]) {
        lastFeedDateSave = [Utils lastFeedDate];
    }
    
    return lastFeedDateSave;
}

//- (void) requestFeedCount
//{
// 	self.feedCount = [[[FeedCount alloc] init] autorelease];
//	feedCount.delegate = self;
//	feedCount.lastFeedDate = [Utils lastFeedDate];
//    
//	[feedCount request];
//}

- (void) requestFeedList {  
//    NSString* feedDate = [Utils lastFeedDate];
    
    self.feedList = [[[FeedList alloc] init] autorelease];
    feedList.delegate = self;
    
    feedList.feedType = @"31";
    feedList.currPage = @"1";
    
    NSString* lastRequestDate = [self lastFeedDateReg];
    feedList.lastFeedDate = lastRequestDate;
    
    [[UserContext sharedUserContext].setting setObject:lastRequestDate forKey:@"lastFeedDateSave"];
    [[UserContext sharedUserContext] saveSettingToFile];
    
    [feedList requestWithoutIndicator];
}

- (void) apiDidLoad:(NSDictionary *)result
{
//	if ([[result objectForKey:@"func"] isEqualToString:@"feedCount"]) {
//        feedCounter.appCnt = [[result objectForKey:@"appCnt"] intValue]; // appCnt에 받아온 카운트를 넣는다.
//        MY_LOG(@"feedCounter.appCnt = %d", feedCounter.appCnt);
//		
//        [feedCounter setBadgeNum:[feedCounter total]]; // total 이라는 함수는 appCnt를 리턴한다.
//		[feedCounter deleteExpired];
//		[feedCounter saveToDatabase];
//	}
    
    if ([[result objectForKey:@"func"] isEqualToString:@"feedList"]) {
        if ( [[result objectForKey:@"totalCnt"] intValue] > 0) { // 새소식이 있으면
            [feedCounter deleteExpired];
            [feedCounter saveToDatabase:result];
        }
    }
    
    if([[result objectForKey:@"func"] isEqualToString:@"cookSnsCookie"]) {
        MY_LOG(@"cookie result = %@", result);
        
        NSMutableArray * cookieArray = [[[NSMutableArray alloc] initWithCapacity:2] autorelease];
        self.snsCookieArray = [[[NSMutableArray alloc] initWithCapacity:2] autorelease];
        
        NSString* cookie = nil;
        
        [cookieArray addObject:[result objectForKey:@"SNS01"]];
        [cookieArray addObject:[result objectForKey:@"SNS03"]];
        
        for (int i=0; i<[cookieArray count]; i++) {
            cookie = [cookieArray objectAtIndex:i];
            if (cookie == nil) {
                return;
            }
            MY_LOG(@"cookie = %@", cookie);
            self.snsCookie = [self setCookie : cookie];
            [ self.snsCookieArray addObject:[self setCookie : cookie]];
        }
        
        MY_LOG(@"dictionary cookie = %@", snsCookie);
    }
    
    
    if([[result objectForKey:@"func"] isEqualToString:@"scrapSync"]) {
        
        NSArray* addedScrapPostIds = [[result objectForKey:@"addedPostId"] componentsSeparatedByString:@"|"];
        NSArray* deletedScrapPostIds = [[result objectForKey:@"deletedPostId"] componentsSeparatedByString:@"|"];
        
        [[TScrap database] beginTransaction];
        
        for (NSString* postId in addedScrapPostIds) {
            [[TScrap database] executeSql:[NSString stringWithFormat:@"INSERT INTO TScrap (postId) VALUES ('%@')", postId]];
        }
        for (NSString* postId in deletedScrapPostIds) {
            [[TScrap database] executeSql:[NSString stringWithFormat:@"DELETE FROM TScrap WHERE postId = '%@'", postId]];
        }
        
        [[TScrap database] commit];
    }
}

- (void) apiFailed 
{
	
}

- (NSMutableDictionary*) setCookie : (NSString*)cookie {
    NSMutableDictionary *cookieProperties = [NSMutableDictionary dictionary];
    NSString* key = nil;
    NSString* value = nil;
    NSArray* keyValues;
    
    NSRange range = [cookie rangeOfString:@";"];
    if (range.location != NSNotFound) {
        NSMutableDictionary *mutableDictionary = [[[NSMutableDictionary alloc] init] autorelease];
        NSString* tempCookie = [cookie substringToIndex:range.location];  // ";" 값 전까지
        cookie = [cookie substringFromIndex:range.location+1]; // 반복 체크 해봐야 하는 나머지 데이타
        
        range = [tempCookie rangeOfString:@"="];
        if (range.location != NSNotFound) {
            [cookieProperties setObject:[tempCookie substringToIndex:range.location] forKey:NSHTTPCookieName];
            [cookieProperties setObject:[tempCookie substringFromIndex:range.location+1] forKey:NSHTTPCookieValue];
        }
        keyValues = [cookie componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"=;"]];
        for (int i=0; i < [keyValues count]; i++) {
            if (i % 2 == 0) {
                // key
                key = [keyValues objectAtIndex:i];
                key = [key stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]; // 스페이스값 없애기
            } else {
                // value
                value = [keyValues objectAtIndex:i];
                value = [value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]; // 스페이스값 없애기
                [mutableDictionary setObject:value forKey:key];
            }
        }
        if ([mutableDictionary objectForKey:@"Domain"] != nil) {
            [cookieProperties setObject:[mutableDictionary objectForKey:@"Domain"] forKey:NSHTTPCookieDomain];  // "Domain=" 값 다음부터 끝까지
            [cookieProperties setObject:[mutableDictionary objectForKey:@"Domain"] forKey:NSHTTPCookieOriginURL];  // "Domain=" 값 다음부터 끝까지
        }
        if ([mutableDictionary objectForKey:@"Path"] != nil) {
            [cookieProperties setObject:[mutableDictionary objectForKey:@"Path"] forKey:NSHTTPCookiePath];  // "Domain=" 값 다음부터 끝까지
        }
    }
    else //만약 네임과 벨류만 있으면 ; 이것이 없을수도 있다.
    {
        range = [cookie rangeOfString:@"="];
        if (range.location != NSNotFound) {
            [cookieProperties setObject:[cookie substringToIndex:range.location] forKey:NSHTTPCookieName];
            [cookieProperties setObject:[cookie substringFromIndex:range.location+1] forKey:NSHTTPCookieValue];
        }
    }
    return cookieProperties;
}

- (void) readSettingFromFile
{
	NSString* path = [[[ApplicationContext sharedApplicationContext] privatePath:snsID] stringByAppendingPathComponent:@"setting.plist"];
	self.setting = [[[NSMutableDictionary alloc] initWithContentsOfFile:path] autorelease];
    MY_LOG(@"%@", setting);
	if (self.setting == nil) {
		self.setting = [[[NSMutableDictionary alloc] initWithCapacity:10] autorelease];
		[self saveSettingToFile];
	}
}

- (void) saveSettingToFile
{
	NSString* path = [[[ApplicationContext sharedApplicationContext] privatePath:snsID] stringByAppendingPathComponent:@"setting.plist"];
	[setting writeToFile:path atomically:YES];
}


- (void) updateDeliveryWithDictionary:(NSDictionary*) deliveryData
{	
    self.cpTwitter = [[[CpData alloc] init] autorelease];
    self.cpFacebook = [[[CpData alloc] init] autorelease];
    self.cpMe2day = [[[CpData alloc] init] autorelease];	
    
	NSArray* resultList = [deliveryData objectForKey:@"data"];
	for (NSDictionary* data in resultList) {
		NSString* cpCode = [data objectForKey:@"cpCode"];
		
		if ([cpCode isEqualToString:@"51"]) { // twitter
			self.cpTwitter = [[[CpData alloc] initWithDictionary:data] autorelease];
		}
		
		if ([cpCode isEqualToString:@"52"]) { // facebook
			self.cpFacebook = [[[CpData alloc] initWithDictionary:data] autorelease];
		}
		
		if ([cpCode isEqualToString:@"50"]) { // me2day
			self.cpMe2day = [[[CpData alloc] initWithDictionary:data] autorelease];
		}
	}
}

- (void) updateProfileInfoWithDictionary:(NSDictionary*) profileInfoData
{
    self.cpPhone = [[[CpData alloc] init] autorelease];
	
	cpPhone.isConnected = [[profileInfoData objectForKey:@"useNPhoneNo"] isEqualToString:@"1"];
	cpPhone.cpCode = @"-1";
	cpPhone.blogId = [profileInfoData objectForKey:@"phoneNo"];
}

- (void) loginProcess:(NSDictionary*) data 
{
	NSDictionary* funcData = [data objectForKey:@"setAuthToken"];
	
	MY_LOG(@"%@", funcData);
	
	self.snsID = [funcData objectForKey:@"snsId"];
	self.nickName = [funcData objectForKey:@"nickname"];
	self.userProfile = [funcData objectForKey:@"profileImg"];
    self.bizType = [funcData objectForKey:@"bizType"];
    self.userType = [funcData objectForKey:@"userType"];
    
    //비즈 홈 유저라면
    
    if ([self isBrandUser]) {
        
        UINavigationController* nav = (UINavigationController*) [ViewControllers sharedViewControllers].homeViewController;
        NSArray *viewControllers = [nav viewControllers];
        if (viewControllers != nil && viewControllers.count > 0) {
            NSMutableArray *array = [NSMutableArray arrayWithArray:viewControllers];
            BrandHomeViewController* homeVC = [[[BrandHomeViewController alloc] initWithNibName:@"BrandHomeViewController" bundle:nil] autorelease];
            [array replaceObjectAtIndex:0 withObject:homeVC];
            nav.viewControllers = array;
        }
    }
    
	//앱버전 체크
	[[ApplicationContext sharedApplicationContext] checkCurAppVer:[funcData objectForKey:@"currAppVer"] 
                                                        returnUrl:[funcData objectForKey:@"appUpdateUrl"] 
                                                          withMsg:[funcData objectForKey:@"msg"]];
	
	//getDelivery 값 세팅
	funcData = [data objectForKey:@"getDelivery"];
	[self updateDeliveryWithDictionary:funcData];
    
    // 가입 일자를 저장한다.
    NSString* regDateLongForm = [[data objectForKey:@"setAuthToken"] objectForKey:@"regDate"];
    if (regDateLongForm) {
        self.regDate = [Utils getDateWithString:regDateLongForm];
        self.regDateString = [[regDateLongForm componentsSeparatedByString:@" "] objectAtIndex:0];
    }    
	
	//유저별 프라이베이트 폴더 안에 디비를 셋업한다.
	[(ImInAppDelegate*)[[UIApplication sharedApplication] delegate] setupDatabase];
	
	// 세팅 파일을 로딩함
	[self readSettingFromFile];
	
	// 단말의 주소록을 가져와서 로컬디비에 업데이트함.
	[self updateAddress];
    
	// profileInf를 통해 폰번호 인증을 세팅함
	funcData = [data objectForKey:@"profileInfo"];
	[self updateProfileInfoWithDictionary:funcData];
	
	// 피드의 갯수 세팅
    [self feedTimerStarter];
	//[self requestFeedList];
    MY_LOG(@"loginProcess!!  requestFeedList");
	
	[[ApplicationContext sharedApplicationContext] openMainFrame];
    
    // 디바이스를 등록 해준다
    [[SnsKeyChain sharedInstance] sendDeviceTokenInfo:YES];
    
    [self syncScrap];
    
    if (snsCookieArray == nil || [snsCookieArray count] < 2) {
        [self requestSnsCookie];
    }
    
    if (isLogin) {
        [self recordKissMetricsWithEvent:@"Visits" withInfo:nil];
    }
}

- (void) logoutProcess
{
    [[SnsKeyChain sharedInstance] setParanId:@""];
	[[SnsKeyChain sharedInstance] setPassword:@""];
	[[SnsKeyChain sharedInstance] setToken:nil]; // 토큰 삭제
	[[SnsKeyChain sharedInstance] setoAuth:nil]; // oAuth 삭제
    [[SnsKeyChain sharedInstance] sendDeviceTokenInfo:NO]; // registerDevice mode 'OFF'
    deviceTokenSent = NO;
    self.snsCookie = nil; // 로그아웃시 하트콘 쿠키를 삭제해야 로그인시 다시 개인 정보 쿠키 받아온다.
    self.snsCookieArray = nil; // 로그아웃시 하트콘 쿠키를 삭제해야 로그인시 다시 개인 정보 쿠키 받아온다.
	self.userPhoneNumber = @"";
	self.userId = @"";
	self.userPassword = @"";
	self.userToken = @"";
	self.userNo = @"";
	self.userProfile = @"";
	self.nickName = @"";
	self.userPhoneNumber = @"";
	self.snsID = @"";
	isLogin = NO;
	[cpMe2day clearData];
	[cpFacebook clearData];
	[cpTwitter clearData];
	
	[ApplicationContext sharedApplicationContext].preTokenExist = YES;
	
	NSHTTPCookieStorage* cookies = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSArray* facebookCookies = [cookies cookiesForURL:
								[NSURL URLWithString:@"http://login.facebook.com"]];
    for (NSHTTPCookie* cookie in facebookCookies) {
		[cookies deleteCookie:cookie];
    }	
	
	NSArray* twitterCookies = [cookies cookiesForURL:
							   [NSURL URLWithString:@"http://twitter.com"]];
	for (NSHTTPCookie* cookie in twitterCookies) {
		[cookies deleteCookie:cookie];
    }
	[self feedTimerStop];
	[(ImInAppDelegate*)[[UIApplication sharedApplication] delegate] restartTabBar];	
}

// 스크랩 싱크
- (void) syncScrap
{
    self.scrapSync = [[[ScrapSync alloc] init] autorelease];
    scrapSync.delegate = self;
    
    NSDictionary* lastScrap = [[[TScrap database] executeSql:@"select * from TScrap order by regDate limit 1"] lastObject];
    if (lastScrap != nil) {
        NSString* scrapRegDate = [[lastScrap objectForKey:@"regDate"] stringByReplacingOccurrencesOfString:@" " withString:@""];
        
        scrapRegDate = [scrapRegDate stringByReplacingOccurrencesOfString:@"-" withString:@""];
        scrapRegDate = [scrapRegDate stringByReplacingOccurrencesOfString:@":" withString:@""];
        [scrapSync.params addEntriesFromDictionary:[NSDictionary dictionaryWithObjectsAndKeys:scrapRegDate, @"syncDate", nil]];
    }
    [scrapSync requestWithAuth:YES withIndicator:YES];
}


- (void) recordKissMetricsWithEvent:(NSString*) eventName withInfo:(NSDictionary*) info {
    self.km = [[[KissMetrics alloc] initWithKey:KISS_CODE] autorelease];
    NSString* tempID = nil;
    if ([nickName isEqualToString:@""] || nickName == nil) {
        tempID = @"New Visitor"; 
        [km identify:tempID];
    } else {
        [km identify:nickName];
    }
    
    // include some info about the type of device, operating system, and version of your app
    if (info == nil) {
        NSNumber* daysAfterRegister = [NSNumber numberWithInt:ABS([self.regDate timeIntervalSinceNow] / 60 / 60 / 24)]; 
        info = [NSDictionary dictionaryWithObjectsAndKeys:
                [UIDevice currentDevice].model, @"Model",
                [UIDevice currentDevice].systemName, @"System Name",
                [UIDevice currentDevice].systemVersion, @"System Version",
                [ApplicationContext appVersion], @"My App Version",
                self.regDateString, @"regDate",
                daysAfterRegister, @"daysAfterRegister",
                nil];
    }
    [km record:eventName properties:info];
}

//- (void) dealloc
//{
//	[feedCounter release];
//	[feedCount release];
//	
//	[cpTwitter release];
//	[cpFacebook release];
//	[cpMe2day release];
//	
//	[deviceToken release];
//    [cookSnsCookie release];
//    [scrapSync release];
//	
//    [userType release];
//    [bizType release];
//    [snsCookieArray release];
//    [km release];
//    
//    [regDateString release];
//    [regDate release];
//    
//	[super dealloc];
//}

- (BOOL) isBrandUser
{
    return ([bizType isEqualToString:@"BT0001"] ||
            [bizType isEqualToString:@"BT0002"]) && [userType isEqualToString:@"UB0001"];
}

@end
