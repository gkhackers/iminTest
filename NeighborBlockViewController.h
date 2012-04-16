//
//  NeighborBlockViewController.h
//  ImIn
//
//  Created by park ja young on 11. 3. 29..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImInProtocol.h"

@class DenyGuestList;

/**
 @brief 이웃 차단
 */
@interface NeighborBlockViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, ImInProtocolDelegate>{
	IBOutlet UITableView* theTableView;

	DenyGuestList* denyGuestList;
	NSMutableArray* denyGuestListResult;
	
	int currPage;
	int scale;
	int totalCnt;
	
	BOOL isTop;
	BOOL isEnd;
	BOOL isLoading;
}

@property (nonatomic, retain) DenyGuestList* denyGuestList;
@property (nonatomic, retain) NSMutableArray* denyGuestListResult;

- (IBAction) popVC;

@end
