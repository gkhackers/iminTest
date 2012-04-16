//
//  BadgeAcquisitionViewController.m
//  ImIn
//
//  Created by Myungjin Choi on 11. 2. 14..
//  Copyright 2011 KTH. All rights reserved.
//

#import "BadgeAcquisitionViewController.h"
#import "BadgeAcquisitionView.h"

@implementation BadgeAcquisitionViewController
@synthesize badgeList;

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


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {

	int badgeCnt = [badgeList count];
	
	badgeScrollView.contentSize = CGSizeMake(320 * badgeCnt, 480);
	badgeScrollView.alwaysBounceHorizontal = NO;

	NSString* badgeHeaderMsg = [NSString stringWithFormat:@"%@ 뱃지 외 총 %d개의 신규 뱃지", 
									[[badgeList objectAtIndex:0] objectForKey:@"badgeName"], 
									badgeCnt-1];
	
	for (int i = 0; i < badgeCnt; i++) {
		NSDictionary* badgeData = [badgeList objectAtIndex:i];
		BadgeAcquisitionView* blackPanel = [[[NSBundle mainBundle] loadNibNamed:@"BadgeAcquisitionView" 
																	 owner:self options:nil] lastObject];
		blackPanel.delegate = self;
		blackPanel.frame = CGRectMake(320 * i, 0, 320, 480);
		blackPanel.badgeData = badgeData;

		if (badgeCnt == 1) {	// 뱃지가 하나 뿐인 경우에는 히든처리
			blackPanel.badgeMessage.hidden = YES;
		}
		
		blackPanel.badgeMessage.text = badgeHeaderMsg;

		if (i + 1 == badgeCnt) {
			[blackPanel.nextOrCloseBtn setImage:[UIImage imageNamed:@"footcheck_confirm.png"] forState:UIControlStateNormal];
		}
		
		[blackPanel requestBadgeInfo];
		
		[badgeScrollView addSubview:blackPanel];
		if (i == 0) { 
			[blackPanel startOpeningAnimationFrom:CGPointMake(320/2, 320) to:CGPointMake(320/2, 76 + 252/2)];
		}
		
		blackPanel.tag = 1000 + i;
	}
	
    [super viewDidLoad];
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
	[badgeList release];
    [super dealloc];
}

/**
 @brief 뱃지 애니메이션 
 */
- (void) delayedBadgeAnimation {
	BadgeAcquisitionView* aView = (BadgeAcquisitionView*)[self.view viewWithTag:1000 + currentBadgeIndex];
	
	CGPoint from = CGPointMake(320/2, 320);
	CGPoint to = CGPointMake(320/2, 76 + 252/2);
	[aView startOpeningAnimationFrom:from to:to];	
}

- (void) goNextBadge {
	MY_LOG(@"다음 뷰로");
	// 마지막이면 닫기
	currentBadgeIndex++;
	if (currentBadgeIndex == [badgeList count]) {
		[self.view removeFromSuperview];
		[self dismissModalViewControllerAnimated:YES];
		return;
	}

	CGRect frame = badgeScrollView.frame;
	frame.origin.x = frame.size.width * currentBadgeIndex;
	frame.origin.y = 0;
	[badgeScrollView scrollRectToVisible:frame animated:YES];

//	[NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(delayedBadgeAnimation) userInfo:nil repeats:NO];
	[self delayedBadgeAnimation];
}

- (void) closeView {
	MY_LOG(@"뷰 닫기");
}



@end
