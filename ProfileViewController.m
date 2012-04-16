//
//  ProfileViewController.m
//  ImIn
//
//  Created by Myungjin Choi on 11. 1. 10..
//  Copyright 2011 KTH. All rights reserved.
//

#import "ProfileViewController.h"
#import "UIImageView+WebCache.h"

#import "TAddressbook.h"
#import "FriendSetViewController.h"
#import "UIMasterViewController.h"
#import "UIColumbusViewController.h"
#import "MyHomeNeighborViewController.h"
#import "HomeInfoDetail.h"
#import "CommonWebViewController.h"
#import <QuartzCore/QuartzCore.h>

#import "iToast.h"
#import "PoiInfo.h"
#import "ShopList.h"
#import "CookSnsCookie.h"
#import "POIDetailViewController.h"

#import "PictureViewController.h"
#import "ProfileEditViewController.h"
#import "BadgeViewController.h"

#import "LatestCheckinViewController.h"
#import "UIHomeViewController.h"
#import "CommonWebViewController.h"


#define TWITTERLINK_TAG 10001
#define FBLINK_TAG 10002
#define M2DLINK_TAG 10003
#define PHONELINK_TAG 10004
#define EMAILLINK_TAG 10005

#define PROFILE_EDIT_BUTTON_TAG 20001
#define FRIEND_SET_BUTTON_TAG 20002

#define PRO_BOT_BETWEEN_TAG 30001

@implementation UILabel (Clipboard)
- (BOOL) canBecomeFirstResponder
{
    return YES;
}
@end


@interface ProfileViewController (privateMethod)
- (void) fillProfileAreaWithDictionary:(NSDictionary*) data;
- (void) fillOwnerShopAreaWithDictionary:(NSDictionary*) data;
- (void) fillSocialLinkAreaWithDictionary:(NSDictionary*) data;
- (void) fillActivityStatusAreaWithDictionary:(NSDictionary*) data;
- (void) fillRelationshipAreaWithDictionary:(NSDictionary*) data;
- (void) fillFavoriteSpotAreaWithDictionary:(NSDictionary*) data;
- (void) fillFooterAreaWithDictionary:(NSDictionary*) data;
@end

@implementation ProfileViewController

@synthesize homeInfoResult, phoneBook, owner, friendCodeInt;
@synthesize homeInfoDetail,homeInfoDetailResult;
@synthesize poiInfo, cookSnsCookie;
@synthesize bizPoiKey;

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
#pragma mark - Request List
- (void) requestHomeInfoDetail
{
	if (coverView == nil)
	{
		coverView = [[UIView alloc] initWithFrame:self.view.bounds];
	}
	coverView.backgroundColor = RGB(39, 57, 63);
	
	[self.view addSubview:coverView];
	self.homeInfoDetail = [[[HomeInfoDetail alloc] init] autorelease];
	homeInfoDetail.delegate = self;
	[homeInfoDetail.params addEntriesFromDictionary:[NSDictionary dictionaryWithObject:owner.snsId forKey:@"snsId"]];
	[homeInfoDetail request];
}

- (void) requestShopList
{
    ShopList *shopList = [[ShopList alloc] init];
    shopList.delegate = self;
    [shopList.params addEntriesFromDictionary:[NSDictionary dictionaryWithObject:owner.snsId forKey:@"snsId"]];
    [shopList request];
}

#pragma mark - View Lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 프로필 보기가 떴을 때, 
    [[UserContext sharedUserContext] recordKissMetricsWithEvent:@"Viewed Someone Else’s Profile" withInfo:nil];
    
    profileTableView.delegate = self;
    profileTableView.dataSource = self;
    
    profileAreaHeight = 259.0f;
    footprintsAreaHeight = 126.0f;
	
	if( FR_YOU == friendCodeInt || FR_NONE == friendCodeInt )
		friendAdded = NO;
	else
		friendAdded = YES;
    
    [self requestHomeInfoDetail];

    if ([[homeInfoResult objectForKey:@"bizType"] isEqualToString:@"BT0003"]) { //소상공인
        isOwner = YES;
        [self requestShopList];
    } else {
        isOwner = NO;
    }
    
	// 초기 위치값 저장
	profileAreaRect = profileAreaCell.frame;
	nicknameLabelRect = nicknameLabel.frame;
	friendSettingBtnRect = friendSettingBtn.frame;
	birthMessageLabelRect = birthMessageLabel.frame;
	birthdayCakeRect = birthdayCake.frame;
	realNameLabelRect = realNameLabel.frame;
	introViewRect = introView.frame;
	prMessageLabelRect = prMessageLabel.frame;
    giftBtnRect = giftBtn.frame;
    
	// 본인의 프로필 변경에 대한 노티 받을 수 있도록 등록
	if ([owner.snsId isEqualToString:[UserContext sharedUserContext].snsID]) {
		NSNotificationCenter* dnc = [NSNotificationCenter defaultCenter];
		[dnc addObserver:self selector:@selector(profileUpdateCompleted:) name:@"profileUpdateCompleted" object:nil];		
	}
        
    // 쿠키 받아오기 요청
    self.cookSnsCookie = [[[CookSnsCookie alloc] init] autorelease];
    [cookSnsCookie request];
}

- (void) viewWillAppear:(BOOL)animated
{	
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(autoUpdateCompleted:) name:@"autoUpdate" object:nil];
}

- (void) viewDidDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"autoUpdate" object:nil];
}

- (void) viewDidAppear:(BOOL)animated
{
}

/*
 // Override to allow orientations other than the default portrait orientation.
 - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
 // Return YES for supported orientations.
 return (interfaceOrientation == UIInterfaceOrientationPortrait);
 }
 */

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [profileTableView release];
    profileTableView = nil;
    [categoryImageView release];
    categoryImageView = nil;
    [ownerNicknameLabel release];
    ownerNicknameLabel = nil;
    [shopName release];
    shopName = nil;
    [description release];
    description = nil;
    [profileAreaCell release];
    profileAreaCell = nil;
    [ownerShopCell release];
    ownerShopCell = nil;
    [socialLinkAreaCell release];
    socialLinkAreaCell = nil;
    [activityStatusCell release];
    activityStatusCell = nil;
    [relationshipAreaCell release];
    relationshipAreaCell = nil;
    [favoriteAreaCell release];
    favoriteAreaCell = nil;
    [latestColumbusCell release];
    latestColumbusCell = nil;
    [roundboxTopCell release];
    roundboxTopCell = nil;
    [roundboxBottomCell release];
    roundboxBottomCell = nil;
    [relationshipBgImageView release];
    relationshipBgImageView = nil;
    [favoriteAreaBgImageView release];
    favoriteAreaBgImageView = nil;
    [eventImage release];
    eventImage = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
	if ([owner.snsId isEqualToString:[UserContext sharedUserContext].snsID]) {
		[[NSNotificationCenter defaultCenter] removeObserver:self name:@"profileUpdateCompleted" object:nil];
	}
}

- (void)dealloc {
	[homeInfoResult release];
	[homeInfoDetailResult release];
	[poiInfo release];
    [cookSnsCookie release];
	[phoneBook release];
	
	[owner release];
	[coverView release];
	
    [profileTableView release];
    [categoryImageView release];
    [ownerNicknameLabel release];
    [shopName release];
    [description release];
    [profileAreaCell release];
    [ownerShopCell release];
    [socialLinkAreaCell release];
    [activityStatusCell release];
    [relationshipAreaCell release];
    [favoriteAreaCell release];
    [latestColumbusCell release];
    [roundboxTopCell release];
    [roundboxBottomCell release];
    [relationshipBgImageView release];
    [favoriteAreaBgImageView release];
    [eventImage release];
    [bizPoiKey release];
    [super dealloc];
}

