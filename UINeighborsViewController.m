//
//  UINeighborsViewController.m
//  ImIn
//
//  Created by mandolin on 10. 4. 6..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "UITabBarItem+WithImage.h"
#import "const.h"
#import "macro.h"
#import "UINeighborsViewController.h"
#import "JSON.h"
#import "UserContext.h"
#import "Utils.h"
#import "iToast.h"

#import "ViewControllers.h"
#import "TableCoverNoticeViewController.h"
#import "UserSearchTableViewController.h"

#import "TwitterInvitationViewController.h"
#import "FBInvitationViewController.h"
#import "PhoneNeighborViewController.h"
#import "CheckMyPhoneViewController.h"

#import "CpData.h"
#import "OAuthWebViewController.h"
#import "NSString+URLEncoding.h"
#import "neighborRecomCnt.h"
#import "FeedCount.h"

#import "TutorialView.h"

enum NEIGHBOR_TYPE {
	NEIGHBORLIST_NICKNAME = 0,
	NEIGHBORLIST_FACEBOOK,
//	NEIGHBORLIST_TWITTER,
	NEIGHBORLIST_PHONE
};

@implementation UINeighborsViewController

@synthesize hasLoaded, selectedSegInt;
@synthesize neighborTableViewController, neighborFindTableViewController;
@synthesize strPostData;
@synthesize cellDataList;
@synthesize neighborRecomCnt, currRecomCount;
@synthesize feedCount;
@synthesize tutorial;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
		connect = nil;
		connect = nil;
		connect = nil;
		
		self.title = @"이웃";
		[self.tabBarItem resetWithNormalImage: [UIImage imageNamed:@"GNB_02_off.png"] 
								selectedImage:[UIImage imageNamed:@"GNB_02_on.png"]];
		
		self.cellDataList = [[[NSMutableArray alloc] initWithCapacity:CELLLIST_CAPACITY] autorelease];
		
		currPageNum0 = 1;
		currPageNum1 = 1;
		
		hasLoaded = NO;
		
		selectedSegInt = 0;
        
        neighborBadgeView.hidden = YES;
        recomBadgeView.hidden = YES;
        recomBadgeViewLarge.hidden = YES;
        
    }
    MY_LOG(@"UINeighborViewController initWithNibName");
    return self;
}


- (void) updateNeighborBadgeNumber:(NSInteger) neighborCnt
{
    if (neighborCnt > 0) {
        neighborCount.text = [NSString stringWithFormat:@"%d", neighborCnt];
        neighborBadgeView.hidden = NO; // 1.4.0에서 구현되었으나 일단 보여주지 않기로 함.
    } else {
        neighborBadgeView.hidden = YES;
    }
}


- (void) viewDidLoad
{		
    MY_LOG(@"UINeighborViewController viewDidLoad");
	[self.navigationController setNavigationBarHidden:YES animated:NO];

	// 이웃 테이블 뷰
	self.neighborTableViewController = [[[MainThreadTableViewController alloc] initWithNibName:@"MainThreadTableViewController" bundle:nil] autorelease];
	neighborTableViewController.isNeighborList = YES;
	[self.view addSubview:neighborTableViewController.view];
	[neighborTableViewController setDelegate:self];
	neighborTableViewController.cellDataList = cellDataList;

	
	// 추천 이웃 테이블 뷰
    self.neighborFindTableViewController = [[[NeighborFindTableViewController alloc] initWithNibName:@"NeighborFindTableViewController" bundle:nil] autorelease]; 
    [self.view addSubview:neighborFindTableViewController.view];
    	
	// 초기 선택 관련
	[self reloadFriendList:selectedSegInt];
    
    NSNotificationCenter* dnc = [NSNotificationCenter defaultCenter];
    [dnc addObserver:self selector:@selector(friendSettingChanged:) name:@"FriendSetSaved" object:nil];
    [dnc addObserver:self selector:@selector(selectTab:) name:@"selectNeighborTab" object:nil];
    [dnc addObserver:self selector:@selector(recomCntBadgeReload:) name:@"recomCntBadgeReload" object:nil];
}

