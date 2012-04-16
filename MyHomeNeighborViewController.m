    //
//  MyHomeNeighborViewController.m
//  ImIn
//
//  Created by 태한 김 on 10. 6. 14..
//  Copyright 2010 kth. All rights reserved.
//

#import "MyHomeNeighborViewController.h"
#import "macro.h"
#import "TutorialView.h"
#import "iToast.h"
#import "TableCoverNoticeViewController.h"

@implementation MyHomeNeighborViewController

@synthesize headStr;
@synthesize cellDataList;
@synthesize userSnsID;
@synthesize nickName;
@synthesize neighborTableViewController;
@synthesize connect;
@synthesize tableRect;
@synthesize listType;


- (id) initWithSnsId:(NSString*) snsIdStr nickName:(NSString*)nName
{
	if (self = [super init]) 
	{
		self.connect = nil;
		
		self.title = @"이웃";
		
		self.cellDataList = [[[NSMutableArray alloc] initWithCapacity:CELLLIST_CAPACITY] autorelease];
		self.userSnsID = snsIdStr;
		self.nickName = nName;
        self.listType = @"M";
		hasLoaded = NO;
		
		self.tableRect = CGRectMake(0.0f, 43, 320.0f, 368);
	}
	return self;
}

- (id) initWithSnsId:(NSString*) snsIdStr nickName:(NSString*)nName listType:(NSString*) type
{
	if (self = [super init]) 
	{
		self.connect = nil;
		
		self.title = @"이웃";
		
		self.cellDataList = [[[NSMutableArray alloc] initWithCapacity:CELLLIST_CAPACITY] autorelease];
		self.userSnsID = snsIdStr;
		self.nickName = nName;
        self.listType = type;
		hasLoaded = NO;
		
		self.tableRect = CGRectMake(0.0f, 43, 320.0f, 368);
	}
	return self;
}



// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
	[self.navigationController setNavigationBarHidden:YES animated:NO];
	
	self.view = [[[UIView alloc]init] autorelease];
	
	UIImageView *headerView = [[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"header_bg.png"]] autorelease];
	[headerView setFrame:HEADERVIEW_FRAME];

	// 제목 문자열 라벨.
	self.headStr = [[[UILabel alloc] initWithFrame:HEADERVIEW_FRAME] autorelease];
	[headStr setTextAlignment:UITextAlignmentCenter];
	[headStr setBackgroundColor:[UIColor clearColor]];
	[headStr setFont:[UIFont fontWithName:@"Helvetica-Bold" size:17.0]];
    if ([listType isEqualToString:@"Y"]) {
        [headStr setText:[NSString stringWithFormat:@"%@을(를) 이웃", nickName]];
    } else {
        [headStr setText:[NSString stringWithFormat:@"%@의 이웃", nickName]];
    }
	
	[headerView addSubview:headStr];

	[self.view addSubview:headerView];
	UIButton *backBtn = [[UIButton alloc]initWithFrame:BACKBTN_FRAME];
	[backBtn setImage:[UIImage imageNamed:@"header_prev.png"] forState:UIControlStateNormal];
	[backBtn addTarget:self
				action:@selector(popViewController:)
	  forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:backBtn];
	[backBtn release];

	// 하단의 발도장 목록 영역을 표시한다. -------------------------------------------
	self.neighborTableViewController = [[[MainThreadTableViewController alloc] initWithNibName:@"MainThreadTableViewController" bundle:nil] autorelease];
	[self.neighborTableViewController.view setFrame:tableRect];
	[self.neighborTableViewController.view setAutoresizesSubviews:YES];
	[self.view addSubview:neighborTableViewController.view];
	[neighborTableViewController setDelegate:self];

	self.neighborTableViewController.cellDataList = self.cellDataList;
}

- (void) viewWillAppear:(BOOL)animated
{
	// 회전 불가능 설정
	//UserContext* userContext = [UserContext sharedUserContext];
    //userContext.bEnableRotate = NO;
	[self logViewControllerName];
	[self.neighborTableViewController viewWillAppear:animated];
}

- (void) viewDidAppear:(BOOL)animated
{
	if (!hasLoaded) {
		[self.cellDataList removeAllObjects];
		[self requestFriendsList];
	}
}

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
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
}


- (void)dealloc {
	if (connect != nil)
	{
		[connect stop];
		[connect release];
		connect = nil;
	}
	
	
	[headStr release];
	[cellDataList release];
	[userSnsID release];
	[nickName release];
	[neighborTableViewController release];
	[connect release];
	
    [super dealloc];
}

#pragma mark -
- (void) postNetworkNoticeWithFrame:(CGRect)frame
{
	TableCoverNoticeViewController* infoView = [[TableCoverNoticeViewController alloc]initWithNibName:@"TableCoverNoticeViewController" bundle:nil];
	infoView.view.frame = frame;
	[self.view addSubview:infoView.view];
	infoView.line1.text = @"네트워크가 불안합니다.";
	infoView.line2.text = @"잠시후 다시 시도해주세요~!";
	
	[infoView release];	
}

#pragma mark -

