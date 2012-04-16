//
//  UserSearchTableViewController.h
//  ImIn
//
//  Created by choipd on 10. 7. 13..
//  Copyright 2010 edbear. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HttpConnect;
@class TableCoverNoticeViewController;
/**
 @brief 닉네임 검색
 */
@interface UserSearchTableViewController : UIViewController <UISearchDisplayDelegate, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource> {
	NSMutableArray* userList;
	NSString* nicknameKeyword;
	
	int currPage;
	int totalCnt;
	int scale;
	
	BOOL isEnd;
	
	HttpConnect* connect1;
	TableCoverNoticeViewController* infoView;
	IBOutlet UITableView* tableView;
}

@property (retain) NSMutableArray* userList;
@property (nonatomic, retain) IBOutlet UITableView* tableView;
@property (nonatomic, retain) NSString* nicknameKeyword;

- (IBAction) popViewController;
- (void) doRequestMore;
@end
