    //
//  UIColumbusViewController.m
//  ImIn
//
//  Created by 태한 김 on 10. 5. 13..
//  Copyright 2010 kth. All rights reserved.
//

#import "UIColumbusViewController.h"
#import "ColumbusTableCell.h"
#import "POIDetailViewController.h"
#import "ColumbusList.h"
#import "iToast.h"

static float MAX_POI_NAME_LENGTH = 260.0f;

@implementation UIColumbusViewController
@synthesize snsId, nickname, cellDataList;
@synthesize tableCoverNoticeMessage;

- (id) init
{
	if (self = [super init]) 
	{
		snsId = nil;
		nickname = nil;
        titleLabel.text = @"콜럼버스";
	}
	return self;
}

- (void) viewDidLoad
{
    
    [mainTableView setSeparatorColor:RGB(181, 181, 181)];
	mainTableView.backgroundColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1];
    
    currColListPage = 1;	

    self.tableCoverNoticeMessage = @"데이터 로딩중...";
    
    [self requestColumbusList];
}

-(void)viewWillAppear:(BOOL)animated
{
	if( nil != nickname){
        titleLabel.text = [NSString stringWithFormat:@"%@님의 콜럼버스", nickname];
	}    
}

#pragma mark -

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [mainTableView release];
    mainTableView = nil;
    [titleLabel release];
    titleLabel = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [snsId release];
    [nickname release];
	[cellDataList release];
    [mainTableView release];
    [titleLabel release];
    [tableCoverNoticeMessage release];
    
    [super dealloc];
}

#pragma mark -
//
//- (void) onColumbusTransDone:(HttpConnect*)up
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
//	self.cellDataList = [results objectForKey:@"data"];
//	colNum = [[results objectForKey:@"totalCnt"] integerValue];
//	
//	if ([cellDataList count] == 0) {
//		
//		TableCoverNoticeViewController* infoView = [[TableCoverNoticeViewController alloc]initWithNibName:@"TableCoverNoticeViewController" bundle:nil];
//		
//		infoView.view.frame = CGRectMake(0, NAVIBAR_H, 320, 480-NAVIBAR_H-69);
//		[columbusTableViewController.view bringSubviewToFront:infoView.view];
//		
//		// 새소식이 없는 경우.
//		// 본인이라면
//		if ([snsIdStr isEqualToString:[UserContext sharedUserContext].snsID]) {
//			infoView.line1.text = @"아무도 다녀가지 않은 곳을 찾아";
//			infoView.line2.text = @"첫 발도장을 찍고 콜럼버스가 되어보세요.";			
//		} else {
//			infoView.line1.text = [NSString stringWithFormat:@"%@님은 아직 콜럼버스인 곳이 없어요", nickName];
//		}
//
//		
//		[columbusTableViewController.tableView setTableHeaderView:infoView.view];
//		
//		[infoView release];
//	} else {
//		[columbusTableViewController.tableView.tableHeaderView removeFromSuperview];
//		columbusTableViewController.tableView.tableHeaderView.frame = CGRectZero;
//		columbusTableViewController.tableView.tableHeaderView = nil;
//		
//		UIEdgeInsets scrollInset = ((UIScrollView*)columbusTableViewController.view).contentInset;
//		scrollInset.top = 0;
//		[((UIScrollView*)columbusTableViewController.view) setContentInset:scrollInset];
//	}
//
//	columbusTableViewController.cellDataList = cellDataList;
//	columbusTableViewController.snsIdStr = snsIdStr;
//	columbusTableViewController.totalCnt = colNum;
//	[columbusTableViewController resetPage];
//	[(UITableView*)columbusTableViewController.view reloadData];
//	
//	[HeadStr setText:[NSString stringWithFormat:@"%@의 콜럼버스",nickName]];
//}



- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return [ApplicationContext sharedApplicationContext].shouldRotate;
}