- (void) selectTab:(NSNotification*) noti
{
    if ([[[noti userInfo] objectForKey:@"tab"] isEqualToString:@"이웃찾기"]) {
        selectedSegInt = 2;
        [neighborFindTableViewController.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
        neighborFindTableViewController.pulldownState = YES;
    }

    if ([[[noti userInfo] objectForKey:@"tab"] isEqualToString:@"이웃초대"]) {
        selectedSegInt = 2;
        [neighborFindTableViewController neighborInvite:nil];
    }

    [self reloadFriendList:selectedSegInt];
}

- (void) friendSettingChanged:(NSNotification*) noti
{
	MY_LOG(@"노티왔다");
#ifdef APP_STORE_FINAL_OFF
	NSDictionary* saveResult = [noti userInfo];
	MY_LOG(@"bool: %@ snsid: %@", [saveResult objectForKey:@"isFollowing"], [saveResult objectForKey:@"snsId"]);
#endif
	[self reloadFriendList:selectedSegInt];
}

- (void) viewWillAppear:(BOOL)animated
{	
    MY_LOG(@"UINeighborViewController viewWillAppear");
	[self logViewControllerName];
	
	[neighborTableViewController.view setFrame:CGRectMake(0.0f, 43, 320.0f, 368)];
    [neighborFindTableViewController.view setFrame:CGRectMake(0.0f, 43, 320.0f, 368)];
	
	[neighborTableViewController viewWillAppear:animated];
    [neighborFindTableViewController viewWillAppear:animated];

    
    [self neighborRecomCntRequest];
    [self requestFeedCount]; // 현재 구현은 되어있으나 1.4.0에서는 사용하지 않는다 하여 현재 request하지 않도록 주석 처리
    
	if (hasLoaded) {
		return;
	}
			
	// CgiStringList 객체 기본 생성
	self.strPostData = [[[CgiStringList alloc]init:@"&"] autorelease];
	[strPostData setMapString:@"svcId" keyvalue:SNS_IPHONE_SVCID];
    [strPostData setMapString:@"appVer" keyvalue:[ApplicationContext appVersion]];
	[strPostData setMapString:@"device" keyvalue:SNS_DEVICE_MOBILE_APP];
	[strPostData setMapString:@"snsId" keyvalue:[UserContext sharedUserContext].snsID];
	[strPostData setMapString:@"av" keyvalue:[UserContext sharedUserContext].snsID];
	[strPostData setMapString:@"at" keyvalue:@"1"];
	[strPostData setMapString:@"scale" keyvalue:@"25"];
	[strPostData setMapString:@"currPage" keyvalue:@"1"];
	
	
	[cellDataList removeAllObjects];
    
    if( 0 == selectedSegInt ) {
		[self requestMyFriendsList];
	} else if( 1 == selectedSegInt ) {
		[self requestMyFollowerList];
	}
}

- (void) viewWillDisappear:(BOOL)animated
{
    [[UserContext sharedUserContext].setting setObject:[NSDate date] forKey:@"lastNeighborCountDate"];
    [[UserContext sharedUserContext] saveSettingToFile];

    [neighborFindTableViewController viewWillDisappear:animated];
}

/*
 // Override to allow orientations other than the default portrait orientation.
 - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
 // Return YES for supported orientations
 return (interfaceOrientation == UIInterfaceOrientationPortrait);
 }
 */

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
	if (connect != nil)
	{
		[connect stop];
		[connect release];
		connect = nil;
	}
	
	if (connect != nil)
	{
		[connect stop];
		[connect release];
		connect = nil;
	}
	
	if (connect != nil)
	{
		[connect stop];
		[connect release];
		connect = nil;
	}
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"selectNeighborTab" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"recomCntBadgeReload" object:nil];
}


- (void)dealloc {
	
	if (connect != nil)
	{
		[connect stop];
		[connect release];
		connect = nil;
	}
	
	if (connect != nil)
	{
		[connect stop];
		[connect release];
		connect = nil;
	}
	
	if (connect != nil)
	{
		[connect stop];
		[connect release];
		connect = nil;
	}
	
	[cellDataList release];
	[strPostData release];
    [neighborRecomCnt release];
    [feedCount release];
	
    [neighborFindTableViewController release];
	[neighborTableViewController release];

    [super dealloc];
}

#pragma mark -

