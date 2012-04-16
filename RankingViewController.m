//
//  RankingViewController.m
//  ImIn
//
//  Created by edbear on 10. 9. 2..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "RankingViewController.h"
#import "UIImageView+WebCache.h"
#import "UIHomeViewController.h"
#import "UIMasterWriteController.h"
#import "CommonWebViewController.h"

@implementation RankingViewController

@synthesize masterList, mastersComment, userPoint, isMaster, isMyStatus, poiNameString;
@synthesize masterViews, graphs, profileImages, nickNames, points;
@synthesize commonWebVC, poiKey;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}

- (void) viewWillAppear:(BOOL)animated
{	
	NSString* rankingUrl = [NSString stringWithFormat:@"%@/mobile/master.kth?snsId=%@&poiKey=%@&wvVer=1d00", RANKING_URL, [UserContext sharedUserContext].snsID, poiKey];
	commonWebVC = [[CommonWebViewController alloc] initWithNibName:@"CommonWebViewController" bundle:nil];
	
	MY_LOG(@"send value = %@", rankingUrl);
	commonWebVC.urlString = rankingUrl;
	commonWebVC.viewType = SUBVIEW_WEB;
	[contentsView addSubview:commonWebVC.view];
	
	poiName.text = [NSString stringWithFormat:@"%@의 랭킹", poiNameString];
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
	[commonWebVC release];
	[mastersComment release];
	
	[masterViews release];
	[graphs release];
	[profileImages release];
	[nickNames release];
	[points release];
	[poiKey release];
	
    [super dealloc];
}

- (IBAction) popVC {
	[self.navigationController popViewControllerAnimated:YES];
}

- (IBAction) openProfile:(UIButton*) sender
{
	int masterIndex = sender.tag - 600;
	if (masterIndex > [masterList count]) return;
	
	
	NSDictionary* masterInfo = [masterList objectAtIndex:masterIndex];
	
	UIHomeViewController *vc = [[UIHomeViewController alloc] initWithNibName:@"UIHomeViewController" bundle:nil];
	
	MemberInfo* owner = [[[MemberInfo alloc] init] autorelease];
	owner.snsId = [masterInfo objectForKey:@"snsId"];
	owner.nickname = [masterInfo objectForKey:@"nickname"];
	owner.profileImgUrl = [masterInfo objectForKey:@"profileImg"];
	
	vc.owner = owner;
	
	[(UINavigationController*)[ViewControllers sharedViewControllers].tabBarController.selectedViewController pushViewController:vc animated:YES];
	[vc release];
}

- (IBAction) openMasterWord
{
	UIMasterWriteController* mw = [[UIMasterWriteController alloc] initWithNibName:@"UIMasterWriteController" bundle:nil];
	mw.poiKey = [[masterList objectAtIndex:0] objectForKey:@"poiKey"];
	mw.stringWillChangeWithNewTitle = self.mastersComment;
	
	UINavigationController *navController = [[[UINavigationController alloc] initWithRootViewController:mw] autorelease];
	[navController setNavigationBarHidden:YES];
	[self presentModalViewController:navController animated:YES];
	
	[mw release];	
}

@end
