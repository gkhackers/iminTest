//
//  ProfileViewController.h
//  ImIn
//
//  Created by Myungjin Choi on 11. 1. 10..
//  Copyright 2011 KTH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImInProtocol.h"


@class TAddressbook;
@class MemberInfo;
@class HomeInfoDetail;
@class PoiInfo;
@class CookSnsCookie;
@class ShopList;
/**
 @brief 프로필 상세 보기
 */
@interface ProfileViewController : UIViewController <ImInProtocolDelegate, UIActionSheetDelegate, UITableViewDelegate, UITableViewDataSource> {
	
	UIView* coverView;
    
    IBOutlet UITableView *profileTableView;

    IBOutlet UITableViewCell *profileAreaCell;
    IBOutlet UITableViewCell *ownerShopCell;
    IBOutlet UITableViewCell *socialLinkAreaCell;
    IBOutlet UITableViewCell *activityStatusCell;
    IBOutlet UITableViewCell *relationshipAreaCell;
    IBOutlet UITableViewCell *favoriteAreaCell;
    IBOutlet UITableViewCell *latestColumbusCell;
    
    IBOutlet UITableViewCell *roundboxTopCell;
    IBOutlet UITableViewCell *roundboxBottomCell;
    
	// 프로필 영역
    IBOutlet UIImageView* profileImageView;
	IBOutlet UILabel* nicknameLabel;
	IBOutlet UIButton* friendSettingBtn;
	IBOutlet UILabel* birthMessageLabel;
	IBOutlet UIImageView* birthdayCake;
	IBOutlet UILabel* realNameLabel;
	IBOutlet UIView* introView;
	IBOutlet UILabel* prMessageLabel;
	IBOutlet UIImageView* prMessageBg;
    IBOutlet UIButton* giftBtn;
	
	CGRect profileAreaRect;
	CGRect nicknameLabelRect;
	CGRect friendSettingBtnRect;
	CGRect birthMessageLabelRect;
	CGRect birthdayCakeRect;
	CGRect realNameLabelRect;
	CGRect introViewRect;
	CGRect prMessageLabelRect;
    CGRect giftBtnRect;
	
	// 소셜 링크 영역
	IBOutlet UIButton* twitterLinkBtn;
	IBOutlet UIButton* fbLinkBtn;
	IBOutlet UIButton* me2dayLinkBtn;
	IBOutlet UIButton* phoneLinkBtn;
	IBOutlet UIButton* emailLinkBtn;
	
	// 활동 지표
	IBOutlet UILabel* checkInNumber;
	IBOutlet UILabel* badgeNumber;
	IBOutlet UILabel* masterNumber;
	IBOutlet UILabel* columbusNumber;
	
    // 발도장 영역
    IBOutlet UIImageView *favoriteAreaBgImageView;
    
	UIActionSheet* aActionSheet;
	
	// 관계
	IBOutlet UIImageView* relationshipTitleImageView;
    IBOutlet UIImageView *relationshipBgImageView;
	
	// footer
	IBOutlet UILabel* regDateLabel;
    IBOutlet UIView* footerArea;
	
	// 소상공인 가게 영역
    IBOutlet UIImageView *categoryImageView;
    IBOutlet UILabel *ownerNicknameLabel;
    IBOutlet UILabel *shopName;
    IBOutlet UILabel *description;                  //주소
    IBOutlet UIImageView *eventImage;
	
	NSString* snsId;
	NSDictionary* homeInfoResult;
	
	NSDictionary* homeInfoDetailResult;
	HomeInfoDetail* homeInfoDetail;
	
	// 전화번호 저장
	TAddressbook* phoneBook;
	
	MemberInfo* owner;
	NSInteger friendCodeInt;
	
	BOOL friendAdded;
	
	PoiInfo* poiInfo;
    CookSnsCookie* cookSnsCookie;
    
    NSUInteger profileAreaHeight;
    NSUInteger relationshipAreaHeight;
    NSUInteger footprintsAreaHeight;
    
    // 소상공인 정보
    NSString *bizPoiKey;
    NSUInteger countOfShopList;
    
    BOOL isOwner;
}

@property (nonatomic, retain) NSDictionary* homeInfoResult;
@property (nonatomic, retain) NSDictionary* homeInfoDetailResult;
@property (nonatomic, retain) TAddressbook* phoneBook;

@property (nonatomic, retain) MemberInfo* owner;
@property (readwrite) NSInteger friendCodeInt;

@property (nonatomic, retain) HomeInfoDetail* homeInfoDetail;
@property (nonatomic, retain) PoiInfo* poiInfo;
@property (nonatomic, retain) CookSnsCookie* cookSnsCookie;

@property (nonatomic, retain) NSString *bizPoiKey;

- (IBAction) closeVC;

- (IBAction) goFriendSettingOrProfileSetting:(UIButton*) sender;
- (IBAction) goGiftSend:(UIButton*) sender;
- (IBAction) showActionSheet:(UIButton*) sender;
- (IBAction) goLargePicture: (UIButton*) sender;

- (IBAction) goBadge:(UIButton*) sender;
- (IBAction) goFootPrints;
- (IBAction) goColumbus;
- (IBAction) goMaster;


@end
