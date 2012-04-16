//
//  BrandCell.m
//  ImIn
//
//  Created by KYONGJIN SEO on 9/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "BrandCell.h"
#import "UIImageView+WebCache.h"
#import "UIHomeViewController.h"
#import "BrandHomeViewController.h"
#import <QuartzCore/QuartzCore.h>

@implementation BrandCell

@synthesize cellData;
@synthesize brandLabel;
@synthesize brandName;
@synthesize logoImage;
@synthesize arrow;
@synthesize snsId;
@synthesize nickname;

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
	UIView* bgView = [[[UIView alloc] initWithFrame:self.frame] autorelease];
	CAGradientLayer *gradient = [CAGradientLayer layer];
	gradient.frame = bgView.bounds;
	gradient.colors = [NSArray arrayWithObjects:(id)[RGB(214, 241, 248) CGColor], (id)[RGB(178, 229, 241) CGColor], nil];
	[bgView.layer insertSublayer:gradient atIndex:0];
	self.selectedBackgroundView = bgView;

//    if (selected) {
//        [self moveToBrandHome];
//    }
   
}

- (void) redrawCellWithCellData: (NSDictionary *) brandCellData
{
    //set data of brand cell
    if ([brandCellData count] > 0) {
        self.cellData = brandCellData;
        
        self.brandName.text = [brandCellData objectForKey:@"bizNickname"];

        self.nickname = [brandCellData objectForKey:@"nickname"];
        self.snsId = [brandCellData objectForKey:@"snsId"];
        [self.logoImage setImageWithURL:[NSURL URLWithString:[brandCellData objectForKey:@"profileImg"]] placeholderImage:nil];
        isBrand = YES;
    } else {
        isBrand = NO;
    }
}

- (IBAction)clickBrandCell 
{
    if (isBrand) {
		MY_LOG(@"브랜드 영역 클릭 => %@,", self.snsId);
		
		GA3(@"POI", @"브랜드영역", nil);
        
		BrandHomeViewController *vc = [[BrandHomeViewController alloc] initWithNibName:@"BrandHomeViewController" bundle:nil];
        MemberInfo *owner = [[[MemberInfo alloc] init] autorelease];
        owner.snsId = snsId;
        owner.nickname = nickname;
        owner.profileImgUrl = [cellData objectForKey:@"profileImg"];
        
        vc.owner = owner;
        
		[(UINavigationController*)[ViewControllers sharedViewControllers].tabBarController.selectedViewController pushViewController:vc animated:YES];
		[vc release];
	}
	else {
		MY_LOG (@"brand data is nil");
	}
}

- (void)moveToBrandHome 
{
    // when press the cell, push to brand home view controller
    // go webviewcontroller
    // key=value&
    
    if (isBrand) {
		MY_LOG(@"브랜드 영역 클릭 => %@,", self.snsId);
		
		GA3(@"POI", @"브랜드영역", nil);
        
		BrandHomeViewController *vc = [[BrandHomeViewController alloc] initWithNibName:@"BrandHomeViewController" bundle:nil];
        MemberInfo *owner = [[[MemberInfo alloc] init] autorelease];
        owner.snsId = snsId;
        owner.nickname = nickname;
        owner.profileImgUrl = [cellData objectForKey:@"profileImg"];
        
        vc.owner = owner;
        	
		[(UINavigationController*)[ViewControllers sharedViewControllers].tabBarController.selectedViewController pushViewController:vc animated:YES];
		[vc release];
	}
	else {
		MY_LOG (@"brand data is nil");
	}
    
}

- (void)dealloc {

    [brandLabel release];
    [brandName release];
    [arrow release];
    [super dealloc];
}
@end
