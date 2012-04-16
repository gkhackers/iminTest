//
//  NetworkTimeoutMessageCell.m
//  ImIn
//
//  Created by Myungjin Choi on 11. 1. 25..
//  Copyright 2011 KTH. All rights reserved.
//

#import "NetworkTimeoutMessageCell.h"


@implementation NetworkTimeoutMessageCell

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
