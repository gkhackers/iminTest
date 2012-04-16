//
//  FeedViewController.m
//  ImIn
//
//  Created by park ja young on 11. 2. 8..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "UIFeedViewController.h"
#import "FeedListTableViewController.h"
#import "UITabBarItem+WithImage.h"
#import "ViewControllers.h"

@implementation UIFeedViewController
@synthesize feedTVC;

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
		self.title = @"새소식";
		[self.tabBarItem resetWithNormalImage:[UIImage imageNamed:@"GNB_04_off.png"] 
								selectedImage:[UIImage imageNamed:@"GNB_04_on.png"]];
    }
    return self;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	[self.navigationController setNavigationBarHidden:YES animated:NO];
	feedTVC = [[FeedListTableViewController alloc] init];
	feedTVC.tableView.frame = CGRectMake(0, 0, 320, 368);
	[feedListView addSubview:feedTVC.view];
}

- (void)viewWillAppear:(BOOL)animated {
	//BOOL isNew = [[TFeedList findWithSql:@"select * from TFeedList where read = 0 and hasDeleted = 0"] count] > 0;
		
    // 쿠키 정보를 요청한다. (없을 경우에만)
    [[UserContext sharedUserContext] requestSnsCookie];
    
	[feedTVC viewWillAppear:YES];
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

- (void) viewDidDisappear:(BOOL)animated {
	[feedTVC viewDidDisappear:animated];
}

- (void)dealloc {
	[feedTVC release];
    [super dealloc];
}

- (IBAction) deleteAllFeed {
    // by mandolin(2012.03.20) : 새소식이 없을때에 전체삭제를 눌렀을때 문구 추가
    if (feedTVC.feedList.count == 0)
    {
        UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"알림" message:@"삭제할 새소식이 없습니다."
                                                        delegate:self cancelButtonTitle:@"확인" otherButtonTitles:nil] autorelease];
        [alert show];
        return;
    }
	UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"알림" message:@"정말로 모든 새소식을 지우실래요?"
													delegate:self cancelButtonTitle:@"취소" otherButtonTitles:@"확인", nil] autorelease];
	alert.tag = 100;
	[alert show];
}

- (void)alertView:(UIAlertView*)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (alertView.tag == 100)
	{
		if (buttonIndex == 1)
		{
			[feedTVC deleteAllFeed];
		}
		return;
	}
}

@end
