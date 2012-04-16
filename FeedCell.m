//
//  FeedCell.m
//  ImIn
//
//  Created by edbear on 10. 9. 9..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FeedCell.h"
#import <QuartzCore/QuartzCore.h>
#import "macro.h"

@implementation FeedCell
@synthesize feedTypeIcon, feedContent, aNewIcon;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        // Initialization code
    }
    return self;
}

/**
 @brief 셀 선택 시 highlight color 설정
 */
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
	UIView* bgView = [[UIView alloc] initWithFrame:self.frame];
	CAGradientLayer *gradient = [CAGradientLayer layer];
	gradient.frame = bgView.bounds;
	gradient.colors = [NSArray arrayWithObjects:(id)[RGB(214, 241, 248) CGColor], (id)[RGB(178, 229, 241) CGColor], nil];
	[bgView.layer insertSublayer:gradient atIndex:0];
	self.selectedBackgroundView = bgView;
	[bgView release];
}

- (void)dealloc {
    [feedContent release];
    [feedTypeIcon release];
    [aNewIcon release];
    
    [super dealloc];
}


@end
