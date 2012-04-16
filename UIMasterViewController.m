    //
//  UIMasterViewController.m
//  ImIn
//  path : myhome > master
//  Created by mandolin on 10. 9. 8..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "UIMasterViewController.h"
#import "macro.h"
#import "const.h"
#import "CgiStringList.h"
#import "UserContext.h"
#import "JSON.h"
#import "UIMasterWriteController.h"
#import "ViewControllers.h"
#import "POIDetailViewController.h"
#import "UIColumbusViewController.h"
#import "TutorialView.h"
#import "iToast.h"

@implementation UIMasterViewController 
@synthesize masterContent, tableRect, tutorial;
- (id)initWithUserNick:(NSString*)nick withSNSid:(NSString*)snsId
{
	self = [super init];
	
	self.tableRect = CGRectMake(0.0f, 30.0f+43.0f, 320.0f, 480.0f-83.0f-55.0f);
	strNick = [[NSString alloc] initWithString:nick];
	pageIndex = 1;
	connect = nil;
	isEnd=NO;
//	nonItemView = nil;
	masterContent = [[NSMutableArray alloc] init];
	strSnsId = [[NSString alloc] initWithString:snsId];
	
	if ([[UserContext sharedUserContext].snsID compare:strSnsId] == NSOrderedSame)
		isMyMaster = YES;
	else
		isMyMaster = NO;
	
	[self.navigationController setNavigationBarHidden:NO animated:NO];

	
	return self;

}

-(void)loadView {
	CGRect mFrame = [[UIScreen mainScreen] applicationFrame];
	UIView *contentView = [[UIView alloc] initWithFrame:mFrame];
	self.view = contentView;
	[contentView release];
	CGPoint frameSize = CGPointMake(mFrame.size.width, mFrame.size.height);
	nvView = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,frameSize.x,43)];
	[nvView setImage:[UIImage imageNamed:@"header_bg.png"]];
	title = [[UILabel alloc] initWithFrame:CGRectMake(60,0,180,40)];
	NSString* nickTitle = [NSString stringWithFormat:@"%@의 마스터",strNick];
	title.text = nickTitle;
	title.textAlignment = UITextAlignmentCenter;
	[title setAdjustsFontSizeToFitWidth:YES];
	title.backgroundColor = [UIColor clearColor];
	
	[nvView addSubview:title];
	[self.view addSubview:nvView];
	[nvView release];
	
	UIButton* backButton = [[UIButton alloc]initWithFrame:BACKBTN_FRAME];
	[backButton setImage:[UIImage imageNamed:@"header_prev.png"] forState:UIControlStateNormal];
	[backButton addTarget:self
				   action:@selector(donePopViewController:)
		 forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:backButton];
	[backButton release];
	
	MY_LOG( @"=============>  %@, %@", [UserContext sharedUserContext].snsID, strSnsId);
	//새소식이 탭으로 바뀌면서 마스터에서 무조건 콜럼버스를 보여줘야한다.
	//if (![[UserContext sharedUserContext].snsID isEqualToString:strSnsId]) 
	{
		UIButton* columbusButton = [[UIButton alloc]initWithFrame: CGRectMake(243, 5, 72, 32)];
		[columbusButton setImage:[UIImage imageNamed:@"btn_colum.png"] forState:UIControlStateNormal];
		[columbusButton addTarget:self
						   action:@selector(pushColumbusController:)
				 forControlEvents:UIControlEventTouchUpInside];
		[self.view addSubview:columbusButton];
		[columbusButton release];		
	}
	
	UIImageView* helpImg = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 43.0f, 320.0f, 30.0f)];
	[helpImg setImage:[UIImage imageNamed:@"master_toptext.png"]];
	[self.view addSubview:helpImg];
	[helpImg release];
	
	mainTableView = [[UITableView alloc] initWithFrame:tableRect style:UITableViewStylePlain];
	[mainTableView setDelegate:self];
	[mainTableView setDataSource:self];
	[mainTableView setSeparatorColor:RGB(181, 181, 181)];
	[self.view addSubview:mainTableView];
	//[mainTableView release];
	
//	nonItemView = nil;
	
	[self requestCaptainList];
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

