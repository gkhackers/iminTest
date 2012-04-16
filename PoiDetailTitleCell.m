//
//  PoiDetailTitleCell.m
//  ImIn
//
//  Created by ja young park on 11. 10. 25..
//  Copyright 2011년 __MyCompanyName__. All rights reserved.
//

#import "PoiDetailTitleCell.h"
#import "UIImageView+WebCache.h"
#import "BrandHomeViewController.h"
#import <QuartzCore/QuartzCore.h>
//#import "PoiInfoViewController.h"

@implementation PoiDetailTitleCell

@synthesize poiData;
@synthesize poiUserData;
@synthesize isLoadFinish;

#define BRAND_LOGO_FRAME CGRectMake(13, 18, 47, 47)
#define LOGO_FRAME CGRectMake(12, 14, 47, 47)

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        brandProfileBtn.hidden = YES;
        brandMarkImg.hidden = YES;
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

    // Configure the view for the selected state
}

- (void) dealloc 
{
    [categoryImg release];
    [brandMarkImg release];
    [poiName release];
    [poiAddress release];
    [poiData release];
    [poiUserData release];
    
    [super dealloc];
}

- (void) redrawCellWithCellData: (NSDictionary *) cellData : (NSDictionary*) poiUser {
    self.poiData = cellData;
    self.poiUserData = poiUser;
    
    poiName.text = [cellData objectForKey:@"poiName"];
    
    NSMutableString* addr = [[NSMutableString alloc] init];
    NSString* key = nil;
    for (int i = 1; i < 4; i++) {
        key = [NSString stringWithFormat:@"addr%d", i];
        NSString* addrString = [cellData objectForKey:key];
        if (i == 3) {
            NSRange spacePos = [[cellData objectForKey:key] rangeOfString:@" "];
            if (spacePos.location != NSNotFound) {
                addrString = [[cellData objectForKey:key] substringToIndex:spacePos.location];
            }
        }
        if (addrString != nil) {
            [addr appendString:addrString];
            [addr appendString:@" "];
        }
    }    
    poiAddress.text = addr;
    [addr release];
    NSString* imgUrl = nil;
    if (isLoadFinish) {
        if (poiUser == nil) {
            if ([Utils isBrandUser:poiUserData]) { //브랜드면
                brandProfileBtn.hidden = NO;
                [brandMarkImg setImage:[UIImage imageNamed:@"brand_mark2.png"]];
                brandMarkImg.hidden = NO;
                categoryImg.frame = BRAND_LOGO_FRAME;
                
                [categoryImg setImageWithURL:[NSURL URLWithString:[cellData objectForKey:@"profileImg"]]
                            placeholderImage:[UIImage imageNamed:@"delay_nosum70.png"]];
            } else {
                MY_LOG(@"====> category img = %@", [cellData objectForKey:@"categoryImg"]);
                brandProfileBtn.hidden = YES;
                
                brandMarkImg.hidden = YES;
                
                imgUrl = [Utils convertImgSize70to47:[cellData objectForKey:@"categoryImg"]];
                [categoryImg setImageWithURL:[NSURL URLWithString:imgUrl]
                            placeholderImage:[UIImage imageNamed:@"9000000_38x38_2@2x.png"]];
            }
        } else {
            if ([Utils isBrandUser:poiUserData]) { //브랜드면
                brandProfileBtn.hidden = NO;
                [brandMarkImg setImage:[UIImage imageNamed:@"brand_mark2.png"]];
                brandMarkImg.hidden = NO;
                categoryImg.frame = BRAND_LOGO_FRAME;
                
                [categoryImg setImageWithURL:[NSURL URLWithString:[poiUser objectForKey:@"profileImg"]]
                            placeholderImage:[UIImage imageNamed:@"delay_nosum70.png"]];
            } else {
                MY_LOG(@"====> category img = %@", [cellData objectForKey:@"categoryImg"]);
                brandProfileBtn.hidden = YES;
                
                brandMarkImg.hidden = YES;
                
                imgUrl = [Utils convertImgSize70to47:[cellData objectForKey:@"categoryImg"]];
                [categoryImg setImageWithURL:[NSURL URLWithString:imgUrl]
                            placeholderImage:[UIImage imageNamed:@"9000000_38x38_2@2x.png"]];
            }
        }
    }  
}

- (IBAction)brandProfileClick { //브랜드의 경우 눌린다.
    if ([poiData objectForKey:@"isEvent"]) {
        GA3(@"이벤트POI", @"브랜드프로필사진", @"이벤트POI내");
    } else {
        GA3(@"POI", @"브랜드프로필사진", @"POI내");
    }

    //브랜드 홈으로 간다.
    BrandHomeViewController *vc = [[BrandHomeViewController alloc] initWithNibName:@"BrandHomeViewController" bundle:nil];
    MemberInfo *owner = [[[MemberInfo alloc] init] autorelease];
    owner.snsId = [poiUserData objectForKey:@"snsId"];
    owner.nickname = [poiUserData objectForKey:@"nickname"];
    owner.profileImgUrl = [poiUserData objectForKey:@"profileImg"];
    
    vc.owner = owner;
    
    [(UINavigationController*)[ViewControllers sharedViewControllers].tabBarController.selectedViewController pushViewController:vc animated:YES];
    [vc release];
}

@end