- (IBAction)closeVC:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [cellDataList count] == 0 ? 2 : 1; // section 0 - list, section 1 - table message
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
	if( 1 == section && [cellDataList count] == 0) return 1;
    
    return [cellDataList count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 1 && [cellDataList count] == 0 ) {
        return tableView.frame.size.height - tableView.tableHeaderView.frame.size.height + 54.0f;
    } else {
        return 58.0;        
    }
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"ColumbusCell";
    
	if( 0 == indexPath.section ){
		ColumbusTableCell *cell = (ColumbusTableCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		if (cell == nil)
		{
			cell = [[[ColumbusTableCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
		}
		// Configure the cell...
		NSDictionary *cellData = nil;
		if ([cellDataList count] != 0 || [cellDataList count] > indexPath.row) {
			cellData = [cellDataList objectAtIndex:indexPath.row];
			cell.poiName.text = [cellData objectForKey:@"poiName"];
			cell.description.text = [NSString stringWithFormat:@"Since %@",
									 [Utils getSimpleDateWithString:[cellData objectForKey:@"regDate"]]];
			
			CGSize withSize = [[cellData objectForKey:@"poiName"] sizeWithFont:cell.poiName.font];
			if (withSize.width < MAX_POI_NAME_LENGTH) {
				cell.redFlag.frame = CGRectMake( 20 +withSize.width , 15, 12, 14);
			} else {
				cell.redFlag.frame = CGRectMake( 20 + MAX_POI_NAME_LENGTH , 15, 12, 14);
			}
            
			
		}
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
		return cell;
	}
	
	if( [cellDataList count] == 0 && 1 == indexPath.section )
	{
        static NSString *CellIdentifier2 = @"NoticeCell";
		
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier2];
		if (cell == nil) {
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier2] autorelease];
        }
        NSDictionary* params = [NSDictionary dictionaryWithObjectsAndKeys:
                                [NSNumber numberWithFloat:tableView.bounds.size.width], @"width", 
                                [NSNumber numberWithFloat:tableView.bounds.size.height], @"height",
                                tableCoverNoticeMessage, @"message",nil];
        UIView* noticeView = [Utils createNoticeViewWithDictionary:params];
        [cell addSubview:noticeView];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;        
		return cell;
	}
    
    return nil;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if( 0 == indexPath.section )
	{
		if ([cellDataList count] == 0 || [cellDataList count] < indexPath.row) {
			return;
		}
		// Navigation logic may go here. Create and push another view controller.
		POIDetailViewController *detailViewController = [[POIDetailViewController alloc] initWithNibName:@"POIDetailViewController" bundle:nil];
        
		detailViewController.poiData = (NSDictionary*)[cellDataList objectAtIndex:indexPath.row];
        
		[(UINavigationController*)[ViewControllers sharedViewControllers].tabBarController.selectedViewController pushViewController:detailViewController animated:YES];
        
		[detailViewController release];
	}
	else if( 1 == indexPath.section )
	{
        // seciton 1은 안내 문구 표시 전용이므로 선택되지 않도록 처리한다.
		return;
	}
}


- (void) requestColumbusList
{
    if ([cellDataList count] != 0 && [cellDataList count] == totalCnt) {
		return;
	}
	
    ColumbusList* columbusList = [[ColumbusList alloc] init];
    columbusList.delegate = self;
    [columbusList.params addEntriesFromDictionary:[NSDictionary dictionaryWithObjectsAndKeys:@"25", @"scale", 
                                                   [NSString stringWithFormat:@"%d", currColListPage++], @"currPage", 
                                                   snsId, @"snsId",
                                                   nil]];
    [columbusList request];

}

- (void) apiDidLoadWithResult:(NSDictionary *)result whichObject:(NSObject *)theObject
{
    if ([[result objectForKey:@"func"] isEqualToString:@"columbusList"]) {
        if (cellDataList == nil) {
            self.cellDataList = [NSMutableArray arrayWithArray:[result objectForKey:@"data"]];
        } else {
            [cellDataList addObjectsFromArray:[result objectForKey:@"data"]];
        }
        totalCnt = [[result objectForKey:@"totalCnt"] intValue];
        
        if (totalCnt == 0) {
            if ([snsId isEqualToString:[UserContext sharedUserContext].snsID]) {
                self.tableCoverNoticeMessage = @"아무도 다녀가지 않은 곳을 찾아\n첫 발도장을 찍고 콜럼버스가 되어보세요.";			
            } else {
                self.tableCoverNoticeMessage = [NSString stringWithFormat:@"%@님은 아직 콜럼버스인 곳이 없어요", nickname];
            }
        }
        
        [mainTableView reloadData];
        
        [theObject release];
    }
}

- (void) apiFailedWhichObject:(NSObject *)theObject
{
    if (totalCnt) {
        //itoast
    }
    self.tableCoverNoticeMessage = @"네트워크가 불안합니다\n다시 시도해 주세요~";
    [theObject release];
}



- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
	
	if (isTop && !isEnd) {
		return;
	}
	
	if (isEnd && !isTop) {
		[self requestColumbusList];
		return;
	}
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	if (scrollView.contentOffset.y < 0) {
		isTop = YES;
	} else {
		isTop = NO;
	}
	
	if (scrollView.contentOffset.y + mainTableView.frame.size.height + 10 > scrollView.contentSize.height) {
		isEnd = YES;
	} else {
		isEnd = NO;
	}
}

@end
