//
//  UIPlazaViewController.m
//  ImIn
//
//  Created by mandolin on 10. 4. 5..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "UIPlazaViewController.h"
#import "UILoginViewController.h"
#import "IntroViewController.h"

#import "UITabBarItem+WithImage.h"
#import "HttpConnect.h"
#import "CgiStringList.h"
#import "JSON.h"

#import "UIPlazaMainHeaderViewController.h"
#import "PlazaSliderViewController.h"
#import "NoticeBarViewController.h"
#import "EmptyListMessageViewController.h"

#import "PostDetailTableViewController.h"
#import "ViewControllers.h"

#import "const.h"
#import "UserContext.h"
#import "CommonAlert.h"
#import "FriendFinderViewController.h"

#import "EventList.h"
#import "PlazaPostList.h"


@implementation UIPlazaViewController

@synthesize isLogin, sliderRange, needToUpdate, hasLoaded, cellDataList;
@synthesize plazaSliderViewController, plazaMainHeaderController;
@synthesize mainThreadTableViewController;
@synthesize eventList;
@synthesize eventTotalCnt, eventFirstData;
@synthesize plazaPostList;
@synthesize defaultText, morningText, lunchText, eveningText, nightText, holidayText;
@synthesize preDelayDate;
@synthesize inputCellText;

- (id) init
{
	if (self = [super init]) 
	{
		connect = nil;
		self.title = @"광장";
		[self.tabBarItem resetWithNormalImage: [UIImage imageNamed:@"GNB_01_off.png"] selectedImage:[UIImage imageNamed:@"GNB_01_on.png"]];
		cellDataList = [[NSMutableArray alloc] initWithCapacity:10];
		
		isSliderShown = NO;
		isLogin = NO;
		
		needToUpdate = YES;
		requestRetryCount = 0;
		self.sliderRange = @"0";
		hasLoaded = NO;
        preDelayDate = nil;
	}
	return self;
}
- (void)loadView
{
	[self.navigationController setNavigationBarHidden:YES animated:NO];
	
	//self.view = [UIView new];
    self.view = [[[UIView alloc]init] autorelease];   
    
    self.defaultText = [NSArray arrayWithObjects:@"어디서 무엇을 하고 계세요?", nil];
    self.morningText = [NSArray arrayWithObjects:@"굿모닝! 어디로 가고 계세요?", @"굿모닝! 지금 날씨는 어떤가요?", @"굿모닝! 오늘 기분은 어떠세요?", nil];
    self.lunchText = [NSArray arrayWithObjects:@"맛있는 식사 하고 계세요?", @"점심은 어떤 메뉴 인가요?", nil];
    self.eveningText = [NSArray arrayWithObjects:@"어디서 누구와 함께 있나요?", @"특별한 시간 보내고 계신가요?", nil];
    self.nightText = [NSArray arrayWithObjects:@"오늘 하루 어떠셨나요?", @"오늘 어떤 일이 있었나요?", nil];
    self.holidayText = [NSArray arrayWithObjects:@"즐거운 휴일 보내고 계세요?", @"지금 특별한 곳에 있나요?", nil];
    
   //self.questText = [NSDictionary dictionaryWithObjectsAndKeys:defaultText, @"default", morningText, @"morning", lunchText, @"lunch", eveningText, @"evening", nightText, @"night", holidayText, @"holiday", nil];
    
    
	// 메인 해더
	self.plazaMainHeaderController = [[[UIPlazaMainHeaderViewController alloc] 
												initWithNibName:@"MainHeader" bundle:nil] autorelease];
	[self.view addSubview:plazaMainHeaderController.view];
	
	// 슬라이더 게이지
	self.plazaSliderViewController = [[[PlazaSliderViewController alloc] 
								 initWithNibName:@"PlazaSliderViewController" 
								 bundle:nil] autorelease];
	[plazaSliderViewController.view setFrame:CGRectMake(0.0f, 43.0f, 320.0f, 35.0f)];
	[self.view addSubview:plazaSliderViewController.view];
	plazaSliderViewController.view.tag = SLIDER_GAUGE_VIEW;
	plazaSliderViewController.view.hidden = YES;
		
	// 메인 테이블 뷰 컨트롤러
	self.mainThreadTableViewController = [[[MainThreadTableViewController alloc] 
									 initWithNibName:@"MainThreadTableViewController" 
									 bundle:nil] autorelease];
	mainThreadTableViewController.isFromPlazaVC = YES;
	[mainThreadTableViewController.view setFrame:CGRectMake(0.0f, 43.0f, 320.0f, 368.0f)];
	[self.view insertSubview:mainThreadTableViewController.view belowSubview:plazaSliderViewController.view];
	[mainThreadTableViewController setDelegate:self];
		
	[ViewControllers sharedViewControllers].plazaViewController = self;
	
    mainThreadTableViewController.enclosingClassName = NSStringFromClass([self class]);
	//notice bar
	noticeBarViewController = [[NoticeBarViewController alloc] 
							   initWithNibName:@"NoticeBarViewController" 
							   bundle:nil];
	//noticeBarViewController.noticeMessage.text = @"";
	[self.view addSubview:noticeBarViewController.view];
	//[noticeBarViewController release];
}

