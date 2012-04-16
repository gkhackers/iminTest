//
//  UIHomeViewController.m
//  ImIn
//
//  Created by edbear on 10. 9. 11..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "UIHomeViewController.h"
#import "UITabBarItem+WithImage.h"
#import "UIImageView+WebCache.h"

#import "UIMasterViewController.h"
#import "POIListViewController.h"

#import "FeedList.h"
#import "HomeInfo.h"
#import "HomeInfoDetail.h"
#import "ScrapDelete.h"

#import "MainThreadCell.h"
#import "MyHomePostCell.h"
#import "PostDetailTableViewController.h"
#import "POIDetailViewController.h"

#import "UIMasterViewController.h"
#import "FriendSetViewController.h"
#import "MyHomeNeighborViewController.h"

#import "ProfileViewController.h"
#import "PostList.h"
#import "ScrapList.h"
#import "iToast.h"
#import "TFeedList.h"

#import "TableCoverNoticeViewController.h"

#import "BadgeViewController.h"
#import "BrandHomeViewController.h"

#import "TutorialView.h"

static const int UIHOMEVIEWCONTOLLER_BACK_BUTTON_TAG = 1000;
static const int UIHOMEVIEWCONTOLLER_NETWORK_NOTICE_VIEW_TAG = 1001;

@implementation UIHomeViewController

@synthesize owner;
@synthesize homeInfo, homeInfoDetail;
@synthesize homeInfoResult;
@synthesize postList;
@synthesize scrapDelete;
@synthesize scrapList;
@synthesize recentFootprints, scraps;
@synthesize tutorial;
@synthesize tableCoverNoticeMessage;

- (void)dealloc {
	[owner release];
	[homeInfo release];
	[homeInfoResult release];
    
    [homeInfoDetail release];
	[postList release];
    [scrapList release];
    [scrapDelete release];
    [mainTableView release];
    [balloonBtn release];

    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
		self.title = @"마이홈";
		[self.tabBarItem resetWithNormalImage:[UIImage imageNamed:@"GNB_03_off.png"] 
								selectedImage:[UIImage imageNamed:@"GNB_03_on.png"]];
    }
    return self;
}

#pragma mark -
#pragma mark notification handler
- (void) autoUpdateCompleted:(NSNotification*) noti
{
	MY_LOG(@"뱃지 리소스 다 받았음!!!");
	NSDictionary* ownerInfo = [noti userInfo];
	MY_LOG(@"뱃지 주인 정보: %@", ownerInfo);
	MemberInfo* badgeOwner = [[[MemberInfo alloc] init] autorelease];
	badgeOwner.snsId = [ownerInfo objectForKey:@"snsId"];
	badgeOwner.profileImgUrl = [ownerInfo objectForKey:@"imgUrl"];
	badgeOwner.nickname = [ownerInfo objectForKey:@"nickname"];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedCloseAndGoHome:) name:@"closeAndGoHome" object:nil];
	BadgeViewController* vc = [[[BadgeViewController alloc] initWithNibName:@"BadgeViewController" bundle:nil] autorelease];
	vc.owner = badgeOwner;
	[self.navigationController presentModalViewController:vc animated:YES];
}

- (void) scrapModified:(NSNotification*) noti
{
	MY_LOG(@"스크랩에 변경이 일어났다");

    NSDictionary* scrapModificationInfo = [noti userInfo];
    NSString* mode = [scrapModificationInfo objectForKey:@"mode"];
    NSDictionary* modifiedScrap = [scrapModificationInfo objectForKey:@"scrap"];
    
    if (tabIndex == 0) {
        int i = 0;
        for (NSDictionary* aScrap in recentFootprints) {
            if ([[aScrap objectForKey:@"postId"] isEqualToString:[modifiedScrap objectForKey:@"postId"]]) {
                [recentFootprints replaceObjectAtIndex:i withObject:modifiedScrap];
                break;
            }
            i++;
        }        
    } else {
        // 나의 홈일 경우에는 리스트에 추가 삭제로 반영된다.
        if ([owner.snsId isEqualToString:[UserContext sharedUserContext].snsID]) {
            
            if ([mode isEqualToString:@"delete"]) {
                for (NSDictionary* aScrap in scraps) {
                    if ([[aScrap objectForKey:@"postId"] isEqualToString:[modifiedScrap objectForKey:@"postId"]]) {
                        [scraps removeObject:aScrap];
                        break;
                    }
                }
            }

            if ([mode isEqualToString:@"insert"]) {
                [scraps insertObject:modifiedScrap atIndex:0];
            }

        } else { // 타인의 홈이라면 리스트에서 변경으로 반영된다.
            int i = 0;
            for (NSDictionary* aScrap in scraps) {
                if ([[aScrap objectForKey:@"postId"] isEqualToString:[modifiedScrap objectForKey:@"postId"]]) {
                    [scraps replaceObjectAtIndex:i withObject:modifiedScrap];
                    break;
                }
                i++;
            }        
        }
    }

    [mainTableView reloadData];
}