- (void)viewWillAppear:(BOOL)animated {
	
}
- (void)dealloc {
	[masterContent release];
	[mainTableView release];
//	if (nonItemView != nil)
//	{
//		[nonItemView removeFromSuperview];
//		[nonItemView release];
//		nonItemView = nil;
//	}
	[strNick release];
	//[backButton removeFromSuperview];
	//[backButton release];
	//[title removeFromSuperview];
	[title release];
	//[doneButton removeFromSuperview];
	//[doneButton release];
	//[nvView release];
	//[strPostNum release];
	[strSnsId release];
	if (connect)
	{
		[connect stop];
		[connect release];
		connect = nil;
	}
    [tutorial release];
	[super dealloc];
}

- (void) donePopViewController:(id)sender {
	[self.navigationController popViewControllerAnimated:YES];
	
}

- (void) pushColumbusController:(id)sender
{
    UIColumbusViewController* vc = [[[UIColumbusViewController alloc] initWithNibName:@"UIColumbusViewController" bundle:nil] autorelease];
    vc.snsId = strSnsId;
    vc.nickname = strNick;
    
    [self.navigationController pushViewController:vc animated:YES];
}
// TableView Delegate
// Section Titles
- (NSString *)tableView:(UITableView *)mainTableView titleForHeaderInSection:(NSInteger)section
{
	return @"";
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)mainTableView 
{
	return 1; //[sectionArray count];
}

// Each row array object contains the members for that section
- (NSInteger)tableView:(UITableView *)mainTableView numberOfRowsInSection:(NSInteger)section 
{
	switch (section) 
	{
		case 0:
			/*if ([lastSendTextArray count]+1 < 5)
			 return 5;*/
			MY_LOG(@"ReportCellCnt ;: %d", [masterContent count]);
			return ([masterContent count]);
		default:
			return 0;
	}
}


// Heights per row
- (CGFloat)tableView:(UITableView *)mainTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{	
	return 61.0f;
	
}