- (void) neighborRecomCntRequest {
    NSDictionary* phoneBook = [[UserContext sharedUserContext] getPhoneBook];
	
	NSString* phoneNumberListString = @"";
    
    if ([UserContext sharedUserContext].cpPhone.isConnected) {
        for (NSString* key in phoneBook) {
            phoneNumberListString = [phoneNumberListString stringByAppendingString:key];
            phoneNumberListString = [phoneNumberListString stringByAppendingString:@"|"];	
        }     
    }
    self.neighborRecomCnt = [[[NeighborRecomCnt alloc] init] autorelease];
    neighborRecomCnt.delegate = self;
    [neighborRecomCnt.params addEntriesFromDictionary:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [[GeoContext sharedGeoContext].lastTmX stringValue], @"pointX", 
      [[GeoContext sharedGeoContext].lastTmY stringValue], @"pointY",
      [UserContext sharedUserContext].snsID, @"snsId",
      @"100", @"scale",
      @"1", @"lt",
      @"2", @"phoneNoType",
      phoneNumberListString, @"phoneNo", nil]];
    
    [neighborRecomCnt requestWithoutIndicator];
}

- (void) requestFeedCount {
	self.feedCount = [[[FeedCount alloc] init] autorelease];
	feedCount.delegate = self;
    feedCount.lastFeedDate = [Utils stringFromDate:[self lastDate] withStyle:@"STRAIGHT"];
    
	[feedCount request];
}


#pragma mark - API 결과
- (void)apiFailed {
    
}


- (void) processNeighborRecomCnt:(NSArray*) list {
    
    NSInteger totalCnt = 0;
    NSInteger recomTypeCnt = 0;
    NSString *recomType;
    
    for (NSDictionary *data in list) 
    {
        recomType = [data objectForKey:@"recomType"];
        recomTypeCnt = [[data objectForKey:@"recomTypeCnt"] intValue];
        if ([recomType isEqualToString:@"11"] || [recomType isEqualToString:@"23"] || [recomType isEqualToString:@"21"]) { //아는 사람
            totalCnt += recomTypeCnt;
        }
        
        MY_LOG(@"recomType = %@, recomTypeCnt = %d", recomType, recomTypeCnt);
    }
    
    if (totalCnt > 0) {
        if (totalCnt > 9) {
            recomBadgeViewLarge.hidden = NO;
            recomBadgeView.hidden = YES;
            recomCountLarge.text = [NSString stringWithFormat:@"%d", totalCnt];
        } else {
            recomCount.text = [NSString stringWithFormat:@"%d", totalCnt];
            recomBadgeViewLarge.hidden = YES;
            recomBadgeView.hidden = NO;
        }
    } else {
        recomCount.text = [NSString stringWithFormat:@"%d", totalCnt];
        recomBadgeView.hidden = YES;
        recomBadgeViewLarge.hidden = YES;
    }
    currRecomCount = totalCnt;
}


- (void)apiDidLoad:(NSDictionary *)result {
    
    if ([[result objectForKey:@"func"] isEqualToString:@"neighborRecomCnt"]) {
        
        [self processNeighborRecomCnt:[result objectForKey:@"data"]];

    }

    if ([[result objectForKey:@"func"] isEqualToString:@"feedCount"]) {
        
        NSInteger neighborCnt = [[result objectForKey:@"neighborCnt"] intValue];
        [self updateNeighborBadgeNumber:neighborCnt];
    }
}

#pragma mark Notificaiton handle
- (void) recomCntBadgeReload: (NSNotification*) noti
{
    MY_LOG(@"이웃찾기 탭의 어깨뺏지에 카운드 하나 줄여서 다시 보여줘라.");
	
    if (currRecomCount-1 > 0) {
        if (currRecomCount-1 > 9) { // 한자리 숫자면
            recomCountLarge.text = [NSString stringWithFormat:@"%d", currRecomCount-1];
            recomBadgeView.hidden = YES;
            recomBadgeViewLarge.hidden = NO;
        } else { //두자리 숫자 이상이면
            recomCount.text = [NSString stringWithFormat:@"%d", currRecomCount-1];
            recomBadgeView.hidden = NO;
            recomBadgeViewLarge.hidden = YES;
        }
    } else {
        recomBadgeView.hidden = YES;
        recomBadgeViewLarge.hidden = YES;
    }
    currRecomCount--;
}

