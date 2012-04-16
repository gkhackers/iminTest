//
//  POIDetailViewController.h
//  ImIn
//
//  Created by choipd on 10. 5. 3..
//  Copyright 2010 edbear. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImInProtocol.h"

@class SmallMapContainerView;
@class PlazaPostListByPoi;
@class CaptainAreaListByPoi;
@class PoiInfo;
@class EventList;
@class HomeInfo;

/**
 @brief POI상세를 보여주는 화면 컨트롤러
 */
@interface POIDetailViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, ImInProtocolDelegate> {
	NSDictionary* poiData;				///< Poi 상세 정보

    NSDictionary* poiInfoData;
    NSMutableArray*      bizDataArray;
    NSMutableArray*      eventDataArray;
    
	NSMutableArray* cellDataList;				///< 해당 POI에 대한 발도장 목록
	
    NSString* columbusSnsID;					///< 콜럼버스 눌렀을 때 이동하기위한 콜럼버스의 snsId
	NSString* columbusProfileImageURL;			///< 콜럼버스 눌렀을 때 이동하기위한 프로필 이미지
	
	NSString* myPoint;							///< 이 장소에서의 내 점수
	
	PlazaPostListByPoi* plazaPostListByPoi;		///< 전체 발도장 request객체
	CaptainAreaListByPoi* captainAreaListByPoi;	///< 마스터 정보 요청 request객체
	PoiInfo* poiInfo;
    EventList* eventList;
    HomeInfo* homeInfo;
	
	NSString* lastPostIdForWhole;				///< 더보기 요청을 위해 마지막 PostId를 저장함
    NSString* latestPostIdForWhole;
	BOOL isTop;									///< 스크롤의 끝임을 확인
	BOOL isEnd;
    BOOL isBackward;
    
	NSInteger isMyStatus;						///< 이 장소에 발도장을 찍은 적이 있는 지 확인
    
    BOOL existResultForWholeView;               ///< 전체 발도장이 존재하는지 여부
	
	BOOL needToUpdate;							///< 갱신할 필요가 있는지 체크
	
	NSString* eventUrlString;
    
    NSString* tableCoverNoticeMessage;          ///< 오류 메시지

    NSDictionary* masterData;
    BOOL isLoadFinish;
    
    IBOutlet UITableView* postListTableView;	///< 해당 POI에 대한 발도장 목록 테이블 
    IBOutlet UIImageView *arrow;
    IBOutlet UILabel *lastUpdateLabel;
}



@property (nonatomic, retain) NSDictionary* poiData;
@property (nonatomic, retain) NSDictionary* masterData;
@property (nonatomic, retain) NSString* columbusSnsID;
@property (nonatomic, retain) NSString* columbusProfileImageURL;
@property (nonatomic, retain) NSMutableArray* cellDataList;
@property (nonatomic, retain) NSString* myPoint;
@property (nonatomic, retain) NSDictionary* poiInfoData;
@property (nonatomic, retain) NSArray*      eventDataArray;
@property (nonatomic, retain) NSMutableArray*      bizDataArray;
@property (nonatomic, retain) NSString* tableCoverNoticeMessage;
@property (nonatomic, retain) PlazaPostListByPoi* plazaPostListByPoi;
@property (nonatomic, retain) CaptainAreaListByPoi* captainAreaListByPoi;
@property (nonatomic, retain) PoiInfo* poiInfo;
@property (nonatomic, retain) EventList* eventList;
@property (nonatomic, retain) HomeInfo* homeInfo;
@property (readwrite) BOOL isLoadFinish;


- (IBAction) popViewController;
- (void) openLargeMap;						///< 지도보기 버튼 눌렀을 때
- (void) openPoiInfo;
//- (IBAction) openRankingView;					///< 랭킹뷰 버튼 눌렀을 때
- (IBAction) profileClicked:(id)sender;			///< Columbus 눌렀을 때
- (void) requestWholeCheckIns;					///< 전체 발도장 목록 요청
- (void)requestPoiInfo;
- (void) requestMasterInfo;						///< 마스터 정보 요청
- (IBAction) openEventUrl;
@end
