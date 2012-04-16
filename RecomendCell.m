//
//  RecomendCell.m
//  ImIn
//
//  Created by 태한 김 on 10. 6. 11..
//  Copyright 2010 kth. All rights reserved.
//

#import "RecomendCell.h"
#import "UIHomeViewController.h"
#import "ViewControllers.h"
#import "UIImageView+WebCache.h"
#import "JSON.h"

#import "UserContext.h"
#import "FriendSetViewController.h"
#import "macro.h"
#import <QuartzCore/QuartzCore.h>
#import "BrandHomeViewController.h"
#import "HomeInfo.h"


#define RECOM_TYPE_HOT 02
#define RECOM_TYPE_MY_PHONE 11
#define RECOM_TYPE_TWITTER 21
#define RECOM_TYPE_FACEBOOK	23
#define RECOM_TYPE_PHONE_EXT 41

#define RECOM_TYPE_FACEBOOK_EXT 43
#define RECOM_TYPE_TWITTER_EXT 42
#define RECOM_TYPE_NEIGHBOR_SHARE 51
#define RECOM_TYPE_NEIGHBOR 52
#define RECOM_TYPE_OTHER_PHONE 12
#define RECOM_TYPE_IMIN_GIRL 03
#define RECOM_TYPE_MANY_FOLLOW 81
#define RECOM_TYPE_VERY_MANY_FOLLOW 82
#define RECOM_TYPE_NEWBEE 01
#define RECOM_TYPE_VERY_KIND 83
#define RECOM_TYPE_KIND 84

#define NAMELABEL_FRAME CGRectMake(27, 23-11, 182, 20)
#define NAMELABEL_DEFAULT_FRAME CGRectMake(27, 23, 182, 20)
#define NAMELABEL_NONIMG_FRAME CGRectMake(8, 23-11, 182+(27-8), 20)
#define CPTYPEIMG_FRAME CGRectMake(8, 24-11, 24, 16)
#define CPTYPEIMG_DEFAULT_FRAME CGRectMake(8, 24, 24, 16)
#define LASTESTPOINAME_FRAME CGRectMake(70, 38, 186, 36)
#define BRAND_LASTESTPOINAME_FRAME CGRectMake(70, 15, 186, 50)
#define LASTESTPOINAME_SEARCH_FRAME CGRectMake(70, 37, 186, 36)


@implementation RecomendCell

@synthesize cellData;
@synthesize cellDataList;
@synthesize cellDataListIndex;
@synthesize cellType;
@synthesize homeInfo;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        connect = nil;
        friendSet = NO;
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
    if (cellType == IMIN_CELLTYPE_WELCOME_RECOMMEND) {
        return;
    }


    [super setSelected:selected animated:animated];
	UIView* bgView = [[[UIView alloc] initWithFrame:self.frame] autorelease];
	CAGradientLayer *gradient = [CAGradientLayer layer];
	gradient.frame = bgView.bounds;
	gradient.colors = [NSArray arrayWithObjects:(id)[RGB(214, 241, 248) CGColor], (id)[RGB(178, 229, 241) CGColor], nil];
	[bgView.layer insertSublayer:gradient atIndex:0];
	self.selectedBackgroundView = bgView;
	
    // Configure the view for the selected state
}


- (void)dealloc {
	if (connect != nil)
	{
		[connect stop];
		[connect release];
		connect = nil;
	}
	
	[cellData release];
	[cellDataList release];
    [goHomeBtn release];
    [homeInfo release];
    [super dealloc];
	
}

