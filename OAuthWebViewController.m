    //
//  OAuthWebViewController.m
//  ImIn
//
//  Created by park ja young on 11. 4. 12..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "macro.h"
#import "OAuthWebViewController.h"
#import "SnsRegistController.h"
#import "NSString+URLEncoding.h"
#import "UIPlazaViewController.h"
#import "SnsKeyChain.h"
#import "SetAuthTokenEx.h"
#import "SetDelivery.h"

@implementation OAuthWebViewController
@synthesize requestInfo, webViewTitle;
@synthesize authType;
@synthesize indicator;
@synthesize jsRtcode, jsRtmsg;
@synthesize setAuthTokenEx;
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
	// 인증 및 회원가입시 쿠키 삭제
	NSHTTPCookieStorage* cookies = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSArray* facebookCookies = [cookies cookiesForURL:
								[NSURL URLWithString:@"http://login.facebook.com"]];
    for (NSHTTPCookie* cookie in facebookCookies) {
		[cookies deleteCookie:cookie];
    }	
	
	NSArray* twitterCookies = [cookies cookiesForURL:
							   [NSURL URLWithString:@"http://twitter.com"]];
	for (NSHTTPCookie* cookie in twitterCookies) {
		[cookies deleteCookie:cookie];
    }
	
	NSArray* emailCookies = [cookies cookiesForURL:
							   [NSURL URLWithString:@"https://user.paran.com/paran/register.do"]];
	for (NSHTTPCookie* cookie in emailCookies) {
		[cookies deleteCookie:cookie];
    }
	
	connect1 = nil;
	
	jsRtcode = @"document.getElementsByName('X-rtcode')[0].getAttribute('content')";
	jsRtmsg = @"document.getElementsByName('X-rtmsg')[0].getAttribute('content')";
	
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
	[HeadStr setFont:[UIFont fontWithName:@"Helvetica-Bold" size:18.0]];
	
	[HeadStr setText:webViewTitle];
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
	
	//if (authType == TWITTER_TYPE || authType == FB_TYPE) {
	//	oAuthWebView = [[UIWebView alloc]initWithFrame:CGRectMake(0, 43, 320, 372)];
	//} else {
	//	oAuthWebView = [[UIWebView alloc]initWithFrame:CGRectMake(0, 43, 320, 421)];
	//}

	
	oAuthWebView = [[UIWebView alloc]initWithFrame:CGRectMake(0, 43, 320, 421)];
	oAuthWebView.autoresizesSubviews = YES;
	oAuthWebView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin;
	
	[oAuthWebView setDataDetectorTypes:UIDataDetectorTypeNone];
	[self.view addSubview:oAuthWebView];
	
	//indicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
	//[indicator setCenter:CGPointMake(160, 240)];
	
	CGRect inframe = CGRectMake(0.0, 0.0, 20, 20);
	indicator = [[UIActivityIndicatorView alloc] initWithFrame:inframe];
	[indicator setCenter:CGPointMake(160, 190)];
	indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
	[self.view addSubview:indicator];
}


/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/

- (void)viewWillAppear:(BOOL)animated {
	NSString* urlEnc;
	 urlEnc = requestInfo;
	
	[oAuthWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlEnc]]];
	[oAuthWebView setDelegate:self];	
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
	if (oAuthWebView != nil) {
		[oAuthWebView stopLoading];
		[oAuthWebView release];		
	}
	
	[indicator stopAnimating];
	[indicator release];
	
	if (connect1 != nil) {
		[connect1 stop];
		[connect1 release];
		connect1 = nil;
	}

	[jsRtcode release];
	[jsRtmsg release];
	[requestInfo release];
	[webViewTitle release];
	[setAuthTokenEx release];
    [setDelivery release];
	
    [super dealloc];
}


// back 버튼 클릭하면 되돌아가야 한다.
- (void) popViewController:(id)sender {
	[oAuthWebView stopLoading];
	
	[self.navigationController popViewControllerAnimated:YES];
}


// close 버튼 클릭하면 되돌아가야 한다.
- (void) closeViewController:(id)sender {
	[oAuthWebView stopLoading];
		
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	indicator.hidden = NO;
	[indicator startAnimating];
	
}

