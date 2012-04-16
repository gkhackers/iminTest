	//
//  FeedListTableViewController.m
//  ImIn
//
//  Created by edbear on 10. 9. 9..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FeedListTableViewController.h"
#import "FeedCell.h"
#import "MyPostListById.h"
#import "PostDetailTableViewController.h"
#import "POIDetailViewController.h"
#import "ViewControllers.h"
#import "TFeedList.h"
#import "UIHomeViewController.h"
#import "HomeInfo.h"
#import "macro.h"
#import "PoiInfo.h"
#import "BadgeInfo.h"
#import "BadgeDetailViewController.h"
#import "BadgeAcquisitionViewController.h"
#import "CommonWebViewController.h"
#import "BrandHomeViewController.h"
#import "FeedClose.h"
#import "EventCell.h"
#import "EventList.h"
#import "BizWebViewController.h"
#import "NSString+URLEncoding.h"
#import "TutorialView.h"


@implementation FeedListTableViewController
@synthesize feedList, feedType, owner;
@synthesize poiInfo, homeInfo, postListById;
@synthesize selectedFeed;
@synthesize badgeInfo;
@synthesize badgeInfoResult;
@synthesize feedClose;
@synthesize eventDataList, eventTotalCnt;
@synthesize eventList;
@synthesize eventFirstData;

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
	[owner release];
	[poiInfo release];
	[homeInfo release];
	[postListById release];
	[selectedFeed release];
	[badgeInfoResult release];
    [eventDataList release];
    [eventList release];
    [eventFirstData release];
	
    [super dealloc];
}

- (void) viewDidLoad {
	//[self.tableView setSeparatorColor:RGB(181, 181, 181)];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	newBadge = YES;
    noResult = NO;
    isTop = NO;
}

/**
 @brief 뱃지 초기화
 @brief 새소식 정보 초기화
 */
- (void) viewDidDisappear:(BOOL)animated {	
	[[UserContext sharedUserContext].feedCounter reset];
	[UIApplication sharedApplication].applicationIconBadgeNumber = 0;
	[ViewControllers sharedViewControllers].feedViewController.tabBarItem.badgeValue = nil;
}

/**
 @brief 새소식 목록 재요청
 @fixme reloading 이 안되는 경우가 존재함
 */
- (void) viewWillAppear:(BOOL)animated
{
	self.feedList = [NSMutableArray arrayWithArray:[TFeedList findWithSql:@"select * from TFeedList where hasDeleted = '0' order by regDate desc"]];
    noResult = [feedList count] > 0? NO:YES;
    [self.tableView reloadData];
    
	[self requestEvent];
    [self requestFeedClose];
    
    //새소식을 봤으면 lastFeedDataSave 값을 @"" 로 변경해서 다음번에는 DB에 있는 데이타의 lastFeedData 값을 이용해 feedList를 호출하도록 만든다.
    [[UserContext sharedUserContext].setting setObject:@"" forKey:@"lastFeedDateSave"];
    [[UserContext sharedUserContext] saveSettingToFile];
}

#pragma mark -
#pragma mark Editing Cells
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    if (indexPath.section == 0 || noResult) {
        return NO;  // 이벤트 섹션은 보여주지 말자
    } else {
        return YES;
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
		[tableView endEditing:YES];
		
		// 디비 지우기
		TFeedList* feed = [feedList objectAtIndex:indexPath.row];
		feed.hasDeleted = @"1";
		[feed save];
		
		// 데이터 소스에서 지우기
		[feedList removeObjectAtIndex:indexPath.row];
		[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationLeft];
        if ([feedList count] == 0) {
            noResult = YES;
            [[UserContext sharedUserContext].feedCounter reset];
            [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
            [ViewControllers sharedViewControllers].feedViewController.tabBarItem.badgeValue = nil;
        }
		[tableView reloadData];
        
        // Delete the row from the data source
        //[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
		//[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if (section == 0) {
        if (eventTotalCnt > 0) {
            return 1;
        } else {
            return 0;
        }
    } else if (section == 1) {
            return [feedList count];
    } else {
        if (noResult) {
            return 1;
        } else {
            return 0;
        }
    }
    return 0;
}

