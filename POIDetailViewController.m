//
//  POIDetailViewController.m
//  ImIn
//
//  Created by choipd on 10. 5. 3..
//  Copyright 2010 edbear. All rights reserved.
//

#import "POIDetailViewController.h"
#import "MainThreadCell.h"
#import "PostDetailTableViewController.h"

#import "UserContext.h"
#import "const.h"
#import "CgiStringList.h"
#import "HttpConnect.h"

#import "JSON.h"
#import "iToast.h"

#import <AudioToolbox/AudioServices.h>
#import "ViewControllers.h"

#import "UIImageView+WebCache.h"
#import "NSString+URLEncoding.h"
#import "Utils.h"

#import "GoogleMapViewController.h"

#import "UIHomeViewController.h"
#import "CommonWebViewController.h"
#import "BizWebViewController.h"

#import "macro.h"

#import "ColumbusCell.h"  
#import "MasterCell.h"
#import "PoiDetailEventCell.h"
#import "PoiDetailTitleCell.h"
#import "PoiDetailCheckInCell.h"
#import "UIMasterWriteController.h"
#import "BrandHomeViewController.h"

#import "PlazaPostListByPoi.h"
#import "CaptainAreaListByPoi.h"
#import "PoiInfo.h"
#import "HomeInfo.h"
#import "EventList.h"
#import "EventCell.h"

#import "PoiInfoViewController.h"

#define FRAME_NO_RESULTS CGRectMake(0, 0, 320, 220)

@implementation POIDetailViewController
@synthesize poiData, columbusProfileImageURL, columbusSnsID, cellDataList;
@synthesize myPoint;

@synthesize plazaPostListByPoi;
@synthesize captainAreaListByPoi;
@synthesize poiInfo;
@synthesize homeInfo;
@synthesize eventList;
@synthesize poiInfoData;
@synthesize bizDataArray;
@synthesize eventDataArray;
@synthesize tableCoverNoticeMessage;
@synthesize masterData;
@synthesize isLoadFinish;


-(void) doRequestWholeCheckIns {
	[self requestWholeCheckIns];
}

-(void) doRequestMasterInfo {
	[self requestMasterInfo];
}

- (void) requestEventList {
    self.eventList = [[[EventList alloc] init] autorelease];
    eventList.delegate = self;
    [eventList.params addEntriesFromDictionary:[NSDictionary dictionaryWithObject:[poiData objectForKey:@"poiKey"] forKey:@"poiKey"]];
    [eventList.params addEntriesFromDictionary:[NSDictionary dictionaryWithObject:[UserContext sharedUserContext].snsID forKey:@"snsId"]];

    [eventList requestWithAuth:NO withIndicator:YES];
}

- (void)viewDidLoad {
    MY_LOG(@"viewDidLoad");
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadList:) name:@"reloadList" object:nil];
	
    isLoadFinish = NO;
	isEnd = NO;
    isTop = NO;
	needToUpdate = NO;
	existResultForWholeView = NO;
    
	lastPostIdForWhole = @"";
	
    postListTableView.delegate = self;
    postListTableView.dataSource = self;
	
	[self doRequestWholeCheckIns];
	
	[postListTableView setSeparatorColor:RGB(181, 181, 181)];
    
    self.tableCoverNoticeMessage = @"데이터를 불러오고 있습니다.";
    
    [self requestPoiInfo];
    [self requestEventList];
}

- (void)viewWillAppear:(BOOL)animated {
    MY_LOG(@"viewWiilAppear");
    [[UserContext sharedUserContext] recordKissMetricsWithEvent:@"POI Page" withInfo:nil];
	
	[postListTableView reloadData];
	
	//TODO: 콜럼버스와 마스터 정보를 매번 요청할 필요가 있을까?
	// 1. POI상세 VC 생성시, 한번 요청
	// 2. 마스터를 딴 경우에 마스터를 보여주고
	// 3. 콜럼버스가 된 경우에 콜럼버스 정보를 보여주면 될 듯
	[self doRequestMasterInfo];
	
	[self logViewControllerName];	
	
	if (needToUpdate) {
		[self doRequestWholeCheckIns];
	}
	
	[super viewWillAppear:animated];

}

- (void)viewWillDisappear:(BOOL)animated
{
}

