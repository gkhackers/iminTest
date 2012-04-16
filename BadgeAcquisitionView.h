//
//  BadgeAcquisitionView.h
//  ImIn
//
//  Created by Myungjin Choi on 11. 2. 21..
//  Copyright 2011 KTH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UIImageView+WebCache.h"
#import "ImInProtocol.h"

@class BadgeInfo;

/**
 @brief 획득한 뱃지 뷰
 */
@interface BadgeAcquisitionView : UIView<ImInProtocolDelegate> {
	
	id delegate;
	
	BOOL isFrontSide;
	NSDictionary* badgeData;
	
	// IBOutlet
	IBOutlet UILabel* titleLabel;
	IBOutlet UILabel* badgeMessage;
	IBOutlet UITextView* getMsgTextView;
	IBOutlet UITextView* guideMsgTextView;
	IBOutlet UIButton* nextOrCloseBtn;
	IBOutlet UILabel* difficulty;
	IBOutlet UILabel* since;
	IBOutlet UILabel* totalUser;
	IBOutlet UIView* badgeRearSide;
	
	// Layers
	CALayer* biggerBadgeIconLayer;
	
	// ImInProtocol
	BadgeInfo* badgeInfo;
	
}
@property (nonatomic, retain) NSDictionary* badgeData;
@property (nonatomic, retain) BadgeInfo* badgeInfo;
@property (nonatomic, retain) IBOutlet UILabel* badgeMessage;
@property (nonatomic, retain) IBOutlet UIButton* nextOrCloseBtn;
@property (nonatomic, retain) id delegate;
@property (nonatomic, retain) CALayer* biggerBadgeIconLayer;

- (IBAction) nextBadge;
- (IBAction) closeView;
- (void) requestBadgeInfo;
- (void) startOpeningAnimationFrom:(CGPoint) from to:(CGPoint) to;

@end
