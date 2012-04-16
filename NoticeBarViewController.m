//
//  NoticeBarViewController.m
//  ImIn
//
//  Created by choipd on 10. 5. 25..
//  Copyright 2010 edbear. All rights reserved.
//

#import "NoticeBarViewController.h"
#import "ViewControllers.h"
#import "UIPlazaViewController.h"

@implementation NoticeBarViewController

@synthesize noticeMessage;

 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
		isShown = NO;
		[self.view setFrame:CGRectMake(0.0f, 500.0f, 320.0f, 45.0f)];
    }
    return self;
}

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/

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
	[noticeMessage release];
    [super dealloc];
}

- (void) toggleView
{
	if (isShown)
	{
		[self viewExplainView:NO];
	} else
	{	
		[self viewExplainView:YES];
	}
}

- (void) viewExplainView:(BOOL)willShow
{
	if (willShow)
	{
		[self.view setFrame:CGRectMake(0.0f, 500.0f, 320.0f, 45.0f)];
		[UIView beginAnimations:@"showExplainView" context:nil];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
		[UIView setAnimationDuration:0.5];
		[self.view setFrame:CGRectMake(0.0f, 366.0f, 320.0f, 45.0f)];
		[UIView commitAnimations];
		isShown = YES;
	} else
	{
		[self.view setFrame:CGRectMake(0.0f, 366.0f, 320.0f, 45.0f)];
		[UIView beginAnimations:@"hideExplainView" context:nil];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
		[UIView setAnimationDuration:0.5];
		[self.view setFrame:CGRectMake(0.0f, 500.0f, 320.0f, 45.0f)];
		[UIView commitAnimations];
		isShown = NO;
	}
}

- (IBAction) closeNotice {
	MY_LOG(@"closeNotice");
	[self viewExplainView:NO];
}

- (IBAction) refreshPlaza {
	UIPlazaViewController* vc = (UIPlazaViewController*)[ViewControllers sharedViewControllers].plazaViewController;
	[vc refresh];
	
	[self closeNotice];
}

@end
