    //
//  UIPostReportViewController.m
//  ImIn
//
//  Created by mandolin on 10. 9. 1..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "UIPostReportViewController.h"
#import "macro.h"
#import "const.h"
#import "CgiStringList.h"
#import "UserContext.h"
#import "JSON.h"

@implementation UIPostReportViewController
@synthesize reportContent;
- (id)init
{
	self = [super init];
	catIndex = -1;
	postId = nil;
	cmtId = nil;
	connect = nil;
	CGRect mFrame = [[UIScreen mainScreen] applicationFrame];
	UIView *contentView = [[UIView alloc] initWithFrame:mFrame];
	self.view = contentView;
	[contentView release];
	CGPoint frameSize = CGPointMake(mFrame.size.width, mFrame.size.height);
	nvView = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,frameSize.x,43)];
	[nvView setImage:[UIImage imageNamed:@"header_bg.png"]];
	title = [[UILabel alloc] initWithFrame:CGRectMake(65,0,frameSize.x-130,43)];
	title.text = @"신고하기";
	title.textAlignment = UITextAlignmentCenter;
	title.backgroundColor = [UIColor clearColor];
	
	[nvView addSubview:title];
	[self.view addSubview:nvView];
	[nvView release];
	
	backButton = [[UIButton alloc]initWithFrame:BACKBTN_FRAME];
	[backButton setImage:[UIImage imageNamed:@"header_prev.png"] forState:UIControlStateNormal];
	[backButton addTarget:self
				   action:@selector(donePopViewController:)
		 forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:backButton];
	[backButton release];
	self.reportContent = [NSMutableArray arrayWithObjects: @"음란성", @"반사회적", @"욕설 및 비방성", @"상업성 광고", @"도배", @"저작권", @"폭력성", @"개인정보", @"명예훼손", @"악성코드", @"권리침해", nil];
	CGRect frame = CGRectMake(0.0f, 43.0f, 320.0f,480.0f-63.0f);
	mainTableView = [[UITableView alloc] initWithFrame:frame style:UITableViewStyleGrouped];
	[mainTableView setBackgroundColor:RGB(239, 239, 239)];
	[mainTableView setDelegate:self];
	[mainTableView setDataSource:self];
	[self.view addSubview:mainTableView];
	[mainTableView release];
	
	doneButton = [[UIButton alloc]initWithFrame:DONEBTN_FRAME];
	[doneButton setImage:[UIImage imageNamed:@"btntop_confirm_gray.png"] forState:UIControlStateNormal];
	[doneButton addTarget:self
				   action:@selector(requestPolice:)
		 forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:doneButton];
	[doneButton release];
	[self.navigationController setNavigationBarHidden:NO animated:NO];
	return self;
} 

- (void) setPostId:(NSString*)pId
{
	if (postId == nil)
	{
		postId = [[NSString alloc] initWithString:pId];
	}
}

- (void) setCmtId:(NSString*)cId
{
	if (cmtId == nil)
	{
		cmtId = [[NSString alloc] initWithString:cId];
	}
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
	[reportContent release];
	//[mainTableView release];
	//[backButton removeFromSuperview];
	//[backButton release];
	//[title removeFromSuperview];
	[title release];
	//[doneButton removeFromSuperview];
	//[doneButton release];
	//[nvView release];
	[strPostNum release];
	if (connect)
	{
		[connect stop];
		[connect release];
		connect = nil;
	}
	if (postId)
	{
		[postId release];
	}
	if (cmtId)
	{
		[cmtId release];
	}
    [super dealloc];
}

- (void) donePopViewController:(id)sender {
	[self.navigationController popViewControllerAnimated:YES];
	
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
			MY_LOG(@"ReportCellCnt ;: %d", [reportContent count]);
			return ([reportContent count]);
		default:
			return 0;
	}
}


// Heights per row
- (CGFloat)tableView:(UITableView *)mainTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{	
	return 48.0f;
	
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
			if (row < [reportContent count])
			{
				cell = [mainTable dequeueReusableCellWithIdentifier:@"postreport"];
				
				if (!cell) {
					cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"postreport"] autorelease];
					cell.selectionStyle = UITableViewCellSelectionStyleGray;
					//cell.backgroundView = [[[UIView alloc] init] autorelease];
										
					[self FillCell:cell withSender:[reportContent objectAtIndex:row]  redraw:false];
				} else
				{
					[self FillCell:cell withSender:[reportContent objectAtIndex:row]  redraw:true];
				}
				
				if (row == catIndex)
				{
					cell.accessoryType = UITableViewCellAccessoryCheckmark; 
				} else
				{
					cell.accessoryType = UITableViewCellAccessoryNone;
				}
				
				
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    if (catIndex == indexPath.row && catIndex != -1) {
        return;
    }
    NSIndexPath *oldIndexPath = [NSIndexPath indexPathForRow:catIndex inSection:0];
	
    UITableViewCell *newCell = [tableView cellForRowAtIndexPath:indexPath];
    if (newCell.accessoryType == UITableViewCellAccessoryNone) {
        newCell.accessoryType = UITableViewCellAccessoryCheckmark;
	}
	
    UITableViewCell *oldCell = [tableView cellForRowAtIndexPath:oldIndexPath];
    if (oldCell.accessoryType == UITableViewCellAccessoryCheckmark) {
        oldCell.accessoryType = UITableViewCellAccessoryNone;
    }
	catIndex = indexPath.row;
}