-(void) reloadFriendList:(NSInteger) listIndex
{	
	followingOnBtn.hidden = YES;
	followerOnBtn.hidden = YES;
	recomOnBtn.hidden = YES;
		
	[neighborTableViewController.tableView setScrollsToTop:NO];
    [neighborFindTableViewController.tableView setScrollsToTop:NO];
    [neighborFindTableViewController.innerTable setScrollsToTop:NO];
	
	if( 0 == listIndex )		// 내가 등록한 이웃의 목록을 보여주자.
	{
		GA3(@"이웃", @"내가추가한이웃탭", @"이웃내");
		
        followingOnBtn.hidden = NO;
		
        [self.view bringSubviewToFront:neighborTableViewController.tableView];

        [neighborFindTableViewController removeSearchKeyboard];
		
        [self requestMyFriendsList];
		
        [neighborTableViewController.tableView setScrollsToTop:YES]; 
		
        currPageNum0 = 1;
	}
	else if( 1 == listIndex )	// 나를 등록한 이웃의 목록을 보여주자.
	{
		GA3(@"이웃", @"나를추가한이웃탭", @"이웃내");
		
        followerOnBtn.hidden = NO;
		
        [self.view bringSubviewToFront:neighborTableViewController.tableView];
		
        [neighborFindTableViewController removeSearchKeyboard];
        
        [self requestMyFollowerList];
		
        [neighborTableViewController.tableView setScrollsToTop:YES]; 
		
        currPageNum1 = 1;
	}
    
	else if( 2 == listIndex )
	{
		GA3(@"이웃", @"이웃찾기탭", @"이웃내");
		recomOnBtn.hidden = NO;
        
		[self.view bringSubviewToFront:neighborFindTableViewController.tableView];
        
        [neighborFindTableViewController sequencialRequestWithMaxRetryCount:1];

        [neighborFindTableViewController.tableView setScrollsToTop:YES];
	}
	
}

// 세그먼트 컨트롤의 선택이 변경되면.
-(IBAction) pickFriendsList: (UIButton*) sender
{
	hasLoaded = NO;
	
	selectedSegInt = [sender tag];
    
//    NSNumber* showCnt = [[UserContext sharedUserContext].setting objectForKey:@"newNeighborShowCnt"];
//    if (showCnt == nil) {
//        showCnt = [NSNumber numberWithInt:0];
//    } 
//    
//    int cnt = [showCnt intValue];
//    MY_LOG(@"show count = %d", cnt);

//    if (selectedSegInt == 1) { // 나를 추가한 사람 누르면
//        if (cnt >= 1) {
//            [self updateNeighborBadgeNumber:0];
//        } 
//        
//        if ( cnt >= 2) {
//            [[UserContext sharedUserContext].setting setObject:[NSNumber numberWithInt:0] forKey:@"newNeighborShowCnt"];
//            [[UserContext sharedUserContext].setting setObject:[NSDate date] forKey:@"lastNeighborCountDate"];
//        } else {
//            cnt++;
//            [[UserContext sharedUserContext].setting setObject:[NSNumber numberWithInt:cnt] forKey:@"newNeighborShowCnt"];
//        }
//        [[UserContext sharedUserContext] saveSettingToFile];
//    }
 	
    if (selectedSegInt == 1) { // 나를 추가한 사람 누르면
        [self updateNeighborBadgeNumber:0];
    }
    
	[self reloadFriendList:selectedSegInt];
}

- (NSDate*) lastDate {
    NSDate* lastNeighborCountDate = [[UserContext sharedUserContext].setting objectForKey:@"lastNeighborCountDate"];
    if (lastNeighborCountDate == nil) {
        lastNeighborCountDate = [NSDate dateWithTimeIntervalSinceNow:-60*60*24];
    }
    
    return lastNeighborCountDate;
}

#pragma mark -

// 내가 등록한 친구 목록 요구하기
- (void) requestMyFriendsList
{
    MY_LOG(@"requestMyFriendsList");
	if (connect != nil)
	{
		[connect stop];
		[connect release];
		connect = nil;
	}
    
    [strPostData setMapString:@"sortType" keyvalue:@"T"];
    [strPostData setMapString:@"lastRequestDate" keyvalue:[Utils stringFromDate:[self lastDate] withStyle:@"STRAIGHT"]];
    
	
	connect = [[HttpConnect alloc] initWithURL: PROTOCOL_NEIGHBOR_LIST 
									   postData: [[strPostData description] stringByAppendingString:@"listType=M&"]
									   delegate: self
								   doneSelector: @selector(onTransDone1:)    
								  errorSelector: @selector(onHttpConnectError1:)  
							   progressSelector: nil];
}