- (void)didReceiveMemoryWarning {
    MY_LOG(@"didReceiveMemoryWarning");
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"reloadList" object:nil];
    
    [super viewDidUnload];
    
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;    
    [postListTableView release];
    postListTableView = nil;
    
    [arrow release];
    arrow = nil;
    
    [lastUpdateLabel release];
    lastUpdateLabel = nil;
}

- (void)viewDidDisappear:(BOOL)animated {
	//[[OperationQueue queue] cancelAllOperations];
}


- (void)dealloc {
	[cellDataList release];
    [poiInfoData release];
	[columbusProfileImageURL release];
	[columbusSnsID release];
    [bizDataArray release];
	
	[plazaPostListByPoi release];
	[captainAreaListByPoi release];
	[poiInfo release];
    [eventList release];
    [homeInfo release];
	    
    [super dealloc];
}


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 6;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    
    switch (section) {
        case 0:
            return 1; //title
            break;
        case 1:
            return [eventDataArray count];
            break;
        case 2:
            return 1; //checkin
            break;
        case 3:
            return 1; //master
            break;
        case 4:
            return [cellDataList count];
            break;
        case 5:
            if ([cellDataList count] == 0) {
                return 1; 
            } else {
                return 0;
            }
        default:
            break;
    }
    
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    switch (indexPath.section) {
        case 0:
            return 73.0f; //title
            break;
        case 1:
            return 42.0f; //event
            break;
        case 2:
            return 48.0f; //checkin
            break;
        case 3:
            return 62.0f; //마스터
            break;
        case 4: //main
        {
            NSDictionary* cellData = [cellDataList objectAtIndex:indexPath.row];
            
            float currentHeight = 0.0f;
            float topInSet = 12.0f;
            float poiNameHeight = 20.0f;
            float poiPostInSet = 2.0f;
            
            currentHeight += topInSet + poiNameHeight + poiPostInSet;
            
            float postHeight = [MainThreadCell requiredLabelSize:cellData withType:NO].height;
            float postDescInSet = 4.0f;
            
            if (postHeight == 0) {
                currentHeight += postDescInSet;
            } else {
                currentHeight += postHeight + postDescInSet;
            }
            
            
            float descHeight = 13.0f;
            currentHeight += descHeight;
            
            float imageBottom;
            if ([Utils isBrandUser:cellData]) { //브랜드면
                imageBottom = 75.0f;
            } else {
                imageBottom = 63.0f;
                //imageBottom = 75.0f;
            }
            
            currentHeight = (currentHeight > imageBottom) ? currentHeight : imageBottom;
            float bottomInSet = 10.0f;
            
            currentHeight += bottomInSet;
            return currentHeight;
        
            break;
        }
        case 5: //발도장이 없을때 뜨는 통
            return 220.0f;
            break;
            
        default:
            return 0.0f;
            break;
    }
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    [tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    switch (indexPath.section) {
        case 0:
        {
            static NSString *CellIdentifier = @"PoiDetailTitleCell";
            PoiDetailTitleCell *cell = (PoiDetailTitleCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil) {
                NSArray* nibObjects = [[NSBundle mainBundle] loadNibNamed:@"PoiDetailTitleCell" owner:nil options:nil];
                
                for (id currentObject in nibObjects) {
                    if([currentObject isKindOfClass:[PoiDetailTitleCell class]]) {
                        cell = (PoiDetailTitleCell*) currentObject;
                    }
                }
            }
            
            NSDictionary* poiUserData = nil;
            if (isLoadFinish) { // 정보 요청 완료 되었으면
                if ([bizDataArray count] > 0) {
                    poiUserData = [bizDataArray objectAtIndex:0];
                } 
                cell.isLoadFinish = YES;
            } else {
                cell.isLoadFinish = NO;
            }

            [cell redrawCellWithCellData:poiData:poiUserData];
            return cell;
            break;
        }
        case 1:
        {
            static NSString *CellIdentifier = @"PoiDetailEventCell";
            PoiDetailEventCell *cell = (PoiDetailEventCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil) {
                NSArray* nibObjects = [[NSBundle mainBundle] loadNibNamed:@"PoiDetailEventCell" owner:nil options:nil];
                
                for (id currentObject in nibObjects) {
                    if([currentObject isKindOfClass:[PoiDetailEventCell class]]) {
                        cell = (PoiDetailEventCell*) currentObject;
                    }
                }
            }
            
            NSDictionary* eventCellData = [eventDataArray objectAtIndex:indexPath.row];
            [cell redrawCellWithCellData:eventCellData];
            
            return cell;
            break;
        }
        case 2:
        {
            static NSString *CellIdentifier = @"PoiDetailCheckInCell";
            PoiDetailCheckInCell *cell = (PoiDetailCheckInCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil) {
                NSArray* nibObjects = [[NSBundle mainBundle] loadNibNamed:@"PoiDetailCheckInCell" owner:nil options:nil];
                
                for (id currentObject in nibObjects) {
                    if([currentObject isKindOfClass:[PoiDetailCheckInCell class]]) {
                        cell = (PoiDetailCheckInCell*) currentObject;
                    }
                }
            }
            
            cell.poiData = poiData;
            
            return cell;
            break;
        }
        case 3:
        {
            // 마스터 셀 그리기
            static NSString *CellIdentifier = @"MasterCell";
            
            MasterCell *cell = (MasterCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil) {
                NSArray* nibObjects = [[NSBundle mainBundle] loadNibNamed:@"MasterCell" owner:nil options:nil];
                
                for (id currentObject in nibObjects) {
                    if([currentObject isKindOfClass:[MasterCell class]]) {
                        cell = (MasterCell*) currentObject;
                    }
                }
            }

            [cell redrawCellWithCellData:masterData: poiData ];
            cell.curPosition = [eventDataArray count] > 0 ? @"2":@"1";
            
            return cell;
            break;
        }
        case 4:
        {
            if ([cellDataList count] > indexPath.row) {
                
                static NSString *CellIdentifier = @"mainThreadCell";
                
                MainThreadCell *cell = (MainThreadCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                if (cell == nil) {
                    //		MY_LOG(@"Cell created");
                    
                    NSArray* nibObjects = [[NSBundle mainBundle] loadNibNamed:@"MainThreadCell" owner:nil options:nil];
                    
                    for (id currentObject in nibObjects) {
                        if([currentObject isKindOfClass:[MainThreadCell class]]) {
                            cell = (MainThreadCell*) currentObject;
                        }
                    }
                }
                
                NSDictionary* cellData = [cellDataList objectAtIndex:indexPath.row];
                if ([eventDataArray count]) {
                    cell.curPosition = @"9";
                }
                else {
                    cell.curPosition = @"5";
                }
                
                if ([bizDataArray count] > 0) {
                    NSDictionary* poiUserValue = [bizDataArray objectAtIndex:0];
                    
                    if ([[poiUserValue objectForKey:@"bizType"] isEqualToString:@"BT0003"] && [[poiUserValue objectForKey:@"snsId"] isEqualToString:[cellData objectForKey:@"snsId"]]) {
                        cell.isOwner = YES; 
                    } else {
                        cell.isOwner = NO;
                    }
                } else {
                    cell.isOwner = NO;
                }
                
                cell.isPoiDetailVC = YES;
                [cell redrawMainThreadCellWithCellData:cellData];
                
                return cell;
            } 
            else {
                static NSString *CellIdentifier2 = @"Cell";
                
                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier2];
                if (cell == nil) {
                    cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier2] autorelease];
                }
                
                // Configure the cell...
                
                return cell;
            }
            break;
        }
        case 5:
        {
            static NSString *CellIdentifier = @"NoticeCell";
            
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil) {
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
            }
            
            NSDictionary* params = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [NSNumber numberWithFloat:320], @"width", 
                                    [NSNumber numberWithFloat:220], @"height",
                                    tableCoverNoticeMessage, @"message",nil];
            UIView* noticeView = [Utils createNoticeViewWithDictionary:params];
            [cell addSubview:noticeView];
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            return cell;
            break;
        }
            
        default:
            break;
    }
    
    return nil;
}

