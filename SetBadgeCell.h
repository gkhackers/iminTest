//
//  SetBadgeCell.h
//  ImIn
//
//  Created by Myungjin Choi on 11. 2. 18..
//  Copyright 2011 KTH. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 @brief 앨범형 뱃지 개체
 */
@interface SetBadgeCell : UITableViewCell {
	IBOutlet UILabel* titleLabel;
	IBOutlet UIImageView* bgImage;
}
- (void) populateWithArray:(NSArray*) badgeList;
@end
