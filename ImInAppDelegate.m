//
//  ImInAppDelegate.m
//  ImIn
//
//  Created by mandolin on 10. 4. 5..
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "ImInAppDelegate.h"
#import "UIPlazaViewController.h"
#import "UINeighborsViewController.h"
#import "MyHomeViewController.h"
//#import "UIHomeViewController.h"
#import "UIFeedViewController.h"
#import "UITabBarItem+WithImage.h"
#import "UITabBar+BackgroundImage.h"

#import "UILoginViewController.h"
#import "ViewControllers.h"
#import "UISettingViewController.h"

#import "UserContext.h"
#import "SnsKeyChain.h"
#import "GeoContext.h"

#import "macro.h"
#import "CommonAlert.h"
#import "CommonWebViewController.h"
#import "BrandHomeViewController.h"

#import "TVersion.h"

#import "KissMetrics.h"

// 통계관련
#import "NWAppUsageLogger.h"
#import <sqlite3.h>

static const NSInteger kGANDispatchPeriodSec = -1; // Dispatch manually
static const NSInteger kDEFAULT_NEXT_SHOW_REVIEW_COUNT = 10; // review쓰러가기 창 보여줄 횟수
/**
 * @mainpage 아임인 아이폰 앱
 *
 * @section intro_sec 소개
 *
 * 대한민국 대표 위치기반SNS 아임IN의 아이폰용 앱
 *
 * 기능 리스트:
 *
 * - 광장: 나의 현재 위치에서 특정 반경 내의 사용자들의 발도장을 보여주는 기능
 * - 이웃: 나를 추가하거나 내가 추가한 이웃의 목록 및 시스템에서 추천된 이웃의 목록을 보여준다. 또 닉네임을 검색할 수 있다.
 * - 마이홈: 나의 발도장 히스토리를 볼 수 있고, 내게 온 메시지를 확인할 수 있다.
 * - 설정: 프로필 이미지 변경, 폰번호인증, 글 내보내기 설정, 
 *
 * 참여한 사람들:
 *
 * - 김동욱(mandolin), 김태한(bladekim), 최명진(choipd aka edbear), 박자영(jjai)
 *
 * @section doc_sections 관련 문서
 * - @subpage development_guide "개발가이드"
 * - @subpage operation_guide "운영가이드"
 * - @subpage db_schema "테이블정의서"
 
 */


/**
 @class ImInAppDelegate
 @brief 앱의 초기화, background/forground 전환, APNS 수신 처리
 
 */

@implementation ImInAppDelegate

@synthesize tabBarController;

- (id) init
{
	self = [super init];
	if (self != nil) {
		//초기화
		isToForeground = NO;
		isPushOn = NO;	//apns 꺼놨다고 초기화한다. apns한번이라도 받으면 이 값을 YES로 변경.
		self.tabBarController = nil;
		//통계관련
		[NWAppUsageLogger loggerWithUsageWebURL:@"http://mstatlog.paran.com/usagelog.html" andAppName:@"ImIn"];
	}
	return self;
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    if (!url) {  
        return NO; }
    
    NSString *urlString = [url absoluteString];
    MY_LOG(@"url string = %@", urlString);
    
    NSString *retValue = nil;
    NSRange range = [urlString rangeOfString:@"result="];
    if (range.location != NSNotFound) {
        retValue = [urlString substringFromIndex:range.location+7];
        retValue = [retValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]; //스페이스 삭제
        [self performSelector:@selector(commonWebVCWithResult:) withObject:retValue afterDelay:1];
    }     
    return YES;
}

