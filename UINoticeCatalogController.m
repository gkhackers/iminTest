    //
//  UINoticeCatalogController.m
//  ImIn
//
//  Created by mandolin on 10. 7. 19..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "UINoticeCatalogController.h"
#import "macro.h"
#import "JSON.h"
#import "UINoticeDetailController.h"
#import "ViewControllers.h"
#import "CgiStringList.h"
#import "BlogAPI.h"

@implementation UINoticeCatalogController
@synthesize curPageNum;
@synthesize noticeArray;
@synthesize blogAPI;

- (id)init
{
	self = [super init];
	curPageNum = 0;
	isTop = NO;
	isEnd = NO;
	
	noticeArray = [[NSMutableArray alloc]init];

	CGRect mFrame = [[UIScreen mainScreen] applicationFrame];
	UIView *contentView = [[UIView alloc] initWithFrame:mFrame];
	//[contentView setEditable:NO];
	self.view = contentView;
	
	[self.view setBackgroundColor:[UIColor colorWithRed:237/255.0 green:249/255.0 blue:252/255.0 alpha:1]];
	[contentView release];
	CGPoint frameSize = CGPointMake(mFrame.size.width, mFrame.size.height);
	nvView = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,frameSize.x,43)];
	[nvView setImage:[UIImage imageNamed:@"header_bg.png"]];
	title = [[UILabel alloc] initWithFrame:CGRectMake(65,0,frameSize.x-130,43)];
	title.text = @"공지/안내";
	title.textAlignment = UITextAlignmentCenter;
	title.backgroundColor = [UIColor clearColor];
	
	[nvView addSubview:title];
	[self.view addSubview:nvView];
	[nvView release];
	
	backButton = [[UIButton alloc]initWithFrame:BACKBTN_FRAME];
	[backButton setImage:[UIImage imageNamed:@"header_prev.png"] forState:UIControlStateNormal];
	[backButton addTarget:self
				   action:@selector(popViewController:)
		 forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:backButton];
	
	CGRect frame = CGRectMake(0.0f, 43.0f, 320.0f, 370);
	mainTableView = [[UITableView alloc] initWithFrame:frame style:UITableViewStylePlain];
	[mainTableView setBackgroundColor:[UIColor colorWithRed:237/255.0 green:249/255.0 blue:252/255.0 alpha:1]];
	[mainTableView setSeparatorColor:RGB(181, 181, 181)];
	[mainTableView setDelegate:self];
	[mainTableView setDataSource:self];
	[self.view addSubview:mainTableView];
	[mainTableView release];
	
	
	[self.navigationController setNavigationBarHidden:NO animated:NO];
	
	[self getNotice];
	
	return self;
}

// back 버튼 클릭하면 되돌아가야 한다.
- (void) popViewController:(id)sender {
	[self.navigationController popViewControllerAnimated:YES];
}
/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/


// Implement loadView to create a view hierarchy programmatically, without using a nib.
/* - (void)loadView {
	 
}*/


/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/

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
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillDisappear:(BOOL)animated
{
	if (connect)
	{
		[connect stop];
		[connect release];
		connect = nil;
	}
}

- (void)dealloc {
	[backButton removeFromSuperview];
	[backButton release];
	[title removeFromSuperview];
	[title release];
	[noticeArray release];
    [blogAPI release];
    [super dealloc];
}

// mainTableView Deleagte

- (NSInteger)numberOfSectionsInTableView:(UITableView *)mainTableView 
{
	return 1; 
}

// Each row array object contains the members for that section
- (NSInteger)tableView:(UITableView *)mainTableView numberOfRowsInSection:(NSInteger)section 
{
	switch (section) 
	{
		case 0:
			return [noticeArray count];
		default:
			return 0;
	}
}

// Section Titles
- (NSString *)tableView:(UITableView *)mainTableView titleForHeaderInSection:(NSInteger)section
{
	return @"";
}	

// Heights per row
- (CGFloat)tableView:(UITableView *)mainTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 45.0f;
}


// Return a cell for the ith row
- (UITableViewCell *)tableView:(UITableView *)mainTable cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSInteger row = [indexPath row];
	NSInteger section = [indexPath section];
	UITableViewCell *cell;
	
	switch (section) 
	{
		case 0:
			if (row < [noticeArray count])
			{
				cell = [mainTable dequeueReusableCellWithIdentifier:@"notice"];
				if (!cell) {
					cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"notice"] autorelease];
					cell.selectionStyle = UITableViewCellSelectionStyleNone;
					//cell.backgroundView = [[[UIView alloc] init] autorelease];
					cell.backgroundColor = [UIColor colorWithRed:237/255.0 green:249/255.0 blue:252/255.0 alpha:1];
					[self FillCell:cell index:row noticeData:[noticeArray objectAtIndex:row]  redraw:false];
				} else
				{
					[self FillCell:cell index:row noticeData:[noticeArray objectAtIndex:row]  redraw:true];
				}
				/* if (selectedRow == row && selectedRow != -1) {
					cell.backgroundView.backgroundColor =[UIColor yellowColor];
				} else */ 
					cell.backgroundView.backgroundColor = [UIColor whiteColor]; 
				
				return cell;
				
			}	
			
			break;
		default:
			break;
			
	}
	cell = [mainTable dequeueReusableCellWithIdentifier:@"any-cell"];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"any-cell"] autorelease];
	}
	return cell;
}