#pragma mark -
#pragma mark IBAction Handler

- (IBAction) closeVC
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)clickOwnerShopBtn {
    self.poiInfo = [[[PoiInfo alloc] init] autorelease];
    poiInfo.delegate = self;
    poiInfo.poiKey = bizPoiKey;
    [poiInfo request];
}

- (IBAction) showActionSheet:(UIButton*) sender
{
	BOOL isMe = [[UserContext sharedUserContext].snsID isEqualToString:owner.snsId];
	NSString* goString = @"";
	switch (sender.tag) {
		case TWITTERLINK_TAG:
            if (isOwner) {
                GA3(@"주인장프로필", @"트위터버튼태핑", @"주인장프로필내");
            } else {
                if (isMe) {
                    GA3(@"마이프로필", @"트위터버튼", @"트위터버튼태핑");
                } else {
                    GA3(@"타인프로필", @"트위터버튼", @"트위터버튼태핑");
                }
            }
			goString = @"트위터 보기";
			break;
		case FBLINK_TAG:
            if (isOwner) {
                GA3(@"주인장프로필", @"페이스북버튼태핑", @"주인장프로필내");
            } else {
                if (isMe) {
                    GA3(@"마이프로필", @"페이스북버튼", @"페이스북버튼태핑");
                } else {
                    GA3(@"타인프로필", @"페이스북버튼", @"페이스북버튼태핑");
                }
            }
			goString = @"페이스북 보기";
			break;
		case M2DLINK_TAG:
            if (isOwner) {
                GA3(@"주인장프로필", @"미투데이버튼태핑", @"주인장프로필내");
            } else {
                if (isMe) {
                    GA3(@"마이프로필", @"미투데이버튼", @"미투데이버튼태핑");
                } else {
                    GA3(@"타인프로필", @"미투데이버튼", @"미투데이버튼태핑");
                }
            }
			goString = @"미투데이 보기";
			break;
		case PHONELINK_TAG:
            if (isMe) {
                GA3(@"마이프로필", @"전화버튼", @"전화버튼태핑");
            } else {
                GA3(@"타인프로필", @"전화버튼", @"전화버튼태핑");
            }
			goString = @"전화걸기";
			break;
		case EMAILLINK_TAG:
            if (isMe) {
                GA3(@"마이프로필", @"메일버튼", @"메일버튼태핑");
            } else {
                GA3(@"타인프로필", @"메일버튼", @"메일버튼태핑");
            }
			goString = @"메일 작성";
			break;
		default:
			break;
	}
	
	aActionSheet = [[UIActionSheet alloc]
                    initWithTitle:nil 
                    delegate:self 
                    cancelButtonTitle:@"취소" 
                    destructiveButtonTitle:nil
                    otherButtonTitles:goString, nil];
	aActionSheet.tag = sender.tag;
	
	[aActionSheet showInView:self.view.window];
}

- (void) profileUpdateCompleted:(NSNotification*) noti
{
	// profile이 업데이트가 되었으니, 다시 요청하자.
	[self requestHomeInfoDetail];
}

- (void) autoUpdateCompleted:(NSNotification*) noti
{
	MY_LOG(@"뱃지 리소스 다 받았음!!!");
	NSDictionary* ownerInfo = [noti userInfo];
	MY_LOG(@"뱃지 주인 정보: %@", ownerInfo);
	MemberInfo* badgeOwner = [[[MemberInfo alloc] init] autorelease];
	badgeOwner.snsId = [ownerInfo objectForKey:@"snsId"];
	badgeOwner.profileImgUrl = [ownerInfo objectForKey:@"imgUrl"];
	badgeOwner.nickname = [ownerInfo objectForKey:@"nickname"];
	
    int badgeCnt = [[homeInfoDetailResult objectForKey:@"badgeCnt"] intValue];

    if (badgeCnt != 0) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedCloseAndGoHome:) name:@"closeAndGoHome" object:nil];
        BadgeViewController* vc = [[[BadgeViewController alloc] initWithNibName:@"BadgeViewController" bundle:nil] autorelease];
        vc.owner = badgeOwner;
        [self.navigationController presentModalViewController:vc animated:YES];		
    }
}

- (void) friendSettingChanged:(NSNotification*) noti
{
	MY_LOG(@"노티왔다");
	NSDictionary* saveResult = [noti userInfo];
	MY_LOG(@"bool: %@ snsid: %@", [saveResult objectForKey:@"isFollowing"], [saveResult objectForKey:@"snsId"]);
	
	
	if ([[saveResult objectForKey:@"isFollowing"] boolValue]) {
		friendAdded = YES;
	} else {
		friendAdded = NO;
	}
	
	[self requestHomeInfoDetail];
	
	NSNotificationCenter* dnc = [NSNotificationCenter defaultCenter];
	[dnc removeObserver:self name:@"FriendSetSaved" object:nil];
}

- (IBAction) goFriendSettingOrProfileSetting:(UIButton*) sender
{
	if (sender.tag == FRIEND_SET_BUTTON_TAG) {
		if (friendAdded == FR_ME || friendAdded == FR_NONE) { // 이웃이 아니면
            if (isOwner) {
                GA3(@"주인장프로필", @"이웃추가버튼", @"주인장프로필내");
            } else {
                GA3(@"타인프로필", @"이웃추가버튼", @"타인프로필내");
            }
		} else {
            if (isOwner) {
                GA3(@"주인장프로필", @"이웃설정버튼", @"주인장프로필내");
            } else {
                GA3(@"타인프로필", @"이웃설정버튼", @"타인프로필내");
            }
		}
        
		FriendSetViewController *vc = [[FriendSetViewController alloc]initWithName:owner.nickname friendSnsId:owner.snsId friendCode:friendAdded?FR_ME:FR_NONE friendImage:[homeInfoResult objectForKey:@"profileImg"]];
		vc.referCode = @"0001";
		
		[self.navigationController pushViewController:vc animated:YES];
		[vc release];
		
		NSNotificationCenter* dnc = [NSNotificationCenter defaultCenter];
		[dnc addObserver:self selector:@selector(friendSettingChanged:) name:@"FriendSetSaved" object:nil];
	} else {
        GA3(@"마이프로필", @"프로필편집버튼", @"마이프로필내");
		// profile setting button
		ProfileEditViewController* vc = [[[ProfileEditViewController alloc] initWithNibName:@"ProfileEditViewController" bundle:nil] autorelease];
		vc.homeInfoDetailResult = homeInfoDetailResult;
		[self.navigationController pushViewController:vc animated:YES];
	}
    
}

- (IBAction) goMaster
{
	BOOL isMe = [[UserContext sharedUserContext].snsID isEqualToString:owner.snsId];
    if (isOwner) {
        GA3(@"주인장프로필", @"마스터숫자버튼", @"주인장프로필내");
    } else {
        if (isMe) {
            GA3(@"마이프로필", @"마스터숫자버튼", @"마이프로필내");
        } else {
            GA3(@"타인프로필", @"마스터숫자버튼", @"타인프로필내");
        }
    }
	
	int masterCnt = [[homeInfoDetailResult objectForKey:@"captainCnt"] intValue];
	
	if (masterCnt != 0) {
		UIMasterViewController* mv = [[UIMasterViewController alloc] initWithUserNick:owner.nickname withSNSid:owner.snsId];
		mv.tableRect = CGRectMake(0.0f, 30.0f+43.0f, 320.0f, 480.0f-83.0f-55.0f+49.0f);
		[self.navigationController  pushViewController:mv animated:YES];
		[mv release];		
	}
}

