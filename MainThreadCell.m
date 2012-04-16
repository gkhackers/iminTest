//
//  MainThreadCell.m
//  ImIn
//
//  Created by choipd on 10. 4. 19..
//  Copyright 2010 edbear. All rights reserved.
//

#import "MainThreadCell.h"
#import "UIImageView+WebCache.h"
#import "UIHomeViewController.h"
#import "MyHomeViewController.h"
#import "ViewControllers.h"
#import "UserContext.h"
#import "PictureViewController.h"
#import "FriendSetViewController.h"
#import "JSON.h"

#import "Utils.h"
#import <QuartzCore/QuartzCore.h>
#import "macro.h"
#import "BadgePictureViewController.h"
#import "BrandHomeViewController.h"
#import "HomeInfo.h"


@implementation MainThreadCell

@synthesize cellData;
@synthesize isToMeNeighbor, isNeighbor, isPoiDetailVC, isOwner;
@synthesize curPosition;
@synthesize cellHeight;
@synthesize homeInfo;

#define PROFILE_BRAND_IMAGE_FRAME CGRectMake(8, 22, 38, 38)
#define PROFILE_DEFAULT_IMAGE_FRAME CGRectMake(8, 12, 38, 38)
#define NICKNAME_BRAND_FRAME CGRectMake(8, 63, 61, 17)
#define NICKNAME_FRAME CGRectMake(8, 51, 61, 17)

/**
 @brief 네트워크 변수, 브랜드 마크 초기화
 @param a NSString that reuseIdentifier
 @return self(id)
 */
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        connect = nil;
        brandMark.hidden = YES;
    }
    return self;
}

/**
 @brief 셀 선택했을 때 실행되는 메소드
 @param a BOOL that selection/non-selection, a BOOL that animation/non-animation
 @result 셀 배경색 변경
 @return void
 */
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];
	UIView* bgView = [[UIView alloc] initWithFrame:self.frame];
	CAGradientLayer *gradient = [CAGradientLayer layer];
	gradient.frame = bgView.bounds;
	gradient.colors = [NSArray arrayWithObjects:(id)[RGB(214, 241, 248) CGColor], (id)[RGB(178, 229, 241) CGColor], nil];
	[bgView.layer insertSublayer:gradient atIndex:0];
	self.selectedBackgroundView = bgView;
	[bgView release];
    // Configure the view for the selected state
}

/**
 @brief 메모리 해제
 @return void
 */
- (void)dealloc {
	if (connect != nil)
	{
		[connect stop];
		[connect release];
		connect = nil;
	}
	[nickName release];
	[profileImg release];
	[iconIn release];
	[iconLock release];
	[post release];
	[postImg release];
	[cmtCntLabel release];
	[poiName release];
	[description release];
	[curPosition release];

    [postImgBtn release];
    [selectedBgView release];
    [eventIcon release];
    [seperatorLine release];
    [brandMark release];
    [homeInfo release];

    [super dealloc];
}

/**
 @brief 포스트 UI 다시 그리기
 @param a float that current cell height, a float that current description's height
 @return void
 */
