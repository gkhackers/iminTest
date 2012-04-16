//
//  LatestCheckinViewController.m
//  ImIn
//
//  Created by Myungjin Choi on 11. 4. 29..
//  Copyright 2011 KTH. All rights reserved.
//

#import "LatestCheckinViewController.h"
#import "MemberInfo.h"
#import "CheckinTableViewController.h"

@implementation LatestCheckinViewController
@synthesize checkinTVC, owner;

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
- (IBAction) popVC {
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
	titleLabel.text = [NSString stringWithFormat:@"%@님의 발도장", owner.nickname];
	
	//테이블 컨트롤러를 생성하고 테이블을 뷰에 삽입
	self.checkinTVC = [[[CheckinTableViewController alloc] initWithNibName:@"MainThreadTableViewController" bundle:nil] autorelease];
	checkinTVC.owner = self.owner;	
	checkinTVC.isIncludeBadge = NO;
	[listAreaView addSubview:checkinTVC.view];
}


- (void) viewWillAppear:(BOOL)animated {
	[checkinTVC viewWillAppear:animated];
}


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
	[owner release];
	[checkinTVC release];
    [super dealloc];
}


@end