- (void) webViewDidFinishLoad:(UIWebView *)webView
{
    MY_LOG(@"%@", [webView stringByEvaluatingJavaScriptFromString:@"document.URL"]);
    MY_LOG(@"%@", [webView stringByEvaluatingJavaScriptFromString:@"document.body.innerHTML"]);
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	indicator.hidden = YES;
	[indicator stopAnimating];
	
	if (authType == EMAIL_TYPE || authType == OAUTH_TYPE) { //이메일가입이나 oauth인증일때
		[self processAuth:webView]; 
	}
	if (authType == TWITTER_TYPE || authType == FB_TYPE) { //페이스북이나 트위터의 글내보내기 설정일때
		[self processDelivery:webView];
	}
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    
//    [CommonAlert alertWithTitle:@"알림" message:@"네트웍 연결을 확인해주세요."];
}

// add by mandolin(2012.03.19) : Twitter로그인 화면에서 "취소하고 앱으로 되돌아가기" 버튼 클릭시에 Navigation Back되도록 처리
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType;
{
	NSURL *url = request.URL;
    NSString* urlStr = [url absoluteString];
    MY_LOG(@"oAuth WebView Request: %@",urlStr);
    if ([urlStr hasPrefix:@"https://main.paran.com/oauth/twitter.do?denied="]   /* iOS5에서는 이 URL호출됨 */ 
        || [urlStr hasPrefix:@"https://main.paran.com:443/oauth/twitter.do?denied="]) /* iOS4에서는 이 URL호출됨 */
    {
        [self popViewController:nil];
    }
    return YES;
}


- (void) processAuth: (UIWebView *) webView {	
	
	/*NSString *currentURL = webView.request.URL.absoluteString;
	MY_LOG(@"currentURL = %@", currentURL);*/
	
	//NSString *html = [webView stringByEvaluatingJavaScriptFromString:@"document.body.innerHTML"];
	//MY_LOG(@"html source = %@", html);
	
	NSString *rtcodeValue = [webView stringByEvaluatingJavaScriptFromString: jsRtcode];
	NSString *rtmsgValue = [webView stringByEvaluatingJavaScriptFromString: jsRtmsg];
		
	MY_LOG(@"rtcodeValue=%@, rtmsgValue = %@", rtcodeValue, rtmsgValue);
	
	if (rtcodeValue.length == 0) { // 에러 혹은 원하는 페이지가 아니다.
		return;
	} 
	else 
	{ // rtcodeValue값이 무언가가 있다. 
		if ([rtcodeValue isEqualToString:@"0"]) 
		{ // rtcodeValue 값이 만약 0이면 성공이다.
			//rtmsg값중에서 atkey값을 얻어서 그걸 snskeychain의 토큰으로 저장한다. 그리고 그 토큰을 가지고 아임인인증을 한다. 
			NSString* atkey;
			NSString* oauth;
			NSString* userNumber;
			
			if (rtmsgValue.length == 0) {
				return;
			}
			
			atkey = [self parsedString:rtmsgValue findString:@"atkey="];
			userNumber = [self parsedString:rtmsgValue findString:@"userno="];
			if ([atkey isEqualToString:@""]) {
				return;
			}
			
			[UserContext sharedUserContext].token = atkey;
			[UserContext sharedUserContext].userNo = userNumber;
			
            NSString *appVer = [ApplicationContext appVersion];
            
			//OAuth인증이나 Email가입이 성공 => 아임인 인증 진행
			
			self.setAuthTokenEx = [[[SetAuthTokenEx alloc] init] autorelease];
			setAuthTokenEx.delegate = self;
			if (authType == OAUTH_TYPE) // 키체인말고 authType으로 oauth인증인지 아닌지 판단가능
			{
				oauth = [self parsedString:rtmsgValue findString:@"oauth="];
				[UserContext sharedUserContext].oAuth = oauth; //oAuth인증이라서 값 처리
				if ([oauth isEqualToString:@""]) {
					UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"알림" message:@"지금 연결에 문제가 있어요~ 다시 시도해 주세요."
																	delegate:self cancelButtonTitle:nil otherButtonTitles:@"확인", nil] autorelease];
					
					[alert show];
					return;
				}
				
				[setAuthTokenEx.params addEntriesFromDictionary:[NSDictionary dictionaryWithObjectsAndKeys:@"3", @"at", 
																 atkey, @"av", 
																 [ApplicationContext sharedApplicationContext].apiVersion, @"ver", 
																 @"ON", @"mode",
																 [UserContext sharedUserContext].deviceToken, @"deviceToken",
                                                                 appVer, @"appVer",
																 oauth, @"oauth",
																 nil]];
			} else {
				[UserContext sharedUserContext].oAuth = @""; //oAuth 인증이 아니라서 "" 처리
				[setAuthTokenEx.params addEntriesFromDictionary:[NSDictionary dictionaryWithObjectsAndKeys:@"3", @"at", 
																 atkey, @"av", 
																 [ApplicationContext sharedApplicationContext].apiVersion, @"ver", 
																 @"ON", @"mode",
																 [UserContext sharedUserContext].deviceToken, @"deviceToken",
                                                                 appVer, @"appVer",
																 nil]];
				
			}

			[setAuthTokenEx requestWithAuth:NO withIndicator:YES];		
			//MY_LOG(@"atkey = %@, oauth = %@", atkey, oauth);
		} 
		else 
		{// rtcodeValue 값이 0이 아니다... 즉 rtcode가 넘어왔으나 에러다. 성공이 아니다.
			UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"알림" message:@"지금 연결에 문제가 있어요~ 다시 시도해 주세요."
															delegate:self cancelButtonTitle:nil otherButtonTitles:@"확인", nil] autorelease];
			
			
			[alert show];
			//[self.navigationController popViewControllerAnimated:YES];
		}
	}
	
	return;
}