- (void) redrawMainThreadCellWithCellData: (RecomendCellData*) myCellData {
    
    cpTypeImg.frame = CPTYPEIMG_DEFAULT_FRAME;
    cpTypeImg.hidden = NO;
    nameLabel.frame = NAMELABEL_DEFAULT_FRAME;
    nameLabel.hidden = NO;
    latestPoiName.frame = LASTESTPOINAME_FRAME;
    latestPoiName.hidden = NO;
    latestPoiName.font = [UIFont fontWithName:@"Helvetica" size:13.0];
    latestPoiName.textColor = RGB(112, 112, 112);
    
    
	self.cellData = myCellData;
    
    int knownTypeInt = [myCellData.knownType intValue];
	int recomTypeInt = [myCellData.recomType intValue];
    //int bizTypeInt = [myCellData.bizType intValue];
    
    nickName.text = myCellData.nickName;
    CGRect textRect = [nickName textRectForBounds:nickName.bounds limitedToNumberOfLines:0];
    CGRect frame = nickName.frame;
    frame.size.height = textRect.size.height;
    nickName.frame = frame;
    
    //nameLabel.frame = NAMELABEL_FRAME;
    
    if (knownTypeInt == 1 && recomTypeInt == RECOM_TYPE_MY_PHONE) { //아는 사람
        NSString* md5phoneString = myCellData.md5phoneNumber;
    
        if (md5phoneString != nil && ![md5phoneString isEqualToString:@""]) {
            
            NSString* phoneName = [Utils getNameWithMd5:md5phoneString];
            
            if (![phoneName isEqualToString:@""]) {
                // 전화번호부에 있다면 그값을 이름으로 넣어라.
                nameLabel.text = phoneName;
            } else {
                if (myCellData.cpName == nil || [myCellData.cpName isEqualToString:@""]) {
                    nameLabel.text = myCellData.nickName;
                } else {
                    nameLabel.text = myCellData.cpName;
                }
            }
        } else {
            if (myCellData.cpName == nil || [myCellData.cpName isEqualToString:@""]) {
                nameLabel.text = myCellData.nickName;
            } else {
                nameLabel.text = myCellData.cpName;  
            }
        }
    } else {
        if (myCellData.cpName == nil || [myCellData.cpName isEqualToString:@""]) {
            nameLabel.text = myCellData.nickName;
        } else {
            nameLabel.text = myCellData.cpName;  
        }
    }

    if (knownTypeInt == 1) { //아는 사람
        switch (recomTypeInt) {
            case RECOM_TYPE_FACEBOOK:
                cpTypeImg.image = [UIImage imageNamed:@"friend_s_icon_facebook.png"];
                break;
            case RECOM_TYPE_MY_PHONE: //11
                cpTypeImg.image = [UIImage imageNamed:@"friend_s_icon_contacts.png"];
                break;
            case RECOM_TYPE_TWITTER:
                cpTypeImg.image = [UIImage imageNamed:@"friend_s_icon_twitter.png"];
                break;
            default:
                break;
        }
        cpTypeImg.hidden = NO;        
        latestPoiName.hidden = YES;
        rejectBtn.hidden = NO;
    } else if (knownTypeInt == 2) { //알수도 있는 사람                
        switch (recomTypeInt) {
            case RECOM_TYPE_FACEBOOK_EXT:
                cpTypeImg.frame = CPTYPEIMG_FRAME;
                nameLabel.frame = NAMELABEL_FRAME;

                cpTypeImg.image = [UIImage imageNamed:@"friend_s_icon_facebook.png"];
                cpTypeImg.hidden = NO;   
                latestPoiName.text = [NSString stringWithFormat:@"%@님 외, 함께 아는 친구 %@명", myCellData.cpNeighborName, myCellData.recomCnt];
                break;
            case RECOM_TYPE_TWITTER_EXT:
                cpTypeImg.frame = CPTYPEIMG_FRAME;
                nameLabel.frame = NAMELABEL_FRAME;

                cpTypeImg.image = [UIImage imageNamed:@"friend_s_icon_twitter.png"];
                cpTypeImg.hidden = NO;   
                latestPoiName.text = [NSString stringWithFormat:@"%@님 외, %@명을 함께 팔로우", myCellData.cpNeighborName, myCellData.recomCnt];
                break;
            case RECOM_TYPE_NEIGHBOR_SHARE:
                nameLabel.frame = NAMELABEL_NONIMG_FRAME;
                cpTypeImg.hidden = YES;
                latestPoiName.text = [NSString stringWithFormat:@"%@님 외, 함께 아는 이웃 %@명", myCellData.cpNeighborName, myCellData.recomCnt];
                break;
            case RECOM_TYPE_NEIGHBOR: //동네이웃
                nameLabel.frame = NAMELABEL_NONIMG_FRAME;
                cpTypeImg.hidden = YES;
                latestPoiName.text = [NSString stringWithFormat:@"나와 %@곳 이상 같은 곳에 발도장", myCellData.recomCnt];
                break;
            case RECOM_TYPE_OTHER_PHONE:
                nameLabel.frame = NAMELABEL_NONIMG_FRAME;
                cpTypeImg.hidden = YES;
                latestPoiName.text = @"내 폰번호를 알고 있는 이웃";
                break;
            case RECOM_TYPE_IMIN_GIRL:
                nameLabel.frame = NAMELABEL_NONIMG_FRAME;
                cpTypeImg.hidden = YES;
                latestPoiName.text = @"아임IN 생활에 많은 도움을 줄 이웃";
                break;
            case RECOM_TYPE_MANY_FOLLOW:
                nameLabel.frame = NAMELABEL_NONIMG_FRAME;
                cpTypeImg.hidden = YES;
                latestPoiName.text = @"많은 사람이 이웃을 맺는 인기 있는 이웃 10인";
                break;
            case RECOM_TYPE_VERY_MANY_FOLLOW:
                nameLabel.frame = NAMELABEL_NONIMG_FRAME;
                cpTypeImg.hidden = YES;
                latestPoiName.text = @"많은 사람이 이웃을 맺는 인기 있는 이웃 50인";
                break;
            case RECOM_TYPE_NEWBEE:
                nameLabel.frame = NAMELABEL_NONIMG_FRAME;
                cpTypeImg.hidden = YES;
                latestPoiName.text = @"관심이 필요한 아임인 초보";
                break;
            case RECOM_TYPE_VERY_KIND:
                nameLabel.frame = NAMELABEL_NONIMG_FRAME;
                cpTypeImg.hidden = YES;
                latestPoiName.text = @"깨알같은 댓글을 남겨주는 친절한 이웃";
                break;
            case RECOM_TYPE_KIND:
                nameLabel.frame = NAMELABEL_NONIMG_FRAME;
                cpTypeImg.hidden = YES;
                latestPoiName.text = @"깨알같은 댓글을 남겨주는 친절한 이웃";
                break;

            default:
                nameLabel.frame = NAMELABEL_NONIMG_FRAME;
                cpTypeImg.hidden = YES;
                latestPoiName.text = @"임의 추천된 이웃";
                break;
        }
        
        CGRect Rect = [latestPoiName textRectForBounds:latestPoiName.bounds limitedToNumberOfLines:2];
        CGRect frame = LASTESTPOINAME_FRAME;
        frame.size.height = Rect.size.height;
        latestPoiName.frame = frame;
        rejectBtn.hidden = NO;
    } else if (knownTypeInt == 3) { //brand 
        cpTypeImg.hidden = YES;
        nameLabel.hidden = YES;
        rejectBtn.hidden = YES;
        latestPoiName.font = [UIFont fontWithName:@"Helvetica" size:14.0];
        latestPoiName.textColor = RGB(17, 17, 17);
        latestPoiName.text = myCellData.comment;
        MY_LOG(@"브랜드 소개멘드 = %@", myCellData.comment);
        //CGRect Rect = [latestPoiName textRectForBounds:latestPoiName.bounds limitedToNumberOfLines:3];
        //CGRect frame = BRANDLASTESTPOINAME_FRAME;
        //frame.origin.y = 14;
        //frame.size.height = Rect.size.height;
        latestPoiName.frame = BRAND_LASTESTPOINAME_FRAME;
    }
    
	snsID = myCellData.snsId;
	imageUrlStr = myCellData.profileImgURL;
    recomType = myCellData.recomType;

	[profileImg setImageWithURL:[NSURL URLWithString: myCellData.profileImgURL] 
			   placeholderImage:[UIImage imageNamed:@"delay_nosum70.png"]];
    
    if ([myCellData.isFriend isEqualToString:@"2"] || [myCellData.isFriend isEqualToString:@""] || myCellData.isFriend == nil) {
        friendSet = NO;
		[setBtn setImage:[UIImage imageNamed:@"friend_friend_pluse.png"] forState:UIControlStateNormal];
	} else {
        friendSet = YES;
		[setBtn setImage:[UIImage imageNamed:@"friend_friend_admin.png"] forState:UIControlStateNormal];
	}
    
    if (cellType == IMIN_CELLTYPE_NICKNAME) {
        rejectBtn.hidden = YES;
        nameLabel.frame = NAMELABEL_NONIMG_FRAME;
        nameLabel.text = [NSString stringWithFormat:@"이웃 %d명",  [myCellData.neighborNum intValue]];
        latestPoiName.text = [NSString stringWithFormat:@"최근발도장 %@", myCellData.latestPoiName];
        CGRect Rect = [latestPoiName textRectForBounds:latestPoiName.bounds limitedToNumberOfLines:2];
        CGRect frame = LASTESTPOINAME_SEARCH_FRAME;
        frame.size.height = Rect.size.height;
        latestPoiName.frame = frame;
    }
    
    if (cellType == IMIN_CELLTYPE_WELCOME_RECOMMEND) {
        rejectBtn.hidden = YES;
        goHomeBtn.enabled = NO;
    }

}

