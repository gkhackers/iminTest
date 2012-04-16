    //
//  UINoticeDetailController.m
//  ImIn
//
//  Created by mandolin on 10. 7. 21..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "macro.h"
#import "UINoticeDetailController.h"
#import "UserContext.h"
#import "CgiStringList.h"
#import "JSON.h"
#import "const.h"
#import "BlogAPI.h"

#define EMAIL_BTN_FRAME CGRectMake(68, 337, 170, 18)
#define PHONE_BTN_FRAME CGRectMake(93, 361, 125, 20)

@implementation UINoticeDetailController
@synthesize postId;
@synthesize blogAPI;

/**
 @brief 선택된 공지사항 값
 @return id
 */
- (id)initWithPostId:(NSString *)pId 
{
	if (self = [super init])
	{
		self.postId = pId;
	}
	return self;
}
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
	[self.navigationController setNavigationBarHidden:YES animated:NO];
	
	self.view = [[[UIView alloc]init] autorelease];
	[self.view setBackgroundColor:[UIColor whiteColor]];
	
	UIScrollView *scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 43, 320, 416)];
	[scrollView setContentSize:CGSizeMake(320, 417)];
	[self.view addSubview:scrollView];
	[scrollView release];
	
	UIImageView *headerView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"header_bg.png"]];
	[headerView setFrame:HEADERVIEW_FRAME];
	
	// 제목 문자열 라벨.
	UILabel* headlabel = [[UILabel alloc] initWithFrame:HEADERVIEW_FRAME];
	headlabel.text = @"공지/안내";
	[headlabel setTextAlignment:UITextAlignmentCenter];
	[headlabel setBackgroundColor:[UIColor clearColor]];
	[headlabel setFont:[UIFont systemFontOfSize:19.0f]];
	
	[headerView addSubview:headlabel];
	[headlabel release];

	[self.view addSubview:headerView];
	[headerView release];

	UIButton *backBtn = [[UIButton alloc]initWithFrame:BACKBTN_FRAME];
	[backBtn setImage:[UIImage imageNamed:@"header_prev.png"] forState:UIControlStateNormal];
	[backBtn addTarget:self
				action:@selector(popViewController:)
	  forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:backBtn];
	[backBtn release];
	
	UIView* bkLine = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 43.0f, 320.0f, 59.0f)];
	[bkLine setBackgroundColor:[UIColor colorWithRed:237/255.0 green:249/255.0 blue:252/255.0 alpha:1]];
	[self.view addSubview:bkLine];
	[bkLine release];
	
	UIView* bkLine2 = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 43+59.0f, 320.0f, 1.0f)];
	[bkLine2 setBackgroundColor:[UIColor colorWithRed:181/255.0 green:181/255.0 blue:181/255.0 alpha:1]];
	[self.view addSubview:bkLine2];
	[bkLine2 release];
	
	
	titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10,43.0f, 300.0f, 45.0f)];
	[titleLabel setTextAlignment:UITextAlignmentCenter];
	[titleLabel setTextColor:[UIColor colorWithRed:17/255.0 green:17/255.0 blue:17/255.0 alpha:1]];
	[titleLabel setBackgroundColor:[UIColor clearColor]];
	titleLabel.lineBreakMode=UILineBreakModeWordWrap;
	titleLabel.numberOfLines=1;
	titleLabel.adjustsFontSizeToFitWidth = YES;
	[titleLabel setFont:[UIFont systemFontOfSize:16.0f]];
	[self.view addSubview:titleLabel];
	[titleLabel release];
	
	timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,43+35, 320.0f, 14.0f)];
	[timeLabel setTextAlignment:UITextAlignmentCenter];
	[timeLabel setTextColor:[UIColor colorWithRed:0 green:145/255.0 blue:195/255.0 alpha:1]];
	[timeLabel setBackgroundColor:[UIColor clearColor]];
	[timeLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:11.0f]];
	[self.view addSubview:timeLabel];
	[timeLabel release];
	

	
	noticeWeb = [[UIWebView alloc] initWithFrame:CGRectMake(15.0f,117.0f, 290.0f, 275.0f)];
	[noticeWeb setBackgroundColor:[UIColor clearColor]];
	[self.view addSubview:noticeWeb];
	[noticeWeb release];

	[self requestPostData];
}

/*
 // Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
 - (void)viewDidLoad {
 [super viewDidLoad];
 }
 */

- (void) viewWillAppear:(BOOL)animated
{
	// 회전불가 설정
	//UserContext* userContext = [UserContext sharedUserContext];
    //userContext.bEnableRotate = NO;
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	[titleLabel release];
	[timeLabel release];
	[noticeWeb release];
	[postId release];
	if (connect != nil)
	{
		[connect stop];
		[connect release];
		connect = nil;
	}
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}