- (void) commonWebVCWithResult:(NSString*)resultKey {
    if ([ApplicationContext sharedApplicationContext].jsCallWebVC == nil) {
        return;
    }
    CommonWebViewController *webVC = (CommonWebViewController*)[ApplicationContext sharedApplicationContext].jsCallWebVC;
    [webVC jaCallWithSchemeKey:resultKey];  
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	
    [[GANTracker sharedTracker] startTrackerWithAccountID:@"UA-20649863-17"
										   dispatchPeriod:kGANDispatchPeriodSec
												 delegate:nil];
    
    [ApplicationContext sendAppStart];
    
//    [[UserContext sharedUserContext].setting setObject:[NSDecimalNumber zero] forKey:@"hasShownSearchBar"];
//    [[UserContext sharedUserContext] saveSettingToFile];
	
	// FOR APNS
	// launchOptions has the incoming notification if we're being launched after the user tapped "view"
	MY_LOG( @"didFinishLaunchingWithOptions:%@", launchOptions );

	// other setup tasks here.... 
    [[UIApplication sharedApplication] 
	 registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | 
										 UIRemoteNotificationTypeSound |
										 UIRemoteNotificationTypeAlert)]; 
	
    // [self updateWithRemoteData];  // freshen your app!
	
	// APNS통한 실행인지 체크
	NSDictionary* options = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];    
	NSDictionary* annotations;

	if(options && (annotations = [options objectForKey:@"aps"])) {
		NSString* str = [annotations objectForKey:@"alert"];
		if ([UserContext sharedUserContext].snsID == nil || [[UserContext sharedUserContext].snsID compare:@""] == NSOrderedSame)
		{
			[UserContext sharedUserContext].pnsStr = str;
		} else
		{
			[self apnsHandlerWithMessage:str];
		}
	}
	// RESET THE BADGE COUNT
    application.applicationIconBadgeNumber = 0; 
	
	[UserContext sharedUserContext].isFirstStart = YES;
	//// End of APNS
	window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

	[self addTabBar];
	[window makeKeyAndVisible];

	[[GeoContext sharedGeoContext] initLocationManager];
    
    //리뷰
    NSInteger appStartCount = [[[NSUserDefaults standardUserDefaults] objectForKey:@"APP_START_COUNT"] intValue];
    NSInteger nextShowReviewCount = [[[NSUserDefaults standardUserDefaults] objectForKey:@"NEXT_SHOW_REVIEW_COUNT"] intValue];
    if (nextShowReviewCount == 0) {
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:kDEFAULT_NEXT_SHOW_REVIEW_COUNT] forKey:@"NEXT_SHOW_REVIEW_COUNT"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }    
    if (appStartCount == nextShowReviewCount) {
        UIAlertView *review = [[[UIAlertView alloc] initWithTitle:@"감사합니다" message:@"아임IN을 잘 사용하고 계신가요? \n나만의 발자취 발도장을 통해서, 새로운 이웃을 만나는 기쁨.\n아임IN을 사용해보지 않은 분들을 위해 리뷰로 남겨주시면 어떨까요?" delegate:self cancelButtonTitle:@"닫기" otherButtonTitles:@"리뷰 작성하기", @"나중에 하기", nil] autorelease];
        review.tag = 300;
        [review show];
    }
    
	return YES;
}

- (void) applicationDidBecomeActive:(UIApplication *)application
{
	MY_LOG(@"Backgrond Process ==> Foreground전환 !!!!");
	
	[[GANTracker sharedTracker] dispatch];
	
//    NSDate* lastAppResume = [ApplicationContext sharedApplicationContext].lastAppResume;
//    NSTimeInterval interval = [lastAppResume timeIntervalSinceNow];
//    if (ABS(interval) > 60*30) {
//        [ApplicationContext sendAppResume];
//        [ApplicationContext sharedApplicationContext].lastAppResume = [NSDate date];
//    }
    
    [ApplicationContext sendAppResume];
    
	if (isToForeground) {
		[[GeoContext sharedGeoContext] refresh];
		isToForeground = NO;
		
		if ([UserContext sharedUserContext].isLogin && tabBarController != nil 
			&& [ViewControllers sharedViewControllers].plazaViewController != nil
			&& tabBarController.selectedIndex == 0) {
			MY_LOG(@"플라자 리프레시 합니다.");
			[(UIPlazaViewController*)[ViewControllers sharedViewControllers].plazaViewController refresh];
		}
		
		if ([UserContext sharedUserContext].isLogin) {
            [[UserContext sharedUserContext] feedTimerStarter];
//			// 새소식을 확인한다
//            [[UserContext sharedUserContext] requestFeedList];
//            MY_LOG(@"Backgrond Process ==> Foreground전환 !!!!  requestFeedList");
		}
	}
}
 
