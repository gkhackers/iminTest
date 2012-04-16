//
//  SNSInvitationTableCell.h
//  ImIn
//
//  Created by choipd on 10. 8. 3..
//  Copyright 2010 edbear. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HttpConnect;
@class HomeInfo;
/**
 @brief SNS초청에 대한 공통 셀 디자인
 */
@interface SNSInvitationTableCell : UITableViewCell<ImInProtocolDelegate> {
	IBOutlet UIImageView* profileImg;
	IBOutlet UILabel* nickName;
	IBOutlet UILabel* cpNickName;
	IBOutlet UILabel* columbus;
	IBOutlet UILabel* neighbor;
	IBOutlet UILabel* lastPoiName;
	
	IBOutlet UIButton* friendAddBtn;
	IBOutlet UIView* imInUserView;
	
	IBOutlet UIView* nonImInUserView;
	IBOutlet UIImageView* cpProfileImg;
	IBOutlet UILabel* cpNickNameLarge;
	
	IBOutlet UIButton* sendDMBtn;
	
	IBOutlet UIImageView* cpIcon;
	
	NSString* cpIdString;
	NSString* snsIdString;
	NSString* nickNameString;
	NSString* profileImgString;
	
	HttpConnect* connect1;
	
	NSString* cpCode;
	
	NSMutableArray* cellDataList;
	NSInteger cellDataListIndex;
	
	NSMutableDictionary* cellDataDictionary;
	
	NSInteger cellType;
    HomeInfo* homeInfo;
	
}

@property (nonatomic, retain) NSMutableArray* cellDataList;
@property (readwrite) NSInteger cellDataListIndex;
@property (nonatomic, retain) NSMutableDictionary* cellDataDictionary;
@property (readwrite) NSInteger cellType;
@property (nonatomic, retain) HomeInfo* homeInfo;

- (void) redrawCellWithDictionary:(NSDictionary*) cellData;
- (IBAction) goSnsInvite;
- (IBAction) goHome;
- (IBAction) goNeighborSetView;

- (void) request;
@end
