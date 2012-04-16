//
//  AdminRecomViewController.m
//  ImIn
//
//  Created by Myungjin Choi on 11. 1. 18..
//  Copyright 2011 KTH. All rights reserved.
//

#import "AdminRecomViewController.h"
#import "AdminRecomList.h"
#import "HomeInfo.h"
#import "UIImageView+WebCache.h"
//#import "MyFriendSetController.h"
#import "FriendSetViewController.h"
#import "ImInAppDelegate.h"
#import "UINeighborsViewController.h"

@implementation AdminRecomViewController

enum RECOM_VIEW {
	RECOM_VIEW_1 = 1000,
	RECOM_VIEW_2,
	RECOM_VIEW_3
};

enum RECOM_INSIDE_VIEW {
	RECOM_INSIDE_VIEW_PROFILE = 100,
	RECOM_INSIDE_VIEW_NICKNAME,
	RECOM_INSIDE_VIEW_NEIGHBORCNT,
	RECOM_INSIDE_VIEW_POICNT,
	RECOM_INSIDE_VIEW_NEIGHBORADDBTN
};


@synthesize profileImageURL, nickname, neigborCnt, poiCnt, snsId;
@synthesize adminRecomList, homeInfo;
@synthesize resultData;
// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    return self;
}
*/

- (void)viewDidLoad {
    [super viewDidLoad];
	[self.navigationController setNavigationBarHidden:YES animated:NO];	
	
	NSNotificationCenter* dnc = [NSNotificationCenter defaultCenter];
	[dnc addObserver:self selector:@selector(friendSettingChanged:) name:@"FriendSetSaved" object:savedData];

	self.adminRecomList = [[[AdminRecomList alloc] init] autorelease];
	adminRecomList.delegate = self;
	
	[adminRecomList request];
}

- (void) viewWillAppear:(BOOL)animated
{

}


- (void) apiDidLoad: (NSDictionary*) result
{
	if ([[result objectForKey:@"func"] isEqualToString:@"adminRecomList"]) {
		NSInteger viewTag = 1000;
		NSArray* dataList = [result objectForKey:@"data"];
		self.resultData = dataList;
		for (NSDictionary *data in dataList) 
		{
			UIView* aView = [self.view viewWithTag:viewTag++];
			
			UIImageView* profileImg = (UIImageView*)[aView viewWithTag:RECOM_INSIDE_VIEW_PROFILE];
			NSString* profileUrl = [data objectForKey:@"profileImg"];
			[profileImg setImageWithURL:[NSURL URLWithString:profileUrl]
							 placeholderImage:[UIImage imageNamed:@"delay_nosum70.png"]];
			
			UILabel* nickName = (UILabel*)[aView viewWithTag:RECOM_INSIDE_VIEW_NICKNAME];
			nickName.text = [data objectForKey:@"nickname"];
			
			UILabel* neigborCount = (UILabel*)[aView viewWithTag:RECOM_INSIDE_VIEW_NEIGHBORCNT];
			neigborCount.text = [NSString stringWithFormat:@"이웃 %@", [data objectForKey:@"totalNeighborCnt"]];
			
			UILabel* poiCount = (UILabel*)[aView viewWithTag:RECOM_INSIDE_VIEW_POICNT];
			poiCount.text = [NSString stringWithFormat:@"발도장 %@", [data objectForKey:@"totalPoiCnt"]];		
		}
	}
	
	if ([[result objectForKey:@"func"] isEqualToString:@"homeInfo"]) {
		
		NSString *whoIs = [result objectForKey:@"isPerm"];
		NSString* profileUrl = [result objectForKey:@"profileImg"];
		// 서로 이웃인지 여부를 확인해서 표시한다.
		if( [whoIs isEqualToString:@"FRIEND"] ){
			friendCodeInt = FR_TRUE;
		}else if( [whoIs isEqualToString:@"NEIGHBOR_YOU"] ){  // 당신이 그를 친구로 등록했다.
			friendCodeInt = FR_ME;
		}else if( [whoIs isEqualToString:@"NEIGHBOR_ME"] ){
			friendCodeInt = FR_YOU;
		}else{
			friendCodeInt = FR_NONE;
		}
				
		FriendSetViewController *friendSetViewController = [[FriendSetViewController alloc] initWithName:self.nickname 
																							 friendSnsId:self.snsId 
																							  friendCode:friendCodeInt 
																							 friendImage:profileUrl];
		friendSetViewController.referCode = @"0002";
		[friendSetViewController setHidesBottomBarWhenPushed:YES];
		[self.navigationController pushViewController:friendSetViewController animated:YES];
		[friendSetViewController release];
	}

	
}

- (void) friendSettingChanged:(NSNotification*) noti
{
	MY_LOG(@"노티왔다");
	NSDictionary* saveResult = [noti userInfo];
	MY_LOG(@"bool: %@ snsid: %@", [saveResult objectForKey:@"isFollowing"], [saveResult objectForKey:@"snsId"]);
	
	for (int i=0; i < 3; i++) {
		NSDictionary* data = [resultData objectAtIndex:i];
		if ([[data objectForKey:@"snsId"] isEqualToString:[saveResult objectForKey:@"snsId"]]) {

			UIButton* aButton;
			switch (i % 3) {
				case 0:
					aButton = firstNeigborAdd;
					break;
				case 1:
					aButton = secondNeigborAdd;
					break;
				case 2:
					aButton = thirdNeigborAdd;
					break;
				default:
					break;
			}
			
			if ([[saveResult objectForKey:@"isFollowing"] boolValue]) {
				[aButton setImage:[UIImage imageNamed:@"friend_friend_admin.png"] forState:UIControlStateNormal];
			} else {
				[aButton setImage:[UIImage imageNamed:@"friend_friend_admin.png"] forState:UIControlStateNormal];
			}
		}
	}
}

- (void) apiFailed {
	MY_LOG(@"API 에러");
}


- (IBAction) pushFriendSetting:(UIButton*) sender
{
	GA3(@"이런이웃", @"이웃추가버튼", @"이런이웃내");
	NSDictionary* data = [resultData objectAtIndex: sender.tag - 10];
	self.snsId = [data objectForKey:@"snsId"];
	self.nickname = [data objectForKey:@"nickname"];
	
	self.homeInfo = [[[HomeInfo alloc] init] autorelease];
	homeInfo.delegate = self;
	homeInfo.snsId = snsId;
	[homeInfo request];
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}




- (void)dealloc {
	NSNotificationCenter* dnc = [NSNotificationCenter defaultCenter];
	[dnc removeObserver:self name:@"FriendSetSaved" object:savedData];

	[profileImageURL release];
	[snsId release];
	[nickname release];
	[neigborCnt release];
	[poiCnt release];

	[adminRecomList release];
	[homeInfo release];
	[resultData release];
    [super dealloc];
}

-(IBAction) closeVC
{
	GA3(@"이런이웃", @"건너뛰기", nil);
	[self dismissModalViewControllerAnimated:YES];
}

- (IBAction) goNeighbor
{
	GA3(@"이런이웃", @"더많은이웃만들기", nil);
	[ViewControllers sharedViewControllers].tabBarController.selectedIndex = 1;
	UINeighborsViewController* neighborVC = (UINeighborsViewController*)([ViewControllers sharedViewControllers].neighbersViewController);
	neighborVC.selectedSegInt = 2;
	[self dismissModalViewControllerAnimated:YES];
}

@end