- (void) applicationWillResignActive:(UIApplication *)application
{
	MY_LOG(@"Foreground --> Background !!!");
	[[GeoContext sharedGeoContext] stopGPS];
	isToForeground = YES;
	
	[[GANTracker sharedTracker] dispatch];
		
	//어플 종료나 백그라운드로 갈 때 뱃지 숫자를 0으로 초기화시킴
	[UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    [[UserContext sharedUserContext] feedTimerStop];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
	MY_LOG(@"Application Will Terminate");
}

- (void) addTabBar {

	NSArray* subviewObjects = [window subviews];
	
	BOOL isTabBarExist = NO;
	for (id currentObject in subviewObjects) {
		if([currentObject isKindOfClass:[UITabBarController class]]) {
			isTabBarExist = YES;
		}
	}
	
	if( !isTabBarExist ) {
		self.tabBarController = [self tabBar];
		[window addSubview:tabBarController.view];
	}
}

- (void) restartTabBar {
	[tabBarController.view removeFromSuperview];
	self.tabBarController = nil;
	
	[self addTabBar];
}

- (UITabBarController*) tabBar {
	NSMutableArray *controllers = [[NSMutableArray alloc] init];
	
    UINavigationController *nav = nil;
    
	UIPlazaViewController* plazaVC = [[UIPlazaViewController alloc] init];
	nav = [[UINavigationController alloc] initWithRootViewController:plazaVC];
	[ViewControllers sharedViewControllers].plazaViewController = nav;
	[controllers addObject:nav];
	[nav release];
	[plazaVC release];
	
	UINeighborsViewController* neighborVC = [[UINeighborsViewController alloc] initWithNibName:@"UINeighborsViewController" bundle:nil];
	nav = [[UINavigationController alloc] initWithRootViewController:neighborVC];
	[ViewControllers sharedViewControllers].neighbersViewController = neighborVC;
	[controllers addObject:nav];
	[nav release];
	[neighborVC release];

	MyHomeViewController* homeVC = [[MyHomeViewController alloc] initWithNibName:@"MyHomeViewController" bundle:nil];
	nav = [[UINavigationController alloc] initWithRootViewController:homeVC];
	[ViewControllers sharedViewControllers].homeViewController = nav;
	[controllers addObject:nav];
	[nav release];
	[homeVC release];
    
//    UIHomeViewController* homeVC = [[UIHomeViewController alloc] initWithNibName:@"UIHomeViewController" bundle:nil];
//	nav = [[UINavigationController alloc] initWithRootViewController:homeVC];
//	[ViewControllers sharedViewControllers].myHomeViewController = nav;
//	[controllers addObject:nav];
//	[nav release];
//	[homeVC release];
		
	UIFeedViewController* feedVC = [[UIFeedViewController alloc] initWithNibName:@"UIFeedViewController" bundle:nil];
	nav = [[UINavigationController alloc] initWithRootViewController:feedVC];
	[ViewControllers sharedViewControllers].feedViewController = nav;
	[controllers addObject:nav];
	[nav release];
	[feedVC release];

	UISettingViewController* settingVC = [[UISettingViewController alloc] init];
	nav = [[UINavigationController alloc] initWithRootViewController:settingVC];
	[ViewControllers sharedViewControllers].settingViewController = nav;
	[controllers addObject:nav];
	[nav release];
	[settingVC release];
		
	// Create the toolbar and add the view controllers
	UITabBarController *tbarController = [[[UITabBarController alloc] init] autorelease];
	tbarController.viewControllers = controllers;
	//tbarController.customizableViewControllers = controllers;
	tbarController.delegate = self;
	
	[ViewControllers sharedViewControllers].tabBarController = tbarController;

	//[tbarController.tabBar addBackgroundWithPattern:[UIImage imageNamed:@"footGNB_bar.png"]];
	//[tbarController.tabBar addBackgroundWithImage:[UIImage imageNamed:@"onepiece.png"]];
	
	[controllers release];

	return tbarController;
}

- (void)dealloc {
	[[GANTracker sharedTracker] stopTracker];
    [window release];
	[tabBarController release];
	
    [super dealloc];
}

#pragma mark -
#pragma mark 지도 회전 관련
// FOR APNS
- (void)application:(UIApplication *)app 
didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)devToken { 
    [self saveDeviceTokenToRemote:devToken]; // send the token to your server
}