- (void) processDelivery: (UIWebView *) webView { 
	NSString *rtcodeValue = [webView stringByEvaluatingJavaScriptFromString: jsRtcode];
	NSString *rtmsgValue = [webView stringByEvaluatingJavaScriptFromString: jsRtmsg];
	
	MY_LOG(@"rtcodeValue=%@, rtmsgValue = %@", rtcodeValue, rtmsgValue);
	
	if (rtcodeValue.length == 0) { // 에러 혹은 원하는 페이지가 아니다.
		return;
	} else { // rtcodeValue값이 무언가가 있다. 
		if ([rtcodeValue isEqualToString:@"0"]) { // rtcodeValue 값이 만약 0이면 성공이다.
			NSString* oauth;
			
			if (rtmsgValue.length == 0) {
				return;
			}
			oauth = rtmsgValue; // 글내보내기의 경우는 rtmsgValue값 전체가 oauth값으로 해서 전송해야 한다.
			
            self.setDelivery = [[[SetDelivery alloc] init] autorelease];
            setDelivery.delegate = self;
            
            NSString* cpCodeValue = nil;
            
            if (authType == TWITTER_TYPE) {
				cpCodeValue = @"51";
			}
			if (authType == FB_TYPE) {
                cpCodeValue = @"52";
			}
            
            [setDelivery.params addEntriesFromDictionary:[NSDictionary dictionaryWithObjectsAndKeys:cpCodeValue, @"cpCode", 
                                                          @"0", @"blogId",
                                                          @"0", @"userName",
                                                          @"0", @"passWd",
                                                          oauth, @"oauth", nil]];
            
            [setDelivery request];
            
//			CgiStringList	*strPostData = [[CgiStringList alloc]init:@"&"];
//			[strPostData setMapString:@"svcId" keyvalue:SNS_IPHONE_SVCID];
//            [strPostData setMapString:@"appVer" keyvalue:[ApplicationContext appVersion]];
//			if (authType == TWITTER_TYPE) {
//				[strPostData setMapString:@"cpCode" keyvalue:@"51"];
//			}
//			if (authType == FB_TYPE) {
//				[strPostData setMapString:@"cpCode" keyvalue:@"52"];
//			}
//			[strPostData setMapString:@"device" keyvalue:SNS_DEVICE_MOBILE_APP];
//			[strPostData setMapString:@"blogId" keyvalue:@"0"];
//			[strPostData setMapString:@"userName" keyvalue:@"0"];
//			[strPostData setMapString:@"passWd" keyvalue:@"0"];
//			[strPostData setMapString:@"at" keyvalue:@"1"];
//			[strPostData setMapString:@"av" keyvalue:[UserContext sharedUserContext].snsID];
//			[strPostData setMapString:@"oauth" keyvalue:oauth];
//
//			if (connect1 != nil) {
//				[connect1 stop];
//				[connect1 release];
//				connect1 = nil;
//			}
//
//			connect1 = [[HttpConnect alloc] initWithURL: PROTOCOL_SET_DELIVERY 
//											   postData: [strPostData description]
//											   delegate: self
//										   doneSelector: @selector(onDeliverySettingDone:)    
//										  errorSelector: @selector(onHttpConnectError:)  
//									   progressSelector: nil];
//
//			[strPostData release];
		} else {// rtcodeValue 값이 0이 아니다... 즉 rtcode가 넘어왔으나 에러다. 성공이 아니다.
			UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"알림" message:@"지금 연결에 문제가 있어요~ 로그아웃 하고 다시 시도해 주세요."
															delegate:self cancelButtonTitle:nil otherButtonTitles:@"확인", nil] autorelease];
			
			
			[alert show];
			//[self.navigationController popViewControllerAnimated:YES];
		}
	}
	
	return;
}

