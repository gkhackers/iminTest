//
//  BadgeDetailView.h
//  ImIn
//
//  Created by Myungjin Choi on 11. 2. 11..
//  Copyright 2011 KTH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIImageView+WebCache.h"
#import "ImInProtocol.h"

@class BadgeInfo;

/**
 @brief 뱃지 상세 페이지에서 애니메이션 들어간 뱃지 뷰
 */
@interface BadgeDetailView : UIView <ImInProtocolDelegate>{
	
	id delegate;
	
	BOOL isFrontSide;
	NSDictionary* badgeData;
	NSArray* ownerList;
	MemberInfo* owner;

	// IBOutlet
	IBOutlet UIView* badgeOwnerListView;
	IBOutlet UILabel* titleLabel;
	IBOutlet UITextView* guideTextView;
	IBOutlet UILabel* difficulty;
	IBOutlet UILabel* since;
	IBOutlet UILabel* totalUser;
	IBOutlet UIView* badgeRearSide;
	
	IBOutlet UIButton* tipButton;
	IBOutlet UIView* tipView;
	IBOutlet UILabel* tipViewTitle;
	IBOutlet UITextView* tipViewTip;
	
	// Layers
	CALayer* biggerBadgeIconLayer;
	
	
	// ImInProtocol
	BadgeInfo* badgeInfo;
}

@property (nonatomic, retain) NSDictionary* badgeData;
@property (nonatomic, retain) NSArray* ownerList;
@property (nonatomic, retain) BadgeInfo* badgeInfo;
@property (assign) id delegate;
@property (nonatomic, retain) CALayer* biggerBadgeIconLayer;
@property (nonatomic, retain) MemberInfo* owner;

- (IBAction) closeBadgeDetailView;
- (IBAction) goHome:(UIButton*) sender;
- (IBAction) showTipView;
- (IBAction) hideTipView;
- (void) requestBadgeInfo;
- (void) startOpeningAnimation;

@end