// 나를 등록한 친구 목록 요구하기
- (void) requestMyFollowerList
{
    MY_LOG(@"requestMyFollowerList");
	if (connect != nil)
	{
		[connect stop];
		[connect release];
		connect = nil;
	}

	[strPostData setMapString:@"sortType" keyvalue:@"M"];
    [strPostData setMapString:@"lastRequestDate" keyvalue:[Utils stringFromDate:[self lastDate] withStyle:@"STRAIGHT"]];
    
	connect = [[HttpConnect alloc] initWithURL: PROTOCOL_NEIGHBOR_LIST
									   postData: [[strPostData description] stringByAppendingString:@"&listType=Y"]
									   delegate: self
								   doneSelector: @selector(onTransDone2:)    
								  errorSelector: @selector(onHttpConnectError2:)  
							   progressSelector: nil];
}

//// 추천 이웃 목록 요구하기
//- (void) requestRecomendList
//{
//	NSDictionary* phoneBook = [[UserContext sharedUserContext] getPhoneBook];
//	
//	NSString* phoneNumberListString = @"";
//    
//    if ([UserContext sharedUserContext].cpPhone.isConnected) {
//        for (NSString* key in phoneBook) {
//            phoneNumberListString = [phoneNumberListString stringByAppendingString:key];
//            phoneNumberListString = [phoneNumberListString stringByAppendingString:@"|"];	
//        }
//    }
//	
//	MY_LOG(@"전화번호 목록 (%d) %@", [phoneBook count], phoneNumberListString);
//	
//	CgiStringList* spData = [[CgiStringList alloc]init:@"&"];
//	[spData setMapString:@"svcId" keyvalue:SNS_IPHONE_SVCID];
//	[spData setMapString:@"device" keyvalue:SNS_DEVICE_MOBILE_APP];	
//	[spData setMapString:@"pointX" keyvalue:[[GeoContext sharedGeoContext].lastTmX stringValue]];
//	[spData setMapString:@"pointY" keyvalue:[[GeoContext sharedGeoContext].lastTmY stringValue]];
//	[spData setMapString:@"lt" keyvalue:@"1"];
//	[spData setMapString:@"snsId" keyvalue:[UserContext sharedUserContext].snsID];
//	[spData setMapString:@"av" keyvalue:[UserContext sharedUserContext].snsID];
//	[spData setMapString:@"at" keyvalue:@"1"];
//	[spData setMapString:@"scale" keyvalue:@"100"];
//	[spData setMapString:@"phoneNoType" keyvalue:@"2"]; // md5 encoding
//	[spData setMapString:@"phoneNo" keyvalue:phoneNumberListString];
//	
//	if (connect != nil)
//	{
//		[connect stop];
//		[connect release];
//		connect = nil;
//	}
//	
//	connect = [[HttpConnect alloc] initWithURL:PROTOCOL_RECOMEND_NEIGHBOR_LIST
//									   postData: [spData description]
//									   delegate: self
//								   doneSelector: @selector(onRecomTransDone:)
//								  errorSelector: @selector(onHttpConnectError3:)
//							   progressSelector: nil];
//    MY_LOG(@"requestRecomendList");
//	[spData release];
//}

#pragma mark -