- (IBAction) goColumbus
{
	BOOL isMe = [[UserContext sharedUserContext].snsID isEqualToString:owner.snsId];
    if (isOwner) {
        GA3(@"주인장프로필", @"콜럼버스숫자버튼", @"주인장프로필내");
    } else {
        if (isMe) {
            GA3(@"마이프로필", @"콜럼버스숫자버튼", @"마이프로필내");
        } else {
            GA3(@"타인프로필", @"콜럼버스숫자버튼", @"타인프로필내");
        }
    }
	int columbusCnt = [[homeInfoDetailResult objectForKey:@"columbusCnt"] intValue];
    
	if (columbusCnt != 0) {
		UIColumbusViewController* vc = [[[UIColumbusViewController alloc] initWithNibName:@"UIColumbusViewController" bundle:nil] autorelease];
        vc.snsId = owner.snsId;
        vc.nickname = owner.nickname;
        
		[self.navigationController pushViewController:vc animated:YES];
	}
    
}

- (IBAction) goFootPrints
{
	BOOL isMe = [[UserContext sharedUserContext].snsID isEqualToString:owner.snsId];
    if (isOwner) {
        GA3(@"주인장프로필", @"발도장숫자버튼", @"주인장프로필내");
    } else {
        if (isMe) {
            GA3(@"마이프로필", @"발도장숫자버튼", @"마이프로필내");
        } else {
            GA3(@"타인프로필", @"발도장숫자버튼", @"타인프로필내");
        }
	}
	int checkinCnt = [[homeInfoDetailResult objectForKey:@"poiCnt"] intValue];
	
	if (checkinCnt != 0) {
		LatestCheckinViewController* vc = [[[LatestCheckinViewController alloc] initWithNibName:@"LatestCheckinViewController" bundle:nil] autorelease];
		vc.owner = owner;
		[self.navigationController pushViewController:vc animated:YES];		
	}
    
}

- (IBAction) goBadge:(UIButton*) sender
{
	BOOL isMe = [[UserContext sharedUserContext].snsID isEqualToString:owner.snsId];
    if (isOwner) {
        GA3(@"주인장프로필", @"뱃지숫자버튼", @"주인장프로필내");
    } else {
        if (isMe) {
            GA3(@"마이프로필", @"뱃지숫자버튼", @"마이프로필내");
        } else {
            GA3(@"타인프로필", @"뱃지숫자버튼", @"타인프로필내");
        }
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
	UIHomeViewController *vc = [[[UIHomeViewController alloc] initWithNibName:@"UIHomeViewController" bundle:nil] autorelease];
	
	MemberInfo* memberInfo = [[[MemberInfo alloc] init] autorelease];
	memberInfo.snsId = [aOwner objectForKey:@"snsId"];
	memberInfo.nickname = [aOwner objectForKey:@"nickname"];
	memberInfo.profileImgUrl = [aOwner objectForKey:@"profileImg"];
	
	vc.owner = memberInfo;
	
	[self.navigationController pushViewController:vc animated:YES];
}

- (void) goPoi:(UIButton*) sender
{
	MY_LOG(@"sender's layername = %@ %@", sender.layer.name, NSStringFromCGPoint(sender.layer.position));
    
	BOOL isMe = [[UserContext sharedUserContext].snsID isEqualToString:owner.snsId];
    if (isOwner) {
        GA3(@"주인장프로필", @"자주발도장찍은장소", @"주인장프로필내");
    } else {
        if (isMe) {
            GA3(@"마이프로필", @"자주발도장찍은장소", @"마이프로필내");
        } else {
            GA3(@"타인프로필", @"자주발도장찍은장소", @"타인프로필내");
        }
    }
    //	CGFloat animationDuration = 0.5;
    //	BOOL removedOnCompletion = YES;
    //	
    //	CABasicAnimation* rotateAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.y"];
    //	rotateAnimation.fromValue = [NSNumber numberWithFloat: 0.0];
    //	rotateAnimation.toValue = [NSNumber numberWithFloat:M_PI/2];
    //	rotateAnimation.duration = animationDuration/2;
    //	rotateAnimation.repeatCount = 2;
    //	rotateAnimation.autoreverses = YES;
    //	rotateAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    //	rotateAnimation.removedOnCompletion = removedOnCompletion;
	
	CABasicAnimation* bounceAnimation = [CABasicAnimation animationWithKeyPath:@"transform.translation.y"];
	bounceAnimation.fromValue = [NSNumber numberWithFloat: sender.layer.bounds.origin.y];
	bounceAnimation.toValue = [NSNumber numberWithFloat: sender.layer.bounds.origin.y - 10];
	bounceAnimation.duration = 0.1;
	bounceAnimation.autoreverses = YES;
	bounceAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
	[sender.layer addAnimation:bounceAnimation forKey:@"bounce"];
	
	self.poiInfo = [[[PoiInfo alloc] init] autorelease];
	self.poiInfo.delegate = self;
	self.poiInfo.poiKey = sender.layer.name;
	[self.poiInfo request];	
}

- (IBAction) goLargePicture: (UIButton*) sender
{
	BOOL isMe = [[UserContext sharedUserContext].snsID isEqualToString:owner.snsId];
    if (isOwner) {
        GA3(@"주인장프로필", @"프로필사진", @"주인장프로필내");
    } else {
        if (isMe) {
            GA3(@"마이프로필", @"프로필사진", @"마이프로필내");
        } else {
            GA3(@"타인프로필", @"프로필사진", @"타인프로필내");
        }
    }
	
	if( nil == owner.profileImgUrl ) return;
	
	PictureViewController* zoomingViewController = [[PictureViewController alloc] initWithNibName:@"PictureViewController" bundle:nil];
	[zoomingViewController setHidesBottomBarWhenPushed:YES];
	[zoomingViewController setPictureURL:owner.profileImgUrl];
	
	[self.navigationController pushViewController:zoomingViewController animated:NO];
	[zoomingViewController release];
}

- (void) goNeighbor:(UIButton*) sender
{
	MY_LOG(@"sender tag: %d", sender.tag);
	
	BOOL isMe = [[UserContext sharedUserContext].snsID isEqualToString:owner.snsId];
    if (isOwner) {
        if (!isMe) {
            GA3(@"주인장프로필", @"함께알고있는이웃", @"주인장프로필내");
        } 
    } else {
        if (!isMe) {
            NSInteger relationType= [[homeInfoDetailResult objectForKey:@"relationType"] intValue];
            switch (relationType) {
                case 2:
                    GA3(@"타인프로필", @"함께알고있는이웃", @"페이스북공통친구");
                    break;
                case 5:
                    GA3(@"타인프로필", @"함께알고있는이웃", @"공통이웃");
                    break;
                case 6:
                    GA3(@"타인프로필", @"함께알고있는이웃", @"이사람을이웃추가한사람");
                    break;
                default:
                    break;
            }
        } 
	}
	NSDictionary* neighbor = [[homeInfoDetailResult objectForKey:@"neighborList"] objectAtIndex:sender.tag];
	MemberInfo* aOwner = [[[MemberInfo alloc] init] autorelease];
	aOwner.snsId = [neighbor objectForKey:@"snsId"];
	aOwner.nickname = [neighbor objectForKey:@"nickname"];
	aOwner.profileImgUrl = [neighbor objectForKey:@"profileImg"];
	
	if ([aOwner.snsId isEqualToString:@""] || [aOwner.snsId isEqualToString:nil]) { // snsId 가 공백일경우... 아임인 유저가 아니다
		CommonWebViewController* commonWebVC = [[[CommonWebViewController alloc]initWithNibName:@"CommonWebViewController" bundle:nil] autorelease];
		commonWebVC.urlString = [neighbor objectForKey:@"cpUrl"];
		[self.navigationController presentModalViewController:commonWebVC animated:YES];
	} else {
		UIHomeViewController* vc = [[[UIHomeViewController alloc] initWithNibName:@"UIHomeViewController" bundle:nil] autorelease];
		vc.owner = aOwner;
		[self.navigationController pushViewController:vc animated:YES];
	}
}

- (void) goGiftSend:(UIButton*) sender
{
    if ([[homeInfoDetailResult objectForKey:@"isDenyGuest"] isEqualToString:@"1"]) { // 차단 유저
        NSString* msg = [NSString stringWithFormat:@"%@님이 선물을 사양하셨어요~", owner.nickname];
        [CommonAlert alertWithTitle:@"안내" message:msg];
        return;
    }
    
    if (isOwner) {
        GA3(@"주인장프로필", @"선물", @"주인장프로필내");
    } else {
        GA3(@"타인프로필", @"선물", @"타인프로필내");
    }
    CommonWebViewController* vc = [[[CommonWebViewController alloc] initWithNibName:@"CommonWebViewController" bundle:nil] autorelease];
    
    vc.urlString = [NSString stringWithFormat:@"%@?snsId=%@&device=%@&osVer=%@&targetSnsId=%@", 
                    HEARTCON_GIFT,
                    [UserContext sharedUserContext].snsID,
                    [ApplicationContext deviceId],
                    [[UIDevice currentDevice] systemVersion],
                    owner.snsId];
    
    vc.titleString = @"선물하기";
    vc.viewType = HEARTCON;
    
    [(UINavigationController*)[ViewControllers sharedViewControllers].tabBarController.selectedViewController 
     presentModalViewController:vc animated:YES];
    
}

- (void) receivedCloseAndGoHome:(NSNotification*) noti
{
	NSDictionary* aOwner = [noti userInfo];
	MY_LOG(@"노티: %@", [aOwner objectForKey:@"nickname"]);
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"closeAndGoHome" object:nil];
	
	[NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(goHome:) userInfo:aOwner repeats:NO];
}