/**
 @brief 셀 높이는 세 가지 경우가 존재
 @brief 이벤트 : 1줄/2줄인 경우
 @brief 새소식
 */
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (eventTotalCnt > 0 && indexPath.section == 0) {
        if (eventTotalCnt == 1) {
            CGSize textSize = [[eventFirstData objectForKey:@"eventCopy"] sizeWithFont:[UIFont fontWithName:@"helvetica" size:14.0f] constrainedToSize:CGSizeMake(246.0f, 36.0f) lineBreakMode:UILineBreakModeWordWrap];
            MY_LOG(@"textSize.height = %f", textSize.height);
            NSUInteger lineCnt = (int)(textSize.height / 18.0f);
            
            if (lineCnt == 2) {
                return 59.0f;
            } else {
                return 43.0f;
            }
        } else {
            return 43.0f;
        }
    } else {
       return 60.0f; 
    }
}

/// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        static NSString *CellIdentifier = @"evnetCell";
		EventCell *cell = (EventCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		if (cell == nil) {
			NSArray* nibObjects = [[NSBundle mainBundle] loadNibNamed:@"EventCell" owner:nil options:nil];
			
			for (id currentObject in nibObjects) {
				if([currentObject isKindOfClass:[EventCell class]]) {
					cell = (EventCell*) currentObject;
				}
			}
		}

        [cell redrawEventCellWithCellData:eventFirstData : eventTotalCnt];
		return cell;
    } else if (indexPath.section == 1) {

        static NSString *CellIdentifier = @"feedCell";
        
        FeedCell *cell = (FeedCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            NSArray* nibObjects = [[NSBundle mainBundle] loadNibNamed:@"FeedCell" owner:nil options:nil];		
            
            for (id currentObject in nibObjects) {
                if([currentObject isKindOfClass:[FeedCell class]]) {
                    cell = (FeedCell*) currentObject;
                }
            }
        }
        
        TFeedList* feed = [feedList objectAtIndex:indexPath.row];
        MY_LOG(@"%@",  feed.msg);
        cell.feedContent.text = feed.msg;
        switch ([feed.evtId intValue]) {
                //		case 100001: //이웃의 새 발도장
                //			[cell.feedTypeIcon setImage:[UIImage imageNamed:@"icon_new.png"]];
                //			break;
            case 100002: // 댓글
                [cell.feedTypeIcon setImage:[UIImage imageNamed:@"myhome_icon_reply.png"]];
                break;
                //		case 100004: // 나를 등록한 이웃
                //			[cell.feedTypeIcon setImage:[UIImage imageNamed:@"friendicon_eachother.png"]];
                //			break;
            case 100005: // 뱃지
                [cell.feedTypeIcon setImage:[UIImage imageNamed:@"badge_noticon.png"]];
                break;
                
            case 100007: // 대댓글
                [cell.feedTypeIcon setImage:[UIImage imageNamed:@"myhome_icon_rereply.png"]];
                break;
            case 100006: // 시스템(X) // 캡틴을 빼앗겼을 경우
            case 100008: // 캡틴이 한마디를 변경했을 경우
            case 100012: // 발도장과 실제 위치사이의 거리가 0일 경우
            case 100013: // 포인트 차감에 의해서 캡틴을 뺐앗겼을 경우
            case 100014: // 포인트 차감에 의해서 캡틴이 된 경우
                [cell.feedTypeIcon setImage:[UIImage imageNamed:@"noti_icon.png"]];
                break;
            case 100015: // 이벤트
                [cell.feedTypeIcon setImage:[UIImage imageNamed:@"noti_event_icon.png"]];
                break;
            case 100016: // 공지
                [cell.feedTypeIcon setImage:[UIImage imageNamed:@"noti_notice_icon.png"]];
                break;
            case 100017: // 아이콘 없는 새소식
                [cell.feedTypeIcon setImage:nil];
                break;
            case 100018: // 선물기능
            case 100019:
            case 100020:
            case 100021:
                [cell.feedTypeIcon setImage:[UIImage imageNamed:@"noti_icon_gift.png"]];
                break;
            case 100022:
                [cell.feedTypeIcon setImage:[UIImage imageNamed:@"noti_icon.png"]];
                break;
                
            default:
                [cell.feedTypeIcon setImage:[UIImage imageNamed:@"noti_icon.png"]];
                break;
        }
        
        if ([feed.read intValue] == 0) {
            cell.aNewIcon.hidden = NO;
        } else {
            cell.aNewIcon.hidden = YES;
        }        
        return cell;
    } else {
            TutorialView *tutorial = [[[NSBundle mainBundle] loadNibNamed:@"TutorialView" owner:self options:nil] lastObject];
            [tutorial createTutorialView:[NSDictionary dictionaryWithObject:@"3" forKey:@"status"]];
            
            NSString *cellIdentifier = @"NotiCell";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (cell == nil) {
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] autorelease];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            [cell.contentView addSubview:tutorial];
            return cell;
    }
    return nil;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        BizWebViewController* vc = [[[BizWebViewController alloc] initWithNibName:@"BizWebViewController" bundle:nil] autorelease];
        
        NSString* titleText = nil;
        if (eventTotalCnt > 1) {
            GA3(@"새소식", @"이벤트배너", @"새소식내");
            
            NSString* encoded = [[NSString stringWithFormat:@"진행중인 이벤트 %d", eventTotalCnt] URLEncodedString];
            titleText = [NSString stringWithFormat:@"&title_text=%@&right_enable=y&pointX=%@&pointY=%@", encoded, [GeoContext sharedGeoContext].lastTmX, [GeoContext sharedGeoContext].lastTmY];
            vc.urlString = [EVENT_LIST_URL stringByAppendingString:titleText];
            vc.curPosition = @"23";
        } else {
            if ([Utils isBrandUser:eventFirstData]) {
                GA3(@"새소식", @"브랜드이벤트배너", @"새소식내");
            } else {
                GA3(@"새소식", @"주인장이벤트배너", @"새소식내");
            }
            
            NSString* encoded = [@"이벤트 상세보기" URLEncodedString];
            titleText = [NSString stringWithFormat:@"&title_text=%@&right_enable=y&pointX=%@&pointY=%@", encoded, [GeoContext sharedGeoContext].lastTmX, [GeoContext sharedGeoContext].lastTmY];
            vc.urlString = [[eventFirstData objectForKey:@"eventInfoLink"] stringByAppendingString:titleText];
            vc.curPosition = @"22";
        }

        MY_LOG(@"event url = %@", vc.urlString);
        [(UINavigationController*)[ViewControllers sharedViewControllers].tabBarController.selectedViewController 
         presentModalViewController:vc animated:YES];
    } else if (indexPath.section == 1) {
        
        FeedCell* cell = (FeedCell*)[tableView cellForRowAtIndexPath:indexPath];
        cell.aNewIcon.hidden = YES;
		
        //	MY_LOG(@"postId: %@", feed.postId);
        //	if ([feed.postId isEqualToString:@"0"]) {
        //		return;
        //	}
        
        TFeedList* feed = [feedList objectAtIndex:indexPath.row];
        self.selectedFeed = feed;
        
        switch ([feed.evtId intValue]) {
            case 100006: // 시스템(X) // 캡틴을 빼앗겼을 경우
            case 100008: // 캡틴이 한마디를 변경했을 경우
            case 100012: // 발도장과 실제 위치사이의 거리가 0일 경우
            case 100013: // 포인트 차감에 의해서 캡틴을 뺐앗겼을 경우
            case 100014: // 포인트 차감에 의해서 캡틴이 된 경우
            case 100015: // 이벤트 feed
            case 100016: // 공지 아이콘
            case 100017: // 아이콘 없는 새소식
            {
                if (feed.evtUrl != nil && ![feed.evtUrl isEqualToString:@""]) {
                    CommonWebViewController* vc = [[[CommonWebViewController alloc] initWithNibName:@"CommonWebViewController" bundle:nil] autorelease];
                    vc.urlString = feed.evtUrl;
                    [(UINavigationController*)[ViewControllers sharedViewControllers].tabBarController.selectedViewController 
                     presentModalViewController:vc animated:YES];
                    break;
                }
                
                if (feed.poiKey != nil && ![feed.poiKey isEqualToString:@""]) {
                    // 해당 POI로 이동시키자
                    self.poiInfo = [[[PoiInfo alloc] init] autorelease];
                    self.poiInfo.delegate = self;
                    self.poiInfo.poiKey = feed.poiKey;
                    [self.poiInfo requestWithoutIndicator];
                    
                } else if (feed.postId != nil && ![feed.postId isEqualToString:@""]) {
                    // postId로 해당 글로 이동하게 하자.
                    self.postListById = [[[MyPostListById alloc] init] autorelease];
                    postListById.delegate = self;
                    postListById.postIdList = feed.postId;
                    [postListById requestWithoutIndicator];
                } else {
                    self.homeInfo = [[[HomeInfo alloc] init] autorelease];
                    self.homeInfo.delegate = self;
                    self.homeInfo.snsId = feed.snsId;
                    if (self.owner == nil) {
                        self.owner = [[[MemberInfo alloc] init] autorelease];
                    }
                    self.owner.snsId = feed.snsId;
                    [self.homeInfo requestWithoutIndicator];
                }
                
                break;
            }
                
            case 100001: //이웃의 새 발도장
            case 100004: // 나를 등록한 이웃
            case 100022: // 스크랩
            case 100011: // 초대 받은 분이 아임IN 시작 했다
            case 100010: // 초대한 사람과 이웃이 되었다.
            {
                self.homeInfo = [[[HomeInfo alloc] init] autorelease];
                self.homeInfo.delegate = self;
                self.homeInfo.snsId = feed.snsId;
                if (self.owner == nil) {
                    self.owner = [[[MemberInfo alloc] init] autorelease];
                }
                
                self.owner.snsId = feed.snsId;
                [self.homeInfo requestWithoutIndicator];
                break;
            }
                
            case 100002: // 댓글
            case 100007: // 대댓글
            {
                // postId로 해당 글로 이동하게 하자.
                self.postListById = [[[MyPostListById alloc] init] autorelease];
                postListById.delegate = self;
                postListById.postIdList = feed.postId;
                [postListById requestWithoutIndicator];
                
                // 해당 댓글에 해당되는 발도장을 봤다면, 해당 댓글들을 모두 지워줘라.
                NSString* query = [NSString stringWithFormat:@"update tfeedlist set read = 1 where postId = %@", feed.postId];
                [[TFeedList database] executeSql:query];
                
                break;
            }
            case 100005: // 뱃지
            {
                if ([[UserContext sharedUserContext].snsID isEqualToString:feed.snsId]) { // 내 뱃지 내용이면
                    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedCloseAndGoHome:) name:@"closeAndGoHome" object:nil];
                    if ([feed.read intValue] == 0) { //새소식이면
                        newBadge = YES;
                    } else { // 한번 봤던 소식이면
                        newBadge = NO;
                    }
                    
                    downloadCompleted = 0;
                    
                    
                    self.badgeInfo = [[[BadgeInfo alloc] init] autorelease];
                    
                    [badgeInfo.params addEntriesFromDictionary:[NSDictionary dictionaryWithObject:feed.badgeId forKey:@"badgeId"]];
                    [badgeInfo.params addEntriesFromDictionary:[NSDictionary dictionaryWithObject:feed.snsId forKey:@"snsId"]];
                    
                    badgeInfo.delegate = self;
                    [badgeInfo request];
                    
                } else { // 내 뱃지 내용이 아니면
                    if (feed.postId == nil || [feed.postId isEqualToString:@""] || [feed.postId isEqualToString:@"0"]) {
                        self.homeInfo = [[[HomeInfo alloc] init] autorelease];
                        self.homeInfo.delegate = self;
                        self.homeInfo.snsId = feed.snsId;
                        if (self.owner == nil) {
                            self.owner = [[[MemberInfo alloc] init] autorelease];
                        }
                        
                        self.owner.snsId = feed.snsId;
                        [self.homeInfo requestWithoutIndicator];
                    } else {
                        self.postListById = [[[MyPostListById alloc] init] autorelease];
                        postListById.delegate = self;
                        postListById.postIdList = feed.postId;
                        [postListById requestWithoutIndicator];
                    }
                }
                break;
            }
                
            case 100018: // 선물기능
            case 100019:
            case 100020:
            case 100021:
                [cell.feedTypeIcon setImage:[UIImage imageNamed:@"noti_icon_gift.png"]];
                if (feed.reserved0 != nil && ![feed.reserved0 isEqualToString:@""]) {
                    CommonWebViewController* vc = [[[CommonWebViewController alloc] initWithNibName:@"CommonWebViewController" bundle:nil] autorelease];
                    vc.urlString = feed.reserved0; // reserved0는 goURL
                    vc.viewType = HEARTCON;
                    vc.titleString = @"선물함";
                    [(UINavigationController*)[ViewControllers sharedViewControllers].tabBarController.selectedViewController 
                     presentModalViewController:vc animated:YES];
                }
                break;
                
            default:
                if (feed.evtUrl != nil && ![feed.evtUrl isEqualToString:@""]) {
                    CommonWebViewController* vc = [[[CommonWebViewController alloc] initWithNibName:@"CommonWebViewController" bundle:nil] autorelease];
                    vc.urlString = feed.evtUrl;
                    [(UINavigationController*)[ViewControllers sharedViewControllers].tabBarController.selectedViewController 
                     presentModalViewController:vc animated:YES];
                }
                break;
        } 
        
        feed.read = [NSNumber numberWithInt:1];
        [feed save];
        
        [self.navigationController dismissModalViewControllerAnimated:YES];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    } else {
        //when section is 3 , Nothing happend
    }
}

