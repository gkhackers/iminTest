//
//  POIListViewController.m
//  ImIn
//
//  Created by choipd on 10. 5. 3..
//  Copyright 2010 edbear. All rights reserved.
//

#import "POIListViewController.h"
#import "POIListCell.h"

#import "POIDetailViewController.h"
#import "ViewControllers.h"
#import "UserContext.h"
#import "CgiStringList.h"
#import "const.h"
#import "JSON.h"
#import "RegisterPOI.h"
#import "UIPlazaViewController.h"
#import "macro.h"
#import "PoiList.h"
#import "LocalList.h"
#import "AutoSearch.h"
#import "iToast.h"
#import "PostComposeViewController.h"

#import "NWAppUsageLogger.h"
#import "GoogleMapViewController.h"

#import "AutoSearchCell.h"
#import "NSCustomLibrary.h"

static float kOFFSET_FOR_KEYBOARD = 87.0f;

@implementation POIListViewController
@synthesize nearPoiList, myPoiList;
@synthesize filteredNearPoiList, savedSearchTerm, searchWasActive;
@synthesize poiList, localList, localSearchList, autoSearchList;
@synthesize selectedTabInt, searchTypeInt;
@synthesize lastPostId;
@synthesize hasMoreItem;
@synthesize autoSearch;
@synthesize searchText;
@synthesize headerView;
@synthesize rootViewController;
@synthesize previousVCDelegate;
@synthesize previousNavi;
@synthesize tabBarNavi;
@synthesize currPostWriteFlow;
@synthesize tableCoverNoticeMessage;
@synthesize nearPoiUIDescriptionArray;
@synthesize myPoiUIDescriptionArray;

#define AUTO_SEARCH 0
#define IMIN_SEARCH 1

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	MY_LOG(@"Got a memory warning");
	UIPlazaViewController* plaza = (UIPlazaViewController*)[ViewControllers sharedViewControllers].plazaViewController;
	plaza.needToUpdate = YES;
    // Relinquish ownership any cached data, images, etc that aren't in use.
}


- (void)dealloc {
	[nearPoiList release];
	[myPoiList release];
	[filteredNearPoiList release];
    [autoSearchList release];
	
	[poiList release];
	[localList release];
	[localSearchList release];
    [lastPostId release];
    [autoSearch release];
    [searchText release];
    [headerView release];
    [tableCoverNoticeMessage release];
    [nearPoiUIDescriptionArray release];
    [myPoiUIDescriptionArray release];
	
    [super dealloc];
}


#pragma mark -
#pragma mark View lifecycle

- (void) loadView {
	
	[super loadView];
	currPage = 1;
	lastPage = 1;
	currPageWithSearch = 1;
	lastPageWithSearch = 1;
    selectedTabInt = 0;
    searchTypeInt = 0;

//	moreBtn.enabled = NO;
	isEnd = NO;
    lastPostId = @"";
    hasMoreItem = FALSE;
    self.nearPoiList = nil;
    self.myPoiList = nil;
    
}

- (void) viewWillAppear:(BOOL)animated
{    
    GA1(@"발도장찍을장소page");
    [self logViewControllerName];
    [[UserContext sharedUserContext] recordKissMetricsWithEvent:@"POI List Page" withInfo:nil];

	[super viewWillAppear:animated];
}

- (IBAction) popViewController {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) dismissModalViewControllerAnimated {

    [self dismissModalViewControllerAnimated:YES];
}

- (void)viewDidLoad {
	[super viewDidLoad];
    
    [self selectPOIList:selectedTabInt];

	onSearching = NO;

	[localListTableView setSeparatorColor:RGB(181, 181, 181)];

	[self.searchDisplayController.searchResultsTableView setSeparatorColor:RGB(227, 227, 227)];		
    
    self.searchDisplayController.searchResultsTableView.tableFooterView = searchMainFooter;
	searchMainFooter.hidden = YES;
    self.nearPoiUIDescriptionArray = [NSMutableArray arrayWithCapacity:3];
    self.myPoiUIDescriptionArray = [NSMutableArray arrayWithCapacity:3];
}


- (void)viewDidUnload {
    
    [searchBar release];
    searchBar = nil;
    
	[headerView release];
    headerView = nil;
    
	[focusSearchBar release];
    focusSearchBar = nil;
    
	[mainFooterView release];
    mainFooterView = nil;
    
    [footerViewMore release];
    footerViewMore = nil;
    
    [footerViewSearch release];
    footerViewSearch = nil;
    
    [searchMainFooter release];
    searchMainFooter = nil;
    
    [searchFooterMore release];
    searchFooterMore = nil;
    
    [searchFooterView release];
    searchFooterView = nil;
        
	[localListTableView release];
    localListTableView = nil;
    
    [moreBtn release];
    moreBtn = nil; 
}