- (IBAction) popViewController {
	[self.navigationController popViewControllerAnimated:YES];
}

NSComparisonResult _dateSort(NSDictionary *s1, NSDictionary *s2, void *context) {
	return [[s2 objectForKey:@"regDate"] compare:[s1 objectForKey:@"regDate"]];
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0 && indexPath.row == 0) {
        [self openPoiInfo];
        //[tableView deselectRowAtIndexPath:indexPath animated:YES];
        return;
    }
    
    if (indexPath.section == 1) { // 이벤트 클릭 
        if ([eventDataArray count] == 1) {
            GA1(@"POI내이벤트배너_한개");
        }  
        else if ([eventDataArray count] > 1 ) {
            GA1(@"POI내이벤트배너_여러개");
        }

        if ([eventDataArray count] > 0) {

            if ([Utils isBrandUser:[eventDataArray objectAtIndex:indexPath.row]]) {
                GA3(@"이벤트POI", @"브랜드이벤트배너", @"이벤트POI내");
            } 
            else {
                GA3(@"이벤트POI", @"주인장이벤트배너", @"이벤트POI내");
            }
            
            BizWebViewController* vc = [[[BizWebViewController alloc] initWithNibName:@"BizWebViewController" bundle:nil] autorelease];
            NSDictionary* eventCellData = [eventDataArray objectAtIndex:indexPath.row];
            NSString* encoded = [@"이벤트 상세보기" URLEncodedString];
            NSString* aUrl = [eventCellData objectForKey:@"eventInfoLink"];
            vc.urlString = [aUrl stringByAppendingFormat:@"&title_text=%@&right_enable=y&pointX=%@&pointY=%@", encoded, [GeoContext sharedGeoContext].lastTmX, [GeoContext sharedGeoContext].lastTmY];
            vc.curPosition = @"22";
            [(UINavigationController*)[ViewControllers sharedViewControllers].tabBarController.selectedViewController presentModalViewController:vc animated:YES];
        }  
        
    } else if (indexPath.section == 3) { // 마스터
        if ([[poiData objectForKey:@"isEvent"] isEqualToString:@"1"]) {
            GA3(@"이벤트POI", @"마스터", @"이벤트POI내");
        } else {
            GA3(@"POI", @"마스터", @"POI내");
        }
        
        NSArray* resultList = [masterData objectForKey:@"data"];
        NSMutableArray* masterDataList = [NSMutableArray arrayWithArray:resultList];
        
        if ([masterDataList count] <= 0) {
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            return;
        }
        
        MemberInfo* owner = [[[MemberInfo alloc] init] autorelease];
        
        owner.snsId = [[masterDataList objectAtIndex:0] objectForKey:@"snsId"];
        owner.nickname = [[masterDataList objectAtIndex:0] objectForKey:@"nickname"]; 
        owner.profileImgUrl = [[masterDataList objectAtIndex:0] objectForKey:@"profileImg"];
        
        NSDictionary* masterCellData = [masterDataList objectAtIndex:0];
        
        if ([Utils isBrandUser:masterCellData]) { //브랜드면
            BrandHomeViewController* vc = [[[BrandHomeViewController alloc] initWithNibName:@"BrandHomeViewController" bundle:nil] autorelease];
            vc.owner = owner;
            [(UINavigationController*)[ViewControllers sharedViewControllers].tabBarController.selectedViewController pushViewController:vc animated:YES];        
            
        } else {
            UIHomeViewController *vc = [[[UIHomeViewController alloc] initWithNibName:@"UIHomeViewController" bundle:nil] autorelease];
            vc.owner = owner;
            [(UINavigationController*)[ViewControllers sharedViewControllers].tabBarController.selectedViewController pushViewController:vc animated:YES];        
        }
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    } else if (indexPath.section == 4) { // 메인스레드
        if ([cellDataList count] == 0 || [cellDataList count] < indexPath.row) {
            return;
        }
        
        if ([[poiData objectForKey:@"isEvent"] isEqualToString:@"1"]) {
            GA3(@"이벤트POI", @"발도장상세보기", @"이벤트POI내");
        } else {
            GA3(@"POI", @"발도장상세보기", @"POI내");
        }
        
        NSDictionary* aCellData = [cellDataList objectAtIndex:indexPath.row];
        PostDetailTableViewController *vc = [[PostDetailTableViewController alloc] initWithNibName:@"PostDetailTableViewController" bundle:nil];	
        vc.postList = cellDataList;
        vc.postIndex = indexPath.row;
        vc.postData = [[[NSMutableDictionary alloc] initWithDictionary:aCellData] autorelease];
        
        [self.navigationController pushViewController:vc animated:YES];
        [vc release];
        
        [self.navigationController dismissModalViewControllerAnimated:YES];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    } 
    return;
}