// Return a cell for the ith row
- (UITableViewCell *)tableView:(UITableView *)mainTable cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSInteger row = [indexPath row];
	NSInteger section = [indexPath section];
	MasterViewCell *cell;
	switch (section) 
	{
		case 0:
			if (row < [masterContent count])
			{
				cell = (MasterViewCell*) [mainTable dequeueReusableCellWithIdentifier:@"postmaster"];
				
				if (!cell) {
                    cell = [[[MasterViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"postmaster"] autorelease];
					cell.selectionStyle = UITableViewCellSelectionStyleGray;
					//cell.selectionBa= nil;
					cell.backgroundView = nil;
					//cell.backgroundView = [[[UIView alloc] init] autorelease];
					cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
					[self FillCell:cell idx:row onMasterData:[masterContent objectAtIndex:row]  redraw:false];
				} else
				{
					[self FillCell:cell idx:row onMasterData:[masterContent objectAtIndex:row]  redraw:true];
				}
				
				
				return cell;
				
			}	
			
			break;
		default:
			break;
			
	}
	cell = (MasterViewCell*)[mainTable dequeueReusableCellWithIdentifier:@"any-cell"];
	if (cell == nil) {
		cell = [[[MasterViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"any-cell"] autorelease];
	}
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
	
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
	
	if( 0 == indexPath.section )
	{
		if ([masterContent count] == 0 || [masterContent count] < indexPath.row) {
			return;
		}
		// Navigation logic may go here. Create and push another view controller.
		 POIDetailViewController *detailViewController = [[POIDetailViewController alloc] initWithNibName:@"POIDetailViewController" bundle:nil];		
		 detailViewController.poiData = [masterContent objectAtIndex:indexPath.row];
		 [self.navigationController pushViewController:detailViewController animated:YES];
		 [detailViewController release];
		 
		 
	}
}

- (void) FillCell:(UITableViewCell*)aCell idx:(NSInteger)row onMasterData:(NSDictionary*)mt redraw:(BOOL)redraw
{
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	
	int mt_point = [[mt objectForKey:@"point"] intValue];
	int mt_point2nd = [[mt objectForKey:@"point2nd"] intValue];
	NSString* mt_poiName = [mt objectForKey:@"poiName"];
	
	if (redraw == false)
	{
		// 신호등
		CGRect tRect = CGRectMake(8.0f, 12.0f, 21.0f, 49.0f);
		UIImageView* signal = [[UIImageView alloc] initWithFrame:tRect];
		if (mt_point-mt_point2nd > 10 || mt_point2nd == 0)
			[signal setImage:[UIImage imageNamed:@"master_signal_green.png"]];
		else
			[signal setImage:[UIImage imageNamed:@"master_signal_red.png"]];
		signal.tag = 100001;
		[aCell.contentView addSubview:signal];
		[signal release];
		
		// 타이틀
		tRect = CGRectMake(36.0f, 10.0f, 240.0f, 22.0f);
		UILabel *title1 = [[UILabel alloc] initWithFrame:tRect];
		title1.tag = 100002;
		[title1 setText:mt_poiName];
		[title1 setTextAlignment:UITextAlignmentLeft];
		title1.font = [UIFont fontWithName:@"Helvetica-Bold" size:16.0f];
		title1.textColor = RGB(1,0x81,0xb0);
		title1.backgroundColor = [UIColor clearColor];
		CGRect frame = [title1 frame];
		CGSize size = [title1.text sizeWithFont:title1.font
								constrainedToSize:CGSizeMake(frame.size.width, 22.0f)
									lineBreakMode:UILineBreakModeWordWrap];
		if (size.width > 210.0f) size.width = 210.0f;
		frame.size.width = size.width;
		[title1 setFrame:frame];
		[aCell.contentView addSubview:title1];
		[title1 release];
		
		// 마스터마크
		tRect = CGRectMake(frame.origin.x+frame.size.width+2,10.0f,21.0f,18.0f);
		UIImageView* masterMark = [[UIImageView alloc] initWithFrame:tRect];
		[masterMark setImage:[UIImage imageNamed:@"master_list_icon.png"]];
		masterMark.tag = 100003;
		[aCell.contentView addSubview:masterMark];
		[masterMark release];
		
		// 내 포인트
		NSString* myPointStr = [NSString stringWithFormat:@"%dpoint",mt_point];
		tRect = CGRectMake(38.0f, 32.0f, 240.0f, 15.0f);
		UILabel *point = [[UILabel alloc] initWithFrame:tRect];
		point.tag = 100004;
		[point setText:myPointStr];
		[point setTextAlignment:UITextAlignmentLeft];
		point.font = [UIFont fontWithName:@"Helvetica" size:11.0f];
		point.textColor = RGB(0x55,0x55,0x55);
		point.backgroundColor = [UIColor clearColor];
		frame = [point frame];
		size = [point.text sizeWithFont:point.font
							  constrainedToSize:CGSizeMake(frame.size.width, 15.0f)
								  lineBreakMode:UILineBreakModeWordWrap];
		frame.size.width = size.width;
		[point setFrame:frame];
		[aCell.contentView addSubview:point];
		[point release];
		
		// 2등과 포인트 격차
		NSString* diffPointStr = [NSString stringWithFormat:@"(2등과의 격차 %dp)",mt_point-mt_point2nd];
		tRect = CGRectMake(frame.origin.x+frame.size.width+2,32.0f,200.0f,15.0f);
		UILabel *diffpoint = [[UILabel alloc] initWithFrame:tRect];
		diffpoint.tag = 100005;
		if (mt_point2nd == 0)
			[diffpoint setText:@""];
		else
			[diffpoint setText:diffPointStr];
		[diffpoint setTextAlignment:UITextAlignmentLeft];
		diffpoint.font = [UIFont fontWithName:@"Helvetica" size:11.0f];
		if (mt_point-mt_point2nd > 10 || mt_point2nd == 0)
			diffpoint.textColor = RGB(85,85,85);
		else
			diffpoint.textColor = RGB(0xD9,0x06,0x66);
		diffpoint.backgroundColor = [UIColor clearColor];
		[diffpoint setFrame:tRect];
		[aCell.contentView addSubview:diffpoint];
		[diffpoint release];
		
		/* if (isMyMaster)
		{// 마스터 쓰기 버튼
			UIButton* masterWriteBtn = [[UIButton alloc]initWithFrame:CGRectMake(275, 12, 37, 37)];
			NSString* tlStr = [NSString stringWithFormat:@"%d", row];
			[masterWriteBtn setTitle:tlStr forState:UIControlStateNormal];
			[masterWriteBtn setImage:[UIImage imageNamed:@"master_btn_word.png"] forState:UIControlStateNormal];
			masterWriteBtn.tag = 100006;
			[masterWriteBtn addTarget:self action:@selector(pushMasterWritePage:) forControlEvents:UIControlEventTouchUpInside];
			[aCell.contentView addSubview:masterWriteBtn];
			[masterWriteBtn release];
		} */
		
	} else
	{
		//신호등
		UIImageView* signal = (UIImageView*)[aCell.contentView viewWithTag:100001];
		if (mt_point-mt_point2nd > 10 || mt_point2nd == 0)
			[signal setImage:[UIImage imageNamed:@"master_signal_green.png"]];
		else
			[signal setImage:[UIImage imageNamed:@"master_signal_red.png"]];
		//타이틀
		UILabel* title1 = (UILabel *)[aCell.contentView viewWithTag:100002];
		[title1 setText:mt_poiName];
		CGRect frame = CGRectMake(37.0f, 10.0f, 240.0f, 22.0f);
		CGSize size = [title1.text sizeWithFont:title1.font
							  constrainedToSize:CGSizeMake(frame.size.width, 22.0f)
								  lineBreakMode:UILineBreakModeWordWrap];
		if (size.width > 210.0f) size.width = 210.0f;
		frame.size.width = size.width;
		[title1 setFrame:frame];
		//마스터마크
		UIImageView* masterMark = (UIImageView*)[aCell.contentView viewWithTag:100003];
		CGRect tRect = CGRectMake(frame.origin.x+frame.size.width+2,10.0f,21.0f,18.0f);
		[masterMark setFrame:tRect];
		//내포인트
		NSString* myPointStr = [NSString stringWithFormat:@"%dpoint",mt_point];
		frame = CGRectMake(38.0f, 32.0f, 240.0f, 15.0f);
		UILabel *point = (UILabel *)[aCell.contentView viewWithTag:100004];
		[point setText:myPointStr];
		size = [point.text sizeWithFont:point.font
							  constrainedToSize:CGSizeMake(frame.size.width, 15.0f)
								  lineBreakMode:UILineBreakModeWordWrap];
		frame.size.width = size.width;
		[point setFrame:frame];
		// 2등과 포인트 격차
		NSString* diffPointStr = [NSString stringWithFormat:@"(2등과의 격차 %dp)",mt_point-mt_point2nd];
		tRect = CGRectMake(frame.origin.x+frame.size.width+2,32.0f,200.0f,15.0f);
		UILabel *diffpoint = (UILabel *)[aCell.contentView viewWithTag:100005];
		if (mt_point-mt_point2nd > 10 || mt_point2nd == 0)
			diffpoint.textColor = RGB(85,85,85);
		else
			diffpoint.textColor = RGB(0xD9,0x06,0x66);
		if (mt_point2nd == 0)
			[diffpoint setText:@""];
		else 
			[diffpoint setText:diffPointStr];
		[diffpoint setFrame:tRect];
		
		/* if (isMyMaster)
		{// 마스터 쓰기 버튼
			UIButton* masterWriteBtn = (UIButton*)[aCell.contentView viewWithTag:100006];
			NSString* tlStr = [NSString stringWithFormat:@"%d", row];
			[masterWriteBtn setTitle:tlStr forState:UIControlStateNormal];
		} */
		
	}
	[pool release];
}

- (void) requestCaptainList
{
	
	CgiStringList* strPostData=[[CgiStringList alloc]init:@"&"];
	[strPostData setMapString:@"svcId" keyvalue:SNS_IPHONE_SVCID];
    [strPostData setMapString:@"appVer" keyvalue:[ApplicationContext appVersion]];
	[strPostData setMapString:@"device" keyvalue:SNS_DEVICE_MOBILE_APP];
	[strPostData setMapString:@"snsId" keyvalue:strSnsId];
	[strPostData setMapString:@"av" keyvalue:[UserContext sharedUserContext].snsID];
	[strPostData setMapString:@"at" keyvalue:@"1"];
	[strPostData setMapString:@"ct" keyvalue:@"json"];
	NSString* pageStr = [NSString stringWithFormat:@"%d",pageIndex];
	[strPostData setMapString:@"currPage" keyvalue:pageStr];
	MY_LOG(@"RequestProtocol:%@",[strPostData description]);
	//[strPostData setMapString:@"postId" keyvalue:postId];
	
	
	
	if (connect != nil)
	{
		[connect stop];
		[connect release];
		connect = nil;
	}
	
	connect = [[HttpConnect alloc] initWithURL: PROTOCOL_CAPTAIN_AREA_LIST
									  postData: [strPostData description]
									  delegate: self
								  doneSelector: @selector(onCaptainListDone:)    
								 errorSelector: @selector(onResultError:) 
							  progressSelector: nil
							isIndicatorVisible: YES];	
	
	[strPostData release];
}

- (void) onCaptainListDone:(HttpConnect*)up
{
	SBJSON* jsonParser = [SBJSON new];
	[jsonParser setHumanReadable:YES];
	NSDictionary* results = (NSDictionary *)[jsonParser objectWithString:up.stringReply error:NULL];
	[jsonParser release];
	
	NSNumber* resultNumber = (NSNumber*)[results objectForKey:@"result"];
	MY_LOG(@"PacketResult:%@", up.stringReply);	
	//[jsonParser release];
	
	if (connect != nil)
	{
		[connect release];
		connect = nil;
	}
	
	if ([resultNumber intValue] == 1)
	{ // 정상 처리
		[masterContent addObjectsFromArray:[results objectForKey:@"data"]];
		pageIndex++;
		[mainTableView reloadData];
	} else
	{ //에러처리
		[CommonAlert alertWithTitle:@"에러" message:[results objectForKey:@"description"]];
	}
	
	if ([masterContent count] == 0)
	{
        self.tutorial = [[[NSBundle mainBundle] loadNibNamed:@"TutorialView" owner:self options:nil] lastObject];
        [tutorial setFrame:CGRectMake(0.0f,43.0f,320.0f,480.0f-43.0f)];
        
        if ([[UserContext sharedUserContext].snsID isEqualToString:strSnsId]) {  //마이홈일 때
            [tutorial createTutorialView:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:2] forKey:@"status"]];
        } else {
            [tutorial createTutorialView:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithInt:9] , strSnsId, nil] forKeys:[NSArray arrayWithObjects:@"status", @"nickname", nil]]];
        }
        
        [self.view addSubview:tutorial];
                    