#pragma mark -
#pragma mark 서버연동부분
- (void) requestMyPoiList {	
	self.poiList = [[[PoiList alloc] init] autorelease];
	poiList.delegate = self;
    NSString* requestPostId = nil;
    if (hasMoreItem) { // 더 요청할 데이타가 있을 경우
        requestPostId = lastPostId;
    } else {
        requestPostId = @"";
    }
	[poiList.params addEntriesFromDictionary:[NSDictionary dictionaryWithObjectsAndKeys:
											  @"F", @"vm",
											  @"1", @"relation",
											  [UserContext sharedUserContext].snsID, @"snsId",
                                              requestPostId, @"postId",
											  [[GeoContext sharedGeoContext].lastTmX stringValue], @"pointX",
											  [[GeoContext sharedGeoContext].lastTmY stringValue], @"pointY",
											  DEFAULT_MY_POI_LIST_RANGE, @"rangeX",
											  DEFAULT_MY_POI_LIST_RANGE, @"rangeY",
											  @"25", @"maxScale",
											  @"0", @"isUniqueUser",
											  nil]];

	[poiList request];
}

- (void) requestLocalList {
	
	self.localList = [[[LocalList alloc] init] autorelease];
	localList.delegate = self;
	
	[localList.params addEntriesFromDictionary:[NSDictionary dictionaryWithObjectsAndKeys:
												[[GeoContext sharedGeoContext].lastTmX stringValue], @"pointX",
												[[GeoContext sharedGeoContext].lastTmY stringValue], @"pointY",
												@"-1", @"range",
												@"25", @"scale",
												[NSString stringWithFormat:@"%d", currPage], @"currPage",
												nil]];

	[localList requestWithAuth:YES withIndicator:YES];
}

- (void) requestQueryWithString {    
	self.localSearchList = [[[LocalList alloc] init] autorelease];
	localSearchList.delegate = self;
	
	[localSearchList.params addEntriesFromDictionary:[NSDictionary dictionaryWithObjectsAndKeys:
												[[GeoContext sharedGeoContext].lastTmX stringValue], @"pointX",
												[[GeoContext sharedGeoContext].lastTmY stringValue], @"pointY",
												@"-1", @"range",
												@"25", @"scale",
												[NSString stringWithFormat:@"%d", currPageWithSearch], @"currPage",
												searchBar.text, @"query",
												nil]];
	[localSearchList requestWithAuth:NO withIndicator:YES];
}

- (void) requestAutoSearch {
    
	self.autoSearch = [[[AutoSearch alloc] init] autorelease];
	autoSearch.delegate = self;
    
    autoSearch.data = [NSDictionary dictionaryWithObjectsAndKeys:searchText, @"Query",
                       nil];
	
    MY_LOG(@"searchText = %@", searchText);
	[autoSearch request];
}