- (void)application:(UIApplication *)app 
didFailToRegisterForRemoteNotificationsWithError:(NSError *)err { 
    [UserContext sharedUserContext].deviceToken = @"didFailToRegisterForRemoteNotificationsWithError";
    MY_LOG(@"Failed to register, error: %@", err); 
} 

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
	MY_LOG( @"didReceiveRemoteNotification:%@", userInfo );
	
	isPushOn = YES; // 푸시를 받았으므로 푸시 사용자라고 가정
	
	//[self.viewController handleDidReceiveRemoteNotification:userInfo];
	NSDictionary *aps = [userInfo valueForKey:@"aps"];
	NSString *alert = [aps valueForKey:@"alert"];
    
    if ([alert isEqualToString:@""]) {
        MY_LOG(@"빈 apns메시지 도착");
        return;
    }
    
    MY_LOG(@"apns메시지 도착");
    
	//[self apnsHandlerWithMessage:alert];
	if ([UserContext sharedUserContext].snsID == nil || [[UserContext sharedUserContext].snsID compare:@""] == NSOrderedSame)
	{
		[UserContext sharedUserContext].pnsStr = alert;
	} else
	{
        [[UserContext sharedUserContext] requestFeedList];
        MY_LOG(@"apns메시지 도착!!  requestFeedList");
		[self apnsHandlerWithMessage:alert];
	}	
}


-(void)saveDeviceTokenToRemote:(NSData *)deviceToken
{
	MY_LOG( @"sendDeviceTokenToRemote:%@", deviceToken );
	
	NSString *inDeviceTokenStr = [deviceToken description];
	NSString *tokenString = [inDeviceTokenStr stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"< >"]];

	[UserContext sharedUserContext].deviceToken = tokenString;
}

#pragma mark -
#pragma mark 데이터베이스 초기화
// 도큐먼트에 DB파일이 존재하는지 확인하고 없다면 복사하라
- (void) copyIfNotExist: (NSString *) source target: (NSString *) target {
	NSFileManager *fileManager = [NSFileManager defaultManager];	
	
	if(![fileManager fileExistsAtPath:target]) {
		[fileManager copyItemAtPath:source toPath:target error:nil];
	}
}