- (void)viewWillAppear:(BOOL)animated {
	[self logViewControllerName];
    
    mainThreadTableViewController.enclosingClassName = NSStringFromClass([self class]);
    
	if ([ApplicationContext sharedApplicationContext].theFirstLogin) {

		[ApplicationContext sharedApplicationContext].theFirstLogin = NO;
        
        //performselector를 쓰면 httpconnect가 끊어짐.. 왤까.. 암턴 그래서 다시 예전 방식으로 변경! 
        //[[ApplicationContext sharedApplicationContext] performSelector:@selector(openFriendFinder) withObject:nil afterDelay:0.5f];		
        FriendFinderViewController* vc = [[[FriendFinderViewController alloc] initWithNibName:@"FriendFinderViewController" bundle:nil] autorelease];
		UINavigationController* nav = [[[UINavigationController alloc] initWithRootViewController:vc] autorelease];
		[self.navigationController presentModalViewController:nav animated:YES];

	} else {
        if (isLogin) {
            [self performSelector:@selector(openWelcomeTutorial) withObject:nil afterDelay:1.0f];            
        }
    }
	    
    // 메모리 문제로 cellDataList가 사라지는 경우(?) 복구하도록 수정
	if (cellDataList == nil) {
		cellDataList = [[NSMutableArray alloc] initWithCapacity:25];
	}
	if (mainThreadTableViewController.cellDataList == nil) {
		mainThreadTableViewController.cellDataList = cellDataList;
	}
    
    if (mainThreadTableViewController.eventFirstData == nil || mainThreadTableViewController.eventTotalCnt == 0) {
        mainThreadTableViewController.eventFirstData = eventFirstData;
        mainThreadTableViewController.eventTotalCnt = eventTotalCnt;
    }

	if(isLogin == YES) {
		if (needToUpdate) {
			[self refresh];
		}
        
		// PNS관련 처리
		if ([UserContext sharedUserContext].pnsStr != nil && [[UserContext sharedUserContext].pnsStr compare:@""] != NSOrderedSame )
		{
			[self apnsHandlerWithMessage:[UserContext sharedUserContext].pnsStr];
			[UserContext sharedUserContext].pnsStr = nil;
		}
        [[UserContext sharedUserContext] recordKissMetricsWithEvent:@"Plaza Page" withInfo:nil];
	} else {
		IntroViewController* introViewController = [[IntroViewController alloc] initWithNibName:@"IntroViewController" bundle:nil];
		[introViewController setHidesBottomBarWhenPushed:YES];
		[self.navigationController pushViewController:introViewController animated:NO];
		[introViewController release];
    }
    
	[plazaMainHeaderController viewWillAppear:animated];
	[mainThreadTableViewController viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	if (connect != nil) {
		[connect stop];
		[connect release];
		connect = nil;
	}
 //   mainThreadTableViewController.enclosingClassName = nil;
	[mainThreadTableViewController viewWillDisappear:animated];
}

- (NSString*) getPlazaQuestText {
    
    NSString* selText = nil;
    NSTimeInterval timeStamp = [[NSDate date] timeIntervalSince1970];
    
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timeStamp];

    if (preDelayDate != nil) { // 만약에 이전에 1분뒤로 잡아놓은 시간이 있으면 현재 시간과 비교해라
        if ([preDelayDate compare:date] == NSOrderedDescending) { // 이전에 1분뒤로 잡아놓은 시간이 현재 시간보다 크냐?
            MY_LOG(@"너무 빨리 요청한다");
            return inputCellText; // 그러면 그냥 이전 보여줬던 텍스트를 보여주렴
        }  
    } 

    // 이전에 1분위로 잡아놓은 시간이 없으면 즉 처음이면 혹은
    // 이전에 1분뒤로 잡아놓은 시간이 현재시간보다 작으면
    // 새로운 랜덤데이타를 보여주렴

    MY_LOG(@"새로운 데이타를 보여줘도 된다");
    self.preDelayDate = [NSDate dateWithTimeIntervalSinceNow:10.0f];
    NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    [dateFormatter setDateFormat:@"HH"];
    NSInteger currTime = [[dateFormatter stringFromDate:date] intValue];
        
    NSCalendar *gregorian = [[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar] autorelease];
    NSDateComponents *weekDayComponents = [gregorian components:NSWeekdayCalendarUnit fromDate:date];
    
    if ([weekDayComponents weekday] == 1 || [weekDayComponents weekday] == 7) {
        selText = [holidayText objectAtIndex:(random() % (([holidayText count]-1)-0+1)) + 0];
    } else {
        if ((currTime >= 0 && currTime <= 6 ) || (currTime >= 9 && currTime <= 11) || (currTime >= 14 && currTime <= 18)) {
            selText = [defaultText objectAtIndex:(random() % (([defaultText count]-1)-0+1)) + 0];
        } else if (currTime >= 7 && currTime <= 8) {
            selText = [morningText objectAtIndex:(random() % (([morningText count]-1)-0+1)) + 0];
        } else if (currTime >= 12 && currTime <= 13) {
            selText = [lunchText objectAtIndex:(random() % (([lunchText count]-1)-0+1)) + 0];
        } else if (currTime >= 19 && currTime <= 21) {
            selText = [eveningText objectAtIndex:(random() % (([eveningText count]-1)-0+1)) + 0];
        } else if (currTime >= 22 && currTime <= 23) {
            selText = [nightText objectAtIndex:(random() % (([nightText count]-1)-0+1)) + 0];
        } else {
            selText = @"지금 추억을 남겨보세요~!";
        }
    }

    self.inputCellText = selText;
    return inputCellText;
}