- (IBAction)profileClicked:(id)sender
{	
    if ([cellData.knownType intValue] == 3) {
        GA3(@"이웃", @"브랜드프로필사진", @"이웃찾기탭내");

        BrandHomeViewController *vc = [[BrandHomeViewController alloc] initWithNibName:@"BrandHomeViewController" bundle:nil];
        MemberInfo* owner = [[[MemberInfo alloc] init] autorelease];
        owner.snsId = snsID;
        owner.nickname = nickName.text;
        owner.profileImgUrl = imageUrlStr;	
        
        vc.owner = owner;
        
        [(UINavigationController*)[ViewControllers sharedViewControllers].tabBarController.selectedViewController pushViewController:vc animated:YES];
        [vc release];
    } else {
        GA3(@"이웃", @"프로필사진", @"이웃찾기탭내");

        UIHomeViewController *vc = [[UIHomeViewController alloc] initWithNibName:@"UIHomeViewController" bundle:nil];
        
        MemberInfo* owner = [[[MemberInfo alloc] init] autorelease];
        owner.snsId = snsID;
        owner.nickname = nickName.text;
        owner.profileImgUrl = imageUrlStr;	
        
        vc.owner = owner;
        
        [(UINavigationController*)[ViewControllers sharedViewControllers].tabBarController.selectedViewController pushViewController:vc animated:YES];
        [vc release];
    }
}