#pragma mark -
#pragma mark 선택

- (void)viewDidLoad {
    [super viewDidLoad];
    
	[self.navigationController setNavigationBarHidden:YES animated:NO];
    //[mainTableView setSeparatorColor:RGB(181, 181, 181)];
    mainTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    UILabel *text = [[UILabel alloc] initWithFrame:CGRectMake(15.0f, 6.0f, 135.0f, 34.0f)];
    text.numberOfLines = 2;
    text.text = @"지금 있는 곳에\n발도장을 찍어보세요!";
    text.font = [UIFont fontWithName:@"helvetica" size:13.0f];
    text.textColor = [UIColor whiteColor];
    text.backgroundColor = [UIColor clearColor];
    [balloonBtn addSubview:text];
    [text release];
    [balloonBtn setHidden:YES];
    
    selectedTab = YES;
    self.tableCoverNoticeMessage = @"데이터를 불러오고 있습니다.";
    noConnection = NO;
	
	//현재 뷰컨트롤러가 탑뷰라면 이전 버튼을 없애주자.
	if( self == [self.navigationController.viewControllers objectAtIndex:0] )
	{
		[self.view viewWithTag:UIHOMEVIEWCONTOLLER_BACK_BUTTON_TAG].hidden = YES;
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
    currPage = 1; // 스크랩 첫 페이지 초기화
    isBackward = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(scrapModified:) name:@"scrapModified" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadList:) name:@"reloadList" object:nil];
}

- (void) viewWillAppear:(BOOL)animated {
    
     if ([[UserContext sharedUserContext].snsID isEqualToString:owner.snsId]) {
         [[UserContext sharedUserContext] recordKissMetricsWithEvent:@"Viewed myhome page" withInfo:nil];
         GA1(@"마이홈page");
     }
    
	// notification observer 등록
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(autoUpdateCompleted:) name:@"autoUpdate" object:nil];
	
	UIView* networkNoticeView = [self.view viewWithTag:UIHOMEVIEWCONTOLLER_NETWORK_NOTICE_VIEW_TAG];
	if (networkNoticeView != nil) {
		[networkNoticeView removeFromSuperview];	
	}
	
	// 마이홈으로 들어올 때마다 요청해서 값을 갱신함.
	[self requestHomeInfo];

    if (recentFootprints == nil) {
        [self requestFootPoiList];                
    }

    // 쿠키 정보를 요청한다. (없을 경우에만)
    [[UserContext sharedUserContext] requestSnsCookie];
    [mainTableView reloadData];
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


- (void)viewDidUnload {
    [balloonBtn release];
    balloonBtn = nil;
    [super viewDidUnload];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"reloadList" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"scrapModified" object:nil];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void) viewDidDisappear:(BOOL)animated {
    [balloonBtn setHidden:YES];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"autoUpdate" object:nil];	
}

- (IBAction)clickBalloon {
    [balloonBtn setHidden:YES];
}

- (IBAction) goBack
{
	[self.navigationController popViewControllerAnimated:YES];
}

- (IBAction) goProfileImage
{	
    if ([[UserContext sharedUserContext].snsID isEqualToString:owner.snsId]) {
		GA3(@"마이홈", @"프로필사진", @"마이홈내");
	} else {
		GA3(@"타인홈", @"프로필사진", @"타인홈내");
	}

	ProfileViewController* vc = [[[ProfileViewController alloc] initWithNibName:@"ProfileViewController" bundle:nil] autorelease];
//	[vc setHidesBottomBarWhenPushed:YES];
	
	vc.owner = owner;
	vc.friendCodeInt = friendCodeInt;
	vc.homeInfoResult = homeInfoResult;
		
	[(UINavigationController*)[ViewControllers sharedViewControllers].tabBarController.selectedViewController pushViewController:vc animated:YES];
}

- (IBAction) goCheckIn
{	
	if ([[UserContext sharedUserContext].snsID isEqualToString:owner.snsId]) {
		GA3(@"마이홈", @"발도장찍기", @"마이홈내");
	} else {
		GA3(@"타인홈", @"발도장찍기", @"타인홈내");
	}

	POIListViewController *vc = [[POIListViewController alloc] initWithNibName:@"POIListViewController" bundle:nil];
    vc.currPostWriteFlow = OLD_POSTFLOW;
	[self.navigationController pushViewController:vc animated:YES];
	[vc release];
}