- (void) setupDatabase {
	NSArray *userDomainPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); 
	NSString *documentsDirectoryPath = [userDomainPaths objectAtIndex:0];

	documentsDirectoryPath = [documentsDirectoryPath stringByAppendingPathComponent:[UserContext sharedUserContext].snsID];
	[[NSFileManager defaultManager] createDirectoryAtPath:documentsDirectoryPath
							  withIntermediateDirectories:NO 
											   attributes:nil error:nil];
	
	NSString *documentDBPath = [documentsDirectoryPath stringByAppendingPathComponent:@"appContext.sqlite"];	
	NSString *bundleDBPath = [[NSBundle mainBundle] pathForResource: @"appContext" ofType: @"sqlite"];
	
	[self copyIfNotExist: bundleDBPath target: documentDBPath];
	MY_LOG(@"디비위치: %@", documentDBPath);
	
	database = [[ISDatabase alloc] initWithPath:documentDBPath];
	[ISModel setDatabase:database];
	
	// TAddressbook 테이블 생성
	[database executeSql:@" \
	 CREATE TABLE IF NOT EXISTS TAddressbook (name VARCHAR NOT NULL, \
											phone VARCHAR NOT NULL, \
											md5 VARCHAR PRIMARY KEY NOT NULL)"];
	
	[database executeSql:@"CREATE TABLE IF NOT EXISTS TVersion (version INTEGER primary key)"];
	// 앞으로 DB 가 업데이트 되게 될때마다 버전관리가 되어야 한다.
	TVersion* tversion = [[TVersion findWithSql:@"select * from tversion"] lastObject];
	MY_LOG(@"DB VERSION: %d", [tversion.version intValue]);
	if (tversion == nil || [tversion.version intValue] < 1) {
		[database executeSql:@"ALTER TABLE TFeedList ADD COLUMN hasDeleted VARCHAR default '0' NOT NULL"];

		[database executeSql:@"ALTER TABLE TFeedList ADD COLUMN badgeId VARCHAR default '0'"];
		
		[database executeSql:@"ALTER TABLE TFeedList ADD COLUMN evtUrl VARCHAR default ''"];
		[database executeSql:@"ALTER TABLE TFeedList ADD COLUMN reserved0 VARCHAR default ''"];
		[database executeSql:@"ALTER TABLE TFeedList ADD COLUMN reserved1 VARCHAR default ''"];
		[database executeSql:@"ALTER TABLE TFeedList ADD COLUMN reserved2 VARCHAR default ''"];
		[database executeSql:@"ALTER TABLE TFeedList ADD COLUMN reserved3 VARCHAR default ''"];
		[database executeSql:@"ALTER TABLE TFeedList ADD COLUMN reserved4 VARCHAR default ''"];
		[database executeSql:@"ALTER TABLE TFeedList ADD COLUMN reserved5 VARCHAR default ''"];
		[database executeSql:@"ALTER TABLE TFeedList ADD COLUMN reserved6 VARCHAR default ''"];
		[database executeSql:@"ALTER TABLE TFeedList ADD COLUMN reserved7 VARCHAR default ''"];
		[database executeSql:@"ALTER TABLE TFeedList ADD COLUMN reserved8 VARCHAR default ''"];
		[database executeSql:@"ALTER TABLE TFeedList ADD COLUMN reserved9 VARCHAR default ''"];
		
        [database executeSql:@"CREATE TABLE IF NOT EXISTS TScrap (postId VARCHAR primary key, \
         regDate DATE DEFAULT (datetime('now','localtime')))"];
        
	}
	else if(tversion != nil && [tversion.version intValue] == 1 ) {
		[database executeSql:@"ALTER TABLE TFeedList ADD COLUMN badgeId VARCHAR default '0'"];
		
		[database executeSql:@"ALTER TABLE TFeedList ADD COLUMN evtUrl VARCHAR default ''"];
		[database executeSql:@"ALTER TABLE TFeedList ADD COLUMN reserved0 VARCHAR default ''"];
		[database executeSql:@"ALTER TABLE TFeedList ADD COLUMN reserved1 VARCHAR default ''"];
		[database executeSql:@"ALTER TABLE TFeedList ADD COLUMN reserved2 VARCHAR default ''"];
		[database executeSql:@"ALTER TABLE TFeedList ADD COLUMN reserved3 VARCHAR default ''"];
		[database executeSql:@"ALTER TABLE TFeedList ADD COLUMN reserved4 VARCHAR default ''"];
		[database executeSql:@"ALTER TABLE TFeedList ADD COLUMN reserved5 VARCHAR default ''"];
		[database executeSql:@"ALTER TABLE TFeedList ADD COLUMN reserved6 VARCHAR default ''"];
		[database executeSql:@"ALTER TABLE TFeedList ADD COLUMN reserved7 VARCHAR default ''"];
		[database executeSql:@"ALTER TABLE TFeedList ADD COLUMN reserved8 VARCHAR default ''"];
		[database executeSql:@"ALTER TABLE TFeedList ADD COLUMN reserved9 VARCHAR default ''"];
        
        [database executeSql:@"CREATE TABLE IF NOT EXISTS TScrap (postId VARCHAR primary key, \
         regDate DATE DEFAULT (datetime('now','localtime')))"];

	} else if(tversion != nil && [tversion.version intValue] == 2) {

		[database executeSql:@"ALTER TABLE TFeedList ADD COLUMN evtUrl VARCHAR default ''"];
		[database executeSql:@"ALTER TABLE TFeedList ADD COLUMN reserved0 VARCHAR default ''"];
		[database executeSql:@"ALTER TABLE TFeedList ADD COLUMN reserved1 VARCHAR default ''"];
		[database executeSql:@"ALTER TABLE TFeedList ADD COLUMN reserved2 VARCHAR default ''"];
		[database executeSql:@"ALTER TABLE TFeedList ADD COLUMN reserved3 VARCHAR default ''"];
		[database executeSql:@"ALTER TABLE TFeedList ADD COLUMN reserved4 VARCHAR default ''"];
		[database executeSql:@"ALTER TABLE TFeedList ADD COLUMN reserved5 VARCHAR default ''"];
		[database executeSql:@"ALTER TABLE TFeedList ADD COLUMN reserved6 VARCHAR default ''"];
		[database executeSql:@"ALTER TABLE TFeedList ADD COLUMN reserved7 VARCHAR default ''"];
		[database executeSql:@"ALTER TABLE TFeedList ADD COLUMN reserved8 VARCHAR default ''"];
		[database executeSql:@"ALTER TABLE TFeedList ADD COLUMN reserved9 VARCHAR default ''"];
        
        [database executeSql:@"CREATE TABLE IF NOT EXISTS TScrap (postId VARCHAR primary key, \
         regDate DATE DEFAULT (datetime('now','localtime')))"];
        
	} else if (tversion != nil && [tversion.version intValue] == 3) {
        [database executeSql:@"CREATE TABLE IF NOT EXISTS TScrap (postId VARCHAR primary key, \
         regDate DATE DEFAULT (datetime('now','localtime')))"];
    }
    
    [database executeSql:@"DELETE FROM TVersion"];
    [database executeSql:@"INSERT INTO TVersion VALUES (4)"];
}