- (void) requestFeedClose {
    // 새소식을 봤다면 feedClose를 보내라
    self.feedClose = [[[FeedClose alloc] init] autorelease];
    [feedClose.params addEntriesFromDictionary:
     [NSDictionary dictionaryWithObject:[UserContext sharedUserContext].deviceToken 
                                 forKey:@"deviceToken"]];
    feedClose.delegate = self;
    [feedClose request];
}

- (void) requestEvent {
    GeoContext* gc = [GeoContext sharedGeoContext];
    if (gc.lastTmX == nil || gc.lastTmY == nil) {
        return;
    }
    NSString* pointX = [gc.lastTmX stringValue];
    NSString* pointY = [gc.lastTmY stringValue];
    
    self.eventList = [[[EventList alloc] init] autorelease];
    eventList.delegate = self;
    
    [eventList.params addEntriesFromDictionary:[NSDictionary dictionaryWithObject:pointX forKey:@"pointX"]]; // 발도장 중심좌표
    [eventList.params addEntriesFromDictionary:[NSDictionary dictionaryWithObject:pointY forKey:@"pointY"]];
    [eventList.params addEntriesFromDictionary:[NSDictionary dictionaryWithObject:@"1" forKey:@"scale"]]; //이벤트 목록이 한개반 요청하면 된다.
    
    [eventList requestWithAuth:NO withIndicator:YES];
}