- (IBAction) goNeighborList
{
	if ([[UserContext sharedUserContext].snsID isEqualToString:owner.snsId]) {
		GA3(@"마이홈", @"이웃버튼", @"마이홈내");
	} else {
		GA3(@"타인홈", @"이웃버튼", @"타인홈내");
	}

	MyHomeNeighborViewController *neiViewController = [[MyHomeNeighborViewController alloc]initWithSnsId:owner.snsId nickName:owner.nickname];
	[(UINavigationController*)[ViewControllers sharedViewControllers].tabBarController.selectedViewController pushViewController:neiViewController animated:YES];
	[neiViewController release];
}

- (IBAction) goFriendSetting
{
	if( FR_YOU == friendCodeInt || FR_NONE == friendCodeInt ) {//이웃이 아닌경우
		GA3(@"타인홈", @"이웃추가버튼", @"타인홈내");
	} else {
		GA3(@"타인홈", @"이웃설정버튼", @"타인홈내");
	}

	FriendSetViewController *vc = [[FriendSetViewController alloc]initWithName:owner.nickname friendSnsId:owner.snsId friendCode:friendCodeInt friendImage:owner.profileImgUrl];
	vc.referCode = @"0001"; // 이웃홈 이웃추가
	[vc setHidesBottomBarWhenPushed:YES];
	[self.navigationController pushViewController:vc animated:YES];
	[vc release];
}

- (IBAction) goMasterList
{
	if ([[UserContext sharedUserContext].snsID isEqualToString:owner.snsId]) {
		GA3(@"마이홈", @"마스터버튼", @"마이홈내");
	} else {
		GA3(@"타인홈", @"마스터버튼", @"타인홈내");
	}
	UIMasterViewController* mv = [[UIMasterViewController alloc] initWithUserNick:owner.nickname withSNSid:owner.snsId];
	[(UINavigationController*)[ViewControllers sharedViewControllers].tabBarController.selectedViewController pushViewController:mv animated:YES];
	[mv release];
}

- (IBAction) goBadge
{
	if ([[UserContext sharedUserContext].snsID isEqualToString:owner.snsId]) {
		GA3(@"마이홈", @"뱃지버튼", @"마이홈내");
	} else {
		GA3(@"타인홈", @"뱃지버튼", @"타인홈내");
	}
	NSDictionary* ownerInfo = [NSDictionary dictionaryWithObjectsAndKeys:owner.nickname, @"nickname", owner.profileImgUrl, @"imgUrl", owner.snsId, @"snsId", nil];
	
	if ([ApplicationContext sharedApplicationContext].updateStatus == AUTO_UPDATE_STATUS_PREPARE) {
		[[ApplicationContext sharedApplicationContext] downloadBadgeImageWithUserInfo:ownerInfo]; 
	} else {
		
		[[NSNotificationCenter defaultCenter] postNotificationName:@"autoUpdate" object:nil userInfo:ownerInfo];
	}

}

- (void) goHome: (NSTimer *)timer
{	
	NSDictionary* aOwner = [timer userInfo];
	NSAssert(aOwner != nil, @"owner값이 설정되어 들어와야 한다");	
	MemberInfo* memberInfo = [[[MemberInfo alloc] init] autorelease];
	memberInfo.snsId = [aOwner objectForKey:@"snsId"];
	memberInfo.nickname = [aOwner objectForKey:@"nickname"];
	memberInfo.profileImgUrl = [aOwner objectForKey:@"profileImg"];
	
	if ([Utils isBrandUser:homeInfoResult]) { //브랜드면
        BrandHomeViewController* vc = [[[BrandHomeViewController alloc] initWithNibName:@"BrandHomeViewController" bundle:nil] autorelease];
        vc.owner = memberInfo;
        [(UINavigationController*)[ViewControllers sharedViewControllers].tabBarController.selectedViewController pushViewController:vc animated:YES];        
        
    } else {
        UIHomeViewController *vc = [[[UIHomeViewController alloc] initWithNibName:@"UIHomeViewController" bundle:nil] autorelease];
        vc.owner = memberInfo;
        [(UINavigationController*)[ViewControllers sharedViewControllers].tabBarController.selectedViewController pushViewController:vc animated:YES];        
    }
}

- (void) receivedCloseAndGoHome:(NSNotification*) noti
{
	NSDictionary* aOwner = [noti userInfo];
	MY_LOG(@"노티: %@", [aOwner objectForKey:@"nickname"]);
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"closeAndGoHome" object:nil];
	
	[NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(goHome:) userInfo:aOwner repeats:NO];
}

#pragma mark - 네트워크 요청