- (void) requestFriendsList
{
	CgiStringList *strPostData = [[[CgiStringList alloc]init:@"&"] autorelease];
	[strPostData setMapString:@"svcId" keyvalue:SNS_IPHONE_SVCID];
    [strPostData setMapString:@"appVer" keyvalue:[ApplicationContext appVersion]];
	[strPostData setMapString:@"device" keyvalue:SNS_DEVICE_MOBILE_APP];
	[strPostData setMapString:@"snsId" keyvalue:userSnsID];
	[strPostData setMapString:@"av" keyvalue:[UserContext sharedUserContext].snsID];
	[strPostData setMapString:@"at" keyvalue:@"1"];
	[strPostData setMapString:@"scale" keyvalue:@"50"];
	[strPostData setMapString:@"sortType" keyvalue:@"T"];
    [strPostData setMapString:@"listType" keyvalue:listType];
		
	neighborCurrPage = 1;

	connect = [[HttpConnect alloc] initWithURL: PROTOCOL_NEIGHBOR_LIST 
												postData: [strPostData description]
												delegate: self
											doneSelector: @selector(onTransDone:)    
										   errorSelector: @selector(onHttpConnectError:)  
										progressSelector: nil];
}

- (void) onTransDone:(HttpConnect*)up
{
//	SBJSON* jsonParser = [SBJSON new];
//	[jsonParser setHumanReadable:YES];
//	
//	NSDictionary* results = (NSDictionary *)[jsonParser objectWithString:up.stringReply error:NULL];
//    [jsonParser release];
    
    NSDictionary* results = [up.stringReply objectFromJSONString];
	
	if (connect != nil)
	{
		[connect release];
		connect = nil;
	}
	
	// 목록에 아무것도 없는 응답이다.
	if( [[results objectForKey:@"totalCnt"] compare:[NSNumber numberWithInt:0]] == NSOrderedSame )
	{
        TutorialView *tutorial = [[[NSBundle mainBundle] loadNibNamed:@"TutorialView" owner:self options:nil] lastObject];
        
        if ([[UserContext sharedUserContext].snsID isEqualToString:self.userSnsID]) {  //마이홈일 때
            [tutorial createTutorialView:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:5] forKey:@"status"]];
        } else {
            [tutorial createTutorialView:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithInt:8] , self.userSnsID, nil] forKeys:[NSArray arrayWithObjects:@"status", @"nickname", nil]]];
        }

        tutorial.frame = self.tableRect;
        [self.view addSubview:tutorial];
        
		[neighborTableViewController.tableView reloadData];
		
		return;
	}
	
	NSArray* poiList = [results objectForKey:@"data"];
	
	for (NSDictionary *poiData in poiList) {
		[cellDataList addObject:poiData];
	}
	
    if ([listType isEqualToString:@"Y"]) {
        [headStr setText:[NSString stringWithFormat:@"%@을(를) 이웃", nickName]];
    } else {
        [headStr setText:[NSString stringWithFormat:@"%@의 이웃", nickName]];
    }

	[neighborTableViewController viewWillAppear:YES];
	[neighborTableViewController.tableView reloadData];

	if( [cellDataList count] >= [[results objectForKey:@"totalCnt"] intValue] )
		neighborTableViewController.footerView.hidden = YES;
	
	hasLoaded = YES;
}

// back 버튼 클릭하면 되돌아가야 한다.
- (void) popViewController:(id)sender {
	[self.navigationController popViewControllerAnimated:YES];
}

- (void) onHttpConnectError:(HttpConnect*)up
{
    //itoast
    UIWindow *window = [[[UIApplication sharedApplication] windows] objectAtIndex:0];
    UIView *v = (UIView *)[window viewWithTag:TAG_iTOAST];
    if (!v) {
        iToast *msg = [[iToast alloc] initWithText:up.stringError];
        [msg setDuration:2000];
        [msg setGravity:iToastGravityCenter];
        [msg show];
        [msg release];
    }
    //	[CommonAlert alertWithTitle:@"에러" message:up.stringError];
	if (connect != nil)
	{
		[connect release];
		connect = nil;
	}
    
    [self postNetworkNoticeWithFrame:tableRect];

}

#pragma mark MainThreadProtocol delegate method

- (CgiStringList*) mainThreadRequestMore
{
	neighborCurrPage++;
	CgiStringList *strPostData = [[[CgiStringList alloc]init:@"&"] autorelease];
	[strPostData setMapString:@"svcId" keyvalue:SNS_IPHONE_SVCID];
    [strPostData setMapString:@"appVer" keyvalue:[ApplicationContext appVersion]];
	[strPostData setMapString:@"device" keyvalue:SNS_DEVICE_MOBILE_APP];
	[strPostData setMapString:@"snsId" keyvalue:userSnsID];
	[strPostData setMapString:@"av" keyvalue:[UserContext sharedUserContext].snsID];
	[strPostData setMapString:@"at" keyvalue:@"1"];
	[strPostData setMapString:@"currPage" keyvalue:[NSString stringWithFormat:@"%d",neighborCurrPage]];
	[strPostData setMapString:@"scale" keyvalue:@"50"];
	[strPostData setMapString:@"sortType" keyvalue:@"T"];

    [strPostData setMapString:@"listType" keyvalue:listType];
    
	return strPostData;
}

// 여기에 mainThreadRquestLatest가 없는 이유;
// API에서 최근 이웃에 대한 요청 자체가 지원되지 않기 때문이다.

-(NSString*) mainThreadRequestAddress
{
	return PROTOCOL_NEIGHBOR_LIST;
}

@end
