//
//  UserSearchTableViewController.m
//  ImIn
//
//  Created by choipd on 10. 7. 13..
//  Copyright 2010 edbear. All rights reserved.
//

#import "UserSearchTableViewController.h"
#import "UserContext.h"
#import "CgiStringList.h"
#import "HttpConnect.h"
#import "TableCoverNoticeViewController.h"
#import "JSON.h"
//#import "UserSearchCellData.h"
#import "RecomendCellData.h"
#import "RecomendCell.h"
#import "UIHomeViewController.h"
#import "ViewControllers.h"
#import "macro.h"
#import "iToast.h"

@implementation UserSearchTableViewController

@synthesize userList;
@synthesize tableView;
@synthesize nicknameKeyword;

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
	userList = [[NSMutableArray alloc] initWithCapacity:10];
	currPage = 1;
	totalCnt = 0;
	scale = 25;
	isEnd = NO;
	
	[self.tableView setSeparatorColor:RGB(181, 181, 181)];
	
//	[self.searchDisplayController setActive:YES animated:YES];

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	[self.searchDisplayController.searchResultsTableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
	[self.searchDisplayController.searchBar becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
	if (connect1 != nil) {
		[connect1 stop];
		[connect1 release];
		connect1 = nil;
	}
}

/*
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}
*/
/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [userList count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 76;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
	
    RecomendCell *cell = (RecomendCell*)[aTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
		NSArray* nibObjects = [[NSBundle mainBundle] loadNibNamed:@"RecomendCell" owner:nil options:nil];
		
		for (id currentObject in nibObjects) {
			if([currentObject isKindOfClass:[RecomendCell class]]) {
				cell = (RecomendCell*) currentObject;
				cell.cellType = IMIN_CELLTYPE_NICKNAME;
				cell.cellDataList = userList;
				cell.cellDataListIndex = indexPath.row;
			}
		}
    }
    
    // Configure the cell...
	RecomendCellData* cellData = [userList objectAtIndex:indexPath.row];
	[cell redrawMainThreadCellWithCellData:cellData];
	
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if ([userList count] == 0 || [userList count] < indexPath.row) {
		[[aTableView cellForRowAtIndexPath:indexPath] setSelected:FALSE animated:YES];
		return;
	}
		
    // Navigation logic may go here. Create and push another view controller.
	[[aTableView cellForRowAtIndexPath:indexPath] setSelected:FALSE animated:YES];
	
	RecomendCellData* cellData = [userList objectAtIndex:indexPath.row];
	
	//해당 사용자의 홈페이지로 이동하게 한다.
	UIHomeViewController *vc = [[UIHomeViewController alloc] initWithNibName:@"UIHomeViewController" bundle:nil];
	
	MemberInfo* owner = [[[MemberInfo alloc] init] autorelease];
	owner.snsId = cellData.snsId;
	owner.nickname = cellData.nickName;
	owner.profileImgUrl = cellData.profileImgURL;	
	
	vc.owner = owner;
	
	[(UINavigationController*)[ViewControllers sharedViewControllers].tabBarController.selectedViewController pushViewController:vc animated:YES];
	[vc release];
}

#pragma mark -
#pragma mark 서버 요청
- (void) request
{
	CgiStringList* strPostData = [[[CgiStringList alloc]init:@"&"] autorelease];
	[strPostData setMapString:@"svcId" keyvalue:SNS_IPHONE_SVCID];
    [strPostData setMapString:@"appVer" keyvalue:[ApplicationContext appVersion]];
	[strPostData setMapString:@"device" keyvalue:SNS_DEVICE_MOBILE_APP];
	[strPostData setMapString:@"snsId" keyvalue:[UserContext sharedUserContext].snsID];
	[strPostData setMapString:@"av" keyvalue:[UserContext sharedUserContext].snsID];
	[strPostData setMapString:@"at" keyvalue:@"1"];
	[strPostData setMapString:@"scale" keyvalue:@"25"];
	[strPostData setMapString:@"nickname" keyvalue:nicknameKeyword];
	[strPostData setMapString:@"currPage" keyvalue:[NSString stringWithFormat:@"%d", currPage]];
	if (connect1 != nil)
	{
		[connect1 stop];
		[connect1 release];
		connect1 = nil;
	}
	
	connect1 = [[HttpConnect alloc] initWithURL: PROTOCOL_SEARCH_USER 
									   postData: [strPostData description]
									   delegate: self
								   doneSelector: @selector(onTransDone1:)    
								  errorSelector: @selector(onHttpConnectError1:)  
							   progressSelector: nil];
}

- (void) doUserSearch
{
	if (nicknameKeyword.length < 1 || nicknameKeyword.length > 256) {
		[CommonAlert alertWithTitle:@"안내" message:@"닉네임 검색은 최소 1글자 이상 입력하셔야 해요."];
		return;
	}
	
	[self request];
}

#pragma mark -
#pragma mark 서버 응답
- (void) onTransDone1:(HttpConnect*)up
{	
	NSIndexPath* previousLastIndexPath = nil;
	if (currPage != 1) {
		// 기존의 리스트의 마지막을 기억하자
		previousLastIndexPath = [NSIndexPath indexPathForRow:[userList count] inSection:0];		
	}
	
	SBJSON* jsonParser = [SBJSON new];
	[jsonParser setHumanReadable:YES];
	
	NSDictionary* results = (NSDictionary *)[jsonParser objectWithString:up.stringReply error:NULL];
	if (connect1 != nil)
	{
		[connect1 release];
		connect1 = nil;
	}
	
	totalCnt = [[results objectForKey:@"totalCnt"] integerValue];
	if (currPage == 1) {
		[userList removeAllObjects];
	}
	[self.searchDisplayController.searchResultsTableView reloadData];
	
	
	// 목록에 아무것도 없는 응답이다.
	if( 0 == totalCnt )
	{
		if (infoView == nil) {
			infoView = [[TableCoverNoticeViewController alloc]initWithNibName:@"TableCoverNoticeViewController" bundle:nil];	
			CGRect frame = self.searchDisplayController.searchResultsTableView.frame;
			frame.origin = CGPointMake(0, 0);
			infoView.view.frame = frame;
			
			infoView.line1.text = @"못 찾겠어요~ 다시 검색해 주세요~";
			
			[self.searchDisplayController.searchResultsTableView addSubview:infoView.view];			
		} else {
			infoView.view.hidden = NO;
		}
		[self.searchDisplayController.searchResultsTableView bringSubviewToFront:infoView.view];

		[jsonParser release];
		return;
	}
	
	if(infoView != nil) {
			infoView.view.hidden = YES;
	}

	
	NSArray* poiList = [results objectForKey:@"data"];
	
	for (NSDictionary *poiData in poiList) {
		RecomendCellData* cellData = [[RecomendCellData alloc] initWithDictionary:poiData];
		[userList addObject:cellData];
		[cellData release];
	}
	
	[jsonParser release];
	
	[self.searchDisplayController.searchResultsTableView reloadData];
	
	if (previousLastIndexPath != nil) {
		[self.searchDisplayController.searchResultsTableView scrollToRowAtIndexPath:previousLastIndexPath 
																   atScrollPosition:UITableViewScrollPositionMiddle 
																		   animated:YES];		
	}
}



- (void) onHttpConnectError1:(HttpConnect*)up
{
    //itoast
    UIWindow *window = [[[UIApplication sharedApplication] windows] objectAtIndex:0];
    UIView *v = (UIView *)[window viewWithTag:TAG_iTOAST];
    if (!v) {
        iToast *msg = [[iToast alloc] initWithText:@" 네트워크가 불안합니다. \n잠시 후 다시 시도해 주세요~"];
        [msg setDuration:2000];
        [msg setGravity:iToastGravityCenter];
        [msg show];
        [msg release];
    }
    //	[CommonAlert alertWithTitle:@"에러" message:@"네트워크가 불안하여 검색할 수 없어요~!"];
	if (connect1 != nil)
	{
		[connect1 release];
		connect1 = nil;
	}
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
	[infoView release];
	[nicknameKeyword release];
    [super dealloc];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)aSearchBar {
	MY_LOG(@"searchBar search button clicked!");

	currPage = 1;
	totalCnt = 0;
	scale = 25;
	
	self.nicknameKeyword = aSearchBar.text;
	
	[self doUserSearch];
	
	[self.tableView setContentOffset:CGPointMake(0, 0) animated:YES];

}

- (void) searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller {
	[controller.searchResultsTableView setSeparatorColor:RGB(181, 181, 181)];
}


- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
	MY_LOG(@"cancel");
	[userList removeAllObjects];
	[self.tableView reloadData];
	
	searchBar.text = @"";
	[searchBar becomeFirstResponder];
	[self.tableView setContentOffset:CGPointMake(0, 0) animated:YES];
}


- (IBAction) popViewController {
	[self.navigationController popViewControllerAnimated:YES];
}


#pragma mark -
#pragma mark UIScrollView delegate

- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView {
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
	if (isEnd) {
		[self doRequestMore];
	}
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	//MY_LOG(@"%f, %f", scrollView.contentOffset.y + 378, scrollView.contentSize.height);
	if (scrollView.contentOffset.y + 378 > scrollView.contentSize.height) {
		isEnd = YES;
	} else {
		isEnd = NO;
	}	
}


#pragma mark -
#pragma mark 액션 정의
- (void) doRequestMore
{
	if (totalCnt > scale * currPage) {
		currPage++;
		[self request];
	}
}


@end

