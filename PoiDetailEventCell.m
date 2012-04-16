//
//  PoiDetailEventCell.m
//  ImIn
//
//  Created by ja young park on 11. 10. 25..
//  Copyright 2011년 __MyCompanyName__. All rights reserved.
//

#import "PoiDetailEventCell.h"

@implementation PoiDetailEventCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [super setHighlighted:highlighted animated:animated];
    
    if(highlighted) {
        [eventBg setImage:[UIImage imageNamed:@"newpoi_eventbox_on.png"]];
    } else {
        [eventBg setImage:[UIImage imageNamed:@"newpoi_eventbox.png"]];
    }
}

- (void)dealloc {
    
    [super dealloc];
}

- (void) redrawCellWithCellData: (NSDictionary *) cellData {
    eventLabel.text = [cellData objectForKey:@"eventCopy"];
}

@end
