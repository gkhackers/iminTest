//
//  TwitterInvitationViewController.h
//  ImIn
//
//  Created by choipd on 10. 7. 30..
//  Copyright 2010 edbear. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HttpConnect;
/**
 @brief SNS초대의 베이스 클래스
 */
@interface SNSInvitationViewController : UIViewController {
	
	NSMutableArray* cellDataList;
	
	HttpConnect* connect1;
	HttpConnect* connect2;
	
	NSString* nickNameToSearch;
	int currPage;
	int scale;
	int totalCnt;
	
	IBOutlet UITableView* myTableView;
	
	NSString* cpCode;
	
	BOOL isLoaded;
	BOOL isEnd;
}
@property (nonatomic, retain) NSMutableArray* cellDataList;
@property (nonatomic, retain) NSString* cpCode;
@property (readwrite) BOOL isLoaded;

- (void) request;
- (void) doRequestMore;
- (IBAction) popViewController;
- (void) requestCpRefresh;
- (void) onCpNeighborListRefreshTransDone:(HttpConnect*)up;
- (void) onCpNeighborListRefreshResultError:(HttpConnect*)connect;

@end