#pragma mark - UIActionSheet Delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	NSString* urlString = @"";
	if (buttonIndex == 0) {
		BOOL isMe = [[UserContext sharedUserContext].snsID isEqualToString:owner.snsId];
		switch (actionSheet.tag) {
			case TWITTERLINK_TAG:
			{
                if (isOwner) {
                    GA3(@"주인장프로필", @"트위터열기", @"주인장프로필내");
                } else {
                    if (isMe) {
                        GA3(@"마이프로필", @"트위터버튼", @"트위터열기");
                    } else {
                        GA3(@"타인프로필", @"트위터버튼", @"트위터열기");
                    }
				}
				NSArray* cpList = [homeInfoDetailResult objectForKey:@"cpInfo"];
				for (NSDictionary* cpData in cpList) {
					if( [[cpData objectForKey:@"cpCode"] isEqualToString:@"51"] )
					{
						urlString = [cpData objectForKey:@"cpUrl"];
						CommonWebViewController* webVC = [[[CommonWebViewController alloc] initWithNibName:@"CommonWebViewController" bundle:nil] autorelease];
						webVC.urlString = urlString;
						[self.navigationController presentModalViewController:webVC animated:YES];
						return;
					}
				}
				break;
			}
			case FBLINK_TAG:
			{
                if (isOwner) {
                    GA3(@"주인장프로필", @"페이스북열기", @"주인장프로필내");
                } else {
                    if (isMe) {
                        GA3(@"마이프로필", @"페이스북버튼", @"페이스북열기");
                    } else {
                        GA3(@"타인프로필", @"페이스북버튼", @"페이스북열기");
                    }
				}
				NSArray* cpList = [homeInfoDetailResult objectForKey:@"cpInfo"];
				for (NSDictionary* cpData in cpList) {
					if( [[cpData objectForKey:@"cpCode"] isEqualToString:@"52"] )
					{
						urlString = [cpData objectForKey:@"cpUrl"];
						CommonWebViewController* webVC = [[[CommonWebViewController alloc] initWithNibName:@"CommonWebViewController" bundle:nil] autorelease];
						webVC.urlString = urlString;
						[self.navigationController presentModalViewController:webVC animated:YES];
					}
				}
				
				break;
			}
			case M2DLINK_TAG:
			{
                if (isOwner) {
                    GA3(@"주인장프로필", @"미투데이열기", @"주인장프로필내");
                } else {
                    if (isMe) {
                        GA3(@"마이프로필", @"미투데이버튼", @"미투데이열기");
                    } else {
                        GA3(@"타인프로필", @"미투데이버튼", @"미투데이열기");
                    }
				}
				NSArray* cpList = [homeInfoDetailResult objectForKey:@"cpInfo"];
				for (NSDictionary* cpData in cpList) {
					if( [[cpData objectForKey:@"cpCode"] isEqualToString:@"50"] )
					{
						urlString = [cpData objectForKey:@"cpUrl"];
						CommonWebViewController* webVC = [[[CommonWebViewController alloc] initWithNibName:@"CommonWebViewController" bundle:nil] autorelease];
						webVC.urlString = urlString;
						[self.navigationController presentModalViewController:webVC animated:YES];
					}
				}
				break;
			}
			case PHONELINK_TAG:
                if (isMe) {
                    GA3(@"마이프로필", @"전화버튼", @"전화열기");
                } else {
                    GA3(@"타인프로필", @"전화버튼", @"전화열기");
                }
				urlString = [NSString stringWithFormat:@"tel://%@", phoneBook.phone];
				[[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
				break;
			case EMAILLINK_TAG:
                if (isMe) {
                    GA3(@"마이프로필", @"메일버튼", @"메일열기");
                } else {
                    GA3(@"타인프로필", @"메일버튼", @"메일열기");
                }
				urlString = [NSString stringWithFormat:@"mailto://%@", [homeInfoDetailResult objectForKey:@"email"]];
				[[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
				break;
			default:
				break;
		}
	}
	
	[actionSheet release];	
}

#pragma mark -
#pragma mark UITableView Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        return profileAreaHeight;
    } else if (indexPath.section == 1) {
        return 104.0f;
    } else if (indexPath.section == 2) {
        return 81.0f;
    } else if (indexPath.section == 3) {
        return 159.0f;
    } else if (indexPath.section == 4) {    // 둥근 테이블 열기 이미지
        if (relationshipAreaHeight == 0 && footprintsAreaHeight == 0) {
            return 0.0f;
        }
        return 38.0f;
    } else if (indexPath.section == 5) {
        return relationshipAreaHeight;
    } else if (indexPath.section == 6) {
        return footprintsAreaHeight;
    } else if (indexPath.section == 7) {    // 둥근 테이블 닫기 이미지
        if (relationshipAreaHeight == 0 && footprintsAreaHeight == 0) {
            return 0.0f;
        }
        return 23.0f;
    }
    return 0.0f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    } else if (section == 1) {
        return ( countOfShopList > 0 ) ? 1 : 0; // 구조상 2개 이상일 경우 재사용 문제 (멤버 변수라서)
    } else if (section == 2) {
        return 1;
    } else if (section == 3) {
        return 1;
    } else if (section == 4) {    // 둥근 테이블 열기 이미지
        if (relationshipAreaHeight == 0 && footprintsAreaHeight == 0) {
            return 0;
        }
        return 1;
    } else if (section == 5) {
        return 1;
    } else if (section == 6) {
        return 1;
    } else if (section == 7) {    // 둥근 테이블 닫기 이미지
        if (relationshipAreaHeight == 0 && footprintsAreaHeight == 0) {
            return 0;
        }
        return 1;
    }
    return 0;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    switch (indexPath.section) {
        case 0:
        {
            static NSString *CellIdentifier = @"ProfileAreaCell";
            UITableViewCell *cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil) {
                cell = profileAreaCell;
            }
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
            
        }
            
        case 1:
        {
            static NSString *CellIdentifier = @"OwnerShopCell";
            UITableViewCell *cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil) {
                cell = ownerShopCell;
            }
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
            
        }
            
        case 2:
        {
            static NSString *CellIdentifier = @"SocialLinkAreaCell";
            UITableViewCell *cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil) {
                cell = socialLinkAreaCell;
            }
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
            
        }
            
        case 3:
        {
            static NSString *CellIdentifier = @"ActivityStatusCell";
            UITableViewCell *cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil) {
                cell = activityStatusCell;
            }
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
            
        }
            
        case 4:
        {
            static NSString *CellIdentifier = @"RoundboxTopCell";
            UITableViewCell *cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil) {
                cell = roundboxTopCell;
            }
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        }
            
        case 5:
        {
            static NSString *CellIdentifier = @"RelationshipAreaCell";
            UITableViewCell *cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil) {
                cell = relationshipAreaCell;
            }
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
            
        }
            
        case 6:
        {
            static NSString *CellIdentifier = @"FavoriteAreaCell";
            UITableViewCell *cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil) {
                cell = favoriteAreaCell;
            }
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
            
        }
            
        case 7:
        {
            static NSString *CellIdentifier = @"RoundboxBottomCell";
            UITableViewCell *cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil) {
                cell = roundboxBottomCell;
            }
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        }
    }
    
    return nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 8;   
}

