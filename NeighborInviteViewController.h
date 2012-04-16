//
//  NeighborInviteViewController.h
//  ImIn
//
//  Created by ja young park on 11. 9. 19..
//  Copyright 2011년 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CpNeighborList;
@class SendMsg;
@class AddLink;

/**
 @brief 이웃 초대
 */
@interface NeighborInviteViewController : UIViewController<UITableViewDelegate, UITableViewDataSource, ImInProtocolDelegate> {
    IBOutlet UITableView *footerTable; // 내 페이스북에 초대문구 게시하기
    IBOutlet UITableView *mainTable; // 각 개인에게 초대하기
    IBOutlet UIView *footerView;
    IBOutlet UILabel *titleLabel;
    //IBOutlet UIView *emptyView;
    CpNeighborList *cpNeighborList; 
    SendMsg *sendMsg;
    AddLink* addLink;
    
    NSMutableArray* cellDataList;
    NSString* nickNameToSearch;
	int currPage;
	int scale;
    int totalCnt;
    BOOL isLoaded;
    BOOL isEnd;
    NSString* titleString;
}

@property (nonatomic, retain)CpNeighborList *cpNeighborList;
@property (nonatomic, retain)SendMsg *sendMsg;
@property (nonatomic, retain)AddLink *addLink;
@property (nonatomic, retain)NSMutableArray* cellDataList;
@property (readwrite)BOOL isLoaded;
@property (nonatomic, retain) NSString* titleString;


- (void) cpNeighborListRequest;
- (void)kakaotokInvite;
- (void)snsInvite:(NSString*)cpCode msgType:(NSString*)msgType msg:(NSString*)msg;
- (IBAction) popViewController;


@end