- (void) onTransDone1:(HttpConnect*)up
{
//    MY_LOG(@"onTransDone1");
//	SBJSON* jsonParser = [SBJSON new];
//	[jsonParser setHumanReadable:YES];
//	
//	NSDictionary* results = (NSDictionary *)[jsonParser objectWithString:up.stringReply error:NULL];
//    
//	[jsonParser release];
    
    NSDictionary* results = [up.stringReply objectFromJSONString];

	if (connect != nil)
	{
		[connect release];
		connect = nil;
	}
	
	if ([results objectForKey:@"totalCnt"] == nil) {
		// 이건 깨진 것. 예외처리한다. 재시도는?
		TableCoverNoticeViewController* infoView = [[TableCoverNoticeViewController alloc]initWithNibName:@"TableCoverNoticeViewController" bundle:nil];
        
        MY_LOG(@"neighborTableViewController.tableView.frame.origin.y = %f", neighborTableViewController.tableView.frame.origin.y);
        
        CGRect neighborTableframe = neighborTableViewController.tableView.frame;
        if (neighborTableframe.origin.y == 0) {
            neighborTableframe.origin.y = neighborTableframe.origin.y + 43;
        }
        
		infoView.view.frame = neighborTableframe;
		[self.view addSubview:infoView.view];
		infoView.line1.text = @"네트워크 상태가 불안하여";
		infoView.line2.text = @"목록을 가져 올 수 없습니다.";
		[infoView release];
		
		[neighborTableViewController.tableView reloadData];
		return;
	}
	
	NSInteger totalCount = [[results objectForKey:@"totalCnt"] integerValue];
	
	// 목록에 아무것도 없는 응답이다.
    // 이웃 찾기 선택 후 다른 탭(아래)에 다녀오면 호출되는 경우가 있음
	if( 0 == totalCount && selectedSegInt == 0)
	{        
        self.tutorial = [[[NSBundle mainBundle] loadNibNamed:@"TutorialView" owner:self options:nil] lastObject];
        [tutorial setFrame:neighborFindTableViewController.tableView.frame];
        [tutorial createTutorialView:[NSDictionary dictionaryWithObject:@"4" forKey:@"status"]];
        tutorial.delegate = self;
        [self.view addSubview:tutorial];
        [neighborTableViewController.tableView reloadData];

		return;
	} else {
        self.tutorial = nil;
    }

	NSArray* poiList = [results objectForKey:@"data"];

	if (hasLoaded == NO || currPageNum0 == 1) {
		[cellDataList removeAllObjects];
	}
	
	[cellDataList addObjectsFromArray:poiList];
	neighborTableViewController.isNeighborList = YES;
	neighborTableViewController.isToMeNeighbor = NO;
	neighborTableViewController.curPosition = @"2";
	
	[neighborTableViewController viewWillAppear:YES];
	[neighborTableViewController.tableView reloadData];
	if (!hasLoaded) {
		[neighborTableViewController.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionNone animated:NO];
	}
	hasLoaded = YES;
	
	if( totalCount == [cellDataList count] )
		neighborTableViewController.footerView.hidden = YES;
}

- (void) onTransDone2:(HttpConnect*)up
{
//    MY_LOG(@"onTransDone2");
//	SBJSON* jsonParser = [SBJSON new];
//	[jsonParser setHumanReadable:YES];
//	
//	NSDictionary* results = (NSDictionary *)[jsonParser objectWithString:up.stringReply error:NULL];
//    
//	[jsonParser release];
    NSDictionary* results = [up.stringReply objectFromJSONString];
    
	if (connect != nil)
	{
		[connect release];
		connect = nil;
	}

	NSInteger totalCount = [[results objectForKey:@"totalCnt"] integerValue];
	
	// 목록에 아무것도 없는 응답이다.
	if( 0 == totalCount )
	{
		self.tutorial = [[[NSBundle mainBundle] loadNibNamed:@"TutorialView" owner:self options:nil] lastObject];
        [tutorial setFrame:neighborFindTableViewController.tableView.frame];
        [tutorial createTutorialView:[NSDictionary dictionaryWithObject:@"4" forKey:@"status"]];
        tutorial.delegate = self;
        [self.view addSubview:tutorial];
        [neighborTableViewController.tableView reloadData];
		return;
	} else {
        self.tutorial = nil;
    }
		
	NSArray* poiList = [results objectForKey:@"data"];

	if (hasLoaded == NO || currPageNum0 == 1) {
		[cellDataList removeAllObjects];
	}
	
	[cellDataList addObjectsFromArray:poiList];
	neighborTableViewController.isNeighborList = YES;
	neighborTableViewController.isToMeNeighbor = YES;
	neighborTableViewController.curPosition = @"21";
		
	[neighborTableViewController viewWillAppear:YES];
	[neighborTableViewController.tableView reloadData];

	if (!hasLoaded) {
		[neighborTableViewController.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionNone animated:NO];
	}
	hasLoaded = YES;
	
	if( totalCount == [cellDataList count] )
		neighborTableViewController.footerView.hidden = YES;
}

#pragma mark -
#pragma mark MainThreadProtocol delegate method

