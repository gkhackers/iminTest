//
//  CheckinTableViewController.h
//  ImIn
//
//  Created by edbear on 10. 9. 12..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainThreadTableViewController.h"


@class MemberInfo;
@class PostList;
@class TableCoverNoticeViewController;
/**
 @brief 최근발도장 테이블뷰 컨트롤러
 */
@interface CheckinTableViewController : MainThreadTableViewController <ImInProtocolDelegate, MainThreadProtocol>{
	MemberInfo* owner;
	PostList* postList;
	
	TableCoverNoticeViewController* infoView;
	BOOL isIncludeBadge;
}
@property (nonatomic, retain) MemberInfo* owner;
@property (nonatomic, retain) PostList* postList;
@property (nonatomic, retain) TableCoverNoticeViewController* infoView;
@property (readwrite) BOOL isIncludeBadge;


- (void) requestFootPoiList;
- (void) request;

@end