/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/
/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	
	if (self.view.frame.origin.y < 0)
    {
        [self setViewMovedUp:NO];
		[searchBar resignFirstResponder];
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

    return 2;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {    
    if (section == 0) {
        if (selectedTabInt == 1) { //가본장소
            return [myPoiList count];
        } else {
            if (tableView == self.searchDisplayController.searchResultsTableView) {
                if (searchTypeInt != AUTO_SEARCH) { // 아임인검색
                    return [filteredNearPoiList count];
                } else { // 자동완성검색
                    MY_LOG(@"[autoSearchList count] = %d", [autoSearchList count]);
                    return [autoSearchList count];
                }
            } else {
                return [nearPoiList count];
            }
        }
    } else {
        if (selectedTabInt == 1 && [myPoiList count] == 0) {
            return 1;
        }
        if (selectedTabInt == 0) {
            if (tableView == self.searchDisplayController.searchResultsTableView) {
                if([filteredNearPoiList count] == 0) {
                    return 1;
                }
            } else {
                if([nearPoiList count] == 0) {
                    return 1;
                }
            }
        }
    }
    return 0;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger cnt = (selectedTabInt == 0) ? [nearPoiList count] : [myPoiList count];
    if (indexPath.section == 1 && cnt == 0) {
        
        [localListTableView setScrollsToTop:YES];
        localListTableView.scrollEnabled = NO;
        
        static NSString *CellIdentifier = @"NoticeCell";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        }
        float messageBoxHeight = 0.0f;
        if (currPostWriteFlow == NEW_POSTFLOW) { // 만약 새로운 발도장 프로세스면 
            if (selectedTabInt == 0) { // 주변장소
                messageBoxHeight = 350.0f;
            } else {
                messageBoxHeight = 400.0f;
            }
        } else {
            if (selectedTabInt == 0) { // 주변장소
                messageBoxHeight = 310.0f;
            } else {
                messageBoxHeight = 360.0f;
            }
        }
        NSDictionary* params = [NSDictionary dictionaryWithObjectsAndKeys:
                                [NSNumber numberWithFloat:320], @"width", 
                                [NSNumber numberWithFloat:messageBoxHeight], @"height",
                                tableCoverNoticeMessage, @"message",nil];
        UIView* noticeView = [Utils createNoticeViewWithDictionary:params];
        [cell addSubview:noticeView];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        return cell;
    } else {
        localListTableView.scrollEnabled = YES;
        NSDictionary* cellData = nil;
        if (tableView == self.searchDisplayController.searchResultsTableView && searchTypeInt == AUTO_SEARCH) { // 자동완성 검색 테이블 값 설정
            static NSString *cellIdentifier = @"autoSearch";
            AutoSearchCell *cell = (AutoSearchCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (cell == nil) {
                NSArray* nibObjects = [[NSBundle mainBundle] loadNibNamed:@"AutoSearchCell" owner:nil options:nil];
                
                for (id currentObject in nibObjects) {
                    if([currentObject isKindOfClass:[AutoSearchCell class]]) {
                        cell = (AutoSearchCell*) currentObject;
                    }
                }
            }
            
            if ([autoSearchList count] >= indexPath.row) {
                [cell populateCellWithData:searchText : [autoSearchList objectAtIndex:indexPath.row]];
            } 
            return cell;
        } else {
            static NSString *CellIdentifier = @"poicell";
            
            POIListCell *cell = (POIListCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil) {
                NSArray* nibObjects = [[NSBundle mainBundle] loadNibNamed:@"POIListCell" owner:nil options:nil];
                
                for (id currentObject in nibObjects) {
                    if([currentObject isKindOfClass:[POIListCell class]]) {
                        cell = (POIListCell*) currentObject;
                    }
                }
            }
            cell.vcDelegate = self;
            
            if (currPostWriteFlow == NEW_POSTFLOW) {
                cell.currPostWriteFlow = NEW_POSTFLOW; 
            } else {
                cell.currPostWriteFlow = OLD_POSTFLOW; 
            }
            
            if (tableView == self.searchDisplayController.searchResultsTableView) { //
                if ([filteredNearPoiList count] >= indexPath.row) {
                    cell.currSelectedTabInt = 0;
                    cellData = [filteredNearPoiList objectAtIndex:indexPath.row];
                }
            } else {
                if (selectedTabInt == 1) {
                    cell.currSelectedTabInt = 1;
                    cellData = [myPoiList objectAtIndex:indexPath.row];
                } else {
                    cell.currSelectedTabInt = 0;
                    cellData = [nearPoiList objectAtIndex:indexPath.row];
                }
            }
            
            [cell populateCellWithData:cellData];
            return cell;
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	NSInteger cnt = (selectedTabInt == 0) ? [nearPoiList count] : [myPoiList count];
    
    if (cnt == 0 && indexPath.section == 1) {   // no data
        if (currPostWriteFlow == NEW_POSTFLOW) { // 만약 새로운 발도장 프로세스면 
            if (selectedTabInt == 0) { // 주변장소
                return 350.0f;
            } else {
                return 400.0f;
            }
        } else {
            if (selectedTabInt == 0) { // 주변장소
                return 310.0f;
            } else {
                return 360.0f;
            }
        }
    } else {
        if (tableView == self.searchDisplayController.searchResultsTableView && searchTypeInt == AUTO_SEARCH) {
            return 34.0f;
        } else {
            return 69.0f;
        }
    } 
}

- (void) setGAData:(NSDictionary*)data {
    NSString* userType = [data objectForKey:@"userType"];
    NSString* bizType = [data objectForKey:@"bizType"];
    NSString* gaText = nil;
    
    if (selectedTabInt == 1) {
        gaText = @"가본장소_발도장내";
    } else {
        gaText = @"주변장소_발도장내";
    }
    
    if (([data objectForKey:@"evtId"] && ![[data objectForKey:@"evtId"] isEqualToString:@""]) || [[data objectForKey:@"isEvent"] isEqualToString:@"1"]) { //이벤트
        if (([bizType isEqualToString:@"BT0001"] || [bizType isEqualToString:@"BT0002"]) && [userType isEqualToString:@"UB0001"]) { //브랜드 이벤트
            GA3(@"발도장찍을장소", @"브랜드이벤트장소명", gaText);
        } else if ([bizType isEqualToString:@"BT0001"] || [bizType isEqualToString:@"BT0002"]) { //브랜드 이벤트
            GA3(@"발도장찍을장소", @"브랜드이벤트장소명", gaText);
        } else if ([bizType isEqualToString:@"BT0003"]) { //소상공인 이벤트
            GA3(@"발도장찍을장소", @"주인장이벤트장소명", gaText);
        } else { //일반 이벤트
            GA3(@"발도장찍을장소", @"장소명", gaText);
        }
    } else { //이벤트가 아닌 POI
        GA3(@"발도장찍을장소", @"장소명", gaText);
    } 
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {   
    if (indexPath.section == 0) {
        NSDictionary *poiData = nil;
        
        if (tableView == self.searchDisplayController.searchResultsTableView) {
            if (searchTypeInt != AUTO_SEARCH) {
                if ([filteredNearPoiList count] == 0 || [filteredNearPoiList count] < indexPath.row) {
                    return;
                }		
                
                [self setGAData:[filteredNearPoiList objectAtIndex:indexPath.row]];
                
                poiData = [filteredNearPoiList objectAtIndex:indexPath.row];
                [tableView deselectRowAtIndexPath:indexPath animated:YES];
            } else {
                if ([autoSearchList count] == 0 || [autoSearchList count] < indexPath.row) {
                    return;
                }		
                [searchBar setText:[autoSearchList objectAtIndex:indexPath.row]];
                if (self.view.frame.origin.y < 0)
                {
                    [self setViewMovedUp:NO];
                    [searchBar resignFirstResponder];
                }
                [self serverSearch];
                [tableView deselectRowAtIndexPath:indexPath animated:YES];
                return;
                // 텍스트 창에 텍스트 넣고 아임인 검색 시작!
            }
        } else {
            if (selectedTabInt == 1) {
                if ([myPoiList count] == 0 || [myPoiList count] < indexPath.row) {
                    return;
                }
                [self setGAData:[myPoiList objectAtIndex:indexPath.row]];
                poiData = [myPoiList objectAtIndex:indexPath.row];
            } else {
                if ([nearPoiList count] == 0 || [nearPoiList count] < indexPath.row) {
                    return;
                }
                [self setGAData:[nearPoiList objectAtIndex:indexPath.row]];
                poiData = [nearPoiList objectAtIndex:indexPath.row];
            }
            [localListTableView deselectRowAtIndexPath:indexPath animated:YES];
        }
        
        if ([rootViewController isEqualToString:@"PostComposeViewController"]) {
            //todo 예외처리
            if (previousVCDelegate) {
                [(PostComposeViewController*)previousVCDelegate setPoiData:poiData];
            } 
            [self popViewController];
        } else {
            PostComposeViewController* vc = [[[PostComposeViewController alloc] initWithNibName:@"PostComposeViewController" bundle:nil] autorelease];
            vc.hidesBottomBarWhenPushed = YES;
            vc.poiData = poiData;
            UINavigationController *navController = [[[UINavigationController alloc] initWithRootViewController:vc] autorelease];
            [navController setNavigationBarHidden:YES] ;
            
            //[[ApplicationContext sharedApplicationContext] presentVC:navController];
            [(UINavigationController*)[ViewControllers sharedViewControllers].tabBarController.selectedViewController presentModalViewController:navController animated:YES];
        }
    }
}


#pragma mark -
#pragma mark Content Filtering
- (void) serverSearch
{
    currPageWithSearch = 1;
	lastPageWithSearch = 1;

    [filteredNearPoiList removeAllObjects];
    self.filteredNearPoiList = nil;
    [autoSearchList removeAllObjects];
    self.autoSearchList = nil;
    
	searchTypeInt = IMIN_SEARCH;
    
    [self.searchDisplayController.searchResultsTableView reloadData];

	[self requestQueryWithString];	
}

#pragma mark -
#pragma mark UISearchDisplayController Delegate Methods

- (void) searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller {
//#ifdef AUTO_SEARCH_FLOW
    searchTypeInt = AUTO_SEARCH;
//#endif
	[self setViewMovedUp:YES];
    
	GA3(@"발도장찍을장소", @"검색창", @"발도장내");
}

- (void) searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller {
	if (self.view.frame.origin.y < 0)
    {
        [self setViewMovedUp:NO];
		[searchBar resignFirstResponder];
    }
}

- (void) searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller {
	[controller.searchResultsTableView setSeparatorColor:RGB(181, 181, 181)];
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    [controller.searchResultsTableView setRowHeight:800];
//#ifdef AUTO_SEARCH_FLOW    
    if (searchTypeInt != AUTO_SEARCH) {
        searchTypeInt = AUTO_SEARCH;
    }

    if ([searchString isEqualToString:@""] || searchString == nil) {
        return NO;
    }
    self.searchText = searchString;
    //todo 타이머 다 날림
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(requestAutoSearch) object:nil];
    [self performSelector:@selector(requestAutoSearch) withObject:nil afterDelay:0.5];
//#endif
	return YES;
}

#pragma mark -
#pragma mark 키보드 처리

- (void)setViewMovedUp:(BOOL)movedUp
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];

    CGRect rect = CGRectZero;
    rect = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height);
    if (movedUp)
    {
        rect.origin.y -= kOFFSET_FOR_KEYBOARD;
        rect.size.height += kOFFSET_FOR_KEYBOARD;
		[headerView setFrame:CGRectMake(0.0f, 0.0f+kOFFSET_FOR_KEYBOARD, 320, 43)];
    }
    else
    {
        rect.origin.y += kOFFSET_FOR_KEYBOARD;
        rect.size.height -= kOFFSET_FOR_KEYBOARD;
		[headerView setFrame:CGRectMake(0.0f, 0.0f, 320, 43)];
    }
    self.view.frame = rect;
    
    [UIView commitAnimations];
}


