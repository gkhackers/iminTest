//
//  ListBadgeCell.m
//  ImIn
//
//  Created by Myungjin Choi on 11. 2. 18..
//  Copyright 2011 KTH. All rights reserved.
//

#import "ListBadgeCell.h"
#import "BadgeImageView.h"

@implementation ListBadgeCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code.
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state.
}


- (void)dealloc {
    [super dealloc];
}

- (void) populateWithDictionary:(NSDictionary*) aBadge {
	NSAssert(aBadge != nil, @"뱃지 정보는 넘어와야 함");

	BOOL hasBadge = [[aBadge objectForKey:@"isBadge"] boolValue];
	NSString* url = [aBadge objectForKey:@"imgUrl"];

	if ([[aBadge objectForKey:@"badgeId"] isEqualToString:[aBadge objectForKey:@"parentBadgeId"]]) {
		if (hasBadge) {
			[badgeImage setImage:[Utils getImageFromBaseUrl:url withSize:@"84x84" withType:@"f"]];
		} else {
			[badgeImage setImage:[Utils getImageFromBaseUrl:url withSize:@"84x84" withType:@"n"]];
		}
		badgeImage.frame = CGRectMake(6, 9, 84, 84);
	} else {
		if (hasBadge) {
			[badgeImage setImage:[Utils getImageFromBaseUrl:url withSize:@"84x84" withType:@"f"]];
		} else {
			[badgeImage setImage:[Utils getImageFromBaseUrl:url withSize:@"84x84" withType:@"n"]];
		}
		badgeImage.frame = CGRectMake(6, 9, 84, 84);
	}

	badgeImage.badgeData = aBadge;
	
	badgeName.text = [aBadge objectForKey:@"badgeName"];
	badgeLevel.text = [aBadge objectForKey:@"badgeLevel"];
	badgeGuide.text = [aBadge objectForKey:@"badgeGuideMsg"];
	badgeOwner.text = [NSString stringWithFormat:@"이 뱃지를 가진 사람 %d명", [[aBadge objectForKey:@"userCnt"] intValue]];
}

@end