// 마이홈 홈 정보 요청
- (void) requestHomeInfo
{
	self.homeInfo = [[[HomeInfo alloc] init] autorelease];
	self.homeInfo.snsId = owner.snsId;
	self.homeInfo.delegate = self;
	[self.homeInfo requestWithoutIndicator];
}


// 마이홈 발도장 목록 요청
- (void) requestFootPoiList
{
	self.postList = [[[PostList alloc] init] autorelease];
    postList.delegate = self;
    
    [postList.params addEntriesFromDictionary:
     [NSDictionary dictionaryWithObjectsAndKeys:owner.snsId, @"snsId",
      @"25", @"maxScale",
      @"1", @"relation",
      @"2", @"postType", nil]];
    
	[postList request];
}

// 이전의 발도장 요청
- (void) requestFootPoiListOld
{
    isBackward = YES; // 이전 것을 요청하니?
    
	self.postList = [[[PostList alloc] init] autorelease];
    postList.delegate = self;
    
    [postList.params addEntriesFromDictionary:
     [NSDictionary dictionaryWithObjectsAndKeys:owner.snsId, @"snsId",
      @"25", @"maxScale",
      @"1", @"relation",
      @"2", @"postType", nil]];
    
    NSString* lastPostId = [[recentFootprints lastObject] objectForKey:@"postId"];
    
    if (lastPostId != nil) {
        [postList.params addEntriesFromDictionary:[NSDictionary dictionaryWithObject:lastPostId forKey:@"postId"]];
    }
    
	[postList request];
}

// 새로운 발도장 요청
- (void) requestFootPoiListNew
{
    isBackward = NO;
    
	self.postList = [[[PostList alloc] init] autorelease];
    postList.delegate = self;
    
    [postList.params addEntriesFromDictionary:
     [NSDictionary dictionaryWithObjectsAndKeys:owner.snsId, @"snsId",
      @"25", @"maxScale",
      @"1", @"relation",
      @"2", @"postType", nil]];
    
    if ([recentFootprints count] > 0) {
        NSString* latestPostId = [[recentFootprints objectAtIndex:0] objectForKey:@"postId"];
        
        if (latestPostId != nil) {
            [postList.params addEntriesFromDictionary:[NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"-%@", latestPostId]
                                                                                  forKey:@"postId"]];
        }        
    }
    
	[postList request];
}


// 스크랩 목록 요청
- (void) requestScrapList
{
    self.scrapList = [[[ScrapList alloc] init] autorelease];
    scrapList.delegate = self;
    [scrapList.params addEntriesFromDictionary:
     [NSDictionary dictionaryWithObjectsAndKeys:owner.snsId, @"snsId",
      @"25", @"scale",
      [NSString stringWithFormat:@"%d", currPage], @"currPage", nil]];
    
    [scrapList request];
}


#pragma mark - 응답에 대한 처리

NSComparisonResult dateSort(NSDictionary *s1, NSDictionary *s2, void *context) {
	return [[s2 objectForKey:@"regDate"] compare:[s1 objectForKey:@"regDate"]];
}

- (void) processPostList:(NSDictionary*) result {

    if (![[result objectForKey:@"result"] boolValue]) {
        self.tableCoverNoticeMessage = [result objectForKey:@"description"];
        [mainTableView reloadData];
        return;
    }
    
    NSIndexPath* thelastCellIndexPath = nil; // 살짝 끌어올리기 용도
    
    NSArray* poiList = [result objectForKey:@"data"];
    
    if ([poiList count] > 0) {
        if (recentFootprints == nil) { // 첫번째 로딩
            self.recentFootprints = [NSMutableArray arrayWithArray:poiList];
        } else {
            if (isBackward) {
                thelastCellIndexPath = [NSIndexPath indexPathForRow:[recentFootprints count] - 1 inSection:0];
            } else {
                thelastCellIndexPath = [NSIndexPath indexPathForRow:[poiList count] - 1 inSection:0];
            }
        }

        for (NSDictionary *poiData in poiList) {
            // 있는지 검색한다. 있으면 댓글 갯수를 업데이트하고 아니면 추가한다.
            BOOL hasFound = NO;
            NSString* postId = [poiData objectForKey:@"postId"];
            for (NSDictionary* oldCell in recentFootprints) {
                if ([[oldCell objectForKey:@"postId"] isEqualToString:postId]) {
                    hasFound = YES;
                }
            }
            if (!hasFound) {
                // 못 찾았다면, 추가해준다.
                [recentFootprints addObject:poiData];
            }            
        }
        [recentFootprints sortUsingFunction:dateSort context:nil];
    } else {
        if ( [owner.snsId isEqualToString:[UserContext sharedUserContext].snsID] ) {
            self.tableCoverNoticeMessage = @"아직 발도장 찍은 곳이 없습니다.\n발도장을 찍어 흔적을 남겨 보세요.";
        } else {
            if (tabIndex == 0) {
                self.tableCoverNoticeMessage = @"아직 발도장 찍은 곳이 없어요.";
            } else {
                self.tableCoverNoticeMessage = @"등록된 발도장이 없어요.\n발도장을 찍어 흔적을 남겨 보세요";
            }
        }

    }

    lastUpdate.text = [NSString stringWithFormat:@"마지막 갱신: %@", [Utils stringFromDate:[NSDate date]]];
    [mainTableView reloadData];
    
    // 추가된 부분이 있다면 살짝 올려준다
    if (thelastCellIndexPath != nil) {
        [mainTableView scrollToRowAtIndexPath:thelastCellIndexPath 
                             atScrollPosition:UITableViewScrollPositionMiddle
                                     animated:YES];
    }
    
    if ([recentFootprints count] > 0) {
        noResult = NO;
    } else {
        noResult = YES;
    }
    
    if ([[UserContext sharedUserContext].snsID isEqualToString:owner.snsId]) {  //마이홈에서만
        if (noResult && tabIndex == 0 && selectedTab) {
            [balloonBtn setHidden:NO];
            selectedTab = NO;
        } else {
            [balloonBtn setHidden:YES];
        }
    }

    [mainTableView reloadData];
}

