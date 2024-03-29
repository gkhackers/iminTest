//
//  AgreementSns.m
//  ImIn
//
//  Created by mandolin on 10. 6. 13..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "AgreementSns.h"


@implementation AgreementSns
@synthesize urlString, webView, agreementTitle;
/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

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
    [urlString release];
    [webView release];
    [agreementTitle release];
    
    [super dealloc];
}

- (void)viewWillAppear:(BOOL)animated {
    titleLabel.text = agreementTitle;
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
	[webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlString]]];
}

- (IBAction)onClickNavigationBarBackBtn : (id)sender{

	[self.navigationController popViewControllerAnimated:YES];
	
}

@end
