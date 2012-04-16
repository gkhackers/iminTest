//
//  NeighborBlockViewController.m
//  ImIn
//
//  Created by park ja young on 11. 3. 29..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NeighborBlockViewController.h"
#import "BlockSettingCell.h"
#import "DenyGuestList.h"
#import "TableCoverNoticeViewController.h"
#import "iToast.h"
@implementation NeighborBlockViewController

@synthesize denyGuestList, denyGuestListResult;

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
		self.denyGuestListResult = [NSMutableArray arrayWithCapacity:25];
		currPage = 1;
		scale = 25; // 페이지당 25개
		totalCnt = 0;
    }
    return self;
}

- (void) requestDenyList {
	self.denyGuestList = [[[DenyGuestList alloc] init] autorelease];
	denyGuestList.delegate = self;
	[denyGuestList.params addEntriesFromDictionary:[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d", scale], @"scale", 
													[NSString stringWithFormat:@"%d", currPage], @"currPage", nil]];
	[denyGuestList request];	
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	[theTableView setSeparatorColor:RGB(181, 181, 181)];
	
	[self requestDenyList];
	// denyListChanged notification 등록
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(denyListChanged:) name:@"denyListChanged" object:nil];
}

- (void) viewWillAppear:(BOOL)animated
{
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"denyListChanged" object:nil];
}


- (void)dealloc {
	[denyGuestList release];
	[denyGuestListResult release];
	
    [super dealloc];
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [denyGuestListResult count];;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 62.0f;
}

// Customize the appearance of table view cells.
/**
 @brief 테이블에 값 설정
 @return UITableViewCell
 */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString* CellIdentifier = @"BlockSettingCell";
	
	BlockSettingCell *cell = (BlockSettingCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		NSArray* nibObjects = [[NSBundle mainBundle] loadNibNamed:@"BlockSettingCell" owner:nil options:nil];
		
		for (id currentObject in nibObjects) {
			if([currentObject isKindOfClass:[BlockSettingCell class]]) {
				cell = (BlockSettingCell*) currentObject;
			}
		}
	}
	[cell populateCellWithDictionary:[denyGuestListResult objectAtIndex:indexPath.row]];
    return cell;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

}


#pragma mark -
#pragma mark ImInProtocol

- (void) apiFailed
{
    //itoast
    UIWindow *window = [[[UIApplication sharedApplication] windows] objectAtIndex:0];
    UIView *v = (UIView *)[window viewWithTag:TAG_iTOAST];
    if (!v) {
        iToast *msg = [[iToast alloc] initWithText:@" 인터넷 연결에 실패하였습니다. 네트워크 설정을 확인하거나, \n잠시 후 다시 시도해주세요~"];
        [msg setDuration:2000];
        [msg setGravity:iToastGravityCenter];
        [msg show];
        [msg release];
    }
//    [CommonAlert alertWithTitle:@"에러" message:@"네트워크가 불안합니다.\n잠시 후 다시 시도해주세요~!"];
}

- (void) apiDidLoad:(NSDictionary *)result
{
	[denyGuestListResult addObjectsFromArray:[result objectForKey:@"data"]];
	[theTableView reloadData];
	if ([denyGuestListResult count] == 0) {
		[CommonAlert alertWithTitle:@"안내" message:@"차단된 사람이 없습니다."];
	} else {
		if (currPage != 1) {
			[theTableView scrollToRowAtIndexPath:
			 [NSIndexPath indexPathForRow:[denyGuestListResult count] - scale  inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
		}
	}

	totalCnt = [[result objectForKey:@"totalCnt"] intValue];
	currPage = [[result objectForKey:@"currPage"] intValue];
}


#pragma mark -
#pragma mark IBAction

- (void) popVC
{
	[self.navigationController popViewControllerAnimated:YES];
}

#pragma mark Notificaiton handle
- (void) denyListChanged: (NSNotification*) noti
{
	NSDictionary* denyGuest = [noti userInfo];
	[denyGuestListResult removeObject:denyGuest];
	
	[theTableView reloadData];
}


#pragma mark -
#pragma mark UIScrollView delegate

- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView {
	
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
	
	if (isTop && !isEnd) {
		return;
	}
	
	if (isEnd && !isTop) {
		int totalPage = totalCnt / scale + (totalCnt % scale != 0 ? 1 : 0);
		if (currPage < totalPage) {
			currPage++;
			[self requestDenyList];			
		}
		return;
	}
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	if (scrollView.contentOffset.y < 0) {
		isTop = YES;
	} else {
		isTop = NO;
	}
	
	if (scrollView.contentOffset.y + theTableView.frame.size.height + 10 > scrollView.contentSize.height) {
		isEnd = YES;
	} else {
		isEnd = NO;
	}
}


@end