- (void) processHomeInfo:(NSDictionary*) result {
    self.homeInfoResult = result;
    
    NSNumber* isOpen = [result objectForKey:@"isOpenHome"];
	
    if (![[UserContext sharedUserContext].snsID isEqualToString:owner.snsId]) {
        if ([isOpen intValue] == 0) {
            [CommonAlert alertWithTitle:@"알림" message:@"해당홈은 비공개입니다."];
            [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(goBack) userInfo:nil repeats:NO];
            //				[self goBack];
            return;
        }
    }
    
    NSString *whoIs = [result objectForKey:@"isPerm"];
    
    // 서로 이웃인지 여부를 확인해서 표시한다.
    if (![whoIs isEqualToString:@"OWNER"]) {
        setBtn.hidden = NO;
        checkinBtn.hidden = YES;
        
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
            [setBtn setImage:[UIImage imageNamed:@"btntop_friadd.png"] forState:UIControlStateNormal];
        else
            [setBtn setImage:[UIImage imageNamed:@"btntop_fri.png"] forState:UIControlStateNormal];
        [setBtn setAlpha:1.0];
        [UIView commitAnimations];
    } else {
        setBtn.hidden = YES;
        checkinBtn.hidden = NO;

        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.3];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [checkinBtn setAlpha:1.0];
        [UIView commitAnimations];			
    }
    
    NSNumber* neighborCnt = [result objectForKey:@"neighborCnt"];
    NSNumber* captainCnt = [result objectForKey:@"captainCnt"];
    NSNumber* badgeCnt = [result objectForKey:@"badgeCnt"];
    NSNumber* poiCnt = [result objectForKey:@"poiCnt"];
    NSNumber* scrapCnt = [result objectForKey:@"totalScrapCnt"];
    totalScrapCnt = [scrapCnt intValue];
    
    numNeighborLabel.text = [neighborCnt stringValue];
    numMasterLabel.text = [captainCnt stringValue];
    numBadgeLabel.text = [badgeCnt stringValue];
    
    UIButton* tab0 = (UIButton*)[self.view viewWithTag:8000];
    [tab0 setTitle:[NSString stringWithFormat:@"발도장 %d", [poiCnt intValue]] forState:UIControlStateNormal];
    
    UIButton* tab1 = (UIButton*)[self.view viewWithTag:8001];
    
    if (totalScrapCnt < 0) {
        totalScrapCnt = 0;
    }
    
    [tab1 setTitle:[NSString stringWithFormat:@"기억하기 %d", totalScrapCnt] forState:UIControlStateNormal];
        
    NSString* nickname = [result objectForKey:@"nickname"];
    nicknameLabel.text = nickname;
    
    NSString* profileImage = [result objectForKey:@"profileImg"];
    [profileImageView setImageWithURL:[NSURL URLWithString:profileImage]
                     placeholderImage:[UIImage imageNamed:@"delay_nosum70.png"]];
    
    
    BOOL isPrNew = [[result objectForKey:@"isPrNew"] boolValue];
    prNewImageView.hidden = !isPrNew;
    
    self.owner.nickname = nickname;
    self.owner.profileImgUrl = profileImage;	
    
    [self refreshFeedList];
}