- (void) FillCell:(UITableViewCell*) aCell withSender:(NSString*)sender redraw:(BOOL)redraw
{
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	
	if (redraw == false)
	{
		// Sender
		CGRect tRect1 = CGRectMake(12.0f, 0.0f, 200.0f, 48.0f);
		UILabel *title1 = [[UILabel alloc] initWithFrame:tRect1];
		title1.tag = 56;
		[title1 setText:sender];
		[title1 setTextAlignment:UITextAlignmentLeft];
		[title1 setFont: [UIFont fontWithName:@"Helvetica" size:18.0f]];
		[title1 setTextColor:[UIColor blackColor]];
		[title1 setBackgroundColor:[UIColor clearColor]];

		[aCell.contentView addSubview:title1];
		[title1 release];
	} else
	{
		UILabel *title1 = (UILabel *)[aCell.contentView viewWithTag:56];
		[title1 setText:sender];
		
	}
	[pool release];
}

- (void) requestPolice:(id)sender
{
	if (catIndex == -1) 
	{
		[CommonAlert alertWithTitle:@"알림" message:@"신고 사유를 선택하지 않으셨어요."]; 
		return;
	}
	if (postId == nil) return;
	CgiStringList* strPostData=[[CgiStringList alloc]init:@"&"];
	[strPostData setMapString:@"svcId" keyvalue:SNS_IPHONE_SVCID];
    [strPostData setMapString:@"appVer" keyvalue:[ApplicationContext appVersion]];
	[strPostData setMapString:@"device" keyvalue:SNS_DEVICE_MOBILE_APP];
	[strPostData setMapString:@"snsId" keyvalue:[UserContext sharedUserContext].snsID];
	[strPostData setMapString:@"av" keyvalue:[UserContext sharedUserContext].snsID];
	[strPostData setMapString:@"at" keyvalue:@"1"];
	[strPostData setMapString:@"ct" keyvalue:@"json"];
	[strPostData setMapString:@"postId" keyvalue:postId];
	
	if (catIndex < 9)
	{
		NSString* policeCode = [NSString stringWithFormat:@"0%d",catIndex+1];
		[strPostData setMapString:@"policeCode" keyvalue:policeCode];
	} else
	{
		NSString* policeCode = [NSString stringWithFormat:@"%d",catIndex+1];
		[strPostData setMapString:@"policeCode" keyvalue:policeCode];
	}
	if (cmtId || [cmtId compare:@""] != NSOrderedSame)
		[strPostData setMapString:@"cmtId" keyvalue:cmtId]; 
	//[strPostData setMapString:@"cmtId" keyvalue:@"iminblog"];
	//[strPostData setMapString:@"postId" keyvalue:postId];
	MY_LOG(@"신고 프로토콜: %@", [strPostData description]);
	if (connect != nil)
	{
		[connect stop];
		[connect release];
		connect = nil;
	}
	
	connect = [[HttpConnect alloc] initWithURL: PROTOCOL_POLICE
									  postData: [strPostData description]
									  delegate: self
								  doneSelector: @selector(onPoliceDone:)    
								 errorSelector: @selector(onResultError:) 
							  progressSelector: nil
							isIndicatorVisible: YES];	
	
	[strPostData release];
}

- (void) onPoliceDone:(HttpConnect*)up
{
	SBJSON* jsonParser = [SBJSON new];
	[jsonParser setHumanReadable:YES];
	NSDictionary* results = (NSDictionary *)[jsonParser objectWithString:up.stringReply error:NULL];
	[jsonParser release];
	
	NSNumber* resultNumber = (NSNumber*)[results objectForKey:@"result"];
	
	
	if (connect != nil)
	{
		[connect release];
		connect = nil;
	}
	
	if ([resultNumber intValue] == 1)
	{ // 정상 처리
		[CommonAlert alertWithTitle:@"에러" message:@"정상적으로 신고 처리 되었습니다. 빠른시간 내 운영자 확인 후 조치하도록 하겠습니다."];
		[self.navigationController popViewControllerAnimated:YES];
	} else
	{ //에러처리
		[CommonAlert alertWithTitle:@"에러" message:[results objectForKey:@"description"]];
	}
}

- (void) onResultError:(HttpConnect*)up
{
	[CommonAlert alertWithTitle:@"에러" message:@"신고 등록에 실패하였습니다."];
	if (connect != nil)
	{
		[connect release];
		connect = nil;
	}
	
}
@end
