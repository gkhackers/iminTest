//
//  TwitterInvitationViewController.m
//  ImIn
//
//  Created by choipd on 10. 7. 30..
//  Copyright 2010 edbear. All rights reserved.
//

#import "SNSInvitationViewController.h"
#import "UserContext.h"
#import "CgiStringList.h"
#import "HttpConnect.h"
#import "JSON.h"
#import "CommonAlert.h"
#import "SNSInvitationTableCell.h"
#import "macro.h"


@implementation SNSInvitationViewController

@synthesize cellDataList, cpCode, isLoaded;


- (void)viewDidLoad {
    [super viewDidLoad];
	currPage = 1;
	scale = 25;
	nickNameToSearch = @"";
	isLoaded = NO;
	isEnd = NO;

	cellDataList = [[NSMutableArray alloc] initWithCapacity:100];
	
	[myTableView setSeparatorColor:RGB(181, 181, 181)];
	
}

- (void) viewWillAppear:(BOOL)animated {
	if (!isLoaded) {
		[cellDataList removeAllObjects];
		[self request];
	}
	[myTableView reloadData];
}

- (void) viewWillDisappear:(BOOL)animated {
	if (connect1 != nil)
	{
		[connect1 stop];
		[connect1 release];
		connect1 = nil;
	}
	
	if (connect2 != nil)
	{
		[connect2 stop];
		[connect2 release];
		connect2 = nil;
	}
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [cellDataList count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	if ([cellDataList count] < indexPath.row) {	// cellDataList를 미쳐 가져오기 전에 테이블 뷰를 그려줘야 하는 문제를 방지하기 위해 삽입한 조건
		static NSString *CellIdentifier = @"Cell";
		
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		if (cell == nil) {
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		}
		
		// Configure the cell...
		
		return cell;
	} else {
		static NSString *CellIdentifier2 = @"SNSInvitationTableCell";
		
		SNSInvitationTableCell *cell = (SNSInvitationTableCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier2];
		if (cell == nil) {
			//			MY_LOG(@"Cell created");
			
			NSArray* nibObjects = [[NSBundle mainBundle] loadNibNamed:@"SNSInvitationTableCell" owner:nil options:nil];
			
			for (id currentObject in nibObjects) {
				if([currentObject isKindOfClass:[SNSInvitationTableCell class]]) {
					cell = (SNSInvitationTableCell*) currentObject;
					
					NSString* className = NSStringFromClass([self class]);
					
					if ([className isEqualToString:@"FBInvitationViewController"]) {
						cell.cellType = IMIN_CELLTYPE_INVITE_FACEBOOK;
					} else if ([className isEqualToString:@"PhoneNeighborViewController"]) {
						cell.cellType = IMIN_CELLTYPE_INVITE_PHONEBOOK;
					} else if ([className isEqualToString:@"TwitterInvitationViewController"]) {
						cell.cellType = IMIN_CELLTYPE_INVITE_TWITTER;
					} else {
						cell.cellType = IMIN_CELLTYPE_UNKNOWN;
					}


					
				}
			}
		}
		
		if ([cellDataList count] > indexPath.row) { // cellDataList를 미쳐 가져오기 전에 테이블 뷰를 그려줘야 하는 문제를 방지하기 위해 삽입한 조건
			cell.cellDataList = cellDataList;
			cell.cellDataListIndex = indexPath.row;
			NSDictionary* cellData = [cellDataList objectAtIndex:indexPath.row];
			[cell redrawCellWithDictionary:cellData];
		}
		
		return cell;
	}
}



- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

	if ([cellDataList count] < indexPath.row) {
		return 0.0f;
	}
	
	NSDictionary* cellData = [cellDataList objectAtIndex:indexPath.row];
	if ([[cellData objectForKey:@"snsId"] isEqualToString:@""]) {
		return 66;
	} else {
		return 76 + 4;
	}

	
}



#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	MY_LOG(@"selected");

	
	[self.navigationController dismissModalViewControllerAnimated:YES];
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
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
    [super dealloc];
}

