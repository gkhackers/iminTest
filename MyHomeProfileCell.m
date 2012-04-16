//
//  MyHomeProfileCell.m
//  ImIn
//
//  Created by oh-sang Kwon, on 12. 3. 28..
//  Copyright (c) 2012년 __MyCompanyName__. All rights reserved.
//

#import "MyHomeProfileCell.h"

@implementation MyHomeProfileCell

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


- (IBAction)fold:(id)sender{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"myHomeProfileFold" object:self userInfo:nil];
}
@end