#pragma mark - ImInProtocol delegate

- (void) apiDidLoadWithResult:(NSDictionary *)result whichObject:(NSObject *)theObject {
    
	if ([[result objectForKey:@"func"] isEqualToString:@"plazaPostListByPoi"]) {
        
		NSArray* posts = [result objectForKey:@"data"];
        
        MY_LOG(@"post 갯수: %d", [posts count]);
		

		if ([posts count] == 0  && [cellDataList count] == 0) {
            existResultForWholeView = NO;
            self.tableCoverNoticeMessage = @"아직 등록된 발도장이 없어요~\n발도장을 찍어 흔적을 남겨보세요~";
			[postListTableView reloadData];
			return;
		} else {
            existResultForWholeView = YES;
        }
		
		if (needToUpdate) {
			[cellDataList removeAllObjects];
			needToUpdate = NO;
		}
		
        NSIndexPath* thelastCellIndexPath = nil; // 살짝 끌어올리기 용도
        
        if (cellDataList == nil) { // 첫번째 로딩
            self.cellDataList = [NSMutableArray arrayWithArray:posts];
        } else {
            if (isBackward) {
                thelastCellIndexPath = [NSIndexPath indexPathForRow:[cellDataList count] - 1 inSection:2];
            } else {
                if ([posts count] > 0) {
                    thelastCellIndexPath = [NSIndexPath indexPathForRow:[posts count] - 1 inSection:2];                    
                }
            }
        }
        
        for (NSDictionary *data in posts) {
            // 있는지 검색한다. 있으면 댓글 갯수를 업데이트하고 아니면 추가한다.
            BOOL hasFound = NO;
            NSString* postId = [data objectForKey:@"postId"];
            for (NSDictionary* oldCell in cellDataList) {
                if ([[oldCell objectForKey:@"postId"] isEqualToString:postId]) {
                    hasFound = YES;
                }
            }
            if (!hasFound) {
                // 못 찾았다면, 추가해준다.
                [cellDataList addObject:data];
            }
        }
        
        [cellDataList sortUsingFunction:_dateSort context:nil];
        

        lastUpdateLabel.text = [NSString stringWithFormat:@"마지막 갱신: %@", [Utils stringFromDate:[NSDate date]]];

		[postListTableView reloadData];		
        
        // 추가된 부분이 있다면 살짝 올려준다
        if (thelastCellIndexPath != nil) {
            [postListTableView scrollToRowAtIndexPath:thelastCellIndexPath 
                                 atScrollPosition:UITableViewScrollPositionMiddle
                                         animated:YES];
        }
	}
	
	
	if ([[result objectForKey:@"func"] isEqualToString:@"captainAreaListByPoi"]) {
        if ([[result objectForKey:@"result"] boolValue]) {
            self.masterData = result;
        } else {
            MY_LOG(@"마스터 정보 실패");
        }
        [postListTableView reloadData];
	}
    
    if ([[result objectForKey:@"func"] isEqualToString:@"poiInfo"]) {
        MY_LOG(@"poiInfo %@", result);
        self.poiInfoData = result;
        if ([[result objectForKey:@"poiUser"] count] > 0) {
            NSArray *poiUsers = [result objectForKey:@"poiUser"];
            
            self.bizDataArray = [[[NSMutableArray alloc] initWithCapacity:3] autorelease];

            for (NSDictionary *bizData in poiUsers) {
                if (![[bizData objectForKey:@"bizType"] isEqualToString:@""]) {
                    [bizDataArray addObject:bizData];
                }
            }
        }
        isLoadFinish = YES;
        [postListTableView reloadData];
    }
    
    if ([[result objectForKey:@"func"] isEqualToString:@"homeInfo"]) {
        
        MemberInfo* owner = [[[MemberInfo alloc] init] autorelease];
		owner.snsId = [result objectForKey:@"snsId"];
		owner.nickname = [result objectForKey:@"nickname"];
		owner.profileImgUrl = [result objectForKey:@"profileImg"];	
        
        if ([Utils isBrandUser:result]) { //브랜드면
            BrandHomeViewController* vc = [[[BrandHomeViewController alloc] initWithNibName:@"BrandHomeViewController" bundle:nil] autorelease];
            vc.owner = owner;
            [(UINavigationController*)[ViewControllers sharedViewControllers].tabBarController.selectedViewController pushViewController:vc animated:YES];        
            
        } else {
            UIHomeViewController *vc = [[[UIHomeViewController alloc] initWithNibName:@"UIHomeViewController" bundle:nil] autorelease];
            vc.owner = owner;
            [(UINavigationController*)[ViewControllers sharedViewControllers].tabBarController.selectedViewController pushViewController:vc animated:YES];        
        }

    }
    
    if ([[result objectForKey:@"func"] isEqualToString:@"eventList"]) { 
        if ([[result objectForKey:@"result"] boolValue]) { //freeEvent
    
            NSMutableArray* eventArray = [[NSMutableArray alloc]init];
            [eventArray addObjectsFromArray:[result objectForKey:@"specialEvent"]];
            [eventArray addObjectsFromArray:[result objectForKey:@"freeEvent"]];
            self.eventDataArray = eventArray;
            [eventArray release];

            [postListTableView reloadData];
        } else {
            MY_LOG(@"event 리스트 실패");
        }
	}
}

