    //
//  Me2dayViewController.m
//  ImIn
//
//  Created by park ja young on 11. 1. 14..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Me2dayViewController.h"
#import "macro.h"
#import "SetDelivery.h"
#import "iToast.h"

@implementation Me2dayViewController

@synthesize me2WebView, connect, authURL, me2dayToken, userID, authToken;
@synthesize setDelivery;
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


// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
	connect = nil;
	self.view = [[[UIView alloc]initWithFrame:CGRectMake(0, 44, 320, 436)] autorelease];
	[self.view setBackgroundColor:[UIColor darkGrayColor]];
	
	self.view.autoresizesSubviews = YES;
	self.view.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin;
	
	UIImageView *headerView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"header_bg.png"]];
	headerView.autoresizesSubviews = YES;
	headerView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin;
	
	[headerView setFrame:HEADERVIEW_FRAME];
	[self.view addSubview:headerView];
	
	// 제목 문자열 라벨.
	UILabel *HeadStr = [[UILabel alloc] initWithFrame:HEADERVIEW_FRAME];
	
	HeadStr.autoresizesSubviews = YES;
	HeadStr.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin;
	
	[HeadStr setTextAlignment:UITextAlignmentCenter];
	[HeadStr setBackgroundColor:[UIColor clearColor]];
	[HeadStr setFont:[UIFont fontWithName:@"Helvetica" size:18.0]];
	[HeadStr setText:@"Me2day 설정"];
	[headerView addSubview:HeadStr];
	[HeadStr release];
	[headerView release];
	
	// back button
	UIButton *backBtn = [[UIButton alloc]initWithFrame:BACKBTN_FRAME];
	[backBtn setImage:[UIImage imageNamed:@"header_prev.png"] forState:UIControlStateNormal];
	[backBtn addTarget:self
				action:@selector(popViewController:)
	  forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:backBtn];
	[backBtn release];
	
	self.me2WebView = [[[UIWebView alloc]initWithFrame:CGRectMake(0, 43, 320, 421)] autorelease];
	me2WebView.autoresizesSubviews = YES;
	me2WebView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin;
	
	[me2WebView setDataDetectorTypes:UIDataDetectorTypeNone];
	[self.view addSubview:me2WebView];
}



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	if (connect != nil) {
		[connect stop];
		[connect release];
		connect = nil;
	}
	
	self.connect = [[[HttpConnect alloc] initWithURL:@"http://me2day.net/api/get_auth_url.json"
										   postData:@"akey=ddfcd54d23bc43555939087d33cdc128"
										   delegate: self
									   doneSelector: @selector(onTransDone:)    
									  errorSelector: @selector(onResultError:)  
								   progressSelector: nil] autorelease];	
	
    [super viewDidLoad];
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/


- (void) onTransDone:(HttpConnect*) up
{
	MY_LOG(@"%@", up.stringReply);
	//[opQueue cancelAllOperations];
	SBJSON* jsonParser = [SBJSON new];
	[jsonParser setHumanReadable:YES];	
	NSDictionary* results = (NSDictionary *)[jsonParser objectWithString:up.stringReply error:NULL];
	[jsonParser release];
	
	self.authURL = [results objectForKey:@"url"];
	self.me2dayToken = [results objectForKey:@"token"];
	
	[me2WebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.authURL]]];
	[me2WebView setDelegate:self];	
	
	
	if (connect != nil)
	{
		[connect release];
		connect = nil;
	}
}

- (void) onResultError:(HttpConnect*) up
{
    //itoast
    UIWindow *window = [[[UIApplication sharedApplication] windows] objectAtIndex:0];
    UIView *v = (UIView *)[window viewWithTag:TAG_iTOAST];
    if (!v) {
        iToast *msg = [[iToast alloc] initWithText:up.stringError];
        [msg setDuration:2000];
        [msg setGravity:iToastGravityCenter];
        [msg show];
        [msg release];
    }
    //	[CommonAlert alertWithTitle:@"에러" message:up.stringError];
	if (connect != nil)
	{
		[connect release];
		connect = nil;
	}
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void) webViewDidFinishLoad:(UIWebView *)webView
{
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	[self locateAuthMetaInWebView:webView];
}

- (void) locateAuthMetaInWebView: (UIWebView *) webView {
	
//	<meta name="X-ME2API-AUTH-RESULT" content="accepted" />
	NSString *js = @"document.getElementsByName('X-ME2API-AUTH-RESULT')[0].getAttribute('content')";
	NSString *metaValue = [webView stringByEvaluatingJavaScriptFromString: js];
	
	
	if (metaValue.length == 0) 
	{
		return;
	}
	
	else 
	{
		if ([metaValue isEqualToString:@"accepted"]) 
		{
			MY_LOG(@"me2dayToken : %@", me2dayToken);
			if (connect != nil) {
				[connect stop];
				[connect release];
				connect = nil;
			}

		    NSString* postValue = [NSString stringWithFormat:@"token=%@&akey=ddfcd54d23bc43555939087d33cdc128", me2dayToken];
			self.connect = [[[HttpConnect alloc] initWithURL:@"http://me2day.net/api/get_full_auth_token.json"
												   postData:postValue
												   delegate: self
											   doneSelector: @selector(onTransDone1:)    
											  errorSelector: @selector(onResultError1:)  
										   progressSelector: nil] autorelease];	
		}
		else {
			[self popView];
		}

	}
	
	return;
}


