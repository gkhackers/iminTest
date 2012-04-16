//
//  PhoneInvitationTableCell.m
//  ImIn
//
//  Created by edbear on 10. 12. 7..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PhoneInvitationTableCell.h"


@implementation PhoneInvitationTableCell

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


@end
