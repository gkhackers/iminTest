//
//  ListBadgeCell.h
//  ImIn
//
//  Created by Myungjin Choi on 11. 2. 18..
//  Copyright 2011 KTH. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BadgeImageView;

/**
 @brief 리스트형 뱃지
 */
@interface ListBadgeCell : UITableViewCell {

	IBOutlet BadgeImageView*	badgeImage;
	IBOutlet UILabel*		badgeName;
	IBOutlet UILabel*		badgeLevel;
	IBOutlet UILabel*		badgeGuide;
	IBOutlet UILabel*		badgeOwner;

}

- (void) populateWithDictionary:(NSDictionary*) badgeCellData;

@end