#pragma mark -
//#ifdef AUTO_SEARCH_FLOW
- (void)searchBarCancelButtonClicked:(UISearchBar *)aSearchBar
{
    searchTypeInt = IMIN_SEARCH;
	[filteredNearPoiList removeAllObjects];
    self.filteredNearPoiList = nil;
    [autoSearchList removeAllObjects];
    self.autoSearchList = nil;
 
    [self.searchDisplayController.searchResultsTableView reloadData];
	
	aSearchBar.text = @"";
	[aSearchBar becomeFirstResponder];
    if (self.view.frame.origin.y < 0)
    {
        [self setViewMovedUp:NO];
		[aSearchBar resignFirstResponder];
    }
}
//#endif

- (void)searchBarSearchButtonClicked:(UISearchBar *)aSearchBar {
	MY_LOG(@"searchBar search button clicked!");
	
	[aSearchBar resignFirstResponder];
	if (self.view.frame.origin.y < 0)
    {
        [self setViewMovedUp:NO];
		[searchBar resignFirstResponder];
    }
    [self serverSearch];

    [[UserContext sharedUserContext] recordKissMetricsWithEvent:@"Searched POI" withInfo:nil];

	// 모바일 통계 적용
	NWAppUsageLogger *logger = [NWAppUsageLogger logger];
	[logger fireUsageLog:@"SEARCH" andEventDesc:aSearchBar.text andCategoryId:nil];

}