- (CgiStringList*) mainThreadRequestMore
{
	CgiStringList *tmpCgiStr = [[[CgiStringList alloc]init:@"&"] autorelease];
	
	int currPageNum = (0 == selectedSegInt) ? ++currPageNum0 : ++currPageNum1;
	[tmpCgiStr setMapString:@"svcId" keyvalue:SNS_IPHONE_SVCID];
	[tmpCgiStr setMapString:@"snsId" keyvalue:[UserContext sharedUserContext].snsID];
	[tmpCgiStr setMapString:@"device" keyvalue:SNS_DEVICE_MOBILE_APP];
	[tmpCgiStr setMapString:@"av" keyvalue:[UserContext sharedUserContext].snsID];
	[tmpCgiStr setMapString:@"at" keyvalue:@"1"];
	[tmpCgiStr setMapString:@"scale" keyvalue:@"25"];
	[tmpCgiStr setMapString:@"currPage" keyvalue:[NSString stringWithFormat:@"%d",currPageNum]];
	
	if( 0 == selectedSegInt ) // 내가 등록한 이웃. 
	{
//		neighborTableViewController.isToMeNeighbor = YES;
        [tmpCgiStr setMapString:@"sortType" keyvalue:@"T"];
		[tmpCgiStr setMapString:@"listType" keyvalue:@"M"];
	}
	
	if( 1 == selectedSegInt )
	{
//		neighborTableViewController.isToMeNeighbor = NO;
        [tmpCgiStr setMapString:@"sortType" keyvalue:@"M"];
		[tmpCgiStr setMapString:@"listType" keyvalue:@"Y"];
	}
	
	return tmpCgiStr;
}

- (CgiStringList*) mainThreadRequestLatest
{
	[self reloadFriendList:selectedSegInt];
	
	return nil;
}

-(NSString*) mainThreadRequestAddress
{
	return PROTOCOL_NEIGHBOR_LIST;
}

//사람찾기 버튼 클릭시 처리되는 코드
#pragma mark -
- (IBAction) findFriend {
	UIActionSheet* actionSheet = [[UIActionSheet alloc]
								  initWithTitle:nil 
								  delegate:self 
								  cancelButtonTitle:@"취소" 
								  destructiveButtonTitle:nil 
								  otherButtonTitles:@"닉네임 검색",@"facebook 초대",/* @"twitter 초대",*/ @"내 폰 주소록", nil];
	[actionSheet showInView:self.view.window];
	[actionSheet release];
}

- (void) pushUserSearch:(id)sender {
	UserSearchTableViewController* vc = [[UserSearchTableViewController alloc] 
										 initWithNibName:@"UserSearchTableViewController" 
										 bundle:nil];
	[(UINavigationController*)[ViewControllers sharedViewControllers].tabBarController.selectedViewController pushViewController:vc animated:YES];
	[vc release];
}


- (void) pushTwitterInvitation {
	if( ![UserContext sharedUserContext].cpTwitter.isConnected ) {
		NSString* temp = [NSString stringWithFormat:@"sitename=twitter.com&appname=%@&env=app&rturl=%@&cskey=%@&atkey=%@", [IMIN_APP_NAME URLEncodedString], [CALLBACK_URL URLEncodedString], [SNS_CONSUMER_KEY  URLEncodedString], [[UserContext sharedUserContext].token URLEncodedString]] ;
		
		OAuthWebViewController* webViewCtrl = [[[OAuthWebViewController alloc] init] autorelease];
		webViewCtrl.requestInfo = [NSString stringWithFormat:@"%@?%@", OAUTH_URL, temp] ;
		webViewCtrl.webViewTitle = @"twitter 설정";
		webViewCtrl.authType = TWITTER_TYPE;
		
		[webViewCtrl setHidesBottomBarWhenPushed:YES];
		[self.navigationController pushViewController:webViewCtrl animated:YES];
		
		return;
	}
	TwitterInvitationViewController* vc = [[TwitterInvitationViewController alloc]
										   initWithNibName:@"TwitterInvitationViewController" bundle:nil];
	[(UINavigationController*)[ViewControllers sharedViewControllers].tabBarController.selectedViewController pushViewController:vc animated:YES];
	[vc release];
}

