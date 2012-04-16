//
//  AlbumBadgeCell.m
//  ImIn
//
//  Created by Myungjin Choi on 11. 2. 18..
//  Copyright 2011 KTH. All rights reserved.
//

#import "AlbumBadgeCell.h"
#import "BadgeImageView.h"


@implementation AlbumBadgeCell

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
		UILabel* badgeLabel = (UILabel*)[self viewWithTag:labelTag++];
		
		badgeImageView.hidden = NO;
		badgeLabel.hidden = NO;
		
		NSString* url = [aBadge objectForKey:@"imgUrl"];
		[badgeImageView setImage:[Utils imageWithURL:[Utils get84ImageFrom:url]]];
		badgeLabel.text = [aBadge objectForKey:@"badgeName"];
	}
	
	int remainCellCount = 3 - [badgeList count];
	for (int i=0; i < remainCellCount; i++) {
		BadgeImageView* badgeImageView = (BadgeImageView*)[self viewWithTag:imageViewTag++];
		UILabel* badgeLabel = (UILabel*)[self viewWithTag:labelTag++];

		badgeImageView.hidden = YES;
		badgeLabel.hidden = YES;
	}
}

@end
