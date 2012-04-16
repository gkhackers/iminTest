//
//  BlockSettingCell.h
//  ImIn
//
//  Created by Myungjin Choi on 11. 4. 21..
//  Copyright 2011 KTH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImInProtocol.h"

@class DenyGuestDelete;

/**
 @brief 차단 설정
 */
@interface BlockSettingCell : UITableViewCell<ImInProtocolDelegate> {
	IBOutlet UILabel* nickname;
	IBOutlet UIImageView* profileImageView;
	IBOutlet UIButton* unblockBtn;
	
	DenyGuestDelete* denyGuestDelete;
	
	NSDictionary* denyGuest;
}

@property (nonatomic, retain) DenyGuestDelete* denyGuestDelete;
@property (nonatomic, retain) NSDictionary* denyGuest;

- (IBAction) unblock:(UIButton*) sender;
- (void) populateCellWithDictionary:(NSDictionary*)data;
@end
