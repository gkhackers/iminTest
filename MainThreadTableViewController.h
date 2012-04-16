//
//  MainThreadTableViewController.h
//  ImIn
//
//  Created by choipd on 10. 4. 22..
//  Copyright 2010 edbear. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CgiStringList.h"
#import "HttpConnect.h"

@protocol MainThreadProtocol <NSObject>
@optional
-(CgiStringList*) mainThreadRequestLatest;
-(CgiStringList*) mainThreadRequestMore;
@required
-(NSString*) mainThreadRequestAddress;

@end
/**
 @brief 메인 쓰레드 테이블
 */

@interface MainThreadTableViewController : UITableViewController <UITableViewDelegate, UITableViewDataSource> {
	id<MainThreadProtocol> delegate;

	NSMutableArray* cellDataList;
    NSDictionary* eventFirstData;
	
	IBOutlet UILabel* loadMore;
	IBOutlet UILabel* loadTail;
	IBOutlet UIButton* loadTailBtn;
	IBOutlet UIActivityIndicatorView* indicator;
	IBOutlet UIImageView* arrow;
	IBOutlet UILabel* loadOneHundredMore;
	IBOutlet UILabel* lastUpdate;
	IBOutlet UIView* footerView;
	IBOutlet UIView* footerSelectedBackgroundView;
	IBOutlet UIView* headerView;
	
	NSString* lastUpdateDate;
	NSString* lastPostID;
	NSString* latestPostID;
    NSString* enclosingClassName;
	
	BOOL isTop;
	BOOL isEnd;
	BOOL isLoading;
    NSInteger eventTotalCnt;
	
	HttpConnect* connect;
	
	// MainThreadCell의 종류를 구분해주기 위해 다음 properties를 추가함.
	BOOL isNeighborList;
	BOOL isToMeNeighbor;	// YES: 
	BOOL isFromPlazaVC;
	NSString* curPosition; // GA분기 위한 코드
    float currentHeight;
	
	NSIndexPath* selectedIndexPath;
}

@property (nonatomic, retain) 	NSMutableArray* cellDataList;
@property (assign) id<MainThreadProtocol> delegate;
@property (nonatomic, retain) 	UIView* footerView;
@property (readwrite) BOOL isNeighborList;
@property (readwrite) BOOL isToMeNeighbor;
@property (readwrite) BOOL isFromPlazaVC;
@property (nonatomic, retain) NSIndexPath* selectedIndexPath;
@property (nonatomic, retain) NSString* latestPostID;
@property (nonatomic, retain) NSString* lastPostID;
@property (nonatomic, retain) NSString* curPosition;
@property (nonatomic, retain) NSString* enclosingClassName;
@property (readwrite) NSInteger eventTotalCnt;
@property (nonatomic, retain) NSDictionary* eventFirstData;

- (void) requestLatest;
- (void) requestBefore;
- (IBAction) doRequestBefore;
- (void) doRequestLatest;
- (void) updateParameter;
- (void) updateRange;

@end
