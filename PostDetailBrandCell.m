//
//  PostDetailBrandCell.m
//  ImIn
//
//  Created by KYONGJIN SEO on 10/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PostDetailBrandCell.h"
#import "BrandHomeViewController.h"
#import "MemberInfo.h"

@implementation PostDetailBrandCell
@synthesize postContentLabel;
@synthesize owner;

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
- (IBAction)brandProfileBtnClicked:(id)sender {
    BrandHomeViewController *brandHomeVC = [[BrandHomeViewController alloc] initWithNibName:@"BrandHomeViewController" bundle:nil];
    brandHomeVC.owner = owner;
    [(UINavigationController*)[ViewControllers sharedViewControllers].tabBarController.selectedViewController pushViewController:brandHomeVC animated:YES];
    [brandHomeVC release];
}

- (void)dealloc {
    [postContentLabel release];
    [dateLabel release];
    [logoImageView release];
    [brandProfileBtn release];
    [super dealloc];
}
@end
