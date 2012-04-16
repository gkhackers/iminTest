//
//  SetBadgeCell.m
//  ImIn
//
//  Created by Myungjin Choi on 11. 2. 18..
//  Copyright 2011 KTH. All rights reserved.
//

#import "SetBadgeCell.h"
#import "BadgeImageView.h"

@implementation SetBadgeCell

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

- (void) populateWithArray:(NSArray*) badgeList {
	int imageViewTag = 100;
	int labelTag = 200;
	for (NSDictionary* aBadge in badgeList) {
		BadgeImageView* badgeImageView = (BadgeImageView*)[self viewWithTag:imageViewTag++];
		badgeImageView.badgeData = aBadge;
		
		BOOL hasBadge = [[aBadge objectForKey:@"isBadge"] boolValue];

		
		UILabel* badgeLabel = (UILabel*)[self viewWithTag:labelTag++];
		
		NSString* url = [aBadge objectForKey:@"imgUrl"];
		if (aBadge == [badgeList lastObject]) {
			if (hasBadge) {
				[badgeImageView setImage:[Utils getImageFromBaseUrl:url withSize:@"168x168" withType:@"f"]];
			} else {
				[badgeImageView setImage:[Utils getImageFromBaseUrl:url withSize:@"168x168" withType:@"n"]];
			}
			[bgImage setImage:[Utils getImageFromBaseUrl:url withSize:@"iph" withType:@"bg"]];
		} else {
			if (hasBadge) {
				[badgeImageView setImage:[Utils getImageFromBaseUrl:url withSize:@"84x84" withType:@"f"]];
			} else {
				[badgeImageView setImage:[Utils getImageFromBaseUrl:url withSize:@"84x84" withType:@"n"]];
			}			
		}

		badgeLabel.text = [aBadge objectForKey:@"badgeName"];
		badgeLabel.hidden = YES;
	}
	
	titleLabel.text = [[badgeList lastObject] objectForKey:@"badgeName"];
	titleLabel.hidden = YES;
}

@end
