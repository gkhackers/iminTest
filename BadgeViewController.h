//
//  BadgeViewController.h
//  ImIn
//
//  Created by Myungjin Choi on 11. 2. 18..
//  Copyright 2011 KTH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImInProtocol.h"
#import "NotiManager.h"

@class LastBadgeList, BadgeList;
/**
 @brief 전체 뱃지 리스트 보여주기
 */
@interface BadgeViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, ImInProtocolDelegate, IminNotificationDelegate> {
	IBOutlet UITableView* badgeTableView;
	IBOutlet UILabel* titleLabel;
	IBOutlet UIView* sectionHeaderViewForLastestBadge;
	IBOutlet UIView* sectionHeaderViewForTotalBadge;
	IBOutlet UILabel* numberOfBadgeOwned;
	IBOutlet UILabel* myBadgeProgress;
	IBOutlet UIButton* viewModeButton;
	
	// ImIn Protocol
	LastBadgeList* lastBadgeList;
	BadgeList* badgeList;
	
	// 데이터
	NSArray* badgeArray;		///< 앨범형 자료
	NSArray* lastBadgeArray;	
	NSArray* badgeListArray;	///< 리스트형 자료
	MemberInfo* owner;
	
	// Cell reuse buffer
	NSMutableDictionary* setBadgeCellList;
	
	BOOL isAlbumView;
	
	int apiDidLoadCnt;
    
    NotiManager *manager;
}

@property (nonatomic, retain) NSArray* badgeArray;
@property (nonatomic, retain) NSArray* badgeListArray;
@property (nonatomic, retain) NSArray* lastBadgeArray;
@property (nonatomic, retain) MemberInfo* owner;
@property (nonatomic, retain) LastBadgeList* lastBadgeList;
@property (nonatomic, retain) BadgeList* badgeList;
@property (nonatomic, retain) NotiManager *manager;

- (IBAction) closeVC;
- (IBAction) toggleViewType:(UIButton*) sender;

- (void) requestBadgeList;
- (void) requestLastBadgeList;
- (void) requestNotiList;

@end
