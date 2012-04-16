//
//  MasterViewCell.m
//  ImIn
//
//  Created by mandolin on 10. 9. 13..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "MasterViewCell.h"
#import <QuartzCore/QuartzCore.h>
#import "macro.h"

@implementation MasterViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        // Initialization code
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
	
    [super setSelected:selected animated:animated];
	UIView* bgView = [[UIView alloc] initWithFrame:self.frame];
	CAGradientLayer *gradient = [CAGradientLayer layer];
	gradient.frame = bgView.bounds;
	gradient.colors = [NSArray arrayWithObjects:(id)[RGB(214, 241, 248) CGColor], (id)[RGB(178, 229, 241) CGColor], nil];
	[bgView.layer insertSublayer:gradient atIndex:0];
	self.selectedBackgroundView = bgView;
	[bgView release];
    // Configure the view for the selected state
}


- (void)dealloc {
    [super dealloc];
}


@end