- (void)toggleSliderView {
    
//#ifndef APP_STORE_FINAL	
//	FriendFinderViewController* vc = [[[FriendFinderViewController alloc] initWithNibName:@"FriendFinderViewController" bundle:nil] autorelease];
//	UINavigationController* nav = [[[UINavigationController alloc] initWithRootViewController:vc] autorelease];
//	[self.navigationController presentModalViewController:nav animated:YES];
//#endif
    
    NSInteger tag = SLIDER_GAUGE_VIEW;
	if (isSliderShown) {
		isSliderShown = NO;
		[self.view viewWithTag:tag].hidden = YES;
	} else {
		isSliderShown = YES;
		[self.view viewWithTag:tag].hidden = NO;
	}
}

- (void) toggleNoticeView {
	[noticeBarViewController toggleView];
}

- (void) openNoticeView {
	[noticeBarViewController viewExplainView:YES];
}

- (void) closeNoticeView {
	[noticeBarViewController viewExplainView:NO];
}

- (void) refresh
{
	[mainThreadTableViewController.tableView setContentOffset:CGPointMake(0, 60) animated:NO];
	
	hasLoaded = NO;
	needToUpdate = YES;
    
    //[self request];
    [self requestOfPlazaList];
    [self requestOfEvent];

}

- (void) requestOfEvent {
    GeoContext* gc = [GeoContext sharedGeoContext];
    if (gc.lastTmX == nil || gc.lastTmY == nil) {
        return;
    }
    NSString* pointX = [gc.lastTmX stringValue];
    NSString* pointY = [gc.lastTmY stringValue];
    
    self.eventList = [[[EventList alloc] init] autorelease];
    eventList.delegate = self;
        
    [eventList.params addEntriesFromDictionary:[NSDictionary dictionaryWithObject:pointX forKey:@"pointX"]]; // 발도장 중심좌표
    [eventList.params addEntriesFromDictionary:[NSDictionary dictionaryWithObject:pointY forKey:@"pointY"]];
    [eventList.params addEntriesFromDictionary:[NSDictionary dictionaryWithObject:@"1" forKey:@"scale"]];
    
    [eventList requestWithAuth:NO withIndicator:YES];
}

