//
//  MasterCell.m
//  ImIn
//
//  Created by ja young park on 11. 10. 25..
//  Copyright 2011년 __MyCompanyName__. All rights reserved.
//

#import "MasterCell.h"
#import "UIImageView+WebCache.h"
#import "RankingViewController.h"
#import "UIHomeViewController.h"
#import "BrandHomeViewController.h"
#import <QuartzCore/QuartzCore.h>

@implementation MasterCell

@synthesize masterInfo, masterList, poiData, curPosition;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
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

- (IBAction)rankingClick {

    if ([[poiData objectForKey:@"isEvent"] isEqualToString:@"1"]) {
        GA3(@"이벤트POI", @"랭킹버튼", @"이벤트POI내");
   } else {
        GA3(@"POI", @"랭킹버튼", @"POI내");
   }

    RankingViewController* vc = [[RankingViewController alloc] initWithNibName:@"RankingViewController" bundle:nil];
    vc.masterList = self.masterList;
    if ([masterList count] > 0) {
        vc.mastersComment = [[masterList objectAtIndex:0] objectForKey:@"msg"];
        vc.userPoint = [[masterList objectAtIndex:0] objectForKey:@"myPoint"]; 
        vc.isMyStatus = [[[masterList objectAtIndex:0] objectForKey:@"isMyStatus"] intValue];
    }
    vc.poiNameString = [poiData objectForKey:@"poiName"];
    vc.poiKey = [poiData objectForKey:@"poiKey"];

    
    [(UINavigationController*)[ViewControllers sharedViewControllers].tabBarController.selectedViewController pushViewController:vc animated:YES];
    [vc release];
}

//- (IBAction)masterClick {    
//    GA3(@"POI", @"콜럼버스영역", nil);
//
//    if ([masterList count] <= 0) {
//        return;
//    }
//    
//    MemberInfo* owner = [[[MemberInfo alloc] init] autorelease];
//
//    owner.snsId = [[masterList objectAtIndex:0] objectForKey:@"snsId"];
//    owner.nickname = [[masterList objectAtIndex:0] objectForKey:@"nickname"]; 
//    owner.profileImgUrl = [[masterList objectAtIndex:0] objectForKey:@"profileImg"];
//    
//    NSDictionary* masterData = [masterList objectAtIndex:0];
//    
//    if ([Utils isBrandUser:masterData]) { //브랜드면
//        BrandHomeViewController* vc = [[[BrandHomeViewController alloc] initWithNibName:@"BrandHomeViewController" bundle:nil] autorelease];
//        vc.owner = owner;
//        [(UINavigationController*)[ViewControllers sharedViewControllers].tabBarController.selectedViewController pushViewController:vc animated:YES];        
//        
//    } else {
//        UIHomeViewController *vc = [[[UIHomeViewController alloc] initWithNibName:@"UIHomeViewController" bundle:nil] autorelease];
//        vc.owner = owner;
//        [(UINavigationController*)[ViewControllers sharedViewControllers].tabBarController.selectedViewController pushViewController:vc animated:YES];        
//    }
//}

- (void) redrawCellWithCellData: (NSDictionary *) cellData : (NSDictionary *) poiInfo {
    self.masterInfo = cellData;
    self.poiData = poiInfo;
    
    NSArray* resultList = [masterInfo objectForKey:@"data"];
    self.masterList = [NSMutableArray arrayWithArray:resultList];
    if ([resultList count] > 0) {
        NSDictionary* data = [resultList objectAtIndex:0];
        nickname.text = [data objectForKey:@"nickname"];
        [profileImg setImageWithURL:[NSURL URLWithString:[data objectForKey:@"profileImg"]] placeholderImage:[UIImage imageNamed:@"delay_nosum70.png"]];
    } else {
        nickname.text = @"마스터에 도전해 보세요~";
        [profileImg setImage:[UIImage imageNamed:@"non_master_sum.png"]];
    }
}

- (void)dealloc {
    [masterInfo release];
    [masterList release];
    [poiData release];

    [super dealloc];
}

@end