- (IBAction) registerPOI {
	GA3(@"발도장찍을장소", @"직접찍기버튼", nil);

	RegisterPOI* registerPOIvc = [[RegisterPOI alloc] initWithNibName:@"RegisterPOI" bundle:nil];
	registerPOIvc.inputPoiName = [searchBar text];
    registerPOIvc.rootViewController = rootViewController;
    if (rootViewController != nil || [rootViewController isEqualToString:@""]) {
        registerPOIvc.rootViewController = rootViewController;
        [self.navigationController pushViewController:registerPOIvc animated:YES];
    } else {
	UINavigationController *navController = (UINavigationController*)[ViewControllers sharedViewControllers].tabBarController.selectedViewController;
	[navController pushViewController:registerPOIvc animated:YES];
    }
	[registerPOIvc release];
}

- (IBAction) goSearchBar
{
	GA3(@"발도장찍을장소", @"장소검색버튼", nil);
	[searchBar becomeFirstResponder];
}

- (IBAction) requestMore
{
	if (currPage < lastPage) {		
		currPage++;
		[self requestLocalList];
	}
}

- (IBAction) requestMoreMyPoiList
{
    if (hasMoreItem) { // 더 요청할 데이타가 있을 경우		
		[self requestMyPoiList];
	}
}

- (IBAction) requestMoreWithSearch
{
	if (currPageWithSearch < lastPageWithSearch) {		
		currPageWithSearch++;
		[self requestQueryWithString];
	}
}

#pragma mark -
#pragma mark UIScrollView delegate

- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView {

}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {

}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	if (scrollView.contentOffset.y + 378 > scrollView.contentSize.height) {
		isEnd = YES;
	} else {
		isEnd = NO;
	}
}


#pragma mark -
#pragma mark ImInProtocol delegate