- (void) apiFailedWhichObject:(NSObject *)theObject {

    self.tableCoverNoticeMessage = @"네트워크가 불안합니다\n다시 시도해 주세요~";

	if (theObject == plazaPostListByPoi) {
        if ([cellDataList count] > 0) {
            UIWindow *window = [[[UIApplication sharedApplication] windows] objectAtIndex:0];
            UIView *v = (UIView *)[window viewWithTag:TAG_iTOAST];
            if (!v) {
                iToast *msg = [[iToast alloc] initWithText:@"네트워크가 불안합니다. \n잠시 후 다시 시도해 주세요~"];
                [msg setDuration:2000];
                [msg setGravity:iToastGravityCenter];
                [msg show];
                [msg release];
            }
        }
//		[CommonAlert alertWithTitle:@"에러" message:@"네트워크가 불안하여 발도장 목록을 가져올수 없어요~"];
		
		if (needToUpdate) {
			needToUpdate = NO;
		}
        existResultForWholeView = NO;
        [postListTableView reloadData];
	}
}

#pragma mark 마스터 요청
- (void) requestMasterInfo {
	self.captainAreaListByPoi = [[[CaptainAreaListByPoi alloc] init] autorelease];
	captainAreaListByPoi.delegate = self;
	MY_LOG(@"poiKey = %@", [poiData objectForKey:@"poiKey"]);
	[captainAreaListByPoi.params addEntriesFromDictionary:[NSDictionary dictionaryWithObject:[poiData objectForKey:@"poiKey"]
																					  forKey:@"poiKey"]];
	[captainAreaListByPoi request];
}

