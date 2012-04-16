    //
//  UISettingViewController.m
//  ImIn
//
//  Created by 태한 김 on 10. 6. 3..
//  Copyright 2010 kth. All rights reserved.
//

#import "macro.h"
#import "UITabBarItem+WithImage.h"
#import "UISettingViewController.h"
#import "UIPlazaViewController.h"
#import "UserContext.h"
#import "ViewControllers.h"
#import "GeoContext.h"
#import "JSON.h"

#import "UIPlazaViewController.h"
#import "UILoginViewController.h"
#import "ImInAppDelegate.h"
#import "AboutViewController.h"
#import "FeedCount.h"
#import "ProfileInfo.h"

@implementation UISettingViewController

@synthesize feedCount;
@synthesize profileInfo;

- (id) init
{
	if (self = [super init]) 
	{
		self.title = @"설정";
		[self.tabBarItem resetWithNormalImage: [UIImage imageNamed:@"GNB_05_off.png"]
								selectedImage:[UIImage imageNamed:@"GNB_05_on.png"]];
	}
	return self;
}

// Implement loadView to create a view hierarchy programmatically, without using a nib.
/**
 @brief ManageTableViewController 생성-세팅 페이지 리스트
 @return void
 */
- (void)loadView {
	[self.navigationController setNavigationBarHidden:YES animated:NO];
	
	self.view = [[[UIView alloc]init] autorelease];
	[self.view setBackgroundColor:[UIColor whiteColor]];
	
	UIImageView *headerView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"header_bg.png"]];
	[headerView setFrame:HEADERVIEW_FRAME];
	[self.view addSubview:headerView];
	
	// 제목 문자열 라벨.
	HeadStr = [[UILabel alloc] initWithFrame:HEADERVIEW_FRAME];
	[HeadStr setTextAlignment:UITextAlignmentCenter];
	[HeadStr setBackgroundColor:[UIColor clearColor]];
	[HeadStr setFont:[UIFont fontWithName:@"Helvetica-Bold" size:19.0]];
	[headerView addSubview:HeadStr];
	[headerView release];
	
	tableViewController = [[ManageTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
	[tableViewController setLogoutAlertDelegate:self];
	[self.view addSubview:tableViewController.view];

//	[self getTwitterSettingStatus];
}

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/

- (void) viewWillAppear:(BOOL)animated
{
	[self logViewControllerName];

	[tableViewController.view setFrame:CGRectMake(0.0f, 43.0f, 320.0f, 369.0f)];
	[HeadStr setText:self.title];
	
	[self requestProfileInfo];
    [self requestGiftInfo];
    
	[tableViewController viewCheckWhenAppear];
    
    // 쿠키 정보를 요청한다. (없을 경우에만)
    [[UserContext sharedUserContext] requestSnsCookie];
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
	[tableViewController release];
	[HeadStr release];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void) viewWillDisappear:(BOOL)animated
{	
	if (connect2 != nil)
	{
		[connect2 stop];
		[connect2 release];
		connect2 = nil;
	}
}


- (void)dealloc {

	if (connect2 != nil)
	{
		[connect2 stop];
		[connect2 release];
		connect2 = nil;
	}
    [feedCount release];
    [profileInfo release];
    [super dealloc];
}



#pragma mark -
#pragma mark 사용자 정보 얻어오기 (전화번호 셋팅때문에 추가됨)

/**
 @brief 사용자 정보를 얻어오기
 @return void
 */
- (void)requestProfileInfo
{
    self.profileInfo = [[[ProfileInfo alloc] init] autorelease];
    profileInfo.delegate = self;
    [profileInfo request];
    
//	CgiStringList	*strPostData = [[CgiStringList alloc]init:@"&"];
//	[strPostData setMapString:@"svcId" keyvalue:SNS_IPHONE_SVCID];
//    [strPostData setMapString:@"appVer" keyvalue:[ApplicationContext appVersion]];
//	[strPostData setMapString:@"device" keyvalue:SNS_DEVICE_MOBILE_APP];
//	[strPostData setMapString:@"av" keyvalue:[UserContext sharedUserContext].snsID];
//	[strPostData setMapString:@"at" keyvalue:@"1"];
//	if (connect2 != nil)
//	{
//		[connect2 stop];
//		[connect2 release];
//		connect2 = nil;
//	}
//	connect2 = [[HttpConnect alloc] initWithURL: PROTOCOL_PROFILEINFO 
//									   postData: [strPostData description]
//									   delegate: self
//								   doneSelector: @selector(onProfileInfoDone:)    
//								  errorSelector: @selector(onHttpConnectError2:)  
//							   progressSelector: nil];	
//	
//	[strPostData release];
}

- (void) requestGiftInfo {
    self.feedCount = [[[FeedCount alloc] init] autorelease];
	feedCount.delegate = self;
    
	[feedCount request];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return [ApplicationContext sharedApplicationContext].shouldRotate;
}

- (void) apiDidLoad:(NSDictionary *)result
{
	if ([[result objectForKey:@"func"] isEqualToString:@"feedCount"]) {
        tableViewController.giftNewCnt = [[result objectForKey:@"giftCnt"] intValue];
        MY_LOG(@"feedCount  for gift = %@", result);
        [tableViewController gitfNewImageSet];
    }
    
    if ([[result objectForKey:@"func"] isEqualToString:@"profileInfo"]) {
        UserContext* uc = [UserContext sharedUserContext];
        uc.userProfile = [result objectForKey:@"profileImg"];
        uc.userPhoneNumber = [result objectForKey:@"phoneNo"];
        uc.cpPhone.isConnected = [[result objectForKey:@"useNPhoneNo"] isEqualToString:@"1"];
        uc.cpPhone.cpCode = @"-1"; // is phonebook
        uc.cpPhone.blogId = [result objectForKey:@"phoneNo"];
        
        [tableViewController viewCheckWhenAppear];
    }
}

- (void) apiFailed {
    
}

//- (void) onHttpConnectError2:(HttpConnect*)up
//{
//	[CommonAlert alertWithTitle:@"에러" message:up.stringError];
//	if (connect2 != nil)
//	{
//		[connect2 release];
//		connect2 = nil;
//	}
//	
//}
//
///**
// @brief 사용자 정보 얻기 완료
// @return void
// */
//- (void) onProfileInfoDone:(HttpConnect*) up
//{
//	SBJSON* jsonParser = [SBJSON new];
//	[jsonParser setHumanReadable:YES];
//	
//	NSDictionary* results = (NSDictionary *)[jsonParser objectWithString:up.stringReply error:NULL];
//	[jsonParser release];
//	
//	if (connect2 != nil)
//	{
//		[connect2 release];
//		connect2 = nil;
//	}
//	
//	UserContext* uc = [UserContext sharedUserContext];
//	uc.userProfile = [results objectForKey:@"profileImg"];
//	uc.userPhoneNumber = [results objectForKey:@"phoneNo"];
//	uc.cpPhone.isConnected = [[results objectForKey:@"useNPhoneNo"] isEqualToString:@"1"];
//	uc.cpPhone.cpCode = @"-1"; // is phonebook
//	uc.cpPhone.blogId = [results objectForKey:@"phoneNo"];
//	
//	[tableViewController viewCheckWhenAppear];
//	
//}


@end