- (void) requestSelectedBadegInfo {
	self.badgeInfo = [[[BadgeInfo alloc] init] autorelease];
	
	[badgeInfo.params addEntriesFromDictionary:[NSDictionary dictionaryWithObject:selectedFeed.badgeId forKey:@"badgeId"]];
	[badgeInfo.params addEntriesFromDictionary:[NSDictionary dictionaryWithObject:selectedFeed.snsId forKey:@"snsId"]];
	
	badgeInfo.delegate = self;
	[badgeInfo request];	
}

- (void) apiDidLoad:(NSDictionary*) result {

	if ([[result objectForKey:@"func"] isEqualToString:@"poiInfo"]) {
		MY_LOG(@"결과: %@", [result objectForKey:@"poiName"]);
		POIDetailViewController *vc = [[POIDetailViewController alloc] initWithNibName:@"POIDetailViewController" bundle:nil];
		vc.poiData = result;
		[(UINavigationController*)[ViewControllers sharedViewControllers].tabBarController.selectedViewController pushViewController:vc animated:YES];
		[vc release];
	}
	
	if ([[result objectForKey:@"func"] isEqualToString:@"myPostListById"]) {
		if ([[result objectForKey:@"data"] count] > 0) {
			MY_LOG(@"결과: %@", [[[result objectForKey:@"data"] objectAtIndex:0] objectForKey:@"post"]);
			
			PostDetailTableViewController* vc = [[PostDetailTableViewController alloc] 
												 initWithNibName:@"PostDetailTableViewController" 
												 bundle:nil];
			vc.postData = [[[NSMutableDictionary alloc] initWithDictionary:[[result objectForKey:@"data"] objectAtIndex:0]] autorelease];
			[(UINavigationController*)[ViewControllers sharedViewControllers].tabBarController.selectedViewController pushViewController:vc animated:YES];
			[vc release];
		} 
		else {
			[CommonAlert alertWithTitle:@"알림" message:@"삭제된 글이예요~"];
		}
	}
	
	// homeInfo
	if ([[result objectForKey:@"func"] isEqualToString:@"homeInfo"]) {
		
		MY_LOG(@"homeInfo 결과값");
        if (owner == nil) {
            self.owner = [[[MemberInfo alloc] init] autorelease];
        }
		self.owner.nickname = [result objectForKey:@"nickname"];		
		self.owner.profileImgUrl = [result objectForKey:@"profileImg"];
        self.owner.snsId = [result objectForKey:@"snsId"];
        
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
	
	if ([[result objectForKey:@"func"] isEqualToString:@"badgeInfo"]) {
		self.badgeInfoResult = result;
		[self downloadImageWithUrl:[result objectForKey:@"imgUrl"]];
	}
    
    if ([[result objectForKey:@"func"] isEqualToString:@"eventList"]) { 
        if ([[result objectForKey:@"result"] boolValue]) {
            NSMutableArray* events = [[NSMutableArray alloc]init];
            [events addObjectsFromArray:[result objectForKey:@"specialEvent"]];
            [events addObjectsFromArray:[result objectForKey:@"freeEvent"]];
            
            if ([events count] > 0) {
                self.eventFirstData = [events objectAtIndex:0];                
            }
            eventTotalCnt = [[result objectForKey:@"totalCnt"] intValue];
            [events release];

        } else {
            MY_LOG(@"event 리스트 실패");
        }
        [self.tableView reloadData];
	}
}

- (void) apiFailed {
	MY_LOG(@"API호출이 실패하였습니다.");
}


- (void) openBadge {
	if (newBadge == YES) {
		NSArray* badgeList = [NSArray arrayWithObject:badgeInfoResult];
		[self badgeAcquisitionViewShow:badgeList];
	}
	else {
		[self badgeDetailViewShow:badgeInfoResult];
	}	
}


- (void) badgeDetailViewShow :(NSDictionary*)badgeData
{
	MY_LOG(@"뱃지새소식 눌렸음-상세보기로 가야함");	
	MemberInfo* aOwner = [[[MemberInfo alloc] init] autorelease];
	aOwner.snsId = selectedFeed.snsId;
	
	BadgeDetailViewController* badgeDetaileVC = [[[BadgeDetailViewController alloc] 
													  initWithNibName:@"BadgeDetailViewController" bundle:nil] autorelease];
	badgeDetaileVC.badgeInfo = badgeData;
	badgeDetaileVC.owner = aOwner;
	badgeDetaileVC.hidesBottomBarWhenPushed = YES;
		
	UINavigationController *navController = [[[UINavigationController alloc] initWithRootViewController:badgeDetaileVC] autorelease];
	[navController setNavigationBarHidden:YES] ;
	
	[[ViewControllers sharedViewControllers].feedViewController presentModalViewController:navController animated:YES];
}

- (void) badgeAcquisitionViewShow :(NSArray*)badgeList
{
	MY_LOG(@"뱃지새소식 눌렸음-뱃지인터렉션 보여줌");
	
	BadgeAcquisitionViewController* badgeAcquisitionVC = [[[BadgeAcquisitionViewController alloc] 
												  initWithNibName:@"BadgeAcquisitionViewController" bundle:nil] autorelease];
	badgeAcquisitionVC.badgeList = badgeList;
	
	badgeAcquisitionVC.hidesBottomBarWhenPushed = YES;
	
	UINavigationController *navController = [[[UINavigationController alloc] initWithRootViewController:badgeAcquisitionVC] autorelease];
	[navController setNavigationBarHidden:YES] ;
	
	[[ViewControllers sharedViewControllers].feedViewController presentModalViewController:navController animated:YES];
}

#pragma mark -
- (void) receivedCloseAndGoHome:(NSNotification*) noti
{
	NSDictionary* aOwner = [noti userInfo];
	MY_LOG(@"노티: %@", [aOwner objectForKey:@"nickname"]);
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"closeAndGoHome" object:nil];
	
	[NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(goHome:) userInfo:aOwner repeats:NO];
}