- (void) apiFailedWhichObject:(NSObject *)theObject {
    if ( [NSStringFromClass([theObject class]) isEqualToString:@"AutoSearch"] ) {
        [autoSearchList removeAllObjects];
        self.autoSearchList = nil;
        
        [self.searchDisplayController.searchResultsTableView reloadData];
    } 
    if (theObject == localList) {
        if ([nearPoiList count] > 0) {
            UIWindow *window = [[[UIApplication sharedApplication] windows] objectAtIndex:0];
            UIView *v = (UIView *)[window viewWithTag:TAG_iTOAST];
            if (!v) {
                iToast *msg = [[iToast alloc] initWithText:@" 인터넷 연결에 실패하였습니다. 네트워크 설정을 확인하거나, \n잠시 후 다시 시도해주세요~"];
                [msg setDuration:2000];
                [msg setGravity:iToastGravityCenter];
                [msg show];
                [msg release];
            }
        } else {
            self.tableCoverNoticeMessage = @"네트워크가 불안합니다.\n잠시 후 다시 시도해 주세요~"; 
        }
    }
    
    if (theObject == poiList) {
        if ([myPoiList count] > 0) {
            UIWindow *window = [[[UIApplication sharedApplication] windows] objectAtIndex:0];
            UIView *v = (UIView *)[window viewWithTag:TAG_iTOAST];
            if (!v) {
                iToast *msg = [[iToast alloc] initWithText:@" 인터넷 연결에 실패하였습니다. 네트워크 설정을 확인하거나, \n잠시 후 다시 시도해주세요~"];
                [msg setDuration:2000];
                [msg setGravity:iToastGravityCenter];
                [msg show];
                [msg release];
            }
        } else {
            self.tableCoverNoticeMessage = @"네트워크가 불안합니다.\n잠시 후 다시 시도해 주세요~";
        }
    }
}

