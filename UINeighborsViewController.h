//
//  UINeighborsViewController.h
//  ImIn
//
//  Created by bladekim on 10. 4. 6..
//  Copyright 2010 KTH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainThreadTableViewController.h"

#import "NeighborFindTableViewController.h"
#import "HttpConnect.h"
#import "CgiStringList.h"

#define CELLLIST_CAPACITY   50

@class NeighborRecomCnt;
@class FeedCount;
@class TutorialView;
/**
 @brief 이웃 탭의 루트 뷰 컨트롤러
 */
@interface UINeighborsViewController : UIViewController <MainThreadProtocol, UIActionSheetDelegate, ImInProtocolDelegate>{
	
	IBOutlet UIButton* followingOnBtn;
	IBOutlet UIButton* followingOffBtn;
	IBOutlet UIButton* followerOnBtn;
	IBOutlet UIButton* followerOffBtn;
	IBOutlet UIButton* recomOnBtn;
	IBOutlet UIButton* recomOffBtn;
		
	
	NSMutableArray		*cellDataList;
    
	NSInteger	selectedSegInt;

	MainThreadTableViewController	*neighborTableViewController;
    NeighborFindTableViewController   *neighborFindTableViewController;

	CgiStringList	*strPostData;
	NSInteger		currPageNum0; // 내가 추가한 이웃 페이징
	NSInteger		currPageNum1; // 나를 추가한 사람 페이징
    
	NSInteger       currRecomCount;
    
	HttpConnect* connect;
	
	BOOL hasLoaded;
    
    IBOutlet UIView *neighborBadgeView;
    IBOutlet UIView *recomBadgeView;
    IBOutlet UIView *recomBadgeViewLarge;
    IBOutlet UILabel *neighborCount;
    IBOutlet UILabel *recomCount;
    IBOutlet UILabel *recomCountLarge;
    
    NeighborRecomCnt *neighborRecomCnt;
    FeedCount* feedCount;
    
    TutorialView *tutorial;
}
@property (readwrite) BOOL hasLoaded;
@property (readwrite) NSInteger	selectedSegInt;
@property (nonatomic, retain) MainThreadTableViewController *neighborTableViewController;
@property (nonatomic, retain) NeighborFindTableViewController *neighborFindTableViewController;
@property (nonatomic, retain) CgiStringList	*strPostData;
@property (nonatomic, retain) NSMutableArray *cellDataList;
@property (nonatomic, retain) NeighborRecomCnt *neighborRecomCnt;
@property (nonatomic) NSInteger currRecomCount;
@property (nonatomic, retain) FeedCount* feedCount;
@property (nonatomic, retain) TutorialView *tutorial;


- (void) requestMyFriendsList;
- (void) requestMyFollowerList;
- (void) reloadFriendList:(NSInteger) listIndex;
- (void) neighborRecomCntRequest;
- (void) requestFeedCount;
- (NSDate*) lastDate;

- (IBAction) findFriend;
- (IBAction) pickFriendsList: (UIButton*) sender;

@end