- (void) requestOfPlazaList {
    self.plazaPostList = [[[PlazaPostList alloc] init] autorelease];
    plazaPostList.delegate = self;
    
    self.sliderRange = [NSString stringWithFormat:@"%d", (int)(plazaSliderViewController.range * 1000)];
    
    if ([sliderRange isEqualToString:@"0"] ) {
		sliderRange = DEFAULT_PLAZA_RANGEX;
	}

    [plazaPostList.params addEntriesFromDictionary:[NSDictionary dictionaryWithObject:[[GeoContext sharedGeoContext].lastTmX stringValue] forKey:@"pointX"]];
    [plazaPostList.params addEntriesFromDictionary:[NSDictionary dictionaryWithObject:[[GeoContext sharedGeoContext].lastTmY stringValue] forKey:@"pointY"]];
    [plazaPostList.params addEntriesFromDictionary:[NSDictionary dictionaryWithObject:sliderRange forKey:@"rangeX"]];
    [plazaPostList.params addEntriesFromDictionary:[NSDictionary dictionaryWithObject:sliderRange forKey:@"rangeY"]];
    [plazaPostList.params addEntriesFromDictionary:[NSDictionary dictionaryWithObject:PLAZA_MAIN_THREAD_DEFAULT_ROWS_NUMBER forKey:@"maxScale"]];
    [plazaPostList.params addEntriesFromDictionary:[NSDictionary dictionaryWithObject:@"F" forKey:@"vm"]];
    [plazaPostList.params addEntriesFromDictionary:[NSDictionary dictionaryWithObject:[ApplicationContext sharedApplicationContext].apiVersion forKey:@"ver"]];

    [plazaPostList requestWithAuth:NO withIndicator:YES];
}

//- (void) request
//{
//    MY_LOG(@"old request call");
//	CgiStringList* strPostData=[[CgiStringList alloc]init:@"&"];
//	[strPostData setMapString:@"svcId" keyvalue:SNS_IPHONE_SVCID];
//    [strPostData setMapString:@"appVer" keyvalue:[ApplicationContext appVersion]];
//	[strPostData setMapString:@"device" keyvalue:SNS_DEVICE_MOBILE_APP];	
//	[strPostData setMapString:@"pointX" keyvalue:[[GeoContext sharedGeoContext].lastTmX stringValue]];
//	[strPostData setMapString:@"pointY" keyvalue:[[GeoContext sharedGeoContext].lastTmY stringValue]];
//	
//    self.sliderRange = [NSString stringWithFormat:@"%d", (int)(plazaSliderViewController.range * 1000)];
//    
//	if ([sliderRange isEqualToString:@"0"] ) {
//		sliderRange = DEFAULT_PLAZA_RANGEX;
//	}
//	[strPostData setMapString:@"rangeX" keyvalue:sliderRange];
//	[strPostData setMapString:@"rangeY" keyvalue:sliderRange];
//	
//	[strPostData setMapString:@"maxScale" keyvalue:PLAZA_MAIN_THREAD_DEFAULT_ROWS_NUMBER];
//	[strPostData setMapString:@"vm" keyvalue:@"F"];
//	[strPostData setMapString:@"ver" keyvalue:[ApplicationContext sharedApplicationContext].apiVersion];
//	
//	if (connect != nil)
//	{
//		[connect stop];
//		[connect release];
//		connect = nil;
//	}
//	
//	connect = [[HttpConnect alloc] initWithURL:PROTOCOL_PLAZA_POST_LIST
//						   postData: [strPostData description]
//						   delegate: self
//					   doneSelector: @selector(onTransDone:)    
//					  errorSelector: @selector(onResultError:)  
//				   progressSelector: nil];
//
//	[strPostData release];
//}