#pragma mark -
#pragma mark ImInProtocol delegate

- (void) apiDidLoadWithResult:(NSDictionary *)result whichObject:(NSObject *)theObject
{
	MY_LOG(@"프로필 정보 ======> %@", result);
    
	if ([[result objectForKey:@"func"] isEqualToString:@"homeInfoDetail"]) {
		
		self.homeInfoDetailResult = result;
        
		[self fillProfileAreaWithDictionary:result];
		[self fillSocialLinkAreaWithDictionary:result];
		[self fillActivityStatusAreaWithDictionary:result];
		[self fillFavoriteSpotAreaWithDictionary:result];
		[self fillRelationshipAreaWithDictionary:result];
		[self fillFooterAreaWithDictionary:result];
		
        [profileTableView reloadData];
		
		[UIView beginAnimations:nil context:nil];
		coverView.alpha = 0.0f;
		[UIView commitAnimations];			
	}
	
	if ([[result objectForKey:@"func"] isEqualToString:@"poiInfo"]) {
		MY_LOG(@"결과: %@", [result objectForKey:@"poiName"]);
		POIDetailViewController *vc = [[POIDetailViewController alloc] initWithNibName:@"POIDetailViewController" bundle:nil];
		vc.poiData = result;
		[(UINavigationController*)[ViewControllers sharedViewControllers].tabBarController.selectedViewController pushViewController:vc animated:YES];
        [vc release];
	}
    
    if ([[result objectForKey:@"func"] isEqualToString:@"shopList"]) {
        
        [self fillOwnerShopAreaWithDictionary:result];
        
        [profileTableView reloadData];
        
        [theObject release];
    }
}

- (void) apiFailedWhichObject:(NSObject *)theObject
{
    MY_LOG(@"api failed!!!!");
    UIWindow *window = [[[UIApplication sharedApplication] windows] objectAtIndex:0];
    UIView *v = (UIView *)[window viewWithTag:TAG_iTOAST];
    if (!v) {
        iToast *msg = [[iToast alloc] initWithText:@" 인터넷 연결에 실패하였습니다. 네트워크 설정을 확인하거나, \n잠시 후 다시 시도해주세요~"];
        [msg setDuration:2000];
        [msg setGravity:iToastGravityCenter];
        [msg show];
        [msg release];
    }
    
    if ( [NSStringFromClass([theObject class]) isEqualToString:@"ShopList"] ) {
         [theObject release];
    } 
    
    [self performSelector:@selector(closeVC) withObject:nil afterDelay:0.5];
}

#pragma mark -
#pragma mark 데이터 채우기

