//
//  BadgeDetailViewController.m
//  ImIn
//
//  Created by Myungjin Choi on 11. 2. 14..
//  Copyright 2011 KTH. All rights reserved.
//

#import "BadgeDetailViewController.h"
#import "BadgeDetailView.h"

@implementation BadgeDetailViewController
@synthesize badgeInfo;
@synthesize owner;

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

	MY_LOG(@"뱃지이름: %@", [badgeInfo objectForKey:@"badgeName"]);
	
	BadgeDetailView* blackPanel = [[[NSBundle mainBundle] loadNibNamed:@"BadgeDetailView" 
																 owner:self options:nil] lastObject];
	blackPanel.delegate = self;
	blackPanel.badgeData = badgeInfo;
	blackPanel.owner = owner;
	[blackPanel requestBadgeInfo];		
	
	[self.view addSubview:blackPanel];
	[blackPanel startOpeningAnimation];		
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
	[badgeInfo release];
	[owner release];
    [super dealloc];
}

- (void) closeVC {
	[self dismissModalViewControllerAnimated:YES];
}


@end