#pragma mark POI 정보 요청
- (void)requestPoiInfo {
    isLoadFinish = NO;
    self.poiInfo = [[[PoiInfo alloc] init] autorelease];
    self.poiInfo.delegate = self;
    self.poiInfo.poiKey = [poiData objectForKey:@"poiKey"];
    [self.poiInfo requestWithoutIndicator];
}

#pragma mark 전체 발도장 리스트 요청
- (void) requestWholeCheckIns {
    
    isBackward = YES;
    
	lastPostIdForWhole = [[cellDataList lastObject] objectForKey:@"postId"];
	
	if (needToUpdate || lastPostIdForWhole == nil)
	{
		lastPostIdForWhole = @"";
	}
    
	self.plazaPostListByPoi = [[[PlazaPostListByPoi alloc] init] autorelease];
	plazaPostListByPoi.delegate = self;
	[plazaPostListByPoi.params addEntriesFromDictionary:[NSDictionary dictionaryWithObjectsAndKeys:
														 lastPostIdForWhole, @"postId",
														 [poiData objectForKey:@"poiKey"], @"poiKey",
														 @"25", @"maxScale",
														 nil]];
    
	[plazaPostListByPoi requestWithAuth:NO withIndicator:YES];
}
- (void) requestWholeCheckInsNew {
    
    isBackward = NO;
    
    if ([cellDataList count] > 0) {
        latestPostIdForWhole = [[cellDataList objectAtIndex:0] objectForKey:@"postId"];    
    }
    else
        latestPostIdForWhole = @"";
    
	self.plazaPostListByPoi = [[[PlazaPostListByPoi alloc] init] autorelease];
	plazaPostListByPoi.delegate = self;
	[plazaPostListByPoi.params addEntriesFromDictionary:[NSDictionary dictionaryWithObjectsAndKeys:
														 [NSString stringWithFormat:@"-%@", latestPostIdForWhole], @"postId",
														 [poiData objectForKey:@"poiKey"], @"poiKey",
														 @"25", @"maxScale",
														 nil]];
    
	[plazaPostListByPoi requestWithAuth:NO withIndicator:YES];
}

