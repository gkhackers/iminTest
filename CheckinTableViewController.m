//
//  CheckinTableViewController.m
//  ImIn
//
//  Created by edbear on 10. 9. 12..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "CheckinTableViewController.h"
#import "PostList.h"
#import "TableCoverNoticeViewController.h"
#import "MemberInfo.h"

@implementation CheckinTableViewController

@synthesize owner;
@synthesize postList;
@synthesize infoView;
@synthesize isIncludeBadge;

#pragma mark -
#pragma mark Initialization

/*
 - (id)initWithStyle:(UITableViewStyle)style {
 // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
 if ((self = [super initWithStyle:style])) {
 }
 return self;
 }
 */


#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
	self.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	
	//	UIEdgeInsets scrollInset = ((UIScrollView*)self.view).contentInset;
	//	scrollInset.top = 0;
	//	[((UIScrollView*)self.view) setContentInset:scrollInset];
	
	[self requestFootPoiList];
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}


- (void)dealloc {
	[owner release];
	[postList release];
	
	[infoView release];
	
	[super dealloc];
	
}


// 마이홈 발도장 목록 가져오기 ------------------------------------------------------
- (void) requestFootPoiList
{
	self.postList = [[[PostList alloc] init] autorelease];
    postList.delegate = self;
    
    [postList.params addEntriesFromDictionary:
     [NSDictionary dictionaryWithObjectsAndKeys:owner.snsId, @"snsId",
      @"25", @"maxScale",
      @"1", @"relation",
      @"2", @"postType", nil]];
    
	[postList request];
}

- (void) apiFailed {
	MY_LOG(@"API 에러");
//    [CommonAlert alertWithTitle:@"알림" message:@"네트웍 연결을 확인해주세요."];
}

NSComparisonResult dateSort2delete(NSDictionary *s1, NSDictionary *s2, void *context) {
	return [[s2 objectForKey:@"regDate"] compare:[s1 objectForKey:@"regDate"]];
}

- (void) apiDidLoad:(NSDictionary *)result
{
	// postList
	if ([[result objectForKey:@"func"] isEqualToString:@"postList"]) {
		
		if (![[result objectForKey:@"result"] boolValue]) {
			// 공개되지 않은 발도장으로 생각하고 처리하면 되겠음.
			self.infoView = [[[TableCoverNoticeViewController alloc]initWithNibName:@"TableCoverNoticeViewController" bundle:nil] autorelease];
			
			infoView.line1.text = @"비공개 회원의 마이홈입니다~!";
			infoView.view.frame = self.view.frame;
			[self.tableView setTableHeaderView:infoView.view];
			
			return;
		}
		
		//[self.cellDataList removeAllObjects];
		
		NSArray* poiList = [result objectForKey:@"data"];
		
		for (NSDictionary *poiData in poiList) {
			// 있는지 검색한다. 있으면 댓글 갯수를 업데이트하고 아니면 추가한다.
			BOOL hasFound = NO;
			NSString* postId = [poiData objectForKey:@"postId"];
			for (NSDictionary* oldCell in cellDataList) {
				if ([[oldCell objectForKey:@"postId"] isEqualToString:postId]) {
					hasFound = YES;
				}
			}
			
			if (!hasFound) {
				// 못 찾았다면, 추가해준다.
				[self.cellDataList addObject:poiData];
			}
			if ( [owner.snsId isEqualToString:[UserContext sharedUserContext].snsID] ) {
				curPosition = @"3";
			} else {
				curPosition = @"4";
			}

		}
		
		[self.cellDataList sortUsingFunction:dateSort2delete context:nil];
				
		if ([self.cellDataList count] == 0) {
			self.infoView = [[[TableCoverNoticeViewController alloc] initWithNibName:@"TableCoverNoticeViewController" bundle:nil] autorelease];
			
			[UIView beginAnimations:nil context:nil];
			[UIView setAnimationDuration:1];
			UIEdgeInsets scrollInset = ((UIScrollView*)self.view).contentInset;
			scrollInset.top = 0;
			[((UIScrollView*)self.view) setContentInset:scrollInset];
			[UIView commitAnimations];
			
			infoView.view.frame = CGRectMake(0, 0, 320, 340);
			[self.view addSubview:infoView.view];
			
			if ( [owner.snsId isEqualToString:[UserContext sharedUserContext].snsID] )
			{ // 본인 발도장이 없는 경우.
				infoView.line1.text = @"아직 발도장 찍은 곳이 없습니다.";
				infoView.line2.text = @"발도장을 찍어 흔적을 남겨보세요.";
			}
			else {
				infoView.line1.text = [NSString stringWithFormat:@"%@님은 아직",owner.nickname];
				infoView.line2.text = @"발도장 찍은 곳이 없어요.";
			}
		} else {
			infoView.view.hidden = YES;
			infoView.view.alpha = 0;
			[infoView.view removeFromSuperview];
			UIEdgeInsets scrollInset = ((UIScrollView*)self.view).contentInset;
			scrollInset.top = -60;
			[((UIScrollView*)self.view) setContentInset:scrollInset];
			
			//아래 로직이 있으면 처음 글의 경우.. 같은 글이 두개가 나온다.
//			if ([self.cellDataList count] == 1) {
//				[self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];				
//			}
		}
		[self updateParameter];
		[self.tableView reloadData];

	}
	
}

#pragma mark -
#pragma mark MainThreadProtocol delegate method

- (CgiStringList*) mainThreadRequestMore
{
	CgiStringList* strPostData = [[[CgiStringList alloc]init:@"&"] autorelease];
	
	[strPostData setMapString:@"svcId" keyvalue:SNS_IPHONE_SVCID];
    [strPostData setMapString:@"appVer" keyvalue:[ApplicationContext appVersion]];
	[strPostData setMapString:@"device" keyvalue:SNS_DEVICE_MOBILE_APP];
	[strPostData setMapString:@"snsId" keyvalue:self.owner.snsId];
	[strPostData setMapString:@"av" keyvalue:[UserContext sharedUserContext].snsID];
	[strPostData setMapString:@"at" keyvalue:@"1"];
	[strPostData setMapString:@"level" keyvalue:@"1"];
	[strPostData setMapString:@"vm" keyvalue:@"A"];	// 뷰 모드 - A : auto
	[strPostData setMapString:@"relation" keyvalue:@"1"]; // 조회관계 - 1:본인
    [strPostData setMapString:@"postType" keyvalue:@"2"]; // 2: 포스트 + 뱃지 + 하트콘
	
	NSString* xPoiKey = nil;
	for(NSDictionary* data in cellDataList) {
		xPoiKey = [xPoiKey stringByAppendingString:[data objectForKey:@"poiKey"]];
		if (data != [cellDataList lastObject]) {
			xPoiKey = [xPoiKey stringByAppendingString:@"|"];
		}

	}
	if (xPoiKey != nil) {
		[strPostData setMapString:@"xPoiKey" keyvalue:xPoiKey];		
	}
	
	return strPostData;
}

- (CgiStringList*) mainThreadRequestLatest {
	return [self mainThreadRequestMore];
}

-(NSString*) mainThreadRequestAddress
{
	return PROTOCOL_POST_LIST;
}

- (void) request {
	[self requestFootPoiList];
}

@end