- (void) pushFBInvitation {
	if( ![UserContext sharedUserContext].cpFacebook.isConnected ) {
		NSString* temp = [NSString stringWithFormat:@"sitename=facebook.com&appname=%@&env=app&rturl=%@&cskey=%@&atkey=%@", [IMIN_APP_NAME URLEncodedString], [CALLBACK_URL URLEncodedString], [SNS_CONSUMER_KEY  URLEncodedString], [[UserContext sharedUserContext].token URLEncodedString]] ;
		
		OAuthWebViewController* webViewCtrl = [[[OAuthWebViewController alloc] init] autorelease];
		webViewCtrl.requestInfo = [NSString stringWithFormat:@"%@?%@", OAUTH_URL, temp] ;
		webViewCtrl.webViewTitle = @"facebook 설정";
		webViewCtrl.authType = FB_TYPE;
		
		[webViewCtrl setHidesBottomBarWhenPushed:YES];
		[self.navigationController pushViewController:webViewCtrl animated:YES];

		return;
	}
	FBInvitationViewController* vc = [[FBInvitationViewController alloc]
									  initWithNibName:@"FBInvitationViewController" bundle:nil];
	[(UINavigationController*)[ViewControllers sharedViewControllers].tabBarController.selectedViewController pushViewController:vc animated:YES];
	[vc release];
}

- (void) pushPhoneInvitation {
//	if (![UserContext sharedUserContext].cpPhone.isConnected) {
//		//연결
//		
//		return;
//	}
	PhoneNeighborViewController* vc = [[[PhoneNeighborViewController alloc]
										initWithNibName:@"PhoneNeighborViewController" bundle:nil] autorelease];
	[(UINavigationController*)[ViewControllers sharedViewControllers].tabBarController.selectedViewController pushViewController:vc animated:YES];
}


- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	MY_LOG(@"눌린 버튼 번호: %d", buttonIndex);
	switch (buttonIndex) {
		case NEIGHBORLIST_NICKNAME:
			GA3(@"이웃", @"사람찾기", @"닉네임검색");
			[self pushUserSearch:nil];
			break;
		case NEIGHBORLIST_FACEBOOK:
			GA3(@"이웃", @"사람찾기", @"페이스북초대");
			[self pushFBInvitation];
			break;
			
//		case NEIGHBORLIST_TWITTER:
//			[self pushTwitterInvitation];
//			break;
			
		case NEIGHBORLIST_PHONE:
			GA3(@"이웃", @"사람찾기", @"내폰주소록");
			if ([UserContext sharedUserContext].cpPhone.isConnected) {
				[self pushPhoneInvitation];
			} else {
				CheckMyPhoneViewController* vc = [[[CheckMyPhoneViewController alloc] initWithNibName:@"CheckMyPhoneViewController" bundle:nil] autorelease];
				[(UINavigationController*)[ViewControllers sharedViewControllers].tabBarController.selectedViewController pushViewController:vc animated:YES];
			}
			break;

		default:
			break;
	}
}



#pragma mark -
//------------------------------------------------------------------------------

- (void) postNetworkNoticeWithFrame:(CGRect)frame
{
	TableCoverNoticeViewController* infoView = [[TableCoverNoticeViewController alloc]initWithNibName:@"TableCoverNoticeViewController" bundle:nil];
	infoView.view.frame = frame;
	[self.view addSubview:infoView.view];
	infoView.line1.text = @"네트워크가 불안합니다.";
	infoView.line2.text = @"잠시후 다시 시도해주세요~!";
	
	[infoView release];	
}

- (void) onHttpConnectError1:(HttpConnect*)up
{
	if (connect != nil)
	{
		[connect release];
		connect = nil;
	}

    [self postNetworkNoticeWithFrame:CGRectMake(0, 43.0f, neighborTableViewController.tableView.frame.size.width, neighborTableViewController.tableView.frame.size.height)];
}

- (void) onHttpConnectError2:(HttpConnect*)up
{
	if (connect != nil)
	{
		[connect release];
		connect = nil;
	}
	[self postNetworkNoticeWithFrame:neighborTableViewController.tableView.frame];
}

//- (void) onHttpConnectError3:(HttpConnect*)up
//{
//	[CommonAlert alertWithTitle:@"에러" message:up.stringError];
//	if (connect != nil)
//	{
//		[connect release];
//		connect = nil;
//	}
//    [self postNetworkNoticeWithFrame:neighborFindTableViewController.tableView.frame];
//}

#pragma mark - Tutorial method
- (void) tutorialBtnClicked {
    
    [self reloadFriendList:2];
    if (!self.neighborFindTableViewController.pulldownState) {
        self.neighborFindTableViewController.pulldownState = YES;
        [self.neighborFindTableViewController downStateDraw];
    }

}

#pragma mark -
#pragma mark 회전 관련
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return [ApplicationContext sharedApplicationContext].shouldRotate;
}

-(BOOL)canBecomeFirstResponder
{
    return YES;
}



@end