- (void) fillProfileAreaWithDictionary:(NSDictionary*) data
{
	float height = 259.0f;
	MY_LOG(@"초기 높이: %f", height);
    
	// profile picture setting
	NSString* profileImageURL = [data objectForKey:@"profileImg"];
	owner.profileImgUrl = profileImageURL;
	
    if ([owner.profileImgUrl rangeOfString:@"no_prf"].location != NSNotFound) {
        [profileImageView setImageWithURL:[NSURL URLWithString: owner.profileImgUrl]
						 placeholderImage:[UIImage imageNamed:@"nonimg_full.png"]];
    }
    else 
    {		
        if (owner.profileImgUrl == nil) {
            return;
        }
        
        NSRange thumb1Range = [owner.profileImgUrl rangeOfString:@"_thumb1" options:NSBackwardsSearch];
        if (thumb1Range.location != NSNotFound) {
            NSString* thumb6ImageURL = [owner.profileImgUrl stringByReplacingCharactersInRange:thumb1Range withString:@"_thumb6"];
            
            [profileImageView setImageWithURL:[NSURL URLWithString: thumb6ImageURL] 
                             placeholderImage: nil];
        }
    }
	
	// nickname setting
	NSString* nickName = [data objectForKey:@"nickname"];
	nicknameLabel.text = nickName;
	
	// realname setting
	NSString* realName = [data objectForKey:@"realName"];
	if (realName && ![realName isEqualToString:@""]) {
		realNameLabel.text = realName;
		realNameLabel.hidden = NO;
		
		birthdayCake.frame = birthdayCakeRect;
		birthMessageLabel.frame = birthMessageLabelRect;
		friendSettingBtn.frame = friendSettingBtnRect;
        giftBtn.frame = giftBtnRect;
		introView.frame = introViewRect;
	} else {
		realNameLabel.hidden = YES;
		
		// 실명이 없다면 영역을 없애라
        const float realNameHeight = 22.0f + 4;
		height -= realNameHeight;
		
		CGRect tmp = birthdayCakeRect;
		tmp.origin.y -= realNameHeight;
		birthdayCake.frame = tmp;
		
		tmp = birthMessageLabelRect;
		tmp.origin.y -= realNameHeight;
		birthMessageLabel.frame = tmp;
		
		tmp = friendSettingBtnRect;
		tmp.origin.y -= realNameHeight;
		friendSettingBtn.frame = tmp;
        
        tmp = giftBtnRect;
        tmp.origin.y -= realNameHeight;
        giftBtn.frame = tmp;
		
		tmp = introViewRect;
		tmp.origin.y -= realNameHeight;
		introView.frame = tmp;
    }
	
	// pr message setting
	NSString* prMsg = [data objectForKey:@"prMsg"];
	if ([prMsg isEqualToString:@""]) {
		prMsg =[NSString stringWithFormat:@"안녕하세요. %@입니다.", nickName];
	} 
	prMessageLabel.text = prMsg;
	CGRect aFrame = prMessageLabel.frame;
	CGSize aSize = [prMsg sizeWithFont:[UIFont systemFontOfSize:13] constrainedToSize:CGSizeMake(272, 400) lineBreakMode:UILineBreakModeCharacterWrap];
	aFrame.size = aSize;
	prMessageLabel.frame = aFrame;
	aFrame = introView.frame;
	aFrame.size = CGSizeMake(introView.frame.size.width, aSize.height + 16 + 15 + 13 + 2);
	height -= introViewRect.size.height;
	introView.frame = aFrame;
	
	aFrame = prMessageBg.frame;
	aFrame.size = CGSizeMake(aFrame.size.width, aSize.height + 20);
	prMessageBg.frame = aFrame;
	height += introView.frame.size.height;
    
	BOOL isMe = [[UserContext sharedUserContext].snsID isEqualToString:owner.snsId];
	// friend button type setting
	
	if (isMe) {
		[friendSettingBtn setImage:[UIImage imageNamed:@"pro_top_btn3.png"] forState:UIControlStateNormal];
		friendSettingBtn.tag = PROFILE_EDIT_BUTTON_TAG;
        giftBtn.hidden = YES;
	} else {
		if( friendAdded )
			[friendSettingBtn setImage:[UIImage imageNamed:@"pro_case_fri_2.png"] forState:UIControlStateNormal];
		else
			[friendSettingBtn setImage:[UIImage imageNamed:@"pro_case_fri_1.png"] forState:UIControlStateNormal];
		
		friendSettingBtn.tag = FRIEND_SET_BUTTON_TAG;
        
        giftBtn.hidden = NO;
	}	
	
	// birthday process	
	BOOL isOpenPrBirth = [[data objectForKey:@"isOpenPrBirth"] boolValue];
	int birthType = [[data objectForKey:@"isBirth"] intValue];
	NSString* message = @"";
	
	if (isOpenPrBirth) {
		if (isMe) {
			switch (birthType) {
				case 0:
				{
					// 생일이 아닌 경우
					NSString* prBirth = [data objectForKey:@"prBirth"];
					NSString* prBirthType = [[data objectForKey:@"prBirthType"] intValue] == 1 ? @"양" : @"음";
					
					if ([prBirth isEqualToString:@""]) {
						break;
					}
					
					NSString* birthString = [NSString stringWithFormat:@"%@월 %@일 (%@)", 
											 [prBirth substringToIndex:2], 
											 [prBirth substringFromIndex:2],
											 prBirthType];					
					message = birthString;
					break;
				}
				case 1:
					// 생일이 1주일 전 ~ 1일전
					message = @"곧 생일이시네요.\n아임IN이 축하드려요.";
					break;
				case 2:
					// 생일 당일
					message = @"Happy Birthday!\n아임IN이 축하드려요.";
					[birthdayCake setImage:[UIImage imageNamed:@"pro_top_icon_cake_on.png"]];
					break;
				default:
					break;
			}
		} else {
			switch (birthType) {
				case 0:
					// 생일이 아닌 경우
					message = @"";
					break;
				case 1:
					// 생일이 1주일 전 ~ 1일전
					message = @"곧 생일이세요.\n축하해 주세요.";
					break;
				case 2:
					// 생일 당일
					message = @"곧 생일이세요.\n축하해 주세요.";
					[birthdayCake setImage:[UIImage imageNamed:@"pro_top_icon_cake_on.png"]];
					break;
				default:
					break;
			}
			
		}
	} else {	// 비공개 인경우
		if (isMe) {
			if ([[data objectForKey:@"prBirth"] isEqualToString:@""]) { // 생일이 설정되지 않은 경우
				message = @"생일을 설정하시고\n축하 받으세요.";
			} else {
				NSString* prBirth = [data objectForKey:@"prBirth"];
				NSString* prBirthType = [[data objectForKey:@"prBirthType"] intValue] == 1 ? @"양" : @"음";				
				NSString* birthString = [NSString stringWithFormat:@"%@월 %@일 (%@) / 비공개", 
										 [prBirth substringToIndex:2], 
										 [prBirth substringFromIndex:2],
										 prBirthType];										 
				message = birthString;
			}
		} else {
			if ([[data objectForKey:@"prBirth"] isEqualToString:@""]) { // 생일이 설정되지 않은 경우
				message = @"";
			} else {
				message = @"생일은 비밀이에요~";
			}
		}
	}
    
	if ([message isEqualToString:@""]) {
		birthdayCake.hidden = YES;
		birthMessageLabel.hidden = YES;
		
		CGRect tmp = friendSettingBtnRect;
		if ([realName isEqualToString:@""]) {
			tmp.origin.y -= 50;
		} else {
			tmp.origin.y -= 34;
		}
		friendSettingBtn.frame = tmp;
        
        tmp = giftBtnRect;
        if ([realName isEqualToString:@""]) {
			tmp.origin.y -= 50;
		} else {
			tmp.origin.y -= 34;
		}
        giftBtn.frame = tmp;
        
		tmp = nicknameLabelRect;
        //		tmp.origin.y += 10;
		nicknameLabel.frame = tmp;
		
		if (![realName isEqualToString:@""]) {
			tmp = introView.frame;
			tmp.origin.y -= 25.0f;
			introView.frame = tmp;
			height -= 25.0f;			
		}
	} else {
		birthdayCake.hidden = NO;
		birthMessageLabel.hidden = NO;
		birthMessageLabel.text = message;		
	}
    
	CGRect newFrame = profileAreaRect;
	newFrame.size.height = height;
	profileAreaCell.frame = newFrame;
    profileAreaHeight = height;
}

- (void) fillOwnerShopAreaWithDictionary:(NSDictionary*) data 
{
    countOfShopList = [[data objectForKey:@"totalCnt"] intValue];
    
    NSArray *shopInfoArray = [data objectForKey:@"data"];
    
    if ([shopInfoArray count] > 0) {
        
        NSDictionary *shopInfo = [[data objectForKey:@"data"] objectAtIndex:0];
        
        self.bizPoiKey = [shopInfo objectForKey:@"poiKey"];
        
        ownerNicknameLabel.text = [NSString stringWithFormat:@"%@님의 가게", owner.nickname];
        ownerNicknameLabel.textColor = RGB(17, 17, 17);
        shopName.text =[shopInfo objectForKey:@"poiName"];
        shopName.textColor =  RGB(2, 129, 176);
        
        NSString *addr = [NSString stringWithFormat:@"%@ %@ %@",  [shopInfo objectForKey:@"addr1"], [shopInfo objectForKey:@"addr2"], [shopInfo objectForKey:@"addr3"]];
        description.text = addr;
        description.textColor =  RGB(102, 102, 102);
        
        if (![[shopInfo objectForKey:@"logoImg"] isEqualToString:@""]) {
            [categoryImageView setFrame:CGRectMake(26, 33, 53, 53)];
            [categoryImageView setImageWithURL:[NSURL URLWithString:[shopInfo objectForKey:@"logoImg"]] placeholderImage:nil];
        } else {
            [categoryImageView setFrame:CGRectMake(26, 36, 47, 47)];
            
            NSString *imgUrl = [Utils convertImgSize70to47:[shopInfo objectForKey:@"categoryImg"]];
            [categoryImageView setImageWithURL:[NSURL URLWithString:imgUrl] placeholderImage:[UIImage imageNamed:@"cate_dummy.png"]];
        }
        
        if ([[shopInfo objectForKey:@"isEvent"] isEqualToString:@"1"]) {
            
            [eventImage setHidden:NO];
            shopName.frame = CGRectMake(shopName.frame.origin.x,
                                        shopName.frame.origin.y,
                                        160.0f, shopName.frame.size.height);
            
            CGSize size = [shopName.text sizeWithFont:shopName.font];
            
            if(size.width < 160.0f) {
                shopName.frame = CGRectMake(shopName.frame.origin.x,
                                            shopName.frame.origin.y,
                                            size.width, shopName.frame.size.height);
            } 
            CGRect frame = eventImage.frame;
            frame.origin.x = shopName.frame.origin.x + shopName.frame.size.width + 3;
            eventImage.frame = frame;
        } else {
            [eventImage setHidden:YES];
        }
    }
}