- (IBAction) popViewController {
	[self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark requst twitter neighbor
- (void) request
{
	UserContext* userContext = [UserContext sharedUserContext];
    
	CgiStringList* strPostData=[[CgiStringList alloc]init:@"&"];
	[strPostData setMapString:@"svcId" keyvalue:SNS_IPHONE_SVCID];
    [strPostData setMapString:@"appVer" keyvalue:[ApplicationContext appVersion]];
	[strPostData setMapString:@"device" keyvalue:SNS_DEVICE_MOBILE_APP];	
	[strPostData setMapString:@"at" keyvalue:@"1"];
	[strPostData setMapString:@"av" keyvalue:userContext.snsID];
	[strPostData setMapString:@"nickName" keyvalue:nickNameToSearch];
	[strPostData setMapString:@"cpCode" keyvalue:cpCode];
	[strPostData setMapString:@"isSnsUser" keyvalue:@"2"];
	[strPostData setMapString:@"scale" keyvalue:[NSString stringWithFormat:@"%d", scale]];
	[strPostData setMapString:@"currPage" keyvalue:[NSString stringWithFormat:@"%d", currPage]];
	
	if (connect1 != nil)
	{
		[connect1 stop];
		[connect1 release];
		connect1 = nil;
	}
	
	connect1 = [[HttpConnect alloc] initWithURL:PROTOCOL_CP_NEIGHBOR_LIST
									   postData: [strPostData description]
									   delegate: self
								   doneSelector: @selector(onCpNeighborListTransDone:)
								  errorSelector: @selector(onCpNeighborListResultError:)
							   progressSelector: nil];
	[strPostData release];
}

- (void) onCpNeighborListTransDone:(HttpConnect*)up 
{
	MY_LOG(@"=== CpNeighborList:\n\n %@\n\n", up.stringReply);
	SBJSON* jsonParser = [SBJSON new];
	[jsonParser setHumanReadable:YES];
	
	NSDictionary* results = (NSDictionary *)[jsonParser objectWithString:up.stringReply error:NULL];
	[jsonParser release];
	
	if (connect1 != nil)
	{
		[connect1 release];
		connect1 = nil;
	}
	
	NSNumber* resultNumber = (NSNumber*)[results objectForKey:@"result"];
	
	if ([resultNumber intValue] == 0) { //에러처리
		[CommonAlert alertWithTitle:@"에러" message:[results objectForKey:@"description"]];
		return;
	} else {
		isLoaded = YES;
		NSArray* resultList = [results objectForKey:@"data"];
		for (NSDictionary* data in resultList) {
			[cellDataList addObject:data];
		}
	}
	[myTableView reloadData];
	
	scale = [(NSNumber*)[results objectForKey:@"scale"] intValue];
	currPage = [(NSNumber*)[results objectForKey:@"currPage"] intValue];
	totalCnt = [(NSNumber*)[results objectForKey:@"totalCnt"] intValue];
}

- (void) onCpNeighborListResultError:(HttpConnect*)connect 
{
	MY_LOG(@"%@", connect.stringReply);	
}


- (void) doRequestMore 
{
	int lastPage = totalCnt / scale + 1;
	if (currPage >= lastPage) {
		//[CommonAlert alertWithTitle:@"안내" message:@"마지막 페이지입니다."];
		return;
	}
	currPage++;
	[self request];
}


- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
	if (isEnd) {
		[self doRequestMore];
	}
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
//	MY_LOG(@"%f, %f", scrollView.contentOffset.y + 378, scrollView.contentSize.height);
	if (scrollView.contentOffset.y + 378 > scrollView.contentSize.height) {
		isEnd = YES;
	} else {
		isEnd = NO;
	}
}


- (void) requestCpRefresh
{
	UserContext* userContext = [UserContext sharedUserContext];
	
	CgiStringList* strPostData=[[CgiStringList alloc]init:@"&"];
	[strPostData setMapString:@"svcId" keyvalue:SNS_IPHONE_SVCID];
    [strPostData setMapString:@"appVer" keyvalue:[ApplicationContext appVersion]];
	[strPostData setMapString:@"device" keyvalue:SNS_DEVICE_MOBILE_APP];	
	[strPostData setMapString:@"at" keyvalue:@"1"];
	[strPostData setMapString:@"av" keyvalue:userContext.snsID];
	[strPostData setMapString:@"cpCode" keyvalue:cpCode];
	[strPostData setMapString:@"isSnsUser" keyvalue:@"2"];
	[strPostData setMapString:@"isResetNeighbor" keyvalue:@"1"];
	
	if (connect2 != nil)
	{
		[connect2 stop];
		[connect2 release];
		connect2 = nil;
	}
	
	connect2 = [[HttpConnect alloc] initWithURL:PROTOCOL_CP_NEIGHBOR_LIST
									   postData: [strPostData description]
									   delegate: self
								   doneSelector: @selector(onCpNeighborListRefreshTransDone:)
								  errorSelector: @selector(onCpNeighborListRefreshResultError:)
							   progressSelector: nil];
	[strPostData release];
}

- (void) onCpNeighborListRefreshTransDone:(HttpConnect*)up 
{
	MY_LOG(@"=== CpNeighborList:\n\n %@\n\n", up.stringReply);
	SBJSON* jsonParser = [SBJSON new];
	[jsonParser setHumanReadable:YES];
	
	NSDictionary* results = (NSDictionary *)[jsonParser objectWithString:up.stringReply error:NULL];
	[jsonParser release];
	
	if (connect2 != nil)
	{
		[connect2 release];
		connect2 = nil;
	}
	
	NSNumber* resultNumber = (NSNumber*)[results objectForKey:@"result"];
	
	if ([resultNumber intValue] == 0) { //에러처리
		[CommonAlert alertWithTitle:@"에러" message:[results objectForKey:@"description"]];
		return;
	} else {
		[CommonAlert alertWithTitle:@"알림" message:@"프렌즈 목록를 다시 가져왔어요~"];
		[cellDataList removeAllObjects];
		NSArray* resultList = [results objectForKey:@"data"];
		for (NSDictionary* data in resultList) {
			[cellDataList addObject:data];
		}
	}
	[myTableView reloadData];
}

- (void) onCpNeighborListRefreshResultError:(HttpConnect*)connect 
{
	MY_LOG(@"%@", connect.stringReply);	
}


@end