//			if (isMyMaster)
//			{	
//				nonItemText = [NSString stringWithFormat:@"%@님은 아직 마스터가 없어요~\n발도장을 찍어 마스터에 도전해 보세요.",strNick];
//				nonItemLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f,85.0f+106.0f+10.0f, 320.0f, 40.0f)];
//				[nonItemLabel setNumberOfLines:2];
//			}
//			else
//			{	
//				nonItemText = [NSString stringWithFormat:@"%@님은 아직 마스터가 없어요~",strNick];
//				nonItemLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f,85.0f+106.0f, 320.0f, 40.0f)];
//				[nonItemLabel setNumberOfLines:1];
//			}
	} else
	{
        self.tutorial = nil;
	}
}

- (void) onResultError:(HttpConnect*)up
{
    //itoast?
    UIWindow *window = [[[UIApplication sharedApplication] windows] objectAtIndex:0];
    UIView *v = (UIView *)[window viewWithTag:TAG_iTOAST];
    if (!v) {
        iToast *msg = [[iToast alloc] initWithText:@"마스터 목록을 가져오지 못했습니다~"];
        [msg setDuration:2000];
        [msg setGravity:iToastGravityCenter];
        [msg show];
        [msg release];
    }
//	[CommonAlert alertWithTitle:@"에러" message:@"마스터 목록을 가져오지 못했습니다~"];
	if (connect != nil)
	{
		[connect release];
		connect = nil;
	}
	
}

