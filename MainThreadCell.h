//
//  MainThreadCell.h
//  ImIn
//
//  Created by choipd on 10. 4. 19..
//  Copyright 2010 edbear. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HttpConnect.h"

@class HomeInfo;
/**
 @brief 메인 스레드 테이블의 셀 디자인
 */
@interface MainThreadCell : UITableViewCell <ImInProtocolDelegate> {
	IBOutlet UILabel* nickName;
	IBOutlet UIImageView* profileImg;
	IBOutlet UIImageView* iconIn;
	IBOutlet UIImageView* iconLock;
	IBOutlet UILabel* post;
	IBOutlet UIImageView* postImg;
	IBOutlet UILabel* cmtCntLabel;
	IBOutlet UILabel* poiName;
	IBOutlet UILabel* description;
	IBOutlet UIButton* postImgBtn;
	IBOutlet UIView* selectedBgView;
	IBOutlet UIImageView* eventIcon;
    IBOutlet UIImageView* seperatorLine;
    IBOutlet UIImageView* brandMark;
	NSString* snsID;
	NSString* imageUrlStr;
	
	BOOL isEvent;
	BOOL isToMeNeighbor;
	BOOL isNeighbor;
    BOOL isPoiDetailVC;
    BOOL isOwner;
	NSString* curPosition;
	BOOL isFriend;
    float cellHeight;
    
    BOOL isBrandProfile;
	
	NSDictionary* cellData;
	
	HttpConnect* connect;
    HomeInfo* homeInfo;
    
}

@property (nonatomic, retain) NSDictionary* cellData;
@property (readwrite) BOOL isToMeNeighbor;
@property (readwrite) BOOL isNeighbor;
@property (readwrite) BOOL isPoiDetailVC;
@property (readwrite) BOOL isOwner;
@property (nonatomic, retain) NSString* curPosition;
@property (nonatomic) float cellHeight;
@property (nonatomic, retain) HomeInfo* homeInfo;

- (void) redrawMainThreadCellWithCellData: (NSDictionary*) myCellData;
- (void) drawSeperatorLine: (float) currPosition;
- (IBAction)profileClicked:(id)sender;
- (IBAction)postImageClicked:(id)sender;
+ (CGSize) requiredLabelSize:(NSDictionary*) cellData withType:(BOOL) isNeighbor;
+ (NSString*) getDescriptionWithDictionary:(NSDictionary*) data;
+ (NSString*) getPostWithDictionary:(NSDictionary*) data;
+ (NSString*) removeCRLFWithString:(NSString*) srcString;
@end