- (void) apiFailedWhichObject:(NSObject *)theObject {
    if (theObject == setDelivery) {
        UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"알림" message:@"연결에 실패하였습니다."
                                                        delegate:self cancelButtonTitle:nil otherButtonTitles:@"확인", nil] autorelease];
        [alert show];	
    } else {
        UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"알림" message:@"네트워크가 불안정합니다.\n재시도 하시겠습니까?"
                                                        delegate:self cancelButtonTitle:@"재시도" otherButtonTitles:@"앱종료", nil] autorelease];
        
        alert.tag = 100;
        [alert show];
    }
}

- (void) apiDidLoadWithResult:(NSDictionary *)result whichObject:(NSObject *)theObject {
    if ([[result objectForKey:@"func"] isEqualToString:@"setAuthTokenEx"]) {
		
		NSNumber* resultNumber = (NSNumber*)[result objectForKey:@"result"];
		
		if ([resultNumber intValue] == 0) { //에러처리
			
			NSString* errCd = [NSString stringWithFormat:@"%@",[result objectForKey:@"errCode"]];
			if ([errCd compare:@"1058"] == NSOrderedSame)
			{
				SnsRegistController *SnsRegist = [[SnsRegistController alloc]init];
				[self.navigationController pushViewController:SnsRegist animated:YES];
				[SnsRegist release];
			} else {
				[CommonAlert alertWithTitle:@"로그인 에러" message:[result objectForKey:@"description"]];
			}
			return;
		}
		
		[[UserContext sharedUserContext] loginProcess:result];
	} 
    
    if ([[result objectForKey:@"func"] isEqualToString:@"setDelivery"]) {
        if( ![[result objectForKey:@"result"] boolValue]){
            return;
        }
        
        NSString* msg = nil;
        UserContext* uc = [UserContext sharedUserContext];
        if (authType == TWITTER_TYPE) {
            uc.cpTwitter.isConnected = YES;
            uc.cpTwitter.isDelivery = YES;
            uc.cpTwitter.blogId = [result objectForKey:@"blogId"];
            uc.cpTwitter.cpCode = @"51";
            msg = @"트위터 연결 설정이\n완료되었습니다.\n발도장을 찍으면 트위터에도\n함께 트윗됩니다.";
        }
        else if (authType == FB_TYPE) {
            uc.cpFacebook.isConnected = YES;
            uc.cpFacebook.isDelivery = YES;
            uc.cpFacebook.blogId = [result objectForKey:@"blogId"];
            uc.cpFacebook.cpCode = @"52";	
            uc.cpFacebook.userName = [result objectForKey:@"userName"];
            MY_LOG(@"userName = %@", uc.cpFacebook.userName);
            msg = @"페이스북 연결 성공!\n발도장을 찍으면 페이스북\n담벼락에 등록되고 페이스북 친구를\n이웃으로 추천 받아요~";
        }
        else {
            msg = nil;
        }
        
        [ApplicationContext stopActivity];
        
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"알림"
                                                       message:msg
                                                      delegate:self
                                             cancelButtonTitle:@"OK"
                                             otherButtonTitles:nil];	
        [alert show];
        [alert release];
    }
}


