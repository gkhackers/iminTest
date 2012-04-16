//
//  NeighborFindTableViewController.h
//  ImIn
//
//  Created by ja young park on 11. 9. 7..
//  Copyright 2011년 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RecomendCellData.h"
#import "RecomendCell.h"

@class RecomendCellData;
@class SearchUser;
@class TableCoverNoticeViewController;

/**
 @brief 이웃 찾기 검색 테이블 뷰 컨트롤러
 */
@interface NeighborFindTableViewController : UITableViewController<UISearchDisplayDelegate, UISearchBarDelegate, ImInProtocolDelegate> {
    
    IBOutlet UISearchBar* searchBar;
    
    NSMutableArray* youMayKnows;
    NSMutableArray* youKnows;
    NSMutableArray* nicknameSearchList;
    NSMutableArray* recomBrands;
    UIView *headerView;
    IBOutlet UIView *footerView;
    
    NSString* nicknameKeyword;
	
	int currPage;
	int searchResultCnt;
	int scale;
	
	BOOL isEnd;
    
    UITableView *innerTable;
    BOOL pulldownState;
    BOOL isLoadNeed;
    BOOL isReUserSearch;
    
    SearchUser *searchUser;
    //IBOutlet UIButton* neighborBtn;
    NSInteger retryCnt; // 여러번 요청시 횟수
    
    BOOL phoneBookConnected;
    BOOL twitterConnected;
    BOOL facebookConnected;
    BOOL initRequest;
    NSMutableArray* indicators;
    TableCoverNoticeViewController* infoView;

}
@property (nonatomic, retain) IBOutlet UITableView *innerTable;
@property (nonatomic, retain) IBOutlet UIView *headerView;
@property (nonatomic, retain) NSMutableArray* youMayKnows;
@property (nonatomic, retain) NSMutableArray* youKnows;
@property (nonatomic, retain) NSMutableArray* nicknameSearchList;
@property (nonatomic, retain) NSMutableArray* recomBrands;
@property (nonatomic, retain) NSString* nicknameKeyword;
@property (nonatomic, retain) SearchUser *searchUser;
@property (readwrite) BOOL pulldownState;


- (IBAction) neighborInvite:(id)sender;
//- (void)reloadDraw:(NSInteger)totalCnt phoneRecomCnt:(NSInteger)phoneRecomCnt facebookRecomCnt:(NSInteger)facebookRecomCnt twitterRecomCnt:(NSInteger)twitterRecomCnt;
- (void) setViewMovedUp:(BOOL)movedUp;
- (void) moreSearch;
- (void) downStateDraw;
- (void) doUserSearch;
- (void) doRequestMore;
- (void) sequencialRequestWithMaxRetryCount:(NSInteger) maxRequestCnt;
- (void) removeSearchKeyboard;
- (void) getEventCoupon:(NSString *)eventUrl;
@end