// footer 설명 - jjai
// localList, poiList를 보여주는 테이블과 검색 테이블이 따로 설정되어 있음
// 따라서 footer 도 따로 관리하고 따로 적용되고 있음 
// 두개의 footer에 대한 상세 설명은 아래에 있음
//
// 1. mainFooterView : localList 와 PoiList를 보여주는 테이블의 footerView
//    - footerViewMore : mainFooterView 의 더보기 부분
//    - footerViewSearch : mainFooterView 의 직접찍기 버튼이 보이는 부분
//
// 2. searchMainFooter : 검색결과를 보여주는 테이블의 footerView
//    - searchFooterMore : searchMainFooter 의 더보기 부분
//    - searchFooterView : searchMainFooter 의 직접찍기 버튼이 보이는 부분
//
- (void) apiDidLoadWithResult:(NSDictionary *)result whichObject:(NSObject *)theObject
{    
	if ([[result objectForKey:@"func"] isEqualToString:@"localList"]) {
		if (theObject == localList) {

			mainFooterView.hidden = NO;
            footerViewSearch.hidden = NO;
			
			int totalCnt = [[result objectForKey:@"totalCnt"] intValue];
			int scale = [[result objectForKey:@"scale"] intValue];
			
			currPage = [[result objectForKey:@"currPage"] intValue];
			lastPage = totalCnt / scale + 1;
			
			if (currPage == lastPage) {
                mainFooterView.frame = CGRectMake(0, 0, 320, 50);
                footerViewMore.frame = CGRectZero;
                footerViewSearch.frame = CGRectMake(0, 0, 320, 50);                
                
				//moreLabel.text = @"마지막 페이지입니다.";
			} else {
                mainFooterView.frame = CGRectMake(0, 0, 320, 85);
                footerViewMore.frame = CGRectMake(0, 0, 320, 35);
                footerViewSearch.frame = CGRectMake(0, 35, 320, 50);
				//moreLabel.text = @"더 보시려면 끌어올려 주세요.";
			}
            
            [nearPoiUIDescriptionArray removeAllObjects];

            CGRect rect = mainFooterView.frame;
            [nearPoiUIDescriptionArray addObject:[NSDictionary dictionaryWithCGRect:rect]];
            rect = footerViewMore.frame;
            [nearPoiUIDescriptionArray addObject:[NSDictionary dictionaryWithCGRect:rect]];
            rect = footerViewSearch.frame;
            [nearPoiUIDescriptionArray addObject:[NSDictionary dictionaryWithCGRect:rect]];
 
			localListTableView.tableFooterView = mainFooterView;
			if (nearPoiList == nil) {
                self.nearPoiList = [NSMutableArray arrayWithArray:[result objectForKey:@"data"]];
            } else {
                [nearPoiList addObjectsFromArray:[result objectForKey:@"data"]];
            }
			
			[localListTableView reloadData];
			localListTableView.scrollEnabled = YES;
		
			if (currPage != 1 && [[result objectForKey:@"data"] count] != 0) {				
				NSIndexPath* endOfPageIndexPath = [NSIndexPath indexPathForRow:(currPage - 1) * scale
																	 inSection:1];
				[localListTableView scrollToRowAtIndexPath:endOfPageIndexPath
										  atScrollPosition:UITableViewScrollPositionMiddle
												  animated:YES];			
			}
		}
		
		if (theObject == localSearchList) {
            searchMainFooter.hidden = NO;
			//page 관련
			int totalCnt = [[result objectForKey:@"totalCnt"] intValue];
			int scale = [[result objectForKey:@"scale"] intValue];
			
			currPageWithSearch = [[result objectForKey:@"currPage"] intValue];
			lastPageWithSearch = totalCnt / scale + 1;
            
            if (currPageWithSearch == lastPageWithSearch) {
                searchMainFooter.frame = CGRectMake(0, 0, 320, 50);
                searchFooterMore.frame = CGRectZero;
                searchFooterView.frame = CGRectMake(0, 0, 320, 50);
			} else {
                searchMainFooter.frame = CGRectMake(0, 0, 320, 85);
                searchFooterMore.frame = CGRectMake(0, 0, 320, 35);
                searchFooterView.frame = CGRectMake(0, 35, 320, 50);
			}
					
            self.searchDisplayController.searchResultsTableView.tableFooterView = searchMainFooter;
            if (filteredNearPoiList == nil) {
                self.filteredNearPoiList = [NSMutableArray arrayWithArray:[result objectForKey:@"data"]];
            } else {
                [filteredNearPoiList addObjectsFromArray:[result objectForKey:@"data"]];
            }
            
			[self.searchDisplayController.searchResultsTableView reloadData];
			
			if (currPageWithSearch != 1) {
				NSIndexPath* endOfPageIndexPath = [NSIndexPath indexPathForRow:(currPageWithSearch - 1) * scale
																	 inSection:0];
				[self.searchDisplayController.searchResultsTableView scrollToRowAtIndexPath:endOfPageIndexPath
																		   atScrollPosition:UITableViewScrollPositionMiddle
																				   animated:YES];				
			} else {
            
                if (totalCnt > 0) {
                    NSIndexPath* topOfPageIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                    [self.searchDisplayController.searchResultsTableView scrollToRowAtIndexPath:topOfPageIndexPath
                                                                               atScrollPosition:UITableViewScrollPositionNone
                                                                                       animated:NO];
                }
            }
		}
	}
	
	if ([[result objectForKey:@"func"] isEqualToString:@"poiList"]) {
        //page 관련
        self.lastPostId = [result objectForKey:@"lastPostId"];
        hasMoreItem = [[result objectForKey:@"hasMoreItem"] boolValue];

        NSString* hiddenState = @"NO";
        footerViewSearch.frame = CGRectZero;
        footerViewSearch.hidden = YES;
        if (hasMoreItem) { 
            mainFooterView.hidden = NO;
            hiddenState = @"NO";
            mainFooterView.frame = CGRectMake(0, 0, 320, 35);
            footerViewMore.frame = CGRectMake(0, 0, 320, 35);

            localListTableView.tableFooterView = mainFooterView;
            //moreLabel.text = @"더 보시려면 끌어올려 주세요.";
        } else { // 더 요청할 데이타가 없을 경우
            mainFooterView.hidden = YES;
            hiddenState = @"YES";
            mainFooterView.frame = CGRectZero;
            //moreLabel.text = @"마지막 페이지입니다.";
        }

        [myPoiUIDescriptionArray removeAllObjects];
        
        [self.myPoiUIDescriptionArray addObject:[NSDictionary dictionaryWithObject:hiddenState forKey:@"hidden"]];
        CGRect rect = mainFooterView.frame;
        [self.myPoiUIDescriptionArray addObject:[NSDictionary dictionaryWithCGRect:rect]];
        rect = footerViewMore.frame;
        [self.myPoiUIDescriptionArray addObject:[NSDictionary dictionaryWithCGRect:rect]];

        localListTableView.tableFooterView = mainFooterView;
        if (myPoiList == nil) {
            self.myPoiList = [NSMutableArray arrayWithArray:[result objectForKey:@"data"]];
        } else {
            [myPoiList addObjectsFromArray:[result objectForKey:@"data"]];
        }

        if (myPoiList == nil || [myPoiList count] == 0) {
            self.tableCoverNoticeMessage = @"이 근방에 가본 장소가 없습니다 \n발도장을 많이 찍어주세요~";
        }
        
        [localListTableView reloadData];
        localListTableView.scrollEnabled = YES;
 	}

//#ifdef AUTO_SEARCH_FLOW
    if ([[result objectForKey:@"func"] isEqualToString:@"autoSearch"]) {
        searchMainFooter.hidden = YES;
        NSMutableArray* data = [[NSMutableArray alloc]init];
        [data addObjectsFromArray:[result objectForKey:@"forward"]];
        [data addObjectsFromArray:[result objectForKey:@"initsyllable"]];
        self.autoSearchList = data;
        [data release];
        [self.searchDisplayController.searchResultsTableView reloadData]; 
    }
//#endif
}