- (NSDictionary *) indexKeyedDictionaryFromArray:(NSArray *)array 
{
    id objectInstance;
    NSUInteger indexKey = 0;
    
    NSMutableDictionary *mutableDictionary = [[NSMutableDictionary alloc] init];
    
    for (objectInstance in array) {
        [mutableDictionary setObject:objectInstance forKey:[NSNumber numberWithInt:indexKey]];
        indexKey++;
    }
    return (NSDictionary *)[mutableDictionary autorelease];
}

#pragma mark -
#pragma merk btnEvent

- (IBAction)friendRejectClicked:(id)sender
{
    if([cellData.knownType isEqualToString:@"1"]) {
        GA3(@"이웃", @"숨김버튼", @"이웃찾기탭내_아는사람내");
    } else {
        GA3(@"이웃", @"숨김버튼", @"이웃찾기탭내_알수도있는사람내");
    }

    // 먼저 노티 보내고 네트워크 요청해라
    [[NSNotificationCenter defaultCenter] postNotificationName:@"friendReject" object:cellData];
}

- (IBAction)friendSetClicked:(id)sender
{
      
    NSString* referCode = @"";
	switch (cellType) {
        case IMIN_CELLTYPE_WELCOME_RECOMMEND: {
            
            if([cellData.knownType isEqualToString:@"1"]) {
                GA3(@"아는사람찾기", @"이웃추가버튼", @"가입_아는사람내");
            } else if ([cellData.knownType intValue] == 2) {
                GA3(@"아는사람찾기", @"이웃추가버튼", @"가입_알수도있는사람내");
            } else if ([cellData.knownType intValue] == 3) {
                GA3(@"아는사람찾기", @"브랜드이웃추가버튼", @"이웃찾기탭내");
            }

            
            NSNumber* welcomeRecomAcceptCnt = [[UserContext sharedUserContext].setting objectForKey:@"welcomeRecomAcceptCnt"];
            if (welcomeRecomAcceptCnt == nil) {
                welcomeRecomAcceptCnt = [NSNumber numberWithInt:0];
            } else {
                int cnt = [welcomeRecomAcceptCnt intValue];
                welcomeRecomAcceptCnt = [NSNumber numberWithInt:++cnt];
            }
            [[UserContext sharedUserContext].setting setObject:welcomeRecomAcceptCnt forKey:@"welcomeRecomAcceptCnt"];
            [[UserContext sharedUserContext] saveSettingToFile];
        }
		case IMIN_CELLTYPE_RECOMMEND:
			referCode = @"0003";
            if([cellData.knownType isEqualToString:@"1"]) {
                GA3(@"이웃", @"이웃추가버튼", @"이웃찾기탭내_아는사람내");
            } else if ([cellData.knownType isEqualToString:@"2"]) {
                GA3(@"이웃", @"이웃추가버튼", @"이웃찾기탭내_알수도있는사람내");
            } else if ([cellData.knownType intValue] == 3) {
                GA3(@"이웃", @"브랜드이웃추가버튼", @"이웃찾기탭내");
            }

			break;
		case IMIN_CELLTYPE_NICKNAME:
			referCode = @"0006";
			break;
		default:
			break;
	}
    
    if (friendSet == NO) { // 친구가아니면

        if (cellType != IMIN_CELLTYPE_NICKNAME) { // 검색의 셀타입이 아니라면
            [[NSNotificationCenter defaultCenter] postNotificationName:@"friendAdd" 
                                                                object:cellData 
                                                              userInfo:[NSDictionary dictionaryWithObject:referCode forKey:@"referCode"]];
        } else {
            NSString *index = [NSString stringWithFormat:@"%d", cellDataListIndex];
            NSDictionary *dic = [NSDictionary dictionaryWithObject:index forKey:@"index"];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"friendAddInSearchResult" object:cellData userInfo:dic];
        }

    } else { //이미 친구인 경우
        // 친구 관계가 어떻게 설정되어 있는지 확인한다.
        self.homeInfo = [[[HomeInfo alloc] init] autorelease];
        homeInfo.delegate = self;
        
        homeInfo.snsId = snsID;
        [homeInfo request];
//        CgiStringList* strPostData=[[CgiStringList alloc]init:@"&"];
//        
//        [strPostData setMapString:@"svcId" keyvalue:SNS_IPHONE_SVCID];
//        [strPostData setMapString:@"appVer" keyvalue:[ApplicationContext appVersion]];
//        [strPostData setMapString:@"device" keyvalue:SNS_DEVICE_MOBILE_APP];
//        [strPostData setMapString:@"snsId" keyvalue:snsID];
//        [strPostData setMapString:@"at" keyvalue:@"1"];
//        [strPostData setMapString:@"av" keyvalue:[UserContext sharedUserContext].snsID];
//        
//        if (connect != nil)
//        {
//            [connect stop];
//            [connect release];
//            connect = nil;
//        }
//        
//        connect = [[HttpConnect alloc] initWithURL: PROTOCOL_MYHOME_INFO
//                                          postData: [strPostData description]
//                                          delegate: self
//                                      doneSelector: @selector(onMyHomeInfoTransdone:)
//                                     errorSelector: @selector(onHttpConnectError:)
//                                  progressSelector: nil];
//        [strPostData release];
    }
}