- (void) pushMasterWritePage:(id)sender
{
	if ([sender isKindOfClass:[UIButton class]])
	{
		UIButton* rcBtn = (UIButton*)sender;
		int nItem = [[rcBtn titleForState:UIControlStateNormal] intValue];
		//NSString* altStr = [NSString stringWithFormat:@"%@번째 아이템",[rcBtn titleForState:UIControlStateNormal]];
		//[CommonAlert alertWithTitle:@"test" message:altStr]; 
		NSDictionary* mc = [masterContent objectAtIndex:nItem];

		
		UIMasterWriteController* mw = [[UIMasterWriteController alloc] initWithNibName:@"UIMasterWriteController" bundle:nil];
		mw.poiKey = [mc objectForKey:@"poiKey"];
		
		UINavigationController *navController = [[[UINavigationController alloc] initWithRootViewController:mw] autorelease];
		[navController setNavigationBarHidden:YES];
		[self presentModalViewController:navController animated:YES];
		
		[mw release];
	}
	
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {

	if (isEnd && connect==nil) {
		[self requestCaptainList];
	}
	isEnd=NO;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	int scLimit = 480-83-55;
	//MY_LOG(@"%f, %f", scrollView.contentOffset.y + scLimit, scrollView.contentSize.height);
	if (scrollView.contentOffset.y + scLimit > scrollView.contentSize.height) {
		isEnd = YES;
	} else {
		isEnd = NO;
	}
	
}

@end