- (void) onTransDone1:(HttpConnect *)up
{
	SBJSON* jsonParser = [SBJSON new];
	[jsonParser setHumanReadable:YES];	
	NSDictionary* results = (NSDictionary *)[jsonParser objectWithString:up.stringReply error:NULL];
	[jsonParser release];
	
	self.userID = [results objectForKey:@"user_id"];
	self.authToken = [results objectForKey:@"auth_token"];
	
	MY_LOG(@"userID : %@, authToken : %@", self.userID, self.authToken);
	
	if (connect != nil)
	{
		[connect stop];
		[connect release];
		connect = nil;
	}
	
	[self setDerivery];
}

- (void) onResultError1:(HttpConnect *)up
{
    //itoast
    UIWindow *window = [[[UIApplication sharedApplication] windows] objectAtIndex:0];
    UIView *v = (UIView *)[window viewWithTag:TAG_iTOAST];
    if (!v) {
        iToast *msg = [[iToast alloc] initWithText:up.stringError];
        [msg setDuration:2000];
        [msg setGravity:iToastGravityCenter];
        [msg show];
        [msg release];
    }
    //	[CommonAlert alertWithTitle:@"에러" message:up.stringError];
	if (connect != nil)
	{
		[connect stop];
		[connect release];
		connect = nil;
	}
}



- (IBAction) setDerivery
{
    self.setDelivery = [[[SetDelivery alloc] init] autorelease];
    setDelivery.delegate = self;
    [setDelivery.params addEntriesFromDictionary:[NSDictionary dictionaryWithObjectsAndKeys:@"50", @"cpCode",
                                                  userID, @"blogId",
                                                  userID, @"userName",
                                                  authToken, @"passWd", nil]];
    [setDelivery request];
    
//	UserContext* userContext = [UserContext sharedUserContext];
//	
//	CgiStringList* strPostData=[[CgiStringList alloc]init:@"&"];
//	[strPostData setMapString:@"svcId" keyvalue:SNS_IPHONE_SVCID];
//    [strPostData setMapString:@"appVer" keyvalue:[ApplicationContext appVersion]];
//	[strPostData setMapString:@"device" keyvalue:SNS_DEVICE_MOBILE_APP];	
//	[strPostData setMapString:@"at" keyvalue:@"1"];
//	[strPostData setMapString:@"av" keyvalue:userContext.snsID];
//	
//	[strPostData setMapString:@"cpCode" keyvalue:@"50"]; // me2day cp code
//	[strPostData setMapString:@"blogId" keyvalue:userID];
//	[strPostData setMapString:@"userName" keyvalue:userID];
//	[strPostData setMapString:@"passWd" keyvalue:authToken];
//	
//	if (connect != nil)
//	{
//		[connect stop];
//		[connect release];
//		connect = nil;
//	}
//	
//	connect = [[HttpConnect alloc] initWithURL:PROTOCOL_SET_DELIVERY
//									   postData: [strPostData description]
//									   delegate: self
//								   doneSelector: @selector(onSetDeliveryTransDone:)    
//								  errorSelector: @selector(onSetDeliveryResultError:)  
//							   progressSelector: nil];
//	[strPostData release];
}

- (void) apiFailed {
	[self.navigationController popViewControllerAnimated:YES];
}

- (void) apiDidLoad:(NSDictionary *)result {
	UserContext* uc = [UserContext sharedUserContext];
	
	uc.cpMe2day.isConnected = YES;
	uc.cpMe2day.isDelivery = YES;
	uc.cpMe2day.blogId = self.userID;
	uc.cpMe2day.userName = self.userID;
	uc.cpMe2day.cpCode = @"50";
	
	UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"알림"
												   message:@"me2day 연결 설정이 완료되었습니다. 발도장을 찍으면 me2day에도 함께 미투됩니다."
												  delegate:self
										 cancelButtonTitle:@"OK"
										 otherButtonTitles:nil];
	[alert show];
	[alert release];
}

//- (void) onSetDeliveryTransDone:(HttpConnect*)up
//{
//	MY_LOG(@"%@", connect.stringReply);
//
//	UserContext* uc = [UserContext sharedUserContext];
//	
//	uc.cpMe2day.isConnected = YES;
//	uc.cpMe2day.isDelivery = YES;
//	uc.cpMe2day.blogId = self.userID;
//	uc.cpMe2day.userName = self.userID;
//	uc.cpMe2day.cpCode = @"50";
//	
//	UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"알림"
//												   message:@"me2day 연결 설정이 완료되었습니다. 발도장을 찍으면 me2day에도 함께 미투됩니다."
//												  delegate:self
//										 cancelButtonTitle:@"OK"
//										 otherButtonTitles:nil];
//	[alert show];
//	[alert release];
//}
//
//
//- (void) onSetDeliveryResultError:(HttpConnect*)up
//{
//	MY_LOG(@"%@", connect.stringReply);
//	[self.navigationController popViewControllerAnimated:YES];
//}
//
- (IBAction) popView {
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	[self popView];
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

- (void) popViewController:(id)sender{
	if (me2WebView != nil) 
	{
		[me2WebView stopLoading];
	}
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)dealloc {
	
	if (connect != nil) {
		[connect stop];
		[connect release];
	}
	
	[authURL release];
	[me2dayToken release];
	[userID release];
	[authToken release];
    [me2WebView release];
    [setDelivery release];
	
    [super dealloc];
}


@end