#pragma mark -
#pragma mark iminprotocol
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
	
	FriendSetViewController *friendSetViewController = [[FriendSetViewController alloc]initWithName:nickName.text friendSnsId: snsID friendCode:friendCodeInt friendImage:imageUrlStr];
	friendSetViewController.cellDataList = self.cellDataList;
	friendSetViewController.cellDataListIndex = self.cellDataListIndex;
	
	NSString* referCode = @"";
	switch (cellType) {
		case IMIN_CELLTYPE_RECOMMEND:
        case IMIN_CELLTYPE_WELCOME_RECOMMEND:
			referCode = @"0003";
			break;
		case IMIN_CELLTYPE_NICKNAME:
			referCode = @"0006";
			break;
		default:
			break;
	}
	friendSetViewController.referCode = referCode;
	friendSetViewController.recomType = cellData.recomType;
	
	MY_LOG(@"my friend set view controller: cellDataListIndex = %d", self.cellDataListIndex);
	
	[friendSetViewController setHidesBottomBarWhenPushed:YES];
	[[ViewControllers sharedViewControllers].neighbersViewController.navigationController pushViewController:friendSetViewController animated:YES];
	[friendSetViewController release];
	[[ViewControllers sharedViewControllers] refreshNeighborVC];
}


//#pragma mark -
//#pragma mark httpconnect
//- (void) onHttpConnectError:(HttpConnect*) up
//{
//	if (connect != nil)
//	{
//		[connect release];
//		connect = nil;
//	}
//}
//
//- (void) onMyHomeInfoTransdone:(HttpConnect*)up
//{
//	NSInteger friendCodeInt;
//	SBJSON* jsonParser = [SBJSON new];
//	[jsonParser setHumanReadable:YES];
//
//	NSDictionary* results = (NSDictionary *)[jsonParser objectWithString:up.stringReply error:NULL];
//	if (connect != nil)
//	{
//		[connect release];
//		connect = nil;
//	}
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
//	FriendSetViewController *friendSetViewController = [[FriendSetViewController alloc]initWithName:nickName.text friendSnsId: snsID friendCode:friendCodeInt friendImage:imageUrlStr];
//	friendSetViewController.cellDataList = self.cellDataList;
//	friendSetViewController.cellDataListIndex = self.cellDataListIndex;
//	
//	NSString* referCode = @"";
//	switch (cellType) {
//		case IMIN_CELLTYPE_RECOMMEND:
//        case IMIN_CELLTYPE_WELCOME_RECOMMEND:
//			referCode = @"0003";
//			break;
//		case IMIN_CELLTYPE_NICKNAME:
//			referCode = @"0006";
//			break;
//		default:
//			break;
//	}
//	friendSetViewController.referCode = referCode;
//	friendSetViewController.recomType = cellData.recomType;
//	
//	MY_LOG(@"my friend set view controller: cellDataListIndex = %d", self.cellDataListIndex);
//	
//	[friendSetViewController setHidesBottomBarWhenPushed:YES];
//	[[ViewControllers sharedViewControllers].neighbersViewController.navigationController pushViewController:friendSetViewController animated:YES];
//	[friendSetViewController release];
//	[[ViewControllers sharedViewControllers] refreshNeighborVC];
//}

@end
