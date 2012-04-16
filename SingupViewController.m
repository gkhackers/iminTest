//
//  SingupViewController.m
//  ImIn
//
//  Created by park ja young on 11. 4. 11..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SingupViewController.h"
#import "OAuthWebViewController.h"
#import <CommonCrypto/CommonDigest.h>
#import "NSString+URLEncoding.h"
#import "UILoginViewController.h"
#import "CommonWebViewController.h"


@implementation SingupViewController

@synthesize udid, oAuthUrl;

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
	
	self.udid = [[ApplicationContext sharedApplicationContext] getDeviceUniqueIdentifier];	
	
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
	[udid release];
	[oAuthUrl release];
	
    [super dealloc];
}

- (IBAction) popViewController {
	[self.navigationController popViewControllerAnimated:YES];
}

- (IBAction) goEmail {	// 웹뷰:회원가입
	GA1(@"이메일가입");
	
	NSString* temp = [NSString stringWithFormat:@"env=app&cskey=%@&rturl=%@&device=%@", [SNS_CONSUMER_KEY URLEncodedString], [CALLBACK_URL URLEncodedString], [udid URLEncodedString]] ;
	self.oAuthUrl = [NSString stringWithFormat:@"%@?%@", OAUTH_REGISTER_URL, temp] ;
		
	OAuthWebViewController* myWebViewController = [[[OAuthWebViewController alloc] init] autorelease];
	
	myWebViewController.requestInfo = oAuthUrl;
	myWebViewController.webViewTitle = @"email 간편 가입";
	myWebViewController.authType = EMAIL_TYPE;
	MY_LOG(@"webViewTitle = %@, myWebViewController.requestInfo = %@", myWebViewController.webViewTitle, myWebViewController.requestInfo);

	[myWebViewController setHidesBottomBarWhenPushed:YES];
	[self.navigationController pushViewController:myWebViewController animated:YES];		
}


- (IBAction) goParan {  // 아임인 로그인창 연동:트위터, 페이스북 로그인 버튼 disable
	GA1(@"파란가입");
	UILoginViewController* loginViewController = [[UILoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
	loginViewController.paranLogin = YES;
	loginViewController.isPreBtn = YES;
	[loginViewController setHidesBottomBarWhenPushed:YES];
	[self.navigationController pushViewController:loginViewController animated:YES];
	[loginViewController release];		
}

- (IBAction) goTwitter {  // 웹뷰:oAuth 로그인
	
	GA1(@"트위터가입");

	NSString* temp = [NSString stringWithFormat:@"loginsitename=twitter.com&loginappname=%@&loginenv=app&loginrturl=%@&logincskey=%@&logindevice=%@", [IMIN_APP_NAME URLEncodedString], [CALLBACK_URL URLEncodedString], [SNS_CONSUMER_KEY  URLEncodedString], [udid URLEncodedString]] ;
	self.oAuthUrl = [NSString stringWithFormat:@"%@?%@", OAUTH_LOGIN_URL, temp] ;
	
	OAuthWebViewController* myWebViewController = [[[OAuthWebViewController alloc] init] autorelease];
	
	myWebViewController.requestInfo = oAuthUrl;
	myWebViewController.webViewTitle = @"twitter 가입";
	myWebViewController.authType = OAUTH_TYPE;
	MY_LOG(@"webViewTitle = %@, myWebViewController.requestInfo = %@", myWebViewController.webViewTitle, myWebViewController.requestInfo);
	[myWebViewController setHidesBottomBarWhenPushed:YES];
	[self.navigationController pushViewController:myWebViewController animated:YES];		
}

- (IBAction) goFacebook {  // 웹뷰:oAuth 로그인
	
	GA1(@"페이스북가입");

	NSString* temp = [NSString stringWithFormat:@"loginsitename=facebook.com&loginappname=%@&loginenv=app&loginrturl=%@&logincskey=%@&logindevice=%@", [IMIN_APP_NAME URLEncodedString], [CALLBACK_URL URLEncodedString], [SNS_CONSUMER_KEY  URLEncodedString], [udid URLEncodedString]] ;
	self.oAuthUrl = [NSString stringWithFormat:@"%@?%@", OAUTH_LOGIN_URL, temp] ;

	OAuthWebViewController* myWebViewController = [[[OAuthWebViewController alloc] init] autorelease];
	
	myWebViewController.requestInfo = oAuthUrl;
	myWebViewController.webViewTitle = @"facebook 가입";
	myWebViewController.authType = OAUTH_TYPE;
	MY_LOG(@"webViewTitle = %@, myWebViewController.requestInfo = %@", myWebViewController.webViewTitle, myWebViewController.requestInfo);
	[myWebViewController setHidesBottomBarWhenPushed:YES];
	[self.navigationController pushViewController:myWebViewController animated:YES];		
}

- (IBAction) goHelp {
	CommonWebViewController* commonWebVC = [[[CommonWebViewController alloc]initWithNibName:@"CommonWebViewController" bundle:nil] autorelease];
    commonWebVC.viewType = TITLE;
	commonWebVC.titleString = @"아임IN 고객센터";
	commonWebVC.urlString = HELP_URL;
	
	[self presentModalViewController:commonWebVC animated:YES];	
}

@end
