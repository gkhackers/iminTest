//
//  UIHomeViewController.h
//  ImIn
//
//  Created by edbear on 10. 9. 11..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//


#import <UIKit/UIKit.h>

@class CheckinTableViewController;
@class HomeInfo;
@class HomeInfoDetail;
@class PostList;
@class ScrapList;
@class ScrapDelete;
@class TutorialView;
@class iToast;
/**
 @brief 마이홈 메인페이지
 */
@interface UIHomeViewController : UIViewController <ImInProtocolDelegate, UITableViewDelegate, UITableViewDataSource> {
	IBOutlet UIImageView* profileImageView;
	IBOutlet UILabel* nicknameLabel;
	IBOutlet UILabel* numNeighborLabel;
	IBOutlet UILabel* numBadgeLabel;
	IBOutlet UILabel* numMasterLabel;
    
    IBOutlet UIImageView* arrow;
    IBOutlet UILabel* lastUpdate;

	IBOutlet UIButton* setBtn;
	IBOutlet UIButton* checkinBtn;
	IBOutlet UIImageView* newBadgeImageView;
	IBOutlet UIImageView* prNewImageView;
			
    IBOutlet UITableView* mainTableView;
    	
	// BO
	MemberInfo* owner;
	NSInteger friendCodeInt;
    NSString* tableCoverNoticeMessage;
    NSInteger totalScrapCnt;
	
	NSDictionary* homeInfoResult;
    NSMutableArray* recentFootprints;
    NSMutableArray* scraps;
    
    NSInteger tabIndex; // 0: 발도장 탭,  1: 스크랩 탭
    NSInteger currPage; // 스크랩 페이징 전용
	
	// NO
	HomeInfo* homeInfo;
    HomeInfoDetail* homeInfoDetail;
    PostList* postList; // 최근 발도장 요청용
    ScrapList* scrapList; // 기억하기 요청용
    ScrapDelete* scrapDelete;
    
    // scroll 처리
    BOOL isTop;
	BOOL isEnd;
	BOOL isLoading;
    BOOL isBackward;
    
    BOOL noResult;
    
    // 튜토리얼 처리
    IBOutlet UIButton *balloonBtn;
    BOOL selectedTab;
    TutorialView *tutorial;
    
    BOOL noConnection;
}

@property (nonatomic, retain) MemberInfo* owner;
@property (nonatomic, retain) HomeInfo* homeInfo;
@property (nonatomic, retain) NSDictionary* homeInfoResult;
@property (nonatomic, retain) HomeInfoDetail* homeInfoDetail;
@property (nonatomic, retain) PostList* postList;
@property (nonatomic, retain) ScrapList* scrapList;
@property (nonatomic, retain) ScrapDelete* scrapDelete;
@property (nonatomic, retain) NSMutableArray* recentFootprints;
@property (nonatomic, retain) NSMutableArray* scraps;
@property (nonatomic, retain) TutorialView *tutorial;
@property (nonatomic, retain) NSString *tableCoverNoticeMessage;

- (IBAction)clickBalloon;

- (IBAction) goBack;
- (IBAction) goProfileImage; ///< 프로필 사진 로드
- (IBAction) goCheckIn; ///< 발도장 찍기
- (IBAction) goFriendSetting; ///< 이웃추가
- (IBAction) goMasterList; ///< 마이홈 마스터 클릭
- (IBAction) goNeighborList; ///< 마이홈 이웃 클릭

- (IBAction) goBadge;

// network i/o
- (void) requestHomeInfo;
- (void) requestFootPoiList;

// ui control
- (void) refreshFeedList; ///< 발도장 & 새소식에 대한 리스트 정보 다시 가져오기
- (IBAction)selectTab:(UIButton*)sender;
@end
