//
//  PostDetailBadgeCell.h
//  ImIn
//
//  Created by park ja young on 11. 2. 23..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@class PostDelete;

/**
 @brief 뱃지 포함한 발도장 셀
 */
@interface PostDetailBadgeCell : UITableViewCell<ImInProtocolDelegate> {

	NSDictionary* postData;
	IBOutlet UIImageView* profileImg;
	IBOutlet UIImageView* postImg;
	IBOutlet UIButton* postImgBtn;
	
	IBOutlet UILabel* descLabel;
	IBOutlet UILabel* badgeMsgLabel;
	IBOutlet UITextView* badgeMsgTextView;
	IBOutlet UILabel* badgeNameLabel;
    IBOutlet UIButton* delBtn;
    IBOutlet UIImageView* brandMark;
	float cellHeight;
    
    PostDelete* postDelete;

}

@property (nonatomic, retain) IBOutlet UIImageView* profileImg;
@property (nonatomic, retain) IBOutlet UIImageView* postImg;
@property (nonatomic, retain) IBOutlet UILabel* badgeMsgLabel;
@property (nonatomic, retain) IBOutlet UITextView* badgeMsgTextView;
@property (nonatomic, retain) IBOutlet UILabel* descLabel;
@property (nonatomic, retain) IBOutlet UILabel* badgeNameLabel;
@property (nonatomic, retain) IBOutlet UIImageView* brandMark;
@property (nonatomic, retain) PostDelete* postDelete;

@property (nonatomic, retain) NSDictionary* postData;

- (IBAction) profileClicked:(id)sender;
- (IBAction) postImgClicked:(id)sender;
- (IBAction) deletePost:(id)sender;

- (void) redrawMainThreadCellWithCellData: (NSDictionary*) data;
- (void) refreshDescLabel;
- (float) getHeight;

@end
