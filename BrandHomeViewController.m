//
//  BrandHomeViewController.m
//  ImIn
//
//  Created by KYONGJIN SEO on 10/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "BrandHomeViewController.h"
#import "UIImageView+WebCache.h"
#import "NSString+URLEncoding.h"
#import "UITabBarItem+WithImage.h"

#import "BizWebViewController.h"
#import "FriendSetViewController.h"
#import "POIDetailViewController.h"
#import "PostDetailTableViewController.h"
#import "POIListViewController.h"

#import "Utils.h"
#import "MainThreadCell.h"
#import "EventCell.h"
#import "iToast.h"

#import "PostList.h"
#import "HomeInfo.h"
#import "HomeInfoDetail.h"
#import "EventList.h"

@implementation BrandHomeViewController
@synthesize friendBtn;
@synthesize homeInfo;
@synthesize postList, eventList;
@synthesize owner;
@synthesize brandDataList;
@synthesize wholeDataList;
@synthesize tableCoverNoticeMessage;
@synthesize footPrintsTableView;
@synthesize isNeighborList;
@synthesize isToMeNeighbor;
@synthesize curPosition;
@synthesize eventDataArray;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
		self.title = @"마이홈";
		[self.tabBarItem resetWithNormalImage:[UIImage imageNamed:@"GNB_03_off.png"] 
								selectedImage:[UIImage imageNamed:@"GNB_03_on.png"]];
    }
    return self;
}

- (void)viewDidLoad
{
    existRecentBrandCheckIn = YES;
    
    [checkInBtn setHidden:YES];
    
    //현재 뷰컨트롤러가 탑뷰라면 이전 버튼을 없애주자.
	if( self == [self.navigationController.viewControllers objectAtIndex:0] ) {
		[self.view viewWithTag:1000].hidden = YES;
	}
    
	// owner를 정의
	if (owner == nil) { 
		// 나의 홈 정보 초기화
		self.owner = [[[MemberInfo alloc] init] autorelease];
		owner.snsId = [UserContext sharedUserContext].snsID;
		owner.profileImgUrl = [UserContext sharedUserContext].userProfile;
		owner.nickname = [UserContext sharedUserContext].nickName;
	}

    
    tabIndex = 0;
    [titleLabel setText:nil];

    [footPrintsTableView setDelegate:self];
    [footPrintsTableView setDataSource:self];
    [footPrintsTableView setSeparatorColor:RGB(181, 181, 181)];
	[self.navigationController setNavigationBarHidden:YES animated:NO];
    
    [self performSelector:@selector(brandCheckInClicked)];
}

- (void) viewWillAppear:(BOOL)animated {
    [self requestHomeInfo];

	// notification observer 등록
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(autoUpdateCompleted:) name:@"autoUpdate" object:nil];
	
    // 쿠키 정보를 요청한다. (없을 경우에만)
    [[UserContext sharedUserContext] requestSnsCookie];
    
    self.tableCoverNoticeMessage = @"데이터를 불러오고 있습니다.";
 
    [footPrintsTableView reloadData];
}

#pragma mark - notification handler
- (void) autoUpdateCompleted:(NSNotification*) noti
{
}

#pragma mark - UIButton handler

- (IBAction) goCheckIn
{	
	if ([[UserContext sharedUserContext].snsID isEqualToString:owner.snsId]) {
		GA3(@"마이홈", @"발도장찍기", @"브랜드홈내");
	} else {
		GA3(@"타인홈", @"발도장찍기", @"브랜드홈내");
	}
    
	POIListViewController *vc = [[POIListViewController alloc] initWithNibName:@"POIListViewController" bundle:nil];
    vc.currPostWriteFlow = OLD_POSTFLOW;
	[self.navigationController pushViewController:vc animated:YES];
	[vc release];
}

- (void)setFootPrintsTab:(BOOL)isRecent {
    //브랜드 발도장 최신 데이트가 일주일 이내일 경우 브랜드 탭을 먼저 보여줌
    if (isRecent) // 최신 데이터 있을 때  
    {
        [self performSelector:@selector(brandCheckInClicked)];
    }
    else
        [self performSelector:@selector(wholeCheckInClicked)];
}