/**
 @brief 공지사항 리스트에서 cell에 채워져야 할 공지사항 하나하나의 상세 데이타 값
 @param aCell 공지사항만큼 cell채워넣을때 그 채워져야 할 cell index
 @param row 공지사항 list index
 @param noticeArr 공지사항 리스트 어레이 데이타 
 @param redraw cell redraw여부
 @return void 
 */
- (void) FillCell:(UITableViewCell*)aCell index:(NSInteger)row noticeData:(NSDictionary*)noticeArr redraw:(BOOL)redraw
{
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];

	NSString* tempTime = [noticeArr objectForKey:@"makeDate"];
	NSString* timeStr = [NSString stringWithFormat:@"%@.%@.%@",
						 [tempTime substringWithRange:NSMakeRange(0,4)],
						 [tempTime substringWithRange:NSMakeRange(4,2)],
						 [tempTime substringWithRange:NSMakeRange(6,2)]];
	NSString* titleStr = [noticeArr objectForKey:@"title"];

#ifdef APP_STORE_FINAL_OFF
	NSString* postIdStr = [noticeArr objectForKey:@"postId"];
	
	MY_LOG(@"BlogData:time = %@, title = %@(postId = %@)", timeStr, titleStr, postIdStr);
#endif		
	if (redraw == false)
	{
		CGRect tRect1 = CGRectMake(12.0f, 5.0f, 60.0f, 36.0f);
		UILabel *title1 = [[UILabel alloc] initWithFrame:tRect1];
		title1.tag = 56;
		[title1 setText:timeStr];
		[title1 setTextAlignment:UITextAlignmentLeft];
		[title1 setFont: [UIFont fontWithName:@"Helvetica-Bold" size:11.0f]];
		[title1 setTextColor:[UIColor colorWithRed:0 green:145/255.0 blue:195/255.0 alpha:1]];
		[title1 setBackgroundColor:[UIColor clearColor]];
		
		CGRect tRect2 = CGRectMake(78.0f, 5.0f, 230.0f, 36.0f);
		UILabel *title2 = [[UILabel alloc] initWithFrame:tRect2];
		title2.tag = 57;

		[title2 setText:titleStr];
		title2.lineBreakMode=UILineBreakModeWordWrap;
		title2.numberOfLines=2;
		[title2 setFont:[UIFont systemFontOfSize:14.0f]];
		[title2 setTextColor:[UIColor colorWithRed:17/255.0 green:17/255.0 blue:17/255.0 alpha:1]];
		[title2 setBackgroundColor:[UIColor clearColor]];	
				
		// Add to cell
		[aCell.contentView addSubview:title1];
		[aCell.contentView addSubview:title2];
		
		[title1 release];
		[title2 release];

	} else
	{
		UILabel *title1 = (UILabel *)[aCell.contentView viewWithTag:56];
		[title1 setText:timeStr];
		UILabel *title2 =  (UILabel *)[aCell.contentView viewWithTag:57];
		[title2 setText:titleStr];
	}
	[pool release];
} 

// Respond to user selection based on the cell type
- (void)tableView:(UITableView *)mainTable didSelectRowAtIndexPath:(NSIndexPath *)newIndexPath
{

	int row = [newIndexPath row];
	if ([noticeArray count] == 0 || row >[noticeArray count]) 
		return;
	
	UINoticeDetailController* ndc = [[UINoticeDetailController alloc] initWithPostId:[[noticeArray objectAtIndex:row] objectForKey:@"postId"]];  
	[[self navigationController] pushViewController:ndc animated:YES];

	[ndc release];
}

#pragma mark -
#pragma mark Notice 
/**
 @brief 공지사항 리스트 가져오기
 @return void
 */
