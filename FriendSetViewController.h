//
//  FriendSetViewController.h
//  ImIn
//
//  Created by park ja young on 11. 3. 7..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ImInProtocol.h"

#define FR_NONE		0
#define FR_ME		1
#define	FR_YOU		2
#define FR_TRUE		3

@class NeighborList;
@class NeighborRegist;
@class NeighborDelete;
@class SetBlock;

@class DenyGuestRegist;
@class DenyGuestDelete;
@class IsDenyGuest;

/**
 @brief 이웃 맺기
 */
@interface FriendSetViewController : UIViewController<ImInProtocolDelegate>{
	IBOutlet UILabel* nickName;
	IBOutlet UISwitch* friendSetSwitch;
	IBOutlet UISwitch* notiSwitch;
	IBOutlet UISwitch* neighborBlockSwitch;
	IBOutlet UILabel* notiLable;
	IBOutlet UILabel* neighborAddLable;
	IBOutlet UIImageView* profileImageView;
	IBOutlet UILabel* neighborNickname;
	
	NSString	*nickNameStr;
	NSString	*snsIdStr;
	NSString    *profileUrl;
	NSMutableArray* cellDataList;
	NSInteger cellDataListIndex;
	
	NSString* recomType;
	NSString* referCode;
	NSString* position;
	NSInteger	frCode;
	Boolean		isFollowing, isNoti;
	Boolean     preFollowing, preNoti;

	Boolean		isDenyGuestValue;
    BOOL        hasNeighborCoupon;
    NSString*   couponId;
	
	NeighborList* neighborList;
	NeighborRegist* neighborRegist;
	NeighborDelete* neighborDelete;
	
	
	SetBlock* setBlock;
	
	DenyGuestRegist* denyGuestRegist;
	DenyGuestDelete* denyGuestDelete;
	
	IsDenyGuest* isDenyGuest;
}

@property (nonatomic, retain) NeighborList* neighborList;
@property (nonatomic, retain ) NeighborRegist* neighborRegist;
@property (nonatomic, retain ) NeighborDelete* neighborDelete;
@property (nonatomic, retain ) SetBlock* setBlock;
@property (nonatomic)	NSInteger frCode;
@property (nonatomic, retain) NSMutableArray* cellDataList;
@property (readwrite) NSInteger cellDataListIndex;

@property (nonatomic, retain) NSString* recomType;
@property (nonatomic, retain) NSString* referCode;
@property (nonatomic, retain) NSString* position;
@property (nonatomic, retain) NSString*   couponId;

@property (nonatomic, retain) DenyGuestRegist* denyGuestRegist;
@property (nonatomic, retain) DenyGuestDelete* denyGuestDelete;
@property (nonatomic, retain) IsDenyGuest* isDenyGuest;


- (id) initWithName:(NSString*)name friendSnsId:(NSString*)snsId friendCode:(NSInteger)code friendImage:(NSString*)profileImage;

- (void) requestNeighborList;
- (void) requestSetBlock;

- (void) beFriend;
- (void) getEventCoupon:(NSString *)eventUrl;

- (IBAction) popViewController;
- (IBAction) neighborSetCancel;
- (IBAction) confirm;
- (IBAction)toggleFriendSetSW;
- (IBAction)toggleFriendBlockSet;


@end
