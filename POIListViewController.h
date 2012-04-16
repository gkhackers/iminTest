//
//  POIListViewController.h
//  ImIn
//
//  Created by choipd on 10. 5. 3..
//  Copyright 2010 edbear. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImInProtocol.h"
/**
 @brief POI 검색 화면
 */

@class PoiList;
@class LocalList;
@class AutoSearch;

@interface POIListViewController : UIViewController 
<UITableViewDelegate, UITableViewDataSource, UISearchDisplayDelegate, UISearchBarDelegate, ImInProtocolDelegate> 
{
	IBOutlet UISearchBar* searchBar;
	IBOutlet UIButton* focusSearchBar;
	IBOutlet UIView* mainFooterView;
    IBOutlet UIView* footerViewMore;
    IBOutlet UIView* footerViewSearch;
    
    IBOutlet UIView* searchMainFooter;
    IBOutlet UIView* searchFooterMore;
    IBOutlet UIView* searchFooterView;
    
	//IBOutlet UIView* moreView;
	//IBOutlet UIView* moreSearchView;
    
    IBOutlet UIButton* historyOnBtn;
    IBOutlet UIButton* historyOffBtn;
    IBOutlet UIButton* locationOnBtn;
    IBOutlet UIButton* locationOffBtn;
	
	IBOutlet UITableView* localListTableView;
    
    IBOutlet UIButton* moreBtn;
	//IBOutlet UIButton* searchMoreBtn;
	//IBOutlet UILabel* moreLabel;
    
    UIView *headerView;
	
	NSMutableArray* nearPoiList;
	NSMutableArray* myPoiList; // 내POI 목록
	NSMutableArray* filteredNearPoiList; //검색한 내용을 담음
    NSMutableArray* autoSearchList;
	
	NSString* savedSearchTerm;
	BOOL searchWasActive;
	
	BOOL onSearching;
    
    NSInteger	selectedTabInt;
    NSInteger   searchTypeInt;
    NSInteger   currPostWriteFlow;
	
	//page
	int currPage;
	int lastPage;
	
	int currPageWithSearch;
	int lastPageWithSearch;
	
	PoiList* poiList;
	LocalList* localList;
	LocalList* localSearchList;
    AutoSearch* autoSearch;
    
    NSString* lastPostId;
    NSString* searchText;
    BOOL hasMoreItem;
	
	BOOL isEnd;
    NSString *rootViewController;
    NSString* tableCoverNoticeMessage;
    NSMutableArray* nearPoiUIDescriptionArray;
    NSMutableArray* myPoiUIDescriptionArray;
    
    id previousVCDelegate;
}

@property (nonatomic, retain) NSMutableArray* nearPoiList;
@property (nonatomic, retain) NSMutableArray* myPoiList;
@property (nonatomic, retain) NSMutableArray* filteredNearPoiList;
@property (nonatomic, retain) NSMutableArray* autoSearchList;

@property (nonatomic, copy) NSString* savedSearchTerm;
@property (nonatomic) BOOL searchWasActive;
@property (nonatomic, retain) PoiList* poiList;
@property (nonatomic, retain) LocalList* localList;
@property (nonatomic, retain) LocalList* localSearchList;
@property (nonatomic, retain) AutoSearch* autoSearch;
@property (readwrite) NSInteger	selectedTabInt;
@property (readwrite) NSInteger searchTypeInt;
@property (nonatomic, retain) NSString* lastPostId;
@property (nonatomic) BOOL hasMoreItem;
@property (nonatomic, retain) NSString* searchText;
@property (nonatomic, retain) IBOutlet UIView *headerView;
@property (nonatomic, retain)  NSString *rootViewController;
@property (nonatomic, assign) id previousVCDelegate;
@property (nonatomic, retain) UINavigationController *previousNavi;
@property (nonatomic, retain) UINavigationController *tabBarNavi;
@property (readwrite) NSInteger currPostWriteFlow;
@property (nonatomic, retain) NSString* tableCoverNoticeMessage;
@property (nonatomic, retain) NSMutableArray* nearPoiUIDescriptionArray;
@property (nonatomic, retain) NSMutableArray* myPoiUIDescriptionArray;



- (IBAction) popViewController;
- (IBAction) registerPOI;
- (IBAction) goSearchBar;
- (IBAction) requestMore;
- (IBAction) requestMoreMyPoiList;
- (IBAction) requestMoreWithSearch;
- (IBAction) moreBtnClick;
- (void) requestLocalList;
- (void) requestMyPoiList;
- (void) requestAutoSearch;
- (void)setViewMovedUp:(BOOL)movedUp;
- (IBAction) selectTab: (UIButton*) sender;
- (void) selectPOIList : (NSInteger)tabIndext;
- (void) serverSearch;
- (void) goPoiDetail : (NSDictionary*)pData;
//- (void) postNetworkNoticeWithFrame:(CGRect)frame;

@end
