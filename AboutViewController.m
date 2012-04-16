//
//  AboutViewController.m
//  ImIn
//
//  Created by choipd on 10. 7. 8..
//  Copyright 2010 edbear. All rights reserved.
//

#import "AboutViewController.h"


@implementation AboutViewController

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	versionLabel.text = [NSString stringWithFormat:@"VERSION %@", [ApplicationContext appVersion]];
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
    [super dealloc];
}

/**
 @brief 관리자 메일 영역 클릭
 @return IBAction
 */
- (IBAction) goMail {
	if([[[UIDevice currentDevice] systemVersion] doubleValue] < 4.0) {
		UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"알림" message:@"지금 문의 메일을 작성하시겠어요?\n아임IN 앱은 종료됩니다. "
													   delegate:self cancelButtonTitle:@"취소" otherButtonTitles:@"확인", nil] autorelease];
		alert.tag = 100;
		[alert show];
	} else {
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"mailto:iminmaster@paran.com"]];
	}

	
}

/**
 @brief 관리자 전화번호 영역 클릭
 @return IBAction
 */
- (IBAction) goCall {
	
	if([[[UIDevice currentDevice] systemVersion] doubleValue] < 4.0) {
		UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"알림" message:@"지금 문의 전화를 거시겠어요?\n아임IN 앱은 종료됩니다 "
													   delegate:self cancelButtonTitle:@"취소" otherButtonTitles:@"확인", nil] autorelease];
		alert.tag = 200;
		[alert show];
	} else {
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"tel:02-1588-5668"]];
	}
	
}

- (void)alertView:(UIAlertView*)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (alertView.tag == 100 && buttonIndex == 1)
	{
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"mailto:iminmaster@paran.com"]];
		return;
	}
	if (alertView.tag == 200 & buttonIndex == 1)
	{
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"tel:02-1588-5668"]];
	}
	
}


- (IBAction) popViewController:(id)sender {
	[self.navigationController popViewControllerAnimated:YES];
}

@end