- (void) postRedrawCell:(float)currHeight : (float)currDescHeight { //post+소상공인(poi랑 매칭될때만)+브랜드
    float currentHeight = currHeight;
    //아직 발도장을 찍은 적이 없는 이웃의 경우는 "아직 발도장을 찍은 곳이 없어요~를 보여줄 위치 지정
    if ([[cellData objectForKey:@"postId"] isEqualToString:@""]) {
        [poiName setTextColor:[UIColor colorWithRed:17/255.0 green:17/255.0 blue:17/255.0 alpha:1]];
        poiName.text = @"이 이웃에게 관심을..";
    }
    
    NSNumber* openState = [cellData objectForKey:@"isOpen"];
	BOOL isOpen = NO;
	if (openState != nil) {
		isOpen = [openState intValue] == 0 ? NO : YES;
	} else {
		isOpen = YES;
	}
    
	if (!isOpen) {
		iconLock.hidden = NO;
		[iconLock setFrame:CGRectMake(70.0f, currentHeight, 8.0f, 10.0f )];
		[description setFrame:CGRectMake(83.0f, currentHeight, 200, currDescHeight)];		
	} else {
		iconLock.hidden = YES;
		[description setFrame:CGRectMake(70.0f, currentHeight, 200, currDescHeight)];
	}
    
    currentHeight += currDescHeight;
    
    [self drawSeperatorLine:currentHeight];
    
    // biz 타입이냐?
    if ([[cellData objectForKey:@"postId"] isEqualToString:[cellData objectForKey:@"bizPostId"]]) {
        [poiName setTextColor:[UIColor colorWithRed:17/255.0 green:17/255.0 blue:17/255.0 alpha:1]];
        poiName.text = [cellData objectForKey:@"nickname"];
    } 

    isEvent = [cellData objectForKey:@"evtId"] && ![[cellData objectForKey:@"evtId"] isEqualToString:@""];
    
    if (![[cellData objectForKey:@"imgUrl"] isEqualToString:@""] && nil != [cellData objectForKey:@"imgUrl"]) {
        [postImg setAlpha:1.0f];
		
        if (isEvent) { // 이벤트면
            poiName.frame = CGRectMake(poiName.frame.origin.x,
                                       poiName.frame.origin.y,
                                       180-32-3, poiName.frame.size.height);
            
            //poiName.text = @"[공식]ABC마트";
            
            eventIcon.hidden = NO; // 이벤트 표시를 해준다.
            
            CGSize size = [poiName.text sizeWithFont:poiName.font];
            
            if(size.width < (180-32-3)) {// 라벨사이즈의 넓이가 한계치보다 크면
                poiName.frame = CGRectMake(poiName.frame.origin.x,
                                           poiName.frame.origin.y,
                                           size.width, poiName.frame.size.height);
            } 
            
            CGRect frame = eventIcon.frame;
            frame.origin.x = poiName.frame.origin.x + poiName.frame.size.width + 3;
            eventIcon.frame = frame;
            
        } else {
            eventIcon.hidden = YES; // 이벤트 표시를 안해준다.
        }
            
        [postImg setImageWithURL:[NSURL URLWithString:[cellData objectForKey:@"imgUrl"]] placeholderImage:[UIImage imageNamed:@"delay_nophoto91.png"]];
		
        
		[postImgBtn setEnabled:YES];
		[postImgBtn setFrame:postImg.frame];
    } else {
        if (isEvent) { // 이벤트면
			poiName.frame = CGRectMake(poiName.frame.origin.x,
									   poiName.frame.origin.y,
									   240-32-3, poiName.frame.size.height);
			
			eventIcon.hidden = NO; // 이벤트 표시를 해준다.
			
			CGSize size = [poiName.text sizeWithFont:poiName.font];
			
			if(size.width < (240-32-3)) {// 라벨사이즈의 넓이가 한계치보다 크면
				poiName.frame = CGRectMake(poiName.frame.origin.x,
										   poiName.frame.origin.y,
										   size.width, poiName.frame.size.height);
			} 
			
			CGRect frame = eventIcon.frame;
			frame.origin.x = poiName.frame.origin.x + poiName.frame.size.width + 3;
			eventIcon.frame = frame;
			
		} else {
			eventIcon.hidden = YES; // 이벤트 표시를 안해준다.
		}
		
		[postImg setAlpha:0.0f];
		[postImgBtn setEnabled:NO];
    }
    
    snsID = [cellData objectForKey:@"snsId"];
}

/**
 @brief 뱃지 UI 다시 그리기
 @param a float that current height, a float that current description's height
 @return void
 */
- (void) badgeRedrawCell:(float)currHeight : (float)currDescHeight { //badge+heartcon
    float currentHeight = currHeight;
    
	NSString* badgeMsgTemp = [cellData objectForKey:@"badgeMsg"];

    iconLock.hidden = YES;
    [description setFrame:CGRectMake(70.0f, currentHeight, 200, currDescHeight)];
    currentHeight += currDescHeight;
    [self drawSeperatorLine:currentHeight];
        
    if ([[cellData objectForKey:@"isBadge"] isEqualToString:@"1"]) { //그려야 할 포스트가 뱃지면
        description.text = [NSString stringWithFormat:@"%@ | 댓글 %@",[Utils getDescriptionWithString:[cellData objectForKey:@"regDate"]], [cellData objectForKey:@"cmtCnt"]];
        
        [poiName setTextColor:[UIColor colorWithRed:17/255.0 green:17/255.0 blue:17/255.0 alpha:1]];
        post.text = badgeMsgTemp;

        [postImg setAlpha:1.0f];
        UIImage* image = [Utils getImageFromBaseUrl:[cellData objectForKey:@"imgUrl"] withSize:@"53x53" withType:@"f"];
        [postImg setImage:image];        
    } else if ([[cellData objectForKey:@"postType"]isEqualToString:@"2"]) { //하트콘이면
        description.text = [NSString stringWithFormat:@"%@ | 댓글 %@",[Utils getDescriptionWithString:[cellData objectForKey:@"regDate"]], [cellData objectForKey:@"cmtCnt"]];
        post.text = [MainThreadCell getPostWithDictionary:cellData];
        [poiName setTextColor:[UIColor colorWithRed:17/255.0 green:17/255.0 blue:17/255.0 alpha:1]];
        
        [postImg setImageWithURL:[NSURL URLWithString:[cellData objectForKey:@"imgUrl"]]
                placeholderImage:[UIImage imageNamed:@"delay_nophoto91.png"]];
    }
    
    [postImgBtn setEnabled:YES];
    [postImgBtn setFrame:postImg.frame];
}