- (IBAction)prevBtnClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)bannerBtnClicked:(id)sender {
    //web page 로 이동
    GA3(@"브랜드홈", @"브랜드홈메인사진", @"브랜드홈내");
    
    BizWebViewController *vc = [[BizWebViewController alloc] initWithNibName:@"BizWebViewController" bundle:nil];
    
#ifdef APP_STORE_FINAL    
    vc.urlString = [NSString stringWithFormat:@"http://im-in.paran.com/mobile/homeInfoDetail.kth?isDataHtml=10&snsId=%@&right_enable=y&title_text=%@&pointX=%@&pointY=%@", owner.snsId, [@"브랜드 프로필" URLEncodedString], [GeoContext sharedGeoContext].lastTmX, [GeoContext sharedGeoContext].lastTmY];
#else
    vc.urlString = [NSString stringWithFormat:@"http://imindev.paran.com/sns/mobile/homeInfoDetail.kth?isDataHtml=10&snsId=%@&right_enable=y&title_text=%@&pointX=%@&pointY=%@", owner.snsId, [@"브랜드 프로필" URLEncodedString], [GeoContext sharedGeoContext].lastTmX, [GeoContext sharedGeoContext].lastTmY];
#endif
    
    [(UINavigationController*)[ViewControllers sharedViewControllers].tabBarController.selectedViewController presentModalViewController:vc animated:YES];
    [vc release];
}

- (IBAction)friendBtnClicked {
    
    if( FR_YOU == friendCodeInt || FR_NONE == friendCodeInt ) {     //이웃이 아닌경우
		GA3(@"브랜드홈", @"브랜드이웃추가버튼", @"브랜드홈내");
	} else {
		GA3(@"브랜드홈", @"브랜드이웃설정버튼", @"브랜드홈내");
	}
    
	FriendSetViewController *vc = [[FriendSetViewController alloc]initWithName:owner.nickname friendSnsId:owner.snsId friendCode:friendCodeInt friendImage:owner.profileImgUrl];
	vc.referCode = @"0001"; // 이웃홈 이웃추가
	[vc setHidesBottomBarWhenPushed:YES];
	[self.navigationController pushViewController:vc animated:YES];
	[vc release];
}

- (IBAction)wholeCheckInClicked {
    
    tabIndex = 1;
    if (wholeDataList!=nil) {
        [wholeDataList removeAllObjects];
        self.wholeDataList = nil;
    }
    [wholeBtn setImage:[UIImage imageNamed:@"brandhome_tab2_on.png"] forState:UIControlStateNormal];
    [brandBtn setImage:[UIImage imageNamed:@"brandhome_tab1_off.png"] forState:UIControlStateNormal];
    
    //request
    self.postList = [[[PostList alloc] init] autorelease];
    postList.delegate = self;
    
    [postList.params addEntriesFromDictionary:
     [NSDictionary dictionaryWithObjectsAndKeys:owner.snsId, @"snsId",
      @"25", @"maxScale",
      @"1", @"relation",
      @"0", @"postType", 
      @"1", @"bizPostType", nil]];
    
	[self requestWholeFootPoiList];
}

