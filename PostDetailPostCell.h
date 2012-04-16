//
//  PostDetailPostCell.h
//  ImIn
//
//  Created by choipd on 10. 4. 28..
//  Copyright 2010 edbear. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HttpConnect.h"
#import "ImInProtocol.h"

@class ScrapDelete, ScrapInsert;

/**
 @brief 글상세보기에서 글영역 셀 디자인
 */
@interface PostDetailPostCell : UITableViewCell <ImInProtocolDelegate> {
	
	NSMutableDictionary* postData;
	
	IBOutlet UIImageView* profileImg;
	IBOutlet UILabel* postLabel;
	IBOutlet UITextView* postTextView;
	IBOutlet UIImageView* postImg;
	IBOutlet UIButton* postImgBtn;
	IBOutlet UILabel* descLabel;
	IBOutlet UIButton* openPOIBtn;
	IBOutlet UILabel* poiNameLabel;
	IBOutlet UIButton* delBtn;
	IBOutlet UIButton* reportBtn;
	IBOutlet UIImageView* eventIcon;
    IBOutlet UIImageView* brandMark;
	
    IBOutlet UIView *extBtnArea;
    
	IBOutlet UIView* bottomView;
    IBOutlet UIButton *scrapBtn;
	float cellHeight;
	BOOL selectedLike;
    IBOutlet UILabel *likeButtonStr;
    IBOutlet UIView *likerImagesArea;
    
	HttpConnect* connect;
    
    ScrapDelete* scrapDelete;
    ScrapInsert* scrapInsert;
}

@property (nonatomic, retain) NSMutableDictionary* postData;
@property (nonatomic, retain) ScrapDelete* scrapDelete;
@property (nonatomic, retain) ScrapInsert* scrapInsert;

- (IBAction) profileClicked:(id)sender;
- (IBAction) postImgClicked:(id)sender;
- (IBAction) openPOIBtnClicked:(id)sender;
- (IBAction) delBtnClicked:(id)sender;
- (IBAction) reportBtnClicked:(id)sender;
- (IBAction)toggleScrap:(UIButton*)sender;

- (void) redrawMainThreadCellWithCellData: (NSDictionary*) data;
- (void) request;
- (float) getHeight;

@end