#pragma mark -
#pragma mark IBAction define

-(void) openLargeMap {
	MY_LOG(@"openLargeMap");
	if ([[poiData objectForKey:@"isEvent"] isEqualToString:@"1"]) {
        GA3(@"이벤트POI", @"지도버튼", @"이벤트POI내");
    } else {
        GA3(@"POI", @"지도버튼", @"POI내");
    }
    
    GoogleMapViewController* mapVC = [[[GoogleMapViewController alloc] init] autorelease];
    mapVC.mapInfo = poiData;
    
    [mapVC setHidesBottomBarWhenPushed:YES];
    
    [(UINavigationController*)[ViewControllers sharedViewControllers].tabBarController.selectedViewController pushViewController:mapVC animated:YES];
}

- (IBAction)profileClicked:(id)sender {
    // 콜럼버스는 사용하지 않으므로 브랜드 홈 적용 안함	
	MemberInfo* owner = [[[MemberInfo alloc] init] autorelease];
	owner.snsId = self.columbusSnsID;
	owner.profileImgUrl = self.columbusProfileImageURL;	
	
	self.homeInfo = [[[HomeInfo alloc] init] autorelease];
	homeInfo.delegate = self;
	homeInfo.snsId = self.columbusSnsID;
	[homeInfo request];
}

- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView {
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    
	if (isTop && !isEnd) {
            [self requestWholeCheckInsNew];
		return;
	}
	
	if (isEnd && !isTop) {
            [self requestWholeCheckIns];       
		return;
	}
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	if (scrollView.contentOffset.y < 0) {
		float y = scrollView.contentOffset.y;
		if (y < -60) {
			y = -60;
		}
		CGAffineTransform transform = CGAffineTransformMakeRotation(y * M_PI / 60);
		arrow.transform = transform;
		isTop = YES;
	} else {
		isTop = NO;
	}
    
	if (scrollView.contentOffset.y + postListTableView.frame.size.height + 10 > scrollView.contentSize.height) {
		isEnd = YES;
	} else {
		isEnd = NO;
	}
}

- (IBAction) openEventUrl
{
	if (![eventUrlString isEqualToString:@""]) {
		CommonWebViewController* vc = [[[CommonWebViewController alloc] initWithNibName:@"CommonWebViewController" bundle:nil] autorelease];
		vc.urlString = eventUrlString;
		[(UINavigationController*)[ViewControllers sharedViewControllers].tabBarController.selectedViewController 
		 presentModalViewController:vc animated:YES];
	}
}

- (void) openPoiInfo
{
    if ([[poiData objectForKey:@"isEvent"] isEqualToString:@"1"]) {
        GA3(@"이벤트POI", @"POI상세", @"이벤트POI내");
    } else {
        GA3(@"POI", @"POI상세", @"POI내");
    }
    if (poiInfoData && [[poiInfoData objectForKey:@"hasShopInfo"] boolValue]) {
        PoiInfoViewController* vc = [[[PoiInfoViewController alloc] initWithNibName:@"PoiInfoViewController" bundle:nil] autorelease];
        vc.poiInfoResult = poiInfoData;
        vc.poiKey = [poiData objectForKey:@"poiKey"];
        
        [(UINavigationController*)[ViewControllers sharedViewControllers].tabBarController.selectedViewController 
         pushViewController:vc animated:YES];
    } else {
        [self openLargeMap];
    }
}

#pragma mark Notification
- (void) reloadList: (NSNotification*) noti
{	
    [self requestWholeCheckInsNew];
}
@end