- (void) goHome: (NSTimer *)timer
{
	NSDictionary* aOwner = [timer userInfo];
	NSAssert(aOwner != nil, @"owner값이 설정되어 들어와야 한다");
    
	self.homeInfo = [[[HomeInfo alloc] init] autorelease];
	homeInfo.delegate = self;
	homeInfo.snsId = [aOwner objectForKey:@"snsId"];
	[homeInfo request];
}

- (void) deleteAllFeed {

	// Model
	NSString* query = @"update tfeedlist set hasDeleted = 1";
	[[TFeedList database] executeSql:query];
	[feedList removeAllObjects];
	//[self.tableView reloadData];
    
    noResult = YES;
	
    // 뱃지 갯수 초기화
    [[UserContext sharedUserContext].feedCounter reset];
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    [ViewControllers sharedViewControllers].feedViewController.tabBarItem.badgeValue = nil;
    [self.tableView reloadData];

}


// 뱃지 획득시에 보여줄 이미지를 다운받는다
- (void) downloadImageWithUrl:(NSString*) baseUrl
{	
	NSString* url = [baseUrl stringByReplacingOccurrencesOfString:@"126x126" withString:@"252x252"];
	
	[Utils requestImageCacheWithURL:url
						   delegate:self
					   doneSelector:@selector(badgeDownloadDone:) 
					  errorSelector:@selector(badgeError:) cacheHitSelector:@selector(badgeCacheDone:)];
	
	url = [url stringByReplacingOccurrencesOfString:@"252x252_f" withString:@"252x252_b"];

	[Utils requestImageCacheWithURL:url
						   delegate:self
					   doneSelector:@selector(badgeDownloadDone:)
					  errorSelector:@selector(badgeError:) cacheHitSelector:@selector(badgeCacheDone:)];
}