- (IBAction)brandCheckInClicked {
    
    tabIndex = 0;
    if (brandDataList!=nil) {
        [brandDataList removeAllObjects];
        self.brandDataList = nil;
    }
    [wholeBtn setImage:[UIImage imageNamed:@"brandhome_tab2_off.png"] forState:UIControlStateNormal];
    [brandBtn setImage:[UIImage imageNamed:@"brandhome_tab1_on.png"] forState:UIControlStateNormal];
    
    //request
    self.postList = [[[PostList alloc] init] autorelease];
    postList.delegate = self;
    
    [postList.params addEntriesFromDictionary:
     [NSDictionary dictionaryWithObjectsAndKeys:owner.snsId, @"snsId",
      @"25", @"maxScale",
      @"1", @"relation",
      @"0", @"postType", 
      @"2", @"bizPostType", nil]];
    
	[self requestBrandFootPoiList];
}
- (IBAction)checkInBtnClicked:(id)sender {    
    
    if ([[UserContext sharedUserContext].snsID isEqualToString:owner.snsId]) {
        GA3(@"마이홈", @"발도장찍기", @"브랜드홈내");
    } else {
        GA3(@"타인홈", @"발도장찍기", @"브랜드홈내");
    }
    
    POIListViewController *vc = [[POIListViewController alloc] initWithNibName:@"POIListViewController" bundle:nil];
    vc.currPostWriteFlow = OLD_POSTFLOW;
    [self.navigationController pushViewController:vc animated:YES];
    [vc release];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    //  section 0   event
    //  section 1   footprints
    //  section 2   error msg view
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    // event 섹션
    if (section == 0) {
        return [eventDataArray count];
    }
    
    // 발도장 섹션
    else if (section == 1) {
        
        return (tabIndex == 0) ? [brandDataList count] : [wholeDataList count];
    }
    
    // 안내 메시지 섹션
    else if (section == 2) {
        if (tabIndex == 0 && [brandDataList count] == 0) {
            return 1;
        }
        if (tabIndex == 1 && [wholeDataList count] == 0) {
            return 1;
        }
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	NSInteger cnt = (tabIndex == 0) ? [brandDataList count] : [wholeDataList count];
    
    if (cnt == 0 && indexPath.section == 2) {   // no data
        return 220.0f;
    } else if (indexPath.section == 0) {
        return 59.0f;
    } else if (indexPath.section == 1 && cnt !=0) {		
		NSDictionary* cellData = (tabIndex == 0) ? [brandDataList objectAtIndex:indexPath.row] : [wholeDataList objectAtIndex:indexPath.row];
		
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
    } 
    
    return 44.0f;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSInteger cnt = (tabIndex == 0) ? [brandDataList count] : [wholeDataList count];
    
    if (indexPath.section == 0) {
        // Event Cell
        static NSString *CellIdentifier = @"eventCell";
        EventCell *cell = (EventCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            MY_LOG(@"만들자");
            NSArray* nibObjects = [[NSBundle mainBundle] loadNibNamed:@"EventCell" owner:nil options:nil];
            
            for (id currentObject in nibObjects) {
                if([currentObject isKindOfClass:[EventCell class]]) {
                    cell = (EventCell*) currentObject;
                }
            }
        }
        [tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        
        NSDictionary* eventCellData = [eventDataArray objectAtIndex:indexPath.row];
        [cell redrawEventCellWithCellData:eventCellData];
        
        return cell;
    }
    else if (indexPath.section == 1) {
        static NSString *CellIdentifier = @"MainThreadCell";
        
        MainThreadCell *cell = (MainThreadCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell == nil) {
            //			MY_LOG(@"Cell created");
            NSArray* nibObjects = [[NSBundle mainBundle] loadNibNamed:@"MainThreadCell" owner:nil options:nil];
            
            for (id currentObject in nibObjects) {
                if([currentObject isKindOfClass:[MainThreadCell class]]) {
                    cell = (MainThreadCell*) currentObject;
                }
            }
        }
        
        if (cnt == 0) {
            return cell;
        }
        NSDictionary* cellData = (tabIndex == 0) ? [brandDataList  objectAtIndex:indexPath.row] : [wholeDataList objectAtIndex:indexPath.row];
        [cell redrawMainThreadCellWithCellData:cellData];
        
        // TODO: GA 적용할 때 분기 처리하기 위해 필요
        //cell.curPosition = [[UserContext sharedUserContext].snsID isEqualToString:owner.snsId] ? @"6" : @"7";

        return cell;
    }
    else if (indexPath.section == 2 && cnt == 0) {
        static NSString *CellIdentifier = @"NoticeCell";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        }
        
//        if (!([owner.nickname isEqualToString:@""] || owner.nickname == nil)) {
//            if ( [owner.snsId isEqualToString:[UserContext sharedUserContext].snsID] ) {
//                self.tableCoverNoticeMessage = @"아직 발도장 찍은 곳이 없습니다.\n발도장을 찍어 흔적을 남겨 보세요.";
//            } else {
//                if (tabIndex == 0) {
//                    self.tableCoverNoticeMessage = [NSString stringWithFormat:@"%@님은 아직\n발도장 찍은 곳이 없어요.",owner.nickname];
//                } else {
//                    self.tableCoverNoticeMessage = [NSString stringWithFormat:@"%@에 등록된 발도장이 없어요.\n발도장을 찍어 흔적을 남겨 보세요",owner.nickname];
//                }
//            }
//        }

        NSDictionary* params = [NSDictionary dictionaryWithObjectsAndKeys:
                                [NSNumber numberWithFloat:320], @"width", 
                                [NSNumber numberWithFloat:220], @"height",
                                tableCoverNoticeMessage, @"message",nil];
        UIView* noticeView = [Utils createNoticeViewWithDictionary:params];
        [cell addSubview:noticeView];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        return cell;
    }
    return nil;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
    if (indexPath.section == 0) {
        
        if ([eventDataArray count] == 1) {
            GA3(@"브랜드홈", @"이벤트배너", @"한개_브랜드홈내");
        } else if ([eventDataArray count] > 1) {
            GA3(@"브랜드홈", @"이벤트배너", @"여러개_브랜드홈내");
        }
        
        if ([eventDataArray count] > 0) {
            BizWebViewController* vc = [[[BizWebViewController alloc] initWithNibName:@"BizWebViewController" bundle:nil] autorelease];
            
            GeoContext* gc = [GeoContext sharedGeoContext];
            
            NSDictionary* eventCellData = [eventDataArray objectAtIndex:indexPath.row];
            vc.urlString = [[eventCellData objectForKey:@"eventInfoLink"] stringByAppendingFormat:@"&title_text=%@&right_enable=y&pointX=%@&pointY=%@", 
                            [@"이벤트 상세보기" URLEncodedString], 
                            [gc.lastTmX stringValue],
                            [gc.lastTmY stringValue]];
            vc.curPosition = @"22";
            
            [(UINavigationController*)[ViewControllers sharedViewControllers].tabBarController.selectedViewController 
             presentModalViewController:vc animated:YES];
        }  
    }
    
    if (indexPath.section == 1) {
        if (tabIndex == 0) {
            if ([brandDataList count] == 0 || [brandDataList count] < indexPath.row) {
                return;
            }
            NSDictionary* cellData = [brandDataList objectAtIndex:indexPath.row];
            
            if ([[cellData objectForKey:@"postId"] isEqualToString:@""]) {
                // 잘못된 postID 에 대해서는 못가게 막자
                return;
            }
            
            PostDetailTableViewController* vc = [[[PostDetailTableViewController alloc] 
                                                  initWithNibName:@"PostDetailTableViewController" 
                                                  bundle:nil] autorelease];
            vc.postList = brandDataList;
            vc.postData = [[[NSMutableDictionary alloc] initWithDictionary:cellData] autorelease];
            vc.postIndex = indexPath.row;
            
            [[tableView cellForRowAtIndexPath:indexPath] setSelected:FALSE animated:YES];
            
            [(UINavigationController*)[ViewControllers sharedViewControllers].tabBarController.selectedViewController pushViewController:vc animated:YES];
            
        }
        
        if (tabIndex == 1) {
            if ([wholeDataList count] == 0) { // 주의: indexPath 0, 0 에 대해서 안내 문구 표시용으로 사용중이므로 선택을 막아야 함.
                return;
            }
            NSDictionary* cellData = [wholeDataList objectAtIndex:indexPath.row];
            
            if (tabIndex == 0) {
                GA3(@"브랜드홈", @"발도장상세보기", @"브랜드발도장탭내");
            } else if (tabIndex == 1) {
                GA3(@"브랜드홈", @"발도장상세보기", @"전체발도장탭내");
            }
            
            PostDetailTableViewController* vc = [[[PostDetailTableViewController alloc] 
                                                  initWithNibName:@"PostDetailTableViewController" 
                                                  bundle:nil] autorelease];
            vc.postList = wholeDataList;
            vc.postData = [[[NSMutableDictionary alloc] initWithDictionary:cellData] autorelease];
            vc.postIndex = indexPath.row;
            
            
            [[tableView cellForRowAtIndexPath:indexPath] setSelected:FALSE animated:YES];
            
            [(UINavigationController*)[ViewControllers sharedViewControllers].tabBarController.selectedViewController pushViewController:vc animated:YES];
            
        }
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

#pragma mark - API handler

-(void) apiDidLoadWithResult:(NSDictionary*)result whichObject:(NSObject*) theObject {
    if ([[result objectForKey:@"func"] isEqualToString:@"homeInfo"]) {
		[self processHomeInfo:result];
	}

    if ([[result objectForKey:@"func"] isEqualToString:@"postList"]) {
        [self processPostList:result];
    }
    
    if ([[result objectForKey:@"func"] isEqualToString:@"eventList"]) { 
        if ([[result objectForKey:@"result"] boolValue]) {
            self.eventDataArray = [result objectForKey:@"specialEvent"];
            [footPrintsTableView reloadData];
        } else {
            MY_LOG(@"event 리스트 실패");
        }
	}
}

- (void) apiFailedWhichObject:(NSObject *)theObject {

    self.tableCoverNoticeMessage = @"네트워크가 불안합니다.\n다시 시도해주세요~!";

    if (theObject == homeInfo) {
//        iToast *msg = [[iToast alloc] initWithText:@"네트워크가 불안합니다. \n잠시 후 다시 시도해 주세요~"];
//        [msg setDuration:2000];
//        [msg setGravity:iToastGravityCenter];
//        [msg show];
//        [msg release];
//        [CommonAlert alertWithTitle:@"안내" message:@"네트워크 접속이 불안정하여 홈 정보를 가져오지 못했습니다~!"];
    }
    
    if (theObject == postList) {
        if (tabIndex == 0 && [wholeDataList count]) {
            UIWindow *window = [[[UIApplication sharedApplication] windows] objectAtIndex:0];
            UIView *v = (UIView *)[window viewWithTag:TAG_iTOAST];
            if (!v) {
                iToast *msg = [[iToast alloc] initWithText:@"네트워크가 불안합니다. \n잠시 후 다시 시도해 주세요~"];
                [msg setDuration:2000];
                [msg setGravity:iToastGravityCenter];
                [msg show];
                [msg release];
            }
            self.wholeDataList = nil;
        }
        else if (tabIndex == 1 && [brandDataList count]) {
            UIWindow *window = [[[UIApplication sharedApplication] windows] objectAtIndex:0];
            UIView *v = (UIView *)[window viewWithTag:TAG_iTOAST];
            if (!v) {
                iToast *msg = [[iToast alloc] initWithText:@"네트워크가 불안합니다. \n잠시 후 다시 시도해 주세요~"];
                [msg setDuration:2000];
                [msg setGravity:iToastGravityCenter];
                [msg show];
                [msg release];
            }
            self.brandDataList = nil;
        }
    }
    [footPrintsTableView reloadData];

}

#pragma mark - UIScrollView delegate

- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView {
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    
	if (isTop && !isEnd) {
        if (tabIndex == 0) {
            [self requestBrandFootPoiListNew];
        } 
        else
            [self requestWholeFootPoiListNew];
		return;
	}
	
	if (isEnd && !isTop) {
        if (tabIndex == 0) {
            [self requestBrandFootPoiListOld];            
        } else {
            [self requestWholeFootPoiListOld];
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
	
	if (scrollView.contentOffset.y + footPrintsTableView.frame.size.height + 10 > scrollView.contentSize.height) {
		isEnd = YES;
	} else {
		isEnd = NO;
	}
}

#pragma mark - 네트워크 요청

// 마이홈 홈 정보 요청
- (void) requestHomeInfo
{
	self.homeInfo = [[[HomeInfo alloc] init] autorelease];
	self.homeInfo.snsId = owner.snsId;
	self.homeInfo.delegate = self;
	[self.homeInfo request];
}

// 마이홈 발도장 목록 요청
- (void) requestBrandFootPoiList
{
	self.postList = [[[PostList alloc] init] autorelease];
    postList.delegate = self;
    
    [postList.params addEntriesFromDictionary:
     [NSDictionary dictionaryWithObjectsAndKeys:owner.snsId, @"snsId",
      @"25", @"maxScale",
      @"1", @"relation",
      @"2", @"postType",
      @"2", @"bizPostType", nil]];  // 2: 브랜드
    
	[postList request];
}

- (void) requestWholeFootPoiList
{
	self.postList = [[[PostList alloc] init] autorelease];
    postList.delegate = self;
    
    [postList.params addEntriesFromDictionary:
     [NSDictionary dictionaryWithObjectsAndKeys:owner.snsId, @"snsId",
      @"25", @"maxScale",
      @"1", @"relation",
      @"2", @"postType",
      @"1", @"bizPostType", nil]];  // 1: 전체
    
	[postList request];
}


// 이전의 발도장 요청
- (void) requestWholeFootPoiListOld
{
    isBackward = YES; // 이전 것을 요청하니?
    
	self.postList = [[[PostList alloc] init] autorelease];
    postList.delegate = self;
    
    [postList.params addEntriesFromDictionary:
     [NSDictionary dictionaryWithObjectsAndKeys:owner.snsId, @"snsId",
      @"25", @"maxScale",
      @"1", @"relation",
      @"2", @"postType",
      @"1", @"bizPostType", nil]];
    
    NSString* lastPostId = [[wholeDataList lastObject] objectForKey:@"postId"];
    
    if (lastPostId != nil) {
        [postList.params addEntriesFromDictionary:[NSDictionary dictionaryWithObject:lastPostId forKey:@"postId"]];
    }
    
	[postList request];
}

- (void) requestBrandFootPoiListOld
{
    isBackward = YES; // 이전 것을 요청하니?
    
	self.postList = [[[PostList alloc] init] autorelease];
    postList.delegate = self;
    
    [postList.params addEntriesFromDictionary:
     [NSDictionary dictionaryWithObjectsAndKeys:owner.snsId, @"snsId",
      @"25", @"maxScale",
      @"1", @"relation",
      @"2", @"postType",
      @"2", @"bizPostType", nil]];
    
    NSString* lastPostId = [[brandDataList lastObject] objectForKey:@"postId"];
    
    if (lastPostId != nil) {
        [postList.params addEntriesFromDictionary:[NSDictionary dictionaryWithObject:lastPostId forKey:@"postId"]];
    }
    
	[postList request];
}

// 새로운 발도장 요청
- (void) requestWholeFootPoiListNew
{
    isBackward = NO;
    
	self.postList = [[[PostList alloc] init] autorelease];
    postList.delegate = self;
    
    [postList.params addEntriesFromDictionary:
     [NSDictionary dictionaryWithObjectsAndKeys:owner.snsId, @"snsId",
      @"25", @"maxScale",
      @"1", @"relation",
      @"2", @"postType",
      @"1", @"bizPostType", nil]];
    
    if ([wholeDataList count] > 0) {
        NSString* latestPostId = [[wholeDataList objectAtIndex:0] objectForKey:@"postId"];
        
        if (latestPostId != nil) {
            [postList.params addEntriesFromDictionary:[NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"-%@", latestPostId]
                                                                                  forKey:@"postId"]];
        }        
    }
    
	[postList request];
}

- (void) requestBrandFootPoiListNew
{
    isBackward = NO;
    
	self.postList = [[[PostList alloc] init] autorelease];
    postList.delegate = self;
    
    [postList.params addEntriesFromDictionary:
     [NSDictionary dictionaryWithObjectsAndKeys:owner.snsId, @"snsId",
      @"25", @"maxScale",
      @"1", @"relation",
      @"2", @"postType",
      @"2", @"bizPostType", nil]];
    
    if ([brandDataList count] > 0) {
        NSString* latestPostId = [[brandDataList objectAtIndex:0] objectForKey:@"postId"];
        
        if (latestPostId != nil) {
            [postList.params addEntriesFromDictionary:[NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"-%@", latestPostId]
                                                                                  forKey:@"postId"]];

        }        
    }
    
	[postList request];
}

- (void) requestEventListWithBizId:(NSString*) bizId 
{
    self.eventList = [[[EventList alloc] init] autorelease];
    eventList.delegate = self;
    [eventList.params addEntriesFromDictionary:[NSDictionary dictionaryWithObject:bizId forKey:@"bizId"]];
    [eventList.params addEntriesFromDictionary:[NSDictionary dictionaryWithObject:[UserContext sharedUserContext].snsID forKey:@"snsId"]];
    
    [eventList requestWithAuth:NO withIndicator:YES];
}

- (void) requestPostListWithOption:(NSInteger) bizPostType 
{
}

#pragma mark - 응답에 대한 처리
NSComparisonResult sortOfDate(NSDictionary *s1, NSDictionary *s2, void *context) {
	return [[s2 objectForKey:@"regDate"] compare:[s1 objectForKey:@"regDate"]];
}

- (void) processPostList:(NSDictionary*) result {
    if (![[result objectForKey:@"result"] boolValue]) {
        self.tableCoverNoticeMessage = [result objectForKey:@"description"];
        [footPrintsTableView reloadData];
        return;
    }
    
    NSIndexPath* thelastCellIndexPath = nil; // 살짝 끌어올리기 용도
    
    BOOL existNewData = NO;                 // 추가데이터가 존재여부 체크 후 스크롤 위치 조절
    
    NSArray* poiList = [result objectForKey:@"data"];
    
    
    if ([poiList count] == 0) {
        if ( [owner.snsId isEqualToString:[UserContext sharedUserContext].snsID] ) {
            self.tableCoverNoticeMessage = @"아직 발도장 찍은 곳이 없습니다.\n발도장을 찍어 흔적을 남겨 보세요.";
        } else {
            //if (!([owner.nickname isEqualToString:@""] || owner.nickname == nil)) {
                if (tabIndex == 0) {
                    self.tableCoverNoticeMessage = @"아직 발도장 찍은 곳이 없어요.";
                } else {
                    self.tableCoverNoticeMessage = @"등록된 발도장이 없어요.\n발도장을 찍어 흔적을 남겨 보세요";
                }
            //}
        }
    } else {
        if (tabIndex == 0) {
            
            if (tabIndex == 0) {
                [brandDataList sortUsingFunction:sortOfDate context:nil];
            }
            else
                [wholeDataList sortUsingFunction:sortOfDate context:nil];

            
            if (brandDataList== nil) { // 첫번째 로딩
                self.brandDataList = [NSMutableArray arrayWithArray:poiList];
            } else {
                if (isBackward) {
                    thelastCellIndexPath = [NSIndexPath indexPathForRow:[brandDataList count] - 1 inSection:1];
                } else {
                    thelastCellIndexPath = [NSIndexPath indexPathForRow:[poiList count] - 1 inSection:1];
                }
            }
        }
        else if (tabIndex == 1) {
            if (wholeDataList== nil) { // 첫번째 로딩
                self.wholeDataList = [NSMutableArray arrayWithArray:poiList];
            } else {
                if (isBackward) {
                    thelastCellIndexPath = [NSIndexPath indexPathForRow:[wholeDataList count] - 1 inSection:1];
                } else {
                    thelastCellIndexPath = [NSIndexPath indexPathForRow:[poiList count] - 1 inSection:1];
                }
            }
        }
        
        for (NSDictionary *poiData in poiList) {
            // 있는지 검색한다. 있으면 댓글 갯수를 업데이트하고 아니면 추가한다.
            BOOL hasFound = NO;
            NSString* postId = [poiData objectForKey:@"postId"];
            NSMutableArray *dataArray = (tabIndex == 0) ? brandDataList : wholeDataList;
            
            for (NSDictionary* oldCell in dataArray) {
                if ([[oldCell objectForKey:@"postId"] isEqualToString:postId]) {
                    hasFound = YES;
                }
            }
            if (!hasFound) {
                // 못 찾았다면, 추가해준다.
                if (tabIndex == 0) {
                    [brandDataList addObject:poiData];
                }
                else
                    [wholeDataList addObject:poiData];
                existNewData = YES;
            }     
            else {
                existNewData = NO;
            }
        }
    }
    
    [footPrintsTableView reloadData];
    
    if (existRecentBrandCheckIn) {        // 브랜드 발도장 최근 글이 일주일 이내일 때 브랜드 발도장 탭 표시
        [self checkRecentBrandCheckInData];
    }
    
    // 추가된 부분이 있다면 살짝 올려준다
    if ( thelastCellIndexPath != nil && existNewData ) {
        [footPrintsTableView scrollToRowAtIndexPath:thelastCellIndexPath 
                             atScrollPosition:UITableViewScrollPositionMiddle
                                     animated:YES];
    }
}

- (void) processHomeInfo:(NSDictionary*) result {
    
    NSNumber* isOpen = [result objectForKey:@"isOpenHome"];
	
    if (![[UserContext sharedUserContext].snsID isEqualToString:owner.snsId]) {
        if ([isOpen intValue] == 0) {
            [CommonAlert alertWithTitle:@"알림" message:@"해당홈은 비공개입니다."];
            [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(goBack) userInfo:nil repeats:NO];
            //				[self goBack];
            return;
        }
        
        [checkInBtn setHidden:YES];
        [friendBtn setHidden:NO];
    }
    else {
        [checkInBtn setHidden:NO];
        [friendBtn setHidden:YES];
    }
    
    NSString *whoIs = [result objectForKey:@"isPerm"];
    
    // 서로 이웃인지 여부를 확인해서 표시한다.
    if (![whoIs isEqualToString:@"OWNER"]) {
        
        if( [whoIs isEqualToString:@"FRIEND"] ){
            friendCodeInt = FR_TRUE;
        }else if( [whoIs isEqualToString:@"NEIGHBOR_YOU"] ){ 
            friendCodeInt = FR_ME;  // 항상 다른사람의 홈페이지으므로 의미가 반대가 된다.
        }else if( [whoIs isEqualToString:@"NEIGHBOR_ME"] ){
            friendCodeInt = FR_YOU; // 따라서, 나(그사람을)를 (내가)등록한 이웃 이라는 뜻이 됨.
        }else{
            friendCodeInt = FR_NONE;
        }
        
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.3];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
        [UIView setAnimationBeginsFromCurrentState:YES];
        
        if( FR_YOU == friendCodeInt || FR_NONE == friendCodeInt )
            [friendBtn setImage:[UIImage imageNamed:@"btntop_friadd.png"] forState:UIControlStateNormal];
        else
            [friendBtn setImage:[UIImage imageNamed:@"btntop_fri.png"] forState:UIControlStateNormal];
        [friendBtn setAlpha:1.0];
        [UIView commitAnimations];
    }
    
    // 브랜드 홈에 대한 처리
    [brandImageVIew setImageWithURL:[NSURL URLWithString:[result objectForKey:@"bgImg4App"]] placeholderImage:[UIImage imageNamed:@"brand_loading.png"]];
    
    NSString* bizId = [[result objectForKey:@"bizId"] stringValue];
    
    self.owner.nickname = [result objectForKey:@"bizNickname"];
    self.owner.profileImgUrl = [result objectForKey:@"profileImg"];
    titleLabel.text = owner.nickname;

    [footPrintsTableView reloadData];
   
    [self requestEventListWithBizId:bizId];
}

- (void) processPoiInfo:(NSDictionary*) result {
    POIDetailViewController *vc = [[POIDetailViewController alloc] initWithNibName:@"POIDetailViewController" bundle:nil];
    vc.poiData = result;
    [(UINavigationController*)[ViewControllers sharedViewControllers].tabBarController.selectedViewController pushViewController:vc animated:YES];
    [vc release];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return [ApplicationContext sharedApplicationContext].shouldRotate;
}

- (IBAction) goBack
{
	[self.navigationController popViewControllerAnimated:YES];
}

- (void) checkRecentBrandCheckInData {
    NSDate *lastDate = [Utils getDateWithString: [[brandDataList objectAtIndex:0] objectForKey:@"regDate"]];
    
    MY_LOG(@"%@", lastDate);
    NSDate *compareDate = [NSDate dateWithTimeIntervalSinceNow: - 604800];
    if ([lastDate earlierDate:compareDate]) {
        [brandBtn setImage:[UIImage imageNamed:@"brandhome_tab1_on.png"] forState:UIControlStateNormal];
        [wholeBtn setImage:[UIImage imageNamed:@"brandhome_tab2_off.png"] forState:UIControlStateNormal];
        tabIndex = 0;
        [footPrintsTableView reloadData];
    }
    else {
        [self wholeCheckInClicked];
    }
    existRecentBrandCheckIn = NO;
    
}

- (void)dealloc {

    [barImageView release];
    [brandImageVIew release];
    [preBtn release];
    [friendBtn release];
    [wholeBtn release];
    [brandBtn release];
    [bannerBtn release];
    [footPrintsTableView release];
    [titleLabel release];
    
    [homeInfo release];    
    [postList release];
    [eventList release];
    [eventDataArray release];
    [checkInBtn release];
    [super dealloc];
}

- (void)viewDidUnload {

    [barImageView release];
    barImageView = nil;
    [brandImageVIew release];
    brandImageVIew = nil;
    [preBtn release];
    preBtn = nil;
    [self setFriendBtn:nil];
    [wholeBtn release];
    wholeBtn = nil;
    [brandBtn release];
    brandBtn = nil;
    [bannerBtn release];
    bannerBtn = nil;
    [footPrintsTableView release];
    footPrintsTableView = nil;
    [titleLabel release];
    titleLabel = nil;
    [checkInBtn release];
    checkInBtn = nil;
    [super viewDidUnload];
}
@end
