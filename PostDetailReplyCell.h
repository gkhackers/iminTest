//
//  PostDetailReplyCell.h
//  ImIn
//
//  Created by choipd on 10. 4. 29..
//  Copyright 2010 edbear. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImInProtocol.h"

@class ReplyCellData;
@class HttpConnect;

/**
 @brief 글상세보기 댓글의 셀 디자인
 */
@interface PostDetailReplyCell : UITableViewCell<ImInProtocolDelegate> {
	IBOutlet UILabel* comment;
	IBOutlet UILabel* description;
	IBOutlet UILabel* nickName;
	IBOutlet UIImageView* profileImg;
	IBOutlet UIImageView* commentImg;
	IBOutlet UIButton* goProfileBtn;
	
	ReplyCellData* cellData;
	ReplyCellData* dataToUpdate;
	NSMutableDictionary* postData;
	
	//swipe
	CGPoint previousTouchPosition1;
	CGPoint previousTouchPosition2;
	CGPoint startTouchPosition1;
	CGPoint startTouchPosition2;
		
	// contextmenu
	BOOL hasShownMenu;
	IBOutlet UIView* contextMenuView;
	IBOutlet UIImageView* contextMenuBg;
	IBOutlet UIButton* replyButton;
	IBOutlet UIButton* delButton;
	IBOutlet UIButton* reportButton;
    IBOutlet UIImageView* brandMark;
	
	BOOL hasParent;
	BOOL isMine;
	
	// api connect
	HttpConnect* connect;
	
	// deleagte
	id delegate;
	
}
@property(nonatomic, retain) IBOutlet UILabel* comment;
@property(nonatomic, retain) IBOutlet UILabel* description;
@property(nonatomic, retain) IBOutlet UILabel* nickName;
@property(nonatomic, retain) IBOutlet UIImageView* profileImg;
@property(nonatomic, retain) IBOutlet UIImageView* commentImg;
@property(nonatomic, retain) ReplyCellData* cellData;
@property(nonatomic, retain) NSMutableDictionary* postData;
@property(nonatomic, retain) ReplyCellData* dataToUpdate;

@property (assign) id delegate;

- (IBAction) goProfile;
- (void) redrawUI;
- (void) showContextMenu:(BOOL)animated;
- (void) disappearConextMenu:(BOOL)animated;
- (void) toggleContextMenu:(BOOL)animated;

- (IBAction) deleteReply:(id) sender;
- (IBAction) writeReply:(id) sender;
- (IBAction) reportReply:(id) sender;

- (void) requestDelComment;
- (void) goReportComment;

@end
