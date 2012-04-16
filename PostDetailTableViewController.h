//
//  PostDetailTableViewController.h
//  ImIn
//
//  Created by choipd on 10. 4. 27..
//  Copyright 2010 edbear. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HttpConnect.h"
#import "ImInProtocol.h"

@class ReplyCellData;
@class HomeInfoDetail;
@class CmtList;

/**
 @brief 글상세보기 테이블
 */
@interface PostDetailTableViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, ImInProtocolDelegate> {

	NSMutableDictionary* postData;
	NSUInteger postIndex;
	NSMutableArray* postList;
	NSMutableArray* replyList;
	
	IBOutlet UILabel* invisibleLabel;
	IBOutlet UITextView* invisibleTextView;
	IBOutlet UILabel* commentInvisibleLabel;
	
	IBOutlet UILabel* titleLabel;
	IBOutlet UITableView* replyTableView;
	
	BOOL isFirst;
	BOOL isReplyListAvailble;
	float firstCellHeight;
	HttpConnect* connect;
	
	int currentPage;
	int scale;
	int totalComment;
	
	int newCmtCnt;
	BOOL isEnd;
	
	BOOL needToUpdateReReply;
	BOOL needToUpdateReply;
	
	BOOL isSelectAndMove;
	
	BOOL networkTimeout;
	
	ReplyCellData* dataToUpdate;
    HomeInfoDetail* homeInfoDetail;
    NSDictionary* homeInfoDetailResult;
    CmtList* cmtList;
}	

@property (nonatomic, retain) NSMutableDictionary* postData;
@property (nonatomic, retain) NSMutableArray* postList;
@property (readwrite) NSUInteger postIndex;
@property (nonatomic, retain) HomeInfoDetail* homeInfoDetail;
@property (nonatomic, retain) NSDictionary* homeInfoDetailResult;
@property (nonatomic, retain) CmtList* cmtList;


- (IBAction) popViewController;
- (IBAction) openCommentView;
- (IBAction) openGiftSend:(UIButton*) sender;

- (void) request;
- (void) requestMore;
- (void) requestReReplyList;
@end