//- (void) onHttpConnectError:(HttpConnect*)up
//{
//	if (connect1 != nil)
//	{
//		[connect1 release];
//		connect1 = nil;
//	}
//	
//	MY_LOG(@"%@", connect1.stringReply);
//	UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"알림" message:@"연결에 실패하였습니다."
//													delegate:self cancelButtonTitle:nil otherButtonTitles:@"확인", nil] autorelease];
//	[alert show];	
//}
//
//- (void) onDeliverySettingDone:(HttpConnect*)up
//{
//	SBJSON* jsonParser = [SBJSON new];
//	[jsonParser setHumanReadable:YES];
//	
//	NSDictionary* results = (NSDictionary *)[jsonParser objectWithString:up.stringReply error:NULL];
//	[jsonParser release];
//	
//	if (connect1 != nil)
//	{
//		[connect1 release];
//		connect1 = nil;
//	}
//	if( ![[results objectForKey:@"result"] boolValue]){
//		return;
//	}
//	
//	NSString* msg = nil;
//	UserContext* uc = [UserContext sharedUserContext];
//	if (authType == TWITTER_TYPE) {
//		uc.cpTwitter.isConnected = YES;
//		uc.cpTwitter.isDelivery = YES;
//		uc.cpTwitter.blogId = [results objectForKey:@"blogId"];
//		uc.cpTwitter.cpCode = @"51";
//		msg = @"트위터 연결 설정이\n완료되었습니다.\n발도장을 찍으면 트위터에도\n함께 트윗됩니다.";
//	}
//	else if (authType == FB_TYPE) {
//		uc.cpFacebook.isConnected = YES;
//		uc.cpFacebook.isDelivery = YES;
//		uc.cpFacebook.blogId = [results objectForKey:@"blogId"];
//		uc.cpFacebook.cpCode = @"52";	
//		uc.cpFacebook.userName = [results objectForKey:@"userName"];
//		MY_LOG(@"userName = %@", uc.cpFacebook.userName);
//		msg = @"페이스북 연결 성공!\n발도장을 찍으면 페이스북\n담벼락에 등록되고 페이스북 친구를\n이웃으로 추천 받아요~";
//	}
//	else {
//		msg = nil;
//	}
//
//    [ApplicationContext stopActivity];
//
//	UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"알림"
//												   message:msg
//												  delegate:self
//										 cancelButtonTitle:@"OK"
//										 otherButtonTitles:nil];	
//	[alert show];
//	[alert release];
//}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
 	if (alertView.tag == 100)
	{
		if (buttonIndex == 0)
		{// 재시도일때
			[self performSelector:@selector(requestSetAuthTonkenEx) withObject:nil afterDelay:0.5];
		} else { // 앱종료일때
			exit(0);
		}
	} else {
		[self.navigationController popViewControllerAnimated:YES];
	}
}

- (void)requestSetAuthTonkenEx
{
    if (setAuthTokenEx) {
        [setAuthTokenEx requestWithAuth:NO withIndicator:YES];
    } 
}

- (NSString*)parsedString:(NSString*)rtMsg findString:(NSString*)findString
{
	NSString* key;
	
	NSRange range = [rtMsg rangeOfString:findString];
	if (range.location != NSNotFound) { //있으면
		NSString* atkeyTemp = [rtMsg substringFromIndex:range.location+6]; //findString 다음부터 끝까지
		NSRange rangeTemp = [atkeyTemp rangeOfString:@"&"];
		if (rangeTemp.location != NSNotFound) { //있으면
			key = [atkeyTemp substringToIndex:rangeTemp.location];
		} else { //없으면 끝이라고 생각하고..
			key = [atkeyTemp substringFromIndex:0]; //없으면 뒤쪽으로 끝까지
		}
		return key;
	} 
	return @"";
}

@end