- (void) fillSocialLinkAreaWithDictionary:(NSDictionary*) data
{
	NSArray* cpInfo = [data objectForKey:@"cpInfo"];
	
	MY_LOG(@"cpInfo.count = %i", cpInfo.count);
	
	for (NSDictionary* data in cpInfo) {
		NSString* cpCode = [data objectForKey:@"cpCode"];
		MY_LOG(@"==> cpCode = %@", cpCode);
        
		if ([cpCode isEqualToString:@"50"]) { //me2day
			me2dayLinkBtn.enabled = YES;
		}
		
		if ([cpCode isEqualToString:@"51"]) { //twitter
			twitterLinkBtn.enabled = YES;
		}
		
		if ([cpCode isEqualToString:@"52"]) { //facebook
			//페이스북 버튼 활성화
			fbLinkBtn.enabled = YES;
		}		
	}
	
	// 이메일 버튼
	if (![[data objectForKey:@"email"] isEqualToString:@""]) {
		emailLinkBtn.enabled = YES;
	}
	
	// 전화번호 버튼
	MY_LOG(@"md5PhoneNo: %@", [data objectForKey:@"md5phoneNo"]);
	NSString* md5PhoneNo = [data objectForKey:@"md5phoneNo"];
	
	self.phoneBook = [[TAddressbook findWithSql:[NSString stringWithFormat:@"select * from TAddressbook where md5 = '%@'", md5PhoneNo]] lastObject];
	MY_LOG(@"phone NO: %@", phoneBook.phone);
	
	if ([[UserContext sharedUserContext].snsID isEqualToString:owner.snsId])
	{
		phoneLinkBtn.enabled = NO;
	}else {
		if(phoneBook == nil || [[data objectForKey:@"isPerm"] isEqualToString:@"OWNER"])
		{
			phoneLinkBtn.enabled = NO;
		}
		else {
			phoneLinkBtn.enabled = YES;
		}
	}
}

- (void) fillActivityStatusAreaWithDictionary:(NSDictionary*) data
{
	NSNumber* masterCnt = [data objectForKey:@"captainCnt"];
	NSNumber* columbusCnt = [data objectForKey:@"columbusCnt"];
	NSNumber* badgeCnt = [data objectForKey:@"badgeCnt"];
	NSNumber* checkinCnt = [data objectForKey:@"poiCnt"];
	
	masterNumber.text = [masterCnt stringValue];
	columbusNumber.text = [columbusCnt stringValue];
	badgeNumber.text = [badgeCnt stringValue];
	checkInNumber.text = [checkinCnt stringValue];	
}