- (void)dealloc {
    [blogAPI release];
    [super dealloc];
}

// back 버튼 클릭하면 되돌아가야 한다.
- (void) popViewController:(id)sender {
	[self.navigationController popViewControllerAnimated:YES];
}


-(void) requestPostData
{
    self.blogAPI = [[[BlogAPI alloc] init] autorelease];
    blogAPI.delegate = self;
    [blogAPI.params addEntriesFromDictionary:[NSDictionary dictionaryWithObjectsAndKeys:@"json", @"ct", 
                                              @"view", @"type", 
                                              @"iminblog", @"blogId",
                                              postId, @"postId", nil]];
    
    [blogAPI requestWithAuth:NO withIndicator:YES];
    
//	CgiStringList* strPostData=[[[CgiStringList alloc]init:@"&"] autorelease];
//	[strPostData setMapString:@"svcId" keyvalue:SNS_IPHONE_SVCID];
//    [strPostData setMapString:@"appVer" keyvalue:[ApplicationContext appVersion]];
//	[strPostData setMapString:@"device" keyvalue:SNS_DEVICE_MOBILE_APP];		
//	[strPostData setMapString:@"ct" keyvalue:@"json"];
//	[strPostData setMapString:@"type" keyvalue:@"view"];
//	[strPostData setMapString:@"blogId" keyvalue:@"iminblog"];
//	[strPostData setMapString:@"postId" keyvalue:postId];
//	
//	if (connect != nil)
//	{
//		[connect stop];
//		[connect release];
//		connect = nil;
//	}
//
//	connect = [[HttpConnect alloc] initWithURL: PROTOCOL_BLOG_API
//									  postData: [strPostData description]
//									  delegate: self
//								  doneSelector: @selector(onNoticeDone:)    
//								 errorSelector: @selector(onResultError:) 
//							  progressSelector: nil
//							isIndicatorVisible: YES];	
	
}

- (void) apiFailed {
    [self.navigationController popViewControllerAnimated:NO];
}

- (void) apiDidLoad:(NSDictionary *)result {
    NSDictionary* data = [result objectForKey:@"data"];
    
	titleLabel.text = [NSString stringWithFormat:@"%@",[data objectForKey:@"title"]];
	
	NSString* tempTime = [NSString stringWithFormat:@"%@",[data objectForKey:@"makeDate"]];
	
	timeLabel.text = [NSString stringWithFormat:@"%@.%@.%@",
                      [tempTime substringWithRange:NSMakeRange(0,4)],
                      [tempTime substringWithRange:NSMakeRange(4,2)],
                      [tempTime substringWithRange:NSMakeRange(6,2)]];
	NSString* postData = [NSString stringWithFormat:@"<html><head/><body style=\"margin:0 0 0 0;font-size:13px;\">%@</body></html>",[data objectForKey:@"content"]];
	
	[noticeWeb loadHTMLString:postData baseURL:nil];
}

//- (void) onNoticeDone:(HttpConnect*)up
//{
//	SBJSON* jsonParser = [SBJSON new];
//	[jsonParser setHumanReadable:YES];
//	
//	NSDictionary* results = (NSDictionary *)[jsonParser objectWithString:up.stringReply error:NULL];
//	[jsonParser release];
//	
//	MY_LOG(@"BlogJSON Data:%@", up.stringReply);
//	if (connect != nil)
//	{
//		[connect release];
//		connect = nil;
//	}
//
//	NSDictionary* data = [results objectForKey:@"data"];
//
//	titleLabel.text = [NSString stringWithFormat:@"%@",[data objectForKey:@"title"]];
//	
//	NSString* tempTime = [NSString stringWithFormat:@"%@",[data objectForKey:@"makeDate"]];
//	
//	timeLabel.text = [NSString stringWithFormat:@"%@.%@.%@",
//			 [tempTime substringWithRange:NSMakeRange(0,4)],
//			 [tempTime substringWithRange:NSMakeRange(4,2)],
//			 [tempTime substringWithRange:NSMakeRange(6,2)]];
//	NSString* postData = [NSString stringWithFormat:@"<html><head/><body style=\"margin:0 0 0 0;font-size:13px;\">%@</body></html>",[data objectForKey:@"content"]];
//	
//	[noticeWeb loadHTMLString:postData baseURL:nil];
//	
//}
//
//- (void) onResultError:(HttpConnect*)up
//{
//	if (up.stringError != nil && [up.stringError compare:@""] != NSOrderedSame )
//		[CommonAlert alertWithTitle:@"에러" message:up.stringError];
//	
//	if (connect != nil)
//	{
//		[connect release];
//		connect = nil;
//	}
//	[self.navigationController popViewControllerAnimated:NO];
//}

@end
