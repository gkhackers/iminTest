//
//  SnsHelpController.m
//  ImIn
//
//  Created by mandolin on 10. 6. 17..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SnsHelpController.h"
#import "SnsKeyChain.h"

@implementation SnsHelpController
@synthesize bEnableBack;

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
- (id) initWithEnableBack:(bool)enableBack
{
	if (self = [super init]) {
		bEnableBack = enableBack;
	}
	return self;
}

- (id) init 
{
	if (self = [super init])
		bEnableBack = YES; 

	return self;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {

    [super viewDidLoad];
	NSString *imagePath;
	NSBundle *bundle = [NSBundle mainBundle]; 
	NSString *path = [bundle bundlePath];
	imagePath = [NSBundle pathForResource:@"guide" ofType:@"png" inDirectory:path];
	NSString *fixedURL = [imagePath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	NSString *commentHtml = [NSString stringWithFormat:@"<img src=\"file:///%@\"/>", fixedURL];
	NSString *html3 = [NSString stringWithFormat:@"<html><head/><body leftmargin=0 topmargin=0>%@</body></html>", commentHtml];
	MY_LOG(@"LoadHTML:%@",html3);
	[webView loadHTMLString:html3 baseURL:nil];
	

}

- (void) viewDidAppear:(BOOL)animated
{
	if (bEnableBack)
	{
		startBtn.hidden = NO;
		backBtn.hidden = YES;
	} else {
		startBtn.hidden = YES;
		backBtn.hidden = NO;
	}
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

- (IBAction)onClickStart:(id)sender 
{	
	[self.navigationController popViewControllerAnimated:NO];
}

- (IBAction)onClickPrev:(id)sender 
{
	[self.navigationController popViewControllerAnimated:YES];
}


@end
