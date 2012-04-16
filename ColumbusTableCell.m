//
//  ColumbusTableCell.m
//  ImIn
//
//  Created by 태한 김 on 10. 5. 17..
//  Copyright 2010 kth. All rights reserved.
//

#import "ColumbusTableCell.h"
#import "macro.h"
#import <QuartzCore/QuartzCore.h>

@implementation ColumbusTableCell

@synthesize poiName;
@synthesize description;
@synthesize redFlag;


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        // Initialization code
		//	self.contentView.backgroundColor = [UIColor colorWithRed:237/255.0 green:249/255.0 blue:252/255.0 alpha:1];
		poiName = [[UILabel alloc]initWithFrame:CGRectMake(15, 14, 260, 17)];
		[poiName setFont:[UIFont systemFontOfSize:16.0f]];
		[poiName setTextColor:RGB(1,0x81,0xb0)];
		[poiName setBackgroundColor:[UIColor clearColor]];
		poiName.lineBreakMode = UILineBreakModeTailTruncation;
		
		description = [[UILabel alloc]initWithFrame:CGRectMake(15, 35, 280, 13)];
		[description setFont:[UIFont fontWithName:@"Helvetica" size:11.0]];
		[description setTextColor:[UIColor darkGrayColor]];
		[description setBackgroundColor:[UIColor clearColor]];
		
		redFlag = [[UIImageView alloc] initWithFrame:CGRectMake(40, 14, 12, 14)];
		[redFlag setImage:[UIImage imageNamed:@"col_flag.png"]];
		
		
		[self.contentView addSubview:poiName];
		[self.contentView addSubview:description];
		[self.contentView addSubview:redFlag];		
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
	[poiName release];
	[description release];
    [super dealloc];
}

@end