- (void) apnsHandlerWithMessage:(NSString*) message
{
    // for silent badge update, do not alert.
	if ([message isEqualToString:@""]) {
        return;
    }
    
	NSInteger tagId = 0;
	if ([message rangeOfString:@"발도장을 찍으셨습니다"].location != NSNotFound ||
		[message rangeOfString:@"의 새로운 마스터"].location != NSNotFound) {
		MY_LOG(@"이웃");
		tagId = 100;
	} else {
		MY_LOG(@"새소식");
		tagId = 200;
	}
	
    [ApplicationContext stopActivity];
    
	UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"알림" message:message
													   delegate:self cancelButtonTitle:@"닫기" otherButtonTitles:@"이동", nil] autorelease];
	alert.tag = tagId;
	[alert show];
}

#pragma mark -
- (void)alertView:(UIAlertView*)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (alertView.tag == 100)
	{
		if (buttonIndex == 1)
		{
			[[ViewControllers sharedViewControllers] refreshNeighborVC];
			[tabBarController setSelectedIndex:1];
		}
		return;
	}
	if (alertView.tag == 200)
	{
		if (buttonIndex == 1)
		{
			[tabBarController setSelectedIndex:3];
			[[ViewControllers sharedViewControllers].feedViewController viewWillAppear:YES];
		}
	}
    if (alertView.tag == 300) {
        NSInteger nextShowReviewCount = [[[NSUserDefaults standardUserDefaults] objectForKey:@"NEXT_SHOW_REVIEW_COUNT"] intValue];
        if (buttonIndex == 1) {
            MY_LOG(@"리뷰 작성하기");
            [ApplicationContext gotoReview];
        } else if (buttonIndex == 2) {
            MY_LOG(@"나중에 하기");
            [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:nextShowReviewCount + 10] forKey:@"NEXT_SHOW_REVIEW_COUNT"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        } else {
            MY_LOG(@"닫기");
            [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:nextShowReviewCount + 100] forKey:@"NEXT_SHOW_REVIEW_COUNT"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }
	
}

#pragma mark -
//탭선택 GA처리 위해 추가
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController;
{	
    NSString* currentTabName = nil;
	switch ([ViewControllers sharedViewControllers].tabBarController.selectedIndex) {
		case 0:
			GA3(@"탭바메뉴", @"광장탭", nil);
            currentTabName = @"plaza";
			break;
		case 1:
			GA3(@"탭바메뉴", @"이웃탭", nil);
            currentTabName = @"neighbor";
			break;
		case 2:
			GA3(@"탭바메뉴", @"마이홈탭", nil);
            currentTabName = @"myhome";
			break;
		case 3:
			GA3(@"탭바메뉴", @"새소식탭", nil);
            currentTabName = @"newsfeed";
			break;
		case 4:
			GA3(@"탭바메뉴", @"설정탭", nil);
            currentTabName = @"setting";
			break;
		default:
            currentTabName = @"somethingWrong";
			break;
	}
    
    NWAppUsageLogger *logger = [NWAppUsageLogger logger];
    [logger fireUsageLog:@"TAB" andEventDesc:currentTabName andCategoryId:nil];
    if (![currentTabName isEqualToString:@"newsfeed"]) {
        [[UserContext sharedUserContext] requestFeedList];
    }
}

#pragma mark - Application's Documents directory

/**
 Returns the URL to the application's Documents directory.
 */
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