- (IBAction) moreBtnClick {
    MY_LOG(@"더보기");
    if(self.searchDisplayController.isActive)
    {
        [self requestMoreWithSearch];
    } else {
        if( 1 == selectedTabInt ) { //가본
            GA3(@"발도장찍을장소", @"장소더보기버튼", @"가보장소_발도장내");
            [self requestMoreMyPoiList];
        } else { //주변
            GA3(@"발도장찍을장소", @"장소더보기버튼", @"주변장소_발도장내");
            [self requestMore];   
        }
    }
}

#pragma mark - 
#pragma mark 탭 클릭

- (IBAction) selectTab: (UIButton*) sender;
{    
    selectedTabInt = [sender tag];
    [self selectPOIList:[sender tag]];
}

- (void) selectPOIList : (NSInteger)tabIndext {
    historyOnBtn.hidden = YES;
	locationOnBtn.hidden = YES;
    
	[localListTableView setScrollsToTop:NO];

    CGRect frame = localListTableView.tableHeaderView.frame;
    
	if( 0 == tabIndext )		// 주변 POI
	{
        mainFooterView.hidden = YES;
        
        GA3(@"발도장찍을장소", @"주변장소", @"발도장내");
        self.searchDisplayController.searchResultsTableView.hidden = NO;
        searchBar.hidden = NO;
        if (frame.size.height == 0) {
            frame.size.height = 44;
        }
        
        [localListTableView.tableHeaderView setFrame:frame];
        [localListTableView setTableHeaderView:self.headerView]; 
        
        locationOnBtn.hidden = NO;

        if (nearPoiList == nil) {
            currPage = 1;
            [self requestLocalList];
            [localListTableView setScrollsToTop:YES];
        } else {
            mainFooterView.hidden = NO;
            footerViewSearch.hidden = NO;

            mainFooterView.frame = [[nearPoiUIDescriptionArray objectAtIndex:0] CGRectValue];
            footerViewMore.frame = [[nearPoiUIDescriptionArray objectAtIndex:1] CGRectValue];
            footerViewSearch.frame = [[nearPoiUIDescriptionArray objectAtIndex:2] CGRectValue];
            
            localListTableView.tableFooterView = mainFooterView;
        }
	}
	else if( 1 == tabIndext )	// 가본 POI
	{
        GA3(@"발도장찍을장소", @"가본장소", @"발도장내");
        mainFooterView.hidden = YES;

        [filteredNearPoiList removeAllObjects];
        self.filteredNearPoiList = nil;
        
        [self.searchDisplayController setActive:NO animated:YES];
        
        frame.size.height = 0;
        searchBar.hidden = YES;
        [localListTableView.tableHeaderView setFrame:frame];
        [localListTableView setTableHeaderView:self.headerView]; 
        
        historyOnBtn.hidden = NO;

        if (myPoiList == nil) {
            hasMoreItem = FALSE;
            [self requestMyPoiList];
            
            [localListTableView setScrollsToTop:YES]; 
        } else {
            NSDictionary* temp = [myPoiUIDescriptionArray objectAtIndex:0];
            NSString* state = [temp objectForKey:@"hidden"];
            if ([state isEqualToString:@"NO"]) {
                mainFooterView.hidden = NO;
            } else {
                mainFooterView.hidden = YES;
            }
            footerViewSearch.hidden = YES;
            mainFooterView.frame = [[myPoiUIDescriptionArray objectAtIndex:1] CGRectValue];
            footerViewMore.frame = [[myPoiUIDescriptionArray objectAtIndex:2] CGRectValue];
            footerViewSearch.frame = CGRectZero;
            localListTableView.tableFooterView = mainFooterView;
        }
	}
    
    [localListTableView reloadData];
}

- (void) goPoiDetail : (NSDictionary*)pData {
    GoogleMapViewController* mapVC = [[[GoogleMapViewController alloc] init] autorelease];
    mapVC.mapInfo = pData;
    
    [mapVC setHidesBottomBarWhenPushed:YES];
    
    [self.navigationController pushViewController:mapVC animated:YES];
}



@end

