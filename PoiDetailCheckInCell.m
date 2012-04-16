//
//  PoiDetailCheckInCell.m
//  ImIn
//
//  Created by ja young park on 11. 10. 25..
//  Copyright 2011년 __MyCompanyName__. All rights reserved.
//

#import "PoiDetailCheckInCell.h"
#import "PostComposeViewController.h"
@implementation PoiDetailCheckInCell

@synthesize poiData;

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

- (void) dealloc {
    [poiData release];
    
    [super dealloc];
}

- (void) redrawCellWithCellData: (NSDictionary *) cellData {
    self.poiData = cellData;
}

- (IBAction)checkInClick {
    GA1(@"여기에발도장찍기");
    if ([[poiData objectForKey:@"isEvent"] isEqualToString:@"1"]) {
        GA3(@"이벤트POI", @"여기에발도장찍기", @"이벤트POI내");
    } else {
        GA3(@"POI", @"여기에발도장찍기", @"POI내");
    }

    PostComposeViewController *vc = [[[PostComposeViewController alloc] initWithNibName:@"PostComposeViewController" bundle:nil] autorelease];
	vc.hidesBottomBarWhenPushed = YES;
	vc.poiData = poiData;
	
	UINavigationController *navController = [[[UINavigationController alloc] initWithRootViewController:vc] autorelease];
	[navController setNavigationBarHidden:YES] ;
    
    [[ApplicationContext sharedApplicationContext] presentVC:navController];
	
	//needToUpdate = YES;
}

@end