/**
 @brief 이웃 목록 셀 UI 다시 그리기
 @param a float that current Description Height
 @return void
 */
- (void) neighborRedrawCell:(float)currHeight : (float)currDescHeight {
    float currentHeight = currHeight;
    //아직 발도장을 찍은 적이 없는 이웃의 경우는 "아직 발도장을 찍은 곳이 없어요~를 보여줄 위치 지정
    if ([[cellData objectForKey:@"postId"] isEqualToString:@""]) {
        [poiName setTextColor:[UIColor colorWithRed:17/255.0 green:17/255.0 blue:17/255.0 alpha:1]];
        poiName.text = @"이 이웃에게 관심을..";
    }
    
    iconLock.hidden = YES;
    [description setFrame:CGRectMake(70.0f, currentHeight, 200, currDescHeight)];
    currentHeight += currDescHeight;
    [self drawSeperatorLine:currentHeight];
    
    // biz 타입이냐?
    if ([[cellData objectForKey:@"postId"] isEqualToString:[cellData objectForKey:@"bizPostId"]]) {
        [poiName setTextColor:[UIColor colorWithRed:17/255.0 green:17/255.0 blue:17/255.0 alpha:1]];
        poiName.text = [cellData objectForKey:@"nickname"];
    } 

    // 이웃 목록에서 사용하는 경우, 이웃 추가 설정 링크 버튼을 우측에 표시하기 위해서.	
    UIImageView *bImg = [[UIImageView alloc]init];
    [bImg setFrame:CGRectMake(270, 15, 42, 40)];
    [self addSubview:bImg];
    [bImg release];
    UIButton *uBtn = [[UIButton alloc]initWithFrame:CGRectMake(274, 14, 38, 38)];
    
    UIView* bgView = [[UIView alloc] initWithFrame:self.frame];
    
    isFriend = [[cellData objectForKey:@"isFriend"] isEqualToString:@"1"] ? YES : NO;

    if( isToMeNeighbor ){ // 나을 추가한 이웃은 서로 이웃 두가지 상태 존재
        if ([[cellData objectForKey:@"isNewNeighbor"] isEqualToString:@"1"]) {
            bgView.backgroundColor = RGB(255, 252, 213);
        } else {
            bgView.backgroundColor = RGB(255, 255, 255);
        }
        if( isFriend ) {
            [uBtn setImage:[UIImage imageNamed:@"friend_friend_admin.png"] forState:UIControlStateNormal];
        } else { 
            [uBtn setImage:[UIImage imageNamed:@"friend_friend_pluse.png"] forState:UIControlStateNormal];
        }                
    } else { //내가 추가한 이웃
        [uBtn setImage:[UIImage imageNamed:@"friend_friend_admin.png"] forState:UIControlStateNormal];
        bgView.backgroundColor = RGB(255, 255, 255);
    }
    
    self.backgroundView = bgView;
    [bgView release];
    
    [uBtn addTarget:self action:@selector(neighborSetPush:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:uBtn];
    [uBtn release];
}

/**
 @brief 구분선 프레임 좌표 수정
 @param a float that current position
 @return void
 */
- (void) drawSeperatorLine: (float) currPosition {
    float imageBottom;
    
    if (isBrandProfile) { //브랜드면
        imageBottom = 75.0f;
    } else {
        imageBottom = 63.0f;
    }
    
    currPosition = (currPosition > imageBottom) ? currPosition : imageBottom;
    float bottomInSet = 10.0f;
    
    currPosition += bottomInSet;
    
    seperatorLine.frame = CGRectMake(0, currPosition-1, seperatorLine.frame.size.width, seperatorLine.frame.size.height);
}

/**
 @brief 기본 셀 UI 다시 그리기
 @return void
 */
- (void) redrawMainThreadCellWithCellData: (NSDictionary*) myCellData {
    self.cellData = myCellData;
    
    float topInSet = 12.0f;
    float poiNameHeight = 20.0f;
    float poiPostInSet = 2.0f;
    float postDescInSet = 4.0f;
    float currentHeight = 0.0f;
    float postHeight = 0.0f;
    float descHeight = 0.0f;

    nickName.text = [myCellData objectForKey:@"nickname"];
    description.text = [MainThreadCell getDescriptionWithDictionary:myCellData];
	imageUrlStr = [myCellData objectForKey:@"profileImg"];
    snsID = [myCellData objectForKey:@"snsId"];
        
    currentHeight = topInSet + poiNameHeight + poiPostInSet; 
    
    // 글 본문 사이즈 계산 및 적용
	CGSize postLabelSize = [MainThreadCell requiredLabelSize:myCellData withType:isNeighbor];
    postLabelSize = CGSizeMake(postLabelSize.width, postLabelSize.height);
	[post setFrame:CGRectMake(70.0f, currentHeight, postLabelSize.width, postLabelSize.height)];
	postHeight = postLabelSize.height;
	
	// description 사이즈 계산
	descHeight = [Utils getWrapperSizeWithLabel:description fixedWidthMode:NO fixedHeightMode:NO].height;
    
	currentHeight += postHeight;
	if (postHeight != 0) {
		currentHeight += postDescInSet;
	}
    
    //브랜드 구분
    if ([Utils isBrandUser:myCellData]) {
        [brandMark setImage:[UIImage imageNamed:@"brand_mark.png"]];
        isBrandProfile = YES;
        profileImg.frame = PROFILE_BRAND_IMAGE_FRAME;
        brandMark.hidden = NO;
        nickName.frame = NICKNAME_BRAND_FRAME;
    } else {
        isBrandProfile = NO;
        profileImg.frame = PROFILE_DEFAULT_IMAGE_FRAME;
        brandMark.hidden = YES;
        nickName.frame = NICKNAME_FRAME;
    }
    
    if (isPoiDetailVC) { //poiDetailViewController이면
        if (isOwner) { //주인장 표시해야 하면
            [brandMark setImage:[UIImage imageNamed:@"owner_mark.png"]];
            isBrandProfile = NO;
            profileImg.frame = PROFILE_BRAND_IMAGE_FRAME;
            brandMark.hidden = NO;
            nickName.frame = NICKNAME_BRAND_FRAME;
        }
    }

    post.text = [MainThreadCell getPostWithDictionary:myCellData];
    [profileImg setImageWithURL:[NSURL URLWithString: [cellData objectForKey:@"profileImg"]] 
			   placeholderImage:[UIImage imageNamed:@"delay_nosum70.png"]];

    
    if ([[myCellData objectForKey:@"isBadge"] isEqualToString:@"1"]) { //  postType -> badge
        poiName.text = [myCellData objectForKey:@"badgeName"];
    } else {
        poiName.text = [myCellData objectForKey:@"poiName"];
    }

	poiName.frame = CGRectMake(poiName.frame.origin.x,
							   poiName.frame.origin.y,
							   172, poiName.frame.size.height);
	
	[poiName setTextColor:[UIColor colorWithRed:1/255.0 green:129/255.0 blue:176/255.0 alpha:1]];

    if ([[myCellData objectForKey:@"isBadge"] isEqualToString:@"1"]) { //  postType -> badge
        [self badgeRedrawCell:currentHeight : descHeight];
    } else if( isNeighbor ) { // postType -> neighbor
        [self neighborRedrawCell:currentHeight : descHeight];
    } else { // postType -> post
        [self postRedrawCell:currentHeight : descHeight];
    }
}

/**
 @brief 프로필 사진 터치 시 해당 홈으로 이동
 @param UIButton sender
 @return IBAction
 */
- (IBAction)profileClicked:(id)sender {
	MY_LOG(@"프로필 사진 클릭 %@, %@", sender, snsID);

    if ([snsID isEqualToString:@""] || snsID == nil) { //발도장이 삭제된 것일 경우 체크
        [CommonAlert alertWithTitle:@"안내" message:@"해당 사용자의 프로필을 보실수 없어요~"];
        return;
    }

    if (isBrandProfile) {
        if ([curPosition isEqualToString:@"1"]) {
         GA3(@"광장", @"브랜드프로필사진", @"광장내");
        }else if ([curPosition isEqualToString:@"2"]) {
            GA3(@"이웃", @"브랜드프로필사진", @"내가추가한이웃탭내");
        } else if ([curPosition isEqualToString:@"21"]) {
            GA3(@"이웃", @"브랜드프로필사진", @"나를추가한이웃탭내");
        } else if ([curPosition isEqualToString:@"9"]) {        //이벤트가 있을 때
            GA3(@"이벤트POI", @"브랜드프로필사진", @"이벤트POI내");
        } else if ([curPosition isEqualToString:@"5"]) {
            GA3(@"POI", @"브랜드프로필사진", @"POI내");
        }
    }
    else {
        if ([curPosition isEqualToString:@"1"]) {
            GA3(@"광장", @"프로필사진", @"광장내"); 
        } else if ([curPosition isEqualToString:@"2"]) {
            GA3(@"이웃", @"프로필사진", @"내가추가한이웃탭내");
        } else if ([curPosition isEqualToString:@"21"]) {
            GA3(@"이웃", @"프로필사진", @"나를추가한이웃탭내");
        } else if ([curPosition isEqualToString:@"6"]) {
            GA3(@"마이홈", @"프로필사진", @"마이홈내_기억탭내");
        } else if ([curPosition isEqualToString:@"7"]) {
            GA3(@"타인홈", @"프로필사진", @"타인홈내_기억탭내");
        } else if ([curPosition isEqualToString:@"9"]) {        //이벤트가 있을 때
            if (isOwner) {
                GA3(@"이벤트POI", @"주인장프로필사진", @"이벤트POI내");
            } else {
                GA3(@"이벤트POI", @"프로필사진", @"이벤트POI내");
            }
        } else if ([curPosition isEqualToString:@"5"]) {
            if (isOwner) {
                GA3(@"POI", @"주인장프로필사진", @"POI내");
            } else {
                GA3(@"POI", @"프로필사진", @"POI내");
            }
        }
    }
    
	
    
    MemberInfo* owner = [[[MemberInfo alloc] init] autorelease];
    owner.snsId = snsID;
    owner.nickname = nickName.text;
    owner.profileImgUrl = imageUrlStr;	

    if (isBrandProfile) { //브랜드면
        BrandHomeViewController* vc = [[[BrandHomeViewController alloc] initWithNibName:@"BrandHomeViewController" bundle:nil] autorelease];
        vc.owner = owner;
        [(UINavigationController*)[ViewControllers sharedViewControllers].tabBarController.selectedViewController pushViewController:vc animated:YES];        

    } else {
        MyHomeViewController *vc = [[[MyHomeViewController alloc] initWithNibName:@"MyHomeViewController" bundle:nil] autorelease];
        vc.owner = owner;
        [(UINavigationController*)[ViewControllers sharedViewControllers].tabBarController.selectedViewController pushViewController:vc animated:YES];        
    }
}

/**
 @brief 포스트 사진 클릭 시 사진 크게 보이기
 @param UIButton sender
 @return IBAction
 */
- (IBAction)postImageClicked:(id)sender {
	MY_LOG(@"포스트 사진 클릭");
	
	if ([[cellData objectForKey:@"isBadge"] isEqualToString:@"1"] || [[cellData objectForKey:@"postType"] isEqualToString:@"2"]) {
		if ([[UserContext sharedUserContext].snsID isEqualToString:[cellData objectForKey:@"snsId"]]) { // 마이홈
			GA3(@"마이홈", @"뱃지이미지", @"마이홈내"); 
		} else {
			GA3(@"타인홈", @"뱃지이미지", @"타인홈내"); 
		}
		BadgePictureViewController* pictureView = [[BadgePictureViewController alloc] initWithNibName:@"BadgePictureViewController" bundle:nil];
        pictureView.postType = [cellData objectForKey:@"postType"];
		[pictureView setPictureUrl:[cellData objectForKey:@"imgUrl"]];
		[pictureView setHidesBottomBarWhenPushed:YES];
		[(UINavigationController*)[ViewControllers sharedViewControllers].tabBarController.selectedViewController pushViewController:pictureView animated:NO];
		[pictureView release];	
	}
	else {
		//광장, POI, 마이홈, 타인홈의 유저생성사진
		MY_LOG(@"curPosition = %@", curPosition);

		if ([curPosition isEqualToString:@"1"]) {
			GA3(@"광장", @"유저생성사진", @"광장내"); 
		} else if ([curPosition isEqualToString:@"6"]) {
			GA3(@"마이홈", @"유저생성사진", @"마이홈내");
		} else if ([curPosition isEqualToString:@"7"]) {
			GA3(@"타인홈", @"유저생성사진", @"타인홈내");
		} else if ([curPosition isEqualToString:@"5"]) {
			GA3(@"POI", @"유저생성사진", @"POI내");
		} else if ([curPosition isEqualToString:@"9"]) {
            GA3(@"이벤트POI", @"유저생성사진", @"이벤트POI내");
        }

		PictureViewController* zoomingViewController = [[PictureViewController alloc] initWithNibName:@"PictureViewController" bundle:nil];
		[zoomingViewController setPictureURL:[cellData objectForKey:@"imgUrl"]];
		[zoomingViewController setHidesBottomBarWhenPushed:YES];
		[(UINavigationController*)[ViewControllers sharedViewControllers].tabBarController.selectedViewController pushViewController:zoomingViewController animated:NO];
		[zoomingViewController release];		
	}
}

/**
 @brief 친구 관계 여부 요청
 @param UIButton sender
 @return void
 */
// 친구 설정을 위히새 우측 버튼을 누르면.
- (void)neighborSetPush:(id)sender {
	// 친구 관계가 어떻게 설정되어 있는지 확인한다.
    self.homeInfo = [[[HomeInfo alloc] init] autorelease];
    homeInfo.delegate = self;
    homeInfo.snsId = snsID;

    [homeInfo request];
    

    
    
//	CgiStringList* strPostData=[[CgiStringList alloc]init:@"&"];
//	
//	[strPostData setMapString:@"svcId" keyvalue:SNS_IPHONE_SVCID];
//    [strPostData setMapString:@"appVer" keyvalue:[ApplicationContext appVersion]];
//	[strPostData setMapString:@"device" keyvalue:SNS_DEVICE_MOBILE_APP];
//	[strPostData setMapString:@"snsId" keyvalue:snsID];
//	[strPostData setMapString:@"at" keyvalue:@"1"];
//	[strPostData setMapString:@"av" keyvalue:[UserContext sharedUserContext].snsID];
//	[strPostData setMapString:@"referCode" keyvalue:@"0004"];
//	
//	if (connect != nil)
//	{
//		[connect stop];
//		[connect release];
//		connect = nil;
//	}
//	
//	connect = [[HttpConnect alloc] initWithURL: PROTOCOL_MYHOME_INFO
//												postData: [strPostData description]
//												delegate: self
//											doneSelector: @selector(onMyHomeInfoTransdone:)
//										   errorSelector: @selector(onTransError:) //@selector(onHttpConnectError:)
//										progressSelector: nil];
//	//[[OperationQueue queue] addOperation:conn];
//	//[conn release];
//	[strPostData release];
}

- (void) apiFailed {
    
}

- (void) apiDidLoad:(NSDictionary *)result {
    NSInteger friendCodeInt;
	if( ![[result objectForKey:@"result"] boolValue]){
		return;
	}
	
	NSString *whoIs = [result objectForKey:@"isPerm"];
    
	// 서로 이웃인지 여부를 확인해서 표시한다.
	if( [whoIs isEqualToString:@"FRIEND"] ){
		friendCodeInt = FR_TRUE;
	}else if( [whoIs isEqualToString:@"NEIGHBOR_YOU"] ){  // 당신이 그를 친구로 등록했다.
		friendCodeInt = FR_ME;
	}else if( [whoIs isEqualToString:@"NEIGHBOR_ME"] ){
		friendCodeInt = FR_YOU;
	}else{
		friendCodeInt = FR_NONE;
	}
	
    if (isBrandProfile) {
        if(friendCodeInt == FR_NONE || friendCodeInt == FR_ME ) { // 친구가 아니면
            GA3(@"이웃", @"브랜드이웃추가버튼", @"나를추가한이웃탭내");
        } else {
            MY_LOG(@"현재 포지션 = %@", curPosition);
            if ([curPosition isEqualToString:@"2"]) {
                GA3(@"이웃", @"브랜드이웃설정버튼", @"내가추가한이웃탭내");
            } else {
                GA3(@"이웃", @"브랜드이웃설정버튼", @"나를추가한이웃탭내");
            }
        }
    }
    else {
        
        if(friendCodeInt == FR_NONE || friendCodeInt == FR_ME ) { // 친구가 아니면
            GA3(@"이웃", @"이웃추가버튼", @"나를추가한사람탭내");
        } else {
            MY_LOG(@"현재 포지션 = %@", curPosition);
            if ([curPosition isEqualToString:@"2"]) {
                GA3(@"이웃", @"이웃설정버튼", @"내가추가한이웃탭내");
            } else {
                GA3(@"이웃", @"이웃설정버튼", @"나를추가한이웃탭내");
            }
        }
    }
	FriendSetViewController *friendSetViewController = [[FriendSetViewController alloc]initWithName:nickName.text friendSnsId: snsID friendCode:friendCodeInt friendImage:imageUrlStr];
	friendSetViewController.recomType = @"";
	[friendSetViewController setHidesBottomBarWhenPushed:YES];
	[[ViewControllers sharedViewControllers].neighbersViewController.navigationController pushViewController:friendSetViewController animated:YES];
	[friendSetViewController release];
	[[ViewControllers sharedViewControllers] refreshNeighborVC];
}

//- (void) onTransError:(HttpConnect*)up
//{
//	if (connect != nil)
//	{
//		[connect release];
//		connect = nil;
//	}
//}

//- (void) onMyHomeInfoTransdone:(HttpConnect*)up
//{
//	NSInteger friendCodeInt;
//	SBJSON* jsonParser = [SBJSON new];
//	[jsonParser setHumanReadable:YES];
//	
//	NSDictionary* results = (NSDictionary *)[jsonParser objectWithString:up.stringReply error:NULL];
//	
//	if (connect != nil)
//	{
//		[connect release];
//		connect = nil;
//	}
//	
//	if( ![[results objectForKey:@"result"] boolValue]){
//		[jsonParser release];
//		return;
//	}
//	
//	NSString *whoIs = [results objectForKey:@"isPerm"];
//		
//	// 서로 이웃인지 여부를 확인해서 표시한다.
//	if( [whoIs isEqualToString:@"FRIEND"] ){
//		friendCodeInt = FR_TRUE;
//	}else if( [whoIs isEqualToString:@"NEIGHBOR_YOU"] ){  // 당신이 그를 친구로 등록했다.
//		friendCodeInt = FR_ME;
//	}else if( [whoIs isEqualToString:@"NEIGHBOR_ME"] ){
//		friendCodeInt = FR_YOU;
//	}else{
//		friendCodeInt = FR_NONE;
//	}
//	
//	[jsonParser release];
//	
//    if (isBrandProfile) {
//        if(friendCodeInt == FR_NONE || friendCodeInt == FR_ME ) { // 친구가 아니면
//            GA3(@"이웃", @"브랜드이웃추가버튼", @"나를추가한이웃탭내");
//        } else {
//            MY_LOG(@"현재 포지션 = %@", curPosition);
//            if ([curPosition isEqualToString:@"2"]) {
//                GA3(@"이웃", @"브랜드이웃설정버튼", @"내가추가한이웃탭내");
//            } else {
//                GA3(@"이웃", @"브랜드이웃설정버튼", @"나를추가한이웃탭내");
//            }
//        }
//    }
//    else {
//        
//        if(friendCodeInt == FR_NONE || friendCodeInt == FR_ME ) { // 친구가 아니면
//            GA3(@"이웃", @"이웃추가버튼", @"나를추가한사람탭내");
//        } else {
//            MY_LOG(@"현재 포지션 = %@", curPosition);
//            if ([curPosition isEqualToString:@"2"]) {
//                GA3(@"이웃", @"이웃설정버튼", @"내가추가한이웃탭내");
//            } else {
//                GA3(@"이웃", @"이웃설정버튼", @"나를추가한이웃탭내");
//            }
//        }
//    }
//	FriendSetViewController *friendSetViewController = [[FriendSetViewController alloc]initWithName:nickName.text friendSnsId: snsID friendCode:friendCodeInt friendImage:imageUrlStr];
//	friendSetViewController.recomType = @"";
//	[friendSetViewController setHidesBottomBarWhenPushed:YES];
//	[[ViewControllers sharedViewControllers].neighbersViewController.navigationController pushViewController:friendSetViewController animated:YES];
//	[friendSetViewController release];
//	[[ViewControllers sharedViewControllers] refreshNeighborVC];
//}
//

#pragma mark -
#pragma mark Label 크기 계산식
/**
 @brief 문자열 빈칸 없애기
 @param a NSString to be CRLF removed
 @return NSString that CRLF removed
 */
+ (NSString*) removeCRLFWithString:(NSString*) srcString 
{
	return [[srcString stringByReplacingOccurrencesOfString:@"\n" withString:@" "] 
			stringByReplacingOccurrencesOfString:@"\r" withString:@""];
}

/**
 @brief cell label 사이즈 지정
 @param a Dictionary that cell Data , a BOOL that neighbor type
 @return CGSize
 */
+ (CGSize) requiredLabelSize:(NSDictionary*) cellData withType:(BOOL) isNeighbor
{	
	float desiredWidth = 0.0f;
	if ( [[cellData objectForKey:@"imgUrl"] isEqualToString:@""] && !isNeighbor) {
		desiredWidth = 233.0f;
	} else {
		desiredWidth = 174.0f;
	}
	CGSize boundingSize = CGSizeMake(desiredWidth, CGFLOAT_MAX);
    	
	CGSize requiredSize;
	
	if ([[cellData objectForKey:@"isBadge"] isEqualToString:@"1"]) {
		requiredSize = [[cellData objectForKey:@"badgeMsg"] sizeWithFont:[UIFont fontWithName:@"Helvetica" size:14.0f] 
										constrainedToSize:boundingSize
											lineBreakMode:UILineBreakModeWordWrap];
		
	} else { // 이 경우는 하트콘과 일반 포스트가 동일한 값을 이용한다.
		NSString* aPost = [MainThreadCell removeCRLFWithString:[cellData objectForKey:@"post"]];
		
		requiredSize = [aPost sizeWithFont:[UIFont fontWithName:@"Helvetica" size:14.0f] 
										constrainedToSize:boundingSize
											lineBreakMode:UILineBreakModeWordWrap];
	}

	//requiredSize.height = 50;
	//requiredSize.width = 190;
	return requiredSize;
}

/**
 @brief description 가져오기
 @param a NSDictionary that data
 @return NSString
 */
+ (NSString*) getDescriptionWithDictionary:(NSDictionary*) data
{
	NSString* timeDesc = [Utils getDescriptionWithString:[data objectForKey:@"regDate"]];
	NSString* retDescription = nil;
	
	if ([[data objectForKey:@"postId"] isEqualToString:@""]) {
		retDescription = @"아직 발도장을 찍은 곳이 없어요~";
	} else {
		if (![[data objectForKey:@"deviceName"] isEqualToString:@""]) {
			retDescription = [NSString stringWithFormat:@"%@%, %@", timeDesc, [data objectForKey:@"deviceName"]];
		} else {
			retDescription = [NSString stringWithString:timeDesc];
		}
		
		if( [data objectForKey:@"cmtCnt"]  )
		{
			retDescription = [retDescription stringByAppendingFormat:@" | 댓글 %@", [data objectForKey:@"cmtCnt"]];	
		}
        
        if ([[data objectForKey:@"scrapCnt"] intValue] > 0) {
            retDescription = [retDescription stringByAppendingFormat:@" | 기억 %@", [data objectForKey:@"scrapCnt"]];
        }
	}
	
	return retDescription;
	
}

/**
 @brief 게시물 보기
 @brief 신고 여부 체크
 @param a NSDictionary that data
 @return NSString
 */
+ (NSString*) getPostWithDictionary:(NSDictionary*) data
{
	NSString* retValue = nil;
	if ([[data objectForKey:@"isBlind"] isEqualToString:@"1"]) {
		retValue = @"이 게시물은 신고되어 내용을 볼 수 없습니다.";
	} else {
		retValue = [data objectForKey:@"post"];
		retValue = [MainThreadCell removeCRLFWithString:retValue];
	}
	return retValue;
}

@end