- (void) processScrapList:(NSDictionary*) result {
    
    if (![[result objectForKey:@"result"] boolValue]) {
        [mainTableView reloadData];
        return;
    }
    
    if (scraps == nil) {
        self.scraps = [NSMutableArray arrayWithArray:[result objectForKey:@"data"]];
    } else {
        NSArray* addedItems = [result objectForKey:@"data"];
        [scraps addObjectsFromArray:addedItems];
    }
    
    if ([scraps count] == 0) {
        noResult = YES;
    } else {
        noResult = NO;
    }
    
    [mainTableView reloadData];
    currPage++;
}

- (void) processPoiInfo:(NSDictionary*) result {
    POIDetailViewController *vc = [[POIDetailViewController alloc] initWithNibName:@"POIDetailViewController" bundle:nil];
    vc.poiData = result;
    [(UINavigationController*)[ViewControllers sharedViewControllers].tabBarController.selectedViewController pushViewController:vc animated:YES];
    [vc release];
}


- (void) apiFailedWhichObject:(NSObject *)theObject {
    
     self.tableCoverNoticeMessage = @"네트워크가 불안합니다.\n다시 시도해주세요~!";
    noConnection = YES;
    NSUInteger cnt = (tabIndex == 0)? [self.recentFootprints count] : [self.scraps count];
    if (cnt) {
        noResult = NO;
    } else {
        noResult = YES;
    }
    
    if (theObject == homeInfo && homeInfoResult == nil) {
        //itoast      
//        iToast *msg = [[iToast alloc] initWithText:@"네트워크가 불안합니다. \n잠시 후 다시 시도해 주세요~"];
//        [msg setDuration:2000];
//        [msg setGravity:iToastGravityCenter];
//        [msg show];
//        [msg release];
//        [CommonAlert alertWithTitle:@"안내" message:@"네트워크 접속이 불안정하여 홈 정보를 가져오지 못했습니다~!"];
    }
    
    if (theObject == postList) {

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
    
    if (theObject == scrapList) {
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
    
    [mainTableView reloadData];

}

-(void) apiDidLoadWithResult:(NSDictionary*)result whichObject:(NSObject*) theObject {
	
    noConnection = NO;
    
    if ([[result objectForKey:@"func"] isEqualToString:@"postList"]) {
        [self processPostList:result];
    }
    
	// homeInfo
	if ([[result objectForKey:@"func"] isEqualToString:@"homeInfo"]) {
		[self processHomeInfo:result];
	}
    
    // scrapList
    if ([[result objectForKey:@"func"] isEqualToString:@"scrapList"]) {
        [self processScrapList:result];
    }
    
    if ([[result objectForKey:@"func"] isEqualToString:@"scrapDelete"]) {
        [CommonAlert alertWithTitle:@"안내" message:@"삭제된 발도장이에요. 목록에서 지워졌습니다~!"];

        // 스크랩 갯수를 하나 줄여주자.
        totalScrapCnt--;
        UIButton* tab1 = (UIButton*)[self.view viewWithTag:8001];
        if (totalScrapCnt < 0) {
            totalScrapCnt = 0;
        }
        [tab1 setTitle:[NSString stringWithFormat:@"기억하기 %d", totalScrapCnt] forState:UIControlStateNormal];

        
        // 스크랩 갯수가 0이라면 안내메시지 수정
        if ([scraps count] == 0) {
            [mainTableView reloadData];
        }
    }
}

- (void) refreshFeedList {
	NSString* sqlQueryText = [NSString stringWithFormat:@"select * from TFeedList where evtId = 100005 and read = 0 and snsId = %@ and hasDeleted = 0", [UserContext sharedUserContext].snsID];
	BOOL isNew = [[TFeedList findWithSql:sqlQueryText] count] > 0;
	
	if (isNew && [[UserContext sharedUserContext].snsID isEqualToString:owner.snsId]) { //내 홈에서 새뱃지가 있다.
		newBadgeImageView.hidden = NO;
	} else { // 새뱃지가 없거나 타인의 홈이다.
		newBadgeImageView.hidden = YES;
	}	
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return [ApplicationContext sharedApplicationContext].shouldRotate;
}



#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
	return 2;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (section == 0) {
        // 탭에 따라 다른 어레이를 사용한다.
        NSInteger cnt = (tabIndex == 0) ? [recentFootprints count] : [scraps count];
        return cnt;
    } else {
        if (noResult) {
            return 1;
        } else {
            return 0;
        }
    }    
    return 0;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 1) {
        
        if (!noConnection) {    // 네트워크 연결 됐을 때
            static NSString *CellIdentifier = @"NoticeCell";
            
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil) {
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
            }
            
            if (noResult) {
                self.tutorial = [[[NSBundle mainBundle] loadNibNamed:@"TutorialView" owner:self options:nil] lastObject];
                [tutorial setFrame:CGRectMake(0, 0, 320, 280)];
                
                if ([[UserContext sharedUserContext].snsID isEqualToString:owner.snsId]) {  //마이홈일 때
                    [tutorial createTutorialView:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:tabIndex] forKey:@"status"]];
                } else {
                    [tutorial createTutorialView:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithInt:(tabIndex+6)] , owner.nickname, nil] forKeys:[NSArray arrayWithObjects:@"status", @"nickname", nil]]];
                }
                
                [cell addSubview:tutorial];
                
                cell.selectionStyle = UITableViewCellSelectionStyleNone;        
            } else {
                self.tutorial = nil;
            }
            return cell;
            
        }  else {    // 네트워크 연결 안됐을 때
            
            static NSString *CellIdentifier = @"CoverViewCell";
            
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil) {
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
            }
            
            if (noResult) {
                
                NSDictionary* params = [NSDictionary dictionaryWithObjectsAndKeys:
                                        [NSNumber numberWithFloat:320], @"width", 
                                        [NSNumber numberWithFloat:280], @"height",
                                        tableCoverNoticeMessage, @"message",nil];
                UIView* noticeView = [Utils createNoticeViewWithDictionary:params];
                [cell addSubview:noticeView];
                return cell;
                
            } else {
                self.tutorial = nil;
            } 
            return cell;
        }
        
    }  else {
        
//        static NSString *CellIdentifier2 = @"mainThreadCell";
//        
//        MainThreadCell *cell = (MainThreadCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier2];
//        
//        if (cell == nil) {
//            cell = [[[NSBundle mainBundle] loadNibNamed:@"MainThreadCell" owner:nil options:nil] lastObject];
//            if (tabIndex == 1) {
//                cell.curPosition = [[UserContext sharedUserContext].snsID isEqualToString:owner.snsId] ? @"6" : @"7";
//            } 
//        }
        
        static NSString *cellIdentifier = @"MyHomePostCell";
        MyHomePostCell *cell = (MyHomePostCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
        if (cell == nil) {
            cell = [[[NSBundle mainBundle] loadNibNamed:cellIdentifier owner:nil options:nil] lastObject];
        }
        NSDictionary* cellData = (tabIndex == 0) ? [recentFootprints objectAtIndex:indexPath.row] : [scraps objectAtIndex:indexPath.row];
        [cell redrawMyHomePostCellWithCellData:cellData];
        
        return cell;
    }
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

	NSInteger cnt = (tabIndex == 0) ? [recentFootprints count] : [scraps count];
    
    if (cnt == 0 && indexPath.section == 1) {
        return tableView.frame.size.height - tableView.tableHeaderView.frame.size.height + 54.0f;
    } else {		
		NSDictionary* cellData = (tabIndex == 0) ? [recentFootprints objectAtIndex:indexPath.row] : [scraps objectAtIndex:indexPath.row];
		
		float currentHeight = 0.0f;
		float topInSet = 12.0f;
		float poiNameHeight = 20.0f;
		float poiPostInSet = 2.0f;
		
		currentHeight += topInSet + poiNameHeight + poiPostInSet;
		
//		float postHeight = [MainThreadCell requiredLabelSize:cellData withType:NO].height;
        float postHeight = [MyHomePostCell requiredLabelSize:cellData withType:[[cellData objectForKey:@"isBadge"] isEqualToString:@"1"] ].height;
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
}




#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
    [balloonBtn setHidden:YES];
    
    if (indexPath.section == 1) {   // seciton 1은 안내 문구 표시 전용이므로 선택되지 않도록 처리한다.
        
        return;
    }
    
    if (tabIndex == 0 && [recentFootprints count] > 0) {
        NSDictionary* cellData = [recentFootprints objectAtIndex:indexPath.row];
        
        if ([[cellData objectForKey:@"postId"] isEqualToString:@""]) {
            // 잘못된 postID 에 대해서는 못가게 막자
            return;
        }
                
        PostDetailTableViewController* vc = [[[PostDetailTableViewController alloc] 
                                              initWithNibName:@"PostDetailTableViewController" 
                                              bundle:nil] autorelease];
        vc.postList = recentFootprints;
        vc.postData = [[[NSMutableDictionary alloc] initWithDictionary:cellData] autorelease];
        vc.postIndex = indexPath.row;
        
        
        [[tableView cellForRowAtIndexPath:indexPath] setSelected:FALSE animated:YES];
        
        [(UINavigationController*)[ViewControllers sharedViewControllers].tabBarController.selectedViewController pushViewController:vc animated:YES];
    }
    
    if (tabIndex == 1 && [scraps count] > 0) {
        NSDictionary* cellData = [scraps objectAtIndex:indexPath.row];
        
        if ([[cellData objectForKey:@"isDelPost"] isEqualToString:@"1"]) {
            if (![[UserContext sharedUserContext].snsID isEqualToString:owner.snsId]) {
                [CommonAlert alertWithTitle:@"안내" message:@"작성자에 의하여 삭제된 발도장입니다."];
                return;
            }
            self.scrapDelete = [[[ScrapDelete alloc] init] autorelease];
            scrapDelete.delegate = self;
            [scrapDelete.params addEntriesFromDictionary:[NSDictionary dictionaryWithObject:[cellData objectForKey:@"postId"] forKey:@"postId"]];
            [scrapDelete request];
            [scraps removeObject:cellData];
            if ([scraps count] == 0) {
                [tableView reloadData];
            } else {
                [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] 
                                 withRowAnimation:UITableViewRowAnimationFade];
            }
        } else {
            
            if ([owner.snsId isEqualToString:[UserContext sharedUserContext].snsID]) {
                GA3(@"마이홈", @"발도장상세보기", @"마이홈내_기억탭");
            } else {
                GA3(@"타인홈", @"발도장상세보기", @"타인홈내_기억탭");
            }

            PostDetailTableViewController* vc = [[[PostDetailTableViewController alloc] 
                                                  initWithNibName:@"PostDetailTableViewController" 
                                                  bundle:nil] autorelease];
            vc.postList = scraps;
            vc.postData = [[[NSMutableDictionary alloc] initWithDictionary:cellData] autorelease];
            vc.postIndex = indexPath.row;
            
            
            [[tableView cellForRowAtIndexPath:indexPath] setSelected:FALSE animated:YES];
            
            [(UINavigationController*)[ViewControllers sharedViewControllers].tabBarController.selectedViewController pushViewController:vc animated:YES];
        }
        
    }

    [tableView deselectRowAtIndexPath:indexPath animated:YES];

}