- (void) fillRelationshipAreaWithDictionary:(NSDictionary*) data
{
	NSInteger relationType = [[data objectForKey:@"relationType"] intValue];
	NSString* titleImageName = nil;
	MY_LOG(@"%d", relationType);
	
	float height = 0.0f;
	
	switch (relationType) {
		case 1: 
		{
			NSArray* neighborList = [data objectForKey:@"neighborList"];
			int count = [neighborList count];
			
			if (count > 0) {
				UIImageView* icon = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"recomType11.png"]] autorelease];
				icon.frame = CGRectMake(26, 26, 16, 16);
				[relationshipAreaCell addSubview:icon];
				UILabel* name = [[[UILabel alloc] initWithFrame:CGRectMake(47, 25, 200, 19)] autorelease];
				NSMutableString *nameTemp = [[[NSMutableString alloc]init] autorelease];
				
				int i = 0;
				for (NSDictionary* neighbor in neighborList) {
					if (phoneBook.name == nil) {
						[nameTemp appendString:[neighbor objectForKey:@"nickname"]];
					} else {
						[nameTemp appendString:phoneBook.name];
					}
					i++;
					if (i < count) {
						[nameTemp appendString:@", "];
					}
				}
				
				name.text = nameTemp;	
				name.font = [UIFont systemFontOfSize:17];
				name.textColor = RGB(0x11, 0x11, 0x11);
				[relationshipAreaCell addSubview:name];	
			}
			
			UILabel* desc = [[[UILabel alloc] initWithFrame:CGRectMake(26, 51, 200, 13)] autorelease];
			desc.text = @"폰번호를 아는 사이에요";
			desc.font = [UIFont systemFontOfSize:13];
			desc.textColor = RGB(0x66, 0x66, 0x66);
			[relationshipAreaCell addSubview:desc];
			
			titleImageName = @"pro_bot_title1_case1.png";
			height = 97;
			break;
		}
			
		case 2:
		{
			UIImageView* icon = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"recomType23.png"]] autorelease];
			icon.frame = CGRectMake(26, 26, 16, 16);
			[relationshipAreaCell addSubview:icon];
			
			UILabel* name = [[[UILabel alloc] initWithFrame:CGRectMake(47, 25, 200, 19)] autorelease]; // 높이가 17이었음.
            
			NSArray* cpList = [homeInfoDetailResult objectForKey:@"cpInfo"];
			for (NSDictionary* cpData in cpList) {
				if( [[cpData objectForKey:@"cpCode"] isEqualToString:@"52"] )
				{
					name.text = [cpData objectForKey:@"cpName"];
					break;
				}
			}
			
			name.font = [UIFont systemFontOfSize:17];
			name.textColor = RGB(0x11, 0x11, 0x11);
			[relationshipAreaCell addSubview:name];
			
			UILabel* desc = [[[UILabel alloc] initWithFrame:CGRectMake(26, 51, 200, 13)] autorelease];
			desc.text = @"페이스북에서 친구예요.";
			desc.font = [UIFont systemFontOfSize:13];
			desc.textColor = RGB(0x66, 0x66, 0x66);
			[relationshipAreaCell addSubview:desc];
			
			titleImageName = @"pro_bot_title1_case1.png";
			height = 97;
			break;
		}
			
		case 3:
		{
			NSArray* neighborList = [data objectForKey:@"neighborList"];
			int count = [neighborList count];
            
			if (count > 0) {
				UIImageView* icon = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"recomType11.png"]] autorelease];
				icon.frame = CGRectMake(26, 26, 16, 16);
				[relationshipAreaCell addSubview:icon];
				UILabel* name = [[[UILabel alloc] initWithFrame:CGRectMake(47, 25, 200, 19)] autorelease];
				NSMutableString *nameTemp = [[[NSMutableString alloc]init] autorelease];
				
				int i = 0;
				for (NSDictionary* neighbor in neighborList) {
					if (phoneBook.name == nil) {
						[nameTemp appendString:[neighbor objectForKey:@"nickname"]];
					} else {
						[nameTemp appendString:phoneBook.name];
					}
					i++;
					if (i < count) {
						[nameTemp appendString:@", "];
					}
				}
				
				name.text = nameTemp;	
				name.font = [UIFont systemFontOfSize:17];
				name.textColor = RGB(0x11, 0x11, 0x11);
				[relationshipAreaCell addSubview:name];	
				
				titleImageName = @"pro_bot_title1_case2.png";
				height = 84;
				//height = 66;
			}
			else {
				height = 0;
			}
            
			break;
		}
			
		case 4:
		{
			NSArray* neighborList = [data objectForKey:@"neighborList"];
			
			int i = 0;
			
			for (NSDictionary* neighbor in neighborList) {
				CGRect aFrame = CGRectMake(26 + i * 46, 32, 38, 38);
				
				UIImageView* picture = [[[UIImageView alloc] initWithFrame:aFrame] autorelease];
				
				if([[[UIDevice currentDevice] systemVersion] doubleValue] >= 4.0) {
					picture.layer.shadowColor = [UIColor grayColor].CGColor;
					picture.layer.shadowOffset = CGSizeMake(0, 1);
					picture.layer.shadowOpacity = 1;
					picture.layer.shadowRadius = 1.0;
				}
				
				NSURL* url = [NSURL URLWithString:[neighbor objectForKey:@"profileImg"]];
                
				[picture setImageWithURL:url placeholderImage:[UIImage imageNamed:@"non_profile_37x37.gif"]];
				
				[relationshipAreaCell addSubview:picture];
                
				UIButton* neighborBtn = [UIButton buttonWithType:UIButtonTypeCustom];
				neighborBtn.tag = i;
				[neighborBtn addTarget:self action:@selector(goNeighbor:) forControlEvents:UIControlEventTouchUpInside];
				neighborBtn.frame = aFrame;
				[relationshipAreaCell addSubview:neighborBtn];
                
				i++;
			}
			
			titleImageName = @"pro_bot_title1_case3.png";
			height = 90 + 23;
			break;
		}
			
		case 5:
		{
			NSArray* neighborList = [data objectForKey:@"neighborList"];
			
			int i = 0;
			for (NSDictionary* neighbor in neighborList) {
				CGRect aFrame = CGRectMake(26 + i * 46, 32, 38, 38);
				UIImageView* picture = [[[UIImageView alloc] initWithFrame:aFrame] autorelease];
				
				if([[[UIDevice currentDevice] systemVersion] doubleValue] >= 4.0) {
					picture.layer.shadowColor = [UIColor grayColor].CGColor;
					picture.layer.shadowOffset = CGSizeMake(0, 1);
					picture.layer.shadowOpacity = 1;
					picture.layer.shadowRadius = 1.0;
				}
				
				NSURL* url = [NSURL URLWithString:[neighbor objectForKey:@"profileImg"]];
				[picture setImageWithURL:url placeholderImage:[UIImage imageNamed:@"non_profile_37x37.gif"]];
				[relationshipAreaCell addSubview:picture];
				
				UIButton* neighborBtn = [UIButton buttonWithType:UIButtonTypeCustom];
				neighborBtn.tag = i;
				[neighborBtn addTarget:self action:@selector(goNeighbor:) forControlEvents:UIControlEventTouchUpInside];
				neighborBtn.frame = aFrame;
				
				[relationshipAreaCell addSubview:neighborBtn];
				
				i++;
			}
			
			titleImageName = @"pro_bot_title1_case4.png";
			height = 90 + 23; 
			break;
		}
			
		case 6:
		{
			NSArray* neighborList = [data objectForKey:@"neighborList"];
			
			int i = 0;
			for (NSDictionary* neighbor in neighborList) {
				CGRect aFrame = CGRectMake(26 + i * 46, 32, 38, 38);
				UIImageView* picture = [[[UIImageView alloc] initWithFrame:aFrame] autorelease];
				NSURL* url = [NSURL URLWithString:[neighbor objectForKey:@"profileImg"]];
				[picture setImageWithURL:url placeholderImage:[UIImage imageNamed:@"non_profile_37x37.gif"]];
				[relationshipAreaCell addSubview:picture];
				
				UIButton* neighborBtn = [UIButton buttonWithType:UIButtonTypeCustom];
				neighborBtn.tag = i;
				[neighborBtn addTarget:self action:@selector(goNeighbor:) forControlEvents:UIControlEventTouchUpInside];
				neighborBtn.frame = aFrame;
				
				[relationshipAreaCell addSubview:neighborBtn];
				
				i++;
			}
			
			titleImageName = @"pro_bot_title1_case5.png";
			height = 90 + 23;
			break;
		}
			
		default:
			height = 0;
			break;
	}
	
	if (titleImageName != nil) {
		[relationshipTitleImageView setImage:[UIImage imageNamed:titleImageName]];
	}
    
    if (footprintsAreaHeight == 0) {
        height = 0;
    }
    
    CGRect newFrame = relationshipAreaCell.frame;
    newFrame.size.height = height;
    relationshipAreaCell.frame = newFrame;
    relationshipAreaHeight = height;
    CGRect bgFrame = relationshipBgImageView.frame;
    bgFrame.size.height = height;
    [relationshipBgImageView setFrame:bgFrame];
    
	if (footprintsAreaHeight != 0) {
        UIImageView* bottomLine = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pro_bot_between.png"]] autorelease];
		bottomLine.tag = PRO_BOT_BETWEEN_TAG;
		bottomLine.frame = CGRectMake(10, height-23, 300, 1);
		[relationshipAreaCell addSubview:bottomLine];
	}
}

- (void) fillFavoriteSpotAreaWithDictionary:(NSDictionary*) data
{
	float height = 0.0f;
	
	NSArray* favoritePoiList = [data objectForKey:@"oPoiList"];
	
	// 이미 들어 있는 버튼들을 제거함
	for (UIView* aView in [favoriteAreaCell subviews]) {
		if ([aView isKindOfClass:[UIButton class]]) {
			[aView removeFromSuperview];
		}
	}
	
	int i=0;
	for (NSDictionary* favoritePoi in favoritePoiList)
	{
		UIButton* poiButton = [UIButton buttonWithType:UIButtonTypeCustom];
		[poiButton setTitle:[NSString stringWithFormat:@"• %@", [favoritePoi objectForKey:@"poiName"]] forState:UIControlStateNormal];
		[poiButton setTitleColor:RGB(0x66, 0x66, 0x66) forState:UIControlStateNormal];
		[poiButton addTarget:self action:@selector(goPoi:) forControlEvents:UIControlEventTouchUpInside];
		poiButton.titleLabel.font = [UIFont systemFontOfSize:14];
		poiButton.titleLabel.lineBreakMode = UILineBreakModeTailTruncation;
		poiButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
		poiButton.contentEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
		
		poiButton.layer.name = [favoritePoi objectForKey:@"poiKey"];
		
		poiButton.frame = CGRectMake( i % 2 * 139 + 16,  i / 2 * 26 + 30, 130, 20);
		MY_LOG(@"frame = %@", NSStringFromCGRect(poiButton.frame));
		[favoriteAreaCell addSubview:poiButton];
		i++;
		// 맨 마지막 poiButton의 높이 값에 23을 더한 것을 이 뷰의 높이로 정한다.
		height = poiButton.frame.origin.y + poiButton.frame.size.height;
	}
	
	CGRect newFrame = favoriteAreaCell.frame;
	newFrame.size.height = height;
	favoriteAreaCell.frame = newFrame;
    footprintsAreaHeight = height;
    CGRect bgFrame = favoriteAreaBgImageView.frame;
    bgFrame.size.height = height;
    [favoriteAreaBgImageView setFrame:bgFrame];
	
	if (height == 0) {
		UIImageView* btwLine = (UIImageView*)[relationshipAreaCell viewWithTag:PRO_BOT_BETWEEN_TAG];
		btwLine.hidden = YES;
	}
}

- (void) fillFooterAreaWithDictionary:(NSDictionary*) data
{
	regDateLabel.text = [NSString stringWithFormat:@"아임IN 시작일 : %@", [Utils getSimpleDateWithString:[data objectForKey:@"regDate"]]];
}

@end