//- (void) onResultError:(HttpConnect*)up
//{
//	if (connect != nil)
//	{
//		[connect release];
//		connect = nil;
//	}
//	[CommonAlert alertWithTitle:@"안내" message:up.stringError];
//}
//
//- (void) onTransDone:(HttpConnect*)up
//{	
//	SBJSON* jsonParser = [SBJSON new];
//	[jsonParser setHumanReadable:YES];
//	
//	NSDictionary* results = (NSDictionary *)[jsonParser objectWithString:up.stringReply error:NULL];
//	[jsonParser release];
//	
//	if (connect != nil)
//	{
//		[connect release];
//		connect = nil;
//	}
//	
//	NSNumber* resultNumber = (NSNumber*)[results objectForKey:@"result"];
//
//	if ([resultNumber intValue] == 0) { //에러처리
//		[CommonAlert alertWithTitle:@"에러" message:[results objectForKey:@"description"]];
//		return;
//	}
//	
//	NSArray* resultList = [results objectForKey:@"data"];
//	
//	if ([resultList count] == 0) {
//		// empty 창 띄우기
//		emptyListMessageViewController = [[EmptyListMessageViewController alloc] 
//										  initWithNibName:@"EmptyListMessageViewController"
//										  bundle:nil];
//		
//		emptyListMessageViewController.view.frame = CGRectMake(0.0f, 43.0f, 320.0f, 440.0f);
//		
//		[self.view insertSubview:emptyListMessageViewController.view belowSubview:plazaSliderViewController.view];
//
//		return;
//	} else {
//		if (emptyListMessageViewController.view != nil) {
//			emptyListMessageViewController.view.hidden = YES;	
//		}
//	}
//
//	[cellDataList removeAllObjects];
//	
//	mainThreadTableViewController.tableView.scrollEnabled = NO;
//	int cellListCount = [cellDataList count];
//	for (int i=0; i < [resultList count]; i++) {
//		NSDictionary *data = [resultList objectAtIndex:i];
//		// TODO: GA 분기
//		mainThreadTableViewController.curPosition = @"1";
//		if (cellListCount < 25) {
//			[cellDataList addObject:data];
//		} else {
//			[cellDataList replaceObjectAtIndex:i withObject:data];
//		}
//	}
//	mainThreadTableViewController.tableView.scrollEnabled = YES;
//
//	mainThreadTableViewController.cellDataList = cellDataList;
//	[mainThreadTableViewController updateParameter];
//	[mainThreadTableViewController.tableView reloadData];
//	[mainThreadTableViewController updateRange];
//	
//	//TODO: NSNotification Center로 변경해야함.
//	[plazaMainHeaderController redrawUI];
//	needToUpdate = NO;
//	hasLoaded = YES;
//}