#pragma mark -
#pragma mark UIScrollView delegate

- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView {

}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {

    
    [balloonBtn setHidden:YES];
    
    if (!self.homeInfoResult) {
        [self requestHomeInfo];
    }
    
	if (isTop && !isEnd) {
        if (tabIndex == 0) {
            [self requestFootPoiListNew];
        } 
		return;
	}
	
	if (isEnd && !isTop) {
        if (tabIndex == 0) {
            [self requestFootPoiListOld];            
        } else {
            [self requestScrapList];
        }
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
    
	if (scrollView.contentOffset.y + mainTableView.frame.size.height + 10 > scrollView.contentSize.height) {
		isEnd = YES;
	} else {
		isEnd = NO;
	}
}



- (IBAction)selectTab:(UIButton*)sender {
    NSInteger tag = sender.tag;
    noResult = NO;
    selectedTab = YES;
    [balloonBtn setHidden:YES];
    
    if (self.tutorial) {
        self.tutorial = nil;
    }
    
    if (tag == 8000) {
        if ([[UserContext sharedUserContext].snsID isEqualToString:owner.snsId]) {
            GA3(@"마이홈", @"발도장탭", @"마이홈내");
        } else {
            GA3(@"타인홈", @"발도장탭", @"타인홈내");
        }
        
        tabIndex = 0;
        currPage = 1;
        
        self.recentFootprints = nil;
        
        [sender setBackgroundImage:[UIImage imageNamed:@"myh_tab1_on.png"] forState:UIControlStateNormal];
        UIButton* tab1 = (UIButton*)[self.view viewWithTag:8001];
        [tab1 setBackgroundImage:[UIImage imageNamed:@"myh_tab2_off.png"] forState:UIControlStateNormal];
        
        
        [self requestFootPoiList];
    } else {
        if ([[UserContext sharedUserContext].snsID isEqualToString:owner.snsId]) {
            GA3(@"마이홈", @"기억탭", @"마이홈내");
        } else {
            GA3(@"타인홈", @"기억탭", @"타인홈내");
        }

        tabIndex = 1;
        currPage = 1;
        
        self.scraps = nil;
        
        [sender setBackgroundImage:[UIImage imageNamed:@"myh_tab2_on.png"] forState:UIControlStateNormal];
        UIButton* tab0 = (UIButton*)[self.view viewWithTag:8000];
        [tab0 setBackgroundImage:[UIImage imageNamed:@"myh_tab1_off.png"] forState:UIControlStateNormal];
                
        [self requestScrapList];
    }
    [mainTableView reloadData];
}

#pragma mark Notification
- (void) reloadList: (NSNotification*) noti
{	
    [self requestFootPoiListNew];
}

#pragma mark - UITouch Event
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [balloonBtn setHidden:YES];
}

@end
