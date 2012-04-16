//
//  BrandHomeViewController.h
//  ImIn
//
//  Created by KYONGJIN SEO on 10/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@class PostList;
@class MemberInfo;
@class HomeInfo;
@class HomeInfoDetail;
@class MainThreadCell;
@class EventList;

/**
 @brief 브랜드 홈 뷰 컨트롤러
 */
@interface BrandHomeViewController : UIViewController <ImInProtocolDelegate, UITableViewDelegate, UITableViewDataSource> {

    IBOutlet UIImageView *barImageView;
    IBOutlet UIButton *preBtn;
    UIButton *friendBtn;
    IBOutlet UIButton *checkInBtn;

    IBOutlet UIImageView *brandImageVIew;
    IBOutlet UILabel *titleLabel;
    IBOutlet UIButton *wholeBtn;
    IBOutlet UIButton *brandBtn;
    IBOutlet UIButton *bannerBtn;
    IBOutlet UITableView *footPrintsTableView;

    HomeInfo *homeInfo;
    EventList* eventList;
    PostList *postList;

    MemberInfo *owner;
    NSMutableArray *brandDataList;
    NSMutableArray *wholeDataList;
    NSArray* eventDataArray;
    
    NSInteger friendCodeInt;
    
    
    NSString* tableCoverNoticeMessage;          ///< 오류 메시지
    
    BOOL existResultForWholeView;
    BOOL needToUpdate;							///< 갱신할 필요가 있는지 체크
    BOOL existRecentBrandCheckIn;
    
    BOOL isNeighborList;
    BOOL isToMeNeighbor;
    NSString *curPosition;    
    
    NSUInteger tabIndex;
    BOOL isBackward;
    
    BOOL isTop;
    BOOL isEnd;
}

@property (nonatomic, retain) IBOutlet UIButton *friendBtn;
@property (nonatomic, retain) HomeInfo *homeInfo;
@property (nonatomic, retain) PostList *postList;
@property (nonatomic, retain) EventList* eventList;
@property (nonatomic, retain) MemberInfo *owner;
@property (nonatomic, retain) NSMutableArray *brandDataList;
@property (nonatomic, retain) NSMutableArray *wholeDataList;
@property (nonatomic, retain) NSString *tableCoverNoticeMessage;
@property (nonatomic, retain) NSArray* eventDataArray;

@property (readwrite) BOOL isNeighborList;
@property (readwrite) BOOL isToMeNeighbor;
@property (nonatomic, retain) NSString *curPosition;

@property (nonatomic, retain) IBOutlet UITableView *footPrintsTableView;


- (void)setFootPrintsTab:(BOOL)isRecent;
- (void) checkRecentBrandCheckInData;       //일주일 이내 브랜드 발도장 체크

- (void) requestHomeInfo;

- (void) requestBrandFootPoiList;
- (void) requestWholeFootPoiList;
- (void) requestWholeFootPoiListOld;
- (void) requestBrandFootPoiListOld;
- (void) requestWholeFootPoiListNew;
- (void) requestBrandFootPoiListNew;

- (void) processPostList:(NSDictionary*) result;
- (void) processHomeInfo:(NSDictionary*) result;
- (void) processPoiInfo:(NSDictionary*) result;
@end