- (void) apiDidLoad:(NSDictionary*)result {
    if ([[result objectForKey:@"func"] isEqualToString:@"eventList"]) { 
        
        if ([[result objectForKey:@"result"] boolValue]) {
            NSMutableArray* events = [[NSMutableArray alloc]init];
            [events addObjectsFromArray:[result objectForKey:@"specialEvent"]];
            [events addObjectsFromArray:[result objectForKey:@"freeEvent"]];
                                      
            if ([events count] > 0) {
                self.eventFirstData = [events objectAtIndex:0];                
            }
            eventTotalCnt = [[result objectForKey:@"totalCnt"] intValue];
            [events release];
        } else {
            MY_LOG(@"event 리스트 실패");
        }

        mainThreadTableViewController.eventFirstData = eventFirstData;
        mainThreadTableViewController.eventTotalCnt = eventTotalCnt;

        [mainThreadTableViewController.tableView reloadData];

//        needToUpdate = NO;
//        hasLoaded = YES;
	}
    
    if ([[result objectForKey:@"func"] isEqualToString:@"plazaPostList"]) {
        NSNumber* resultNumber = (NSNumber*)[result objectForKey:@"result"];
        
        if ([resultNumber intValue] == 0) { //에러처리
            [CommonAlert alertWithTitle:@"에러" message:[result objectForKey:@"description"]];
            return;
        }
        
        NSArray* resultList = [result objectForKey:@"data"];
        if ([resultList count] == 0) {
            // empty 창 띄우기
            emptyListMessageViewController = [[EmptyListMessageViewController alloc] 
                                              initWithNibName:@"EmptyListMessageViewController"
                                              bundle:nil];
            
            emptyListMessageViewController.view.frame = CGRectMake(0.0f, 43.0f, 320.0f, 440.0f);
            
            [self.view insertSubview:emptyListMessageViewController.view belowSubview:plazaSliderViewController.view];
            return;
        } else {
            if (emptyListMessageViewController.view != nil) {
                emptyListMessageViewController.view.hidden = YES;	
            }
        }
        
        [cellDataList removeAllObjects];
        
        mainThreadTableViewController.tableView.scrollEnabled = NO;
        int cellListCount = [cellDataList count];
        for (int i=0; i < [resultList count]; i++) {
            NSDictionary *data = [resultList objectAtIndex:i];
            // TODO: GA 분기
            mainThreadTableViewController.curPosition = @"1";
            if (cellListCount < 25) {
                [cellDataList addObject:data];
            } else {
                [cellDataList replaceObjectAtIndex:i withObject:data];
            }
        }
        mainThreadTableViewController.tableView.scrollEnabled = YES;
        
        mainThreadTableViewController.cellDataList = cellDataList;
        [mainThreadTableViewController updateParameter];
        [mainThreadTableViewController.tableView reloadData];
        [mainThreadTableViewController updateRange];
        
        //TODO: NSNotification Center로 변경해야함.
        [plazaMainHeaderController redrawUI];
        needToUpdate = NO;
        hasLoaded = YES;
    }
}

- (void) apiFaled {
    
}

#pragma mark -
#pragma mark MainThreadProtocol delegate method

- (CgiStringList*) mainThreadRequestMore
{
	CgiStringList* strPostData=[[[CgiStringList alloc]init:@"&"] autorelease];
	[strPostData setMapString:@"svcId" keyvalue:SNS_IPHONE_SVCID];
    [strPostData setMapString:@"appVer" keyvalue:[ApplicationContext appVersion]];
	[strPostData setMapString:@"device" keyvalue:SNS_DEVICE_MOBILE_APP];
	[strPostData setMapString:@"pointX" keyvalue:[[GeoContext sharedGeoContext].lastTmX stringValue]];
	[strPostData setMapString:@"pointY" keyvalue:[[GeoContext sharedGeoContext].lastTmY stringValue]];
	[strPostData setMapString:@"vm" keyvalue:@"F"];
	if ([sliderRange isEqualToString:@"0"] ) {
		sliderRange = DEFAULT_PLAZA_RANGEX;
	}
	[strPostData setMapString:@"rangeX" keyvalue:sliderRange];
	[strPostData setMapString:@"rangeY" keyvalue:sliderRange];
	
	return strPostData;
}

- (CgiStringList*) mainThreadRequestLatest
{
	return [self mainThreadRequestMore];
}

//  테이블 스크롤잉 맨 아래에서 다음 페이지 보여줘야 할떄.
-(NSString*) mainThreadRequestAddress 
{
	return PROTOCOL_PLAZA_POST_LIST;
}



- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
	if (connect != nil)
	{
		[connect stop];
		[connect release];
		connect = nil;
	}
	[cellDataList release];
	[plazaSliderViewController release];
    [plazaMainHeaderController release];
    [sliderRange release];
    [mainThreadTableViewController release];
    [eventList release];
    [eventFirstData release];
    [plazaPostList release];
    [defaultText release];
    [morningText release];
    [lunchText release];
    [eveningText release];
    [nightText release];
    [holidayText release];
    [preDelayDate release];

	[super dealloc];
}

-(BOOL)canBecomeFirstResponder
{
    return YES;
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
		MY_LOG(@"마이홈");
		tagId = 200;
	}
		
	UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"알림" message:message
													   delegate:self cancelButtonTitle:@"확인" otherButtonTitles:@"이동", nil] autorelease];
	alert.tag = tagId;
	[alert show];
}
	
- (void)alertView:(UIAlertView*)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (alertView.tag == 100)
	{
		if (buttonIndex == 1)
		{
			[[ViewControllers sharedViewControllers].tabBarController setSelectedIndex:1];
		}
	}
	if (alertView.tag == 200)
	{
		if (buttonIndex == 1)
		{
			[[ViewControllers sharedViewControllers].tabBarController setSelectedIndex:2];
		}
	}		
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return [ApplicationContext sharedApplicationContext].shouldRotate;
}

- (void) openWelcomeTutorial
{
    if ([[[UserContext sharedUserContext].setting objectForKey:@"hasDoneFriendFinder"] intValue] != 1) {
        return;
    }
    
    if ([[[UserContext sharedUserContext].setting objectForKey:@"welcomeTutorialShown"] intValue] == 1) {
        return;
    }
    
    if ([self.view viewWithTag:8080] != nil) { // 떠있다면 띄우지 말기~!
        return;
    }
            
    NSDecimalNumber* welcomeRecomAcceptCnt = (NSDecimalNumber*)[[UserContext sharedUserContext].setting objectForKey:@"welcomeRecomAcceptCnt"];
    NSDecimalNumber* neighborCnt = (NSDecimalNumber*)[[UserContext sharedUserContext].setting objectForKey:@"neighborCnt"];
    
    if (welcomeRecomAcceptCnt == nil) {
        welcomeRecomAcceptCnt = [NSDecimalNumber zero];
        [[UserContext sharedUserContext].setting setObject:welcomeRecomAcceptCnt forKey:@"welcomeRecomAcceptCnt"];
        [[UserContext sharedUserContext] saveSettingToFile];
    }
    if (neighborCnt == nil) {
        neighborCnt = [NSDecimalNumber zero];
        [[UserContext sharedUserContext].setting setObject:neighborCnt forKey:@"neighborCnt"];
        [[UserContext sharedUserContext] saveSettingToFile];
    }

    UIButton* tutorial = [UIButton buttonWithType:UIButtonTypeCustom];
    [tutorial setFrame:CGRectMake(0, 0, 320, 411)];
    tutorial.tag = 8080;

//    if ([welcomeRecomAcceptCnt intValue] == 0) {
//        //TODO: 이웃 튜토리얼 띄우기 (02)
//        [tutorial setImage:[UIImage imageNamed:@"tutorial02.png"] forState:UIControlStateNormal];
//    } else {
//        //TODO: 발도장 찍기 튜토리얼 띄우기 (01)
        [tutorial setImage:[UIImage imageNamed:@"tutorial01.png"] forState:UIControlStateNormal];
//    }
    tutorial.alpha = 0.9f;
    [tutorial addTarget:self action:@selector(tutorialtapped:) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:tutorial];
    

    GA1(@"튜토리얼");
}

- (void) tutorialtapped:(UIButton*) sender
{
    [sender removeFromSuperview];
    [[UserContext sharedUserContext].setting setObject:[NSNumber numberWithInt:1] forKey:@"welcomeTutorialShown"];
    [[UserContext sharedUserContext] saveSettingToFile];
}

@end