-(void) getNotice
{
    self.blogAPI = [[[BlogAPI alloc] init] autorelease];
    blogAPI.delegate = self;
    [blogAPI.params addEntriesFromDictionary:[NSDictionary dictionaryWithObjectsAndKeys:@"json", @"ct",
                                              @"list", @"type",
                                              @"iminblog", @"blogId", 
                                              @"3064632", @"categoryId", 
                                              [NSString stringWithFormat:@"%d",curPageNum], @"currPage", nil]];
    
    [blogAPI requestWithAuth:NO withIndicator:YES];
    
//	CgiStringList* strPostData=[[CgiStringList alloc]init:@"&"];
//	[strPostData setMapString:@"svcId" keyvalue:SNS_IPHONE_SVCID];
//    [strPostData setMapString:@"appVer" keyvalue:[ApplicationContext appVersion]];
//	[strPostData setMapString:@"device" keyvalue:SNS_DEVICE_MOBILE_APP];		
//	[strPostData setMapString:@"ct" keyvalue:@"json"];
//	[strPostData setMapString:@"type" keyvalue:@"list"];
//	[strPostData setMapString:@"blogId" keyvalue:@"iminblog"];
//	[strPostData setMapString:@"categoryId" keyvalue:@"3064632"];
////    [strPostData setMapString:@"av" keyvalue:[UserContext sharedUserContext].snsID];
////    [strPostData setMapString:@"at" keyvalue:@"1"];
//	[strPostData setMapString:@"currPage" keyvalue:[NSString stringWithFormat:@"%d",curPageNum]];  
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
//	
//	[strPostData release];
}

- (void) apiFailed {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) apiDidLoad:(NSDictionary *)result {
	if (![[result objectForKey:@"errCode"] isEqualToString:@"000"]) { //에러처리
		[CommonAlert alertWithTitle:@"에러" message:[result objectForKey:@"description"]];
		return;
	}
	
	NSDictionary* datas = [result objectForKey:@"data"];
	NSArray* resultList = [datas objectForKey:@"posts"];
	
	int lastCellIndex = [noticeArray count] - 3;
	if (lastCellIndex < 0) {
		lastCellIndex = 0;
	}
    
	[noticeArray addObjectsFromArray:[datas objectForKey:@"posts"]];// 리스트를 통채로 받는다.
	MY_LOG(@"noticeArray count = %d, lastCellIndex = %d", [noticeArray count], lastCellIndex);
	curPageNum++;
	[mainTableView reloadData];
	
	if ([resultList count] > 0 && [noticeArray count] > 0) {
		[mainTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:lastCellIndex inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
	}
}

//- (void) onNoticeDone:(HttpConnect*)up
//{
//	SBJSON* jsonParser = [SBJSON new];
//	[jsonParser setHumanReadable:YES];
//	
//	NSDictionary* results = (NSDictionary *)[jsonParser objectWithString:up.stringReply error:NULL];
//	[jsonParser release];
//	MY_LOG(@"BlogJSON Data:%@", up.stringReply);
//	if (connect != nil)
//	{
//		[connect release];
//		connect = nil;
//	}
//	
//	if (![[results objectForKey:@"errCode"] isEqualToString:@"000"]) { //에러처리
//		[CommonAlert alertWithTitle:@"에러" message:[results objectForKey:@"description"]];
//		return;
//	}
//	
//	NSDictionary* datas = [results objectForKey:@"data"];
//	NSArray* resultList = [datas objectForKey:@"posts"];
//	
//	int lastCellIndex = [noticeArray count] - 3;
//	if (lastCellIndex < 0) {
//		lastCellIndex = 0;
//	}
//
//	[noticeArray addObjectsFromArray:[datas objectForKey:@"posts"]];// 리스트를 통채로 받는다.
//	MY_LOG(@"noticeArray count = %d, lastCellIndex = %d", [noticeArray count], lastCellIndex);
//	curPageNum++;
//	[mainTableView reloadData];
//	
//	if ([resultList count] > 0 && [noticeArray count] > 0) {
//		[mainTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:lastCellIndex inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
//	}
//}
//
//- (void) onResultError:(HttpConnect*)up
//{
//	if (up.stringError != nil && [up.stringError compare:@""] != NSOrderedSame ) {
//		[CommonAlert alertWithTitle:@"에러" message:up.stringError];
//    }
//	
//	if (connect != nil)
//	{
//		[connect release];
//		connect = nil;
//	}
//	
//	[self.navigationController popViewControllerAnimated:YES];
//}

#pragma mark -
#pragma mark UIScrollView delegate

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {


	if (isEnd) {
		[self requestLatest];
		return;
	}

}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {

	if (scrollView.contentOffset.y < 0) {
		isTop = YES;
	} else {
		isTop = NO;
	}
	
	//MY_LOG(@"%f, %f", scrollView.contentOffset.y + mainTableView.frame.size.height + 10, scrollView.contentSize.height);
	
	if (scrollView.contentOffset.y + mainTableView.frame.size.height + 10 > scrollView.contentSize.height) {
		isEnd = YES;
	} else {
		isEnd = NO;
	}	
}

- (void) requestLatest {
	[self getNotice];
	isEnd = NO;
}

@end
