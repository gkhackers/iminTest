//
//  FeedListTableViewController.h
//  ImIn
//
//  Created by edbear on 10. 9. 9..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
 
@class PoiInfo;
@class HomeInfo;
@class MyPostListById;
@class BadgeInfo;
@class TFeedList;
@class FeedClose;
@class EventList;

/**
 @brief 마이홈페이지의 발도장&새소식의 리스트 뷰컨트롤러
 */
@interface FeedListTableViewController : UITableViewController<ImInProtocolDelegate> {
	NSMutableArray* feedList;   ///< 노출할 새소식 목록
	NSNumber* feedType; ///< 새소식 유형
    
    /// 현재 진행중인 이벤트
    NSMutableArray* eventDataList;  
    NSDictionary* eventFirstData;
    NSInteger eventTotalCnt;
	
    /// 새소식 이동 시 필요한 정보 
	MemberInfo* owner;
	PoiInfo* poiInfo;
	HomeInfo* homeInfo;
	MyPostListById* postListById;
	BadgeInfo* badgeInfo;
    FeedClose* feedClose;
	BOOL newBadge;
    EventList *eventList;
	
	TFeedList* selectedFeed;
	
	NSUInteger downloadCompleted;
	
	NSDictionary* badgeInfoResult;

    BOOL noResult;
    BOOL isTop;
}

@property (nonatomic, retain) NSMutableArray* feedList;
@property (nonatomic, retain) NSNumber* feedType;

@property (nonatomic, retain) MemberInfo* owner;
@property (nonatomic, retain) PoiInfo* poiInfo;
@property (nonatomic, retain) HomeInfo* homeInfo;
@property (nonatomic, retain) MyPostListById* postListById;
@property (nonatomic, retain) BadgeInfo* badgeInfo;
@property (nonatomic, retain) FeedClose* feedClose;
@property (nonatomic, retain) TFeedList* selectedFeed;
@property (nonatomic, retain) NSDictionary* badgeInfoResult;
@property (readwrite) NSInteger eventTotalCnt;
@property (nonatomic, retain) NSMutableArray* eventDataList;
@property (nonatomic, retain) EventList *eventList;
@property (nonatomic, retain) NSDictionary* eventFirstData;

- (void) badgeDetailViewShow :(NSDictionary*)badgeData;
- (void) badgeAcquisitionViewShow :(NSArray*)badgeList;
- (void) deleteAllFeed;
- (void) downloadImageWithUrl:(NSString*) url;
- (void) requestEvent;
- (void) requestFeedClose;
- (void) doRefresh;

@end