- (void) badgeDownloadDone:(NSString*) url {
	downloadCompleted++;
	if (downloadCompleted == 2) {
		downloadCompleted = 0;
		[self openBadge];
	}
	MY_LOG(@"뱃지 획득 이미지 받았음: %@", url);
}

- (void) badgeCacheDone:(NSString*) url {
	downloadCompleted++;
	if (downloadCompleted == 2) {
		downloadCompleted = 0;
		[self openBadge];
	}
	MY_LOG(@"뱃지 획득 이미지 캐시: %@", url);
}

- (void) badgeError:(NSString*) url {
	MY_LOG(@"뱃지 획득 이미지 에러: %@", url);
	[CommonAlert alertWithTitle:@"안내" message:@"뱃지 리소스 다운로드에 실패했습니다. 다시 한번 시도해주세요"];
}

#pragma mark -
#pragma mark UIScrollView delegate

- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView {

}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
	if (isTop) {
        [self doRefresh];
		return;
	}
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	if (scrollView.contentOffset.y < 0) {
		isTop = YES;
	} else {
		isTop = NO;
	}
}

- (void) doRefresh {
    MY_LOG(@"doRefresh");
    self.feedList = [NSMutableArray arrayWithArray:[TFeedList findWithSql:@"select * from TFeedList where hasDeleted = '0' order by regDate desc"]];
    [self.tableView reloadData];
}


@end

