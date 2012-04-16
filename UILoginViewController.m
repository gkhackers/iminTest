//
//  UILoginViewController.m
//
//  Created by choipd on 10. 4. 19..
//  Copyright 2010 edbear. All rights reserved.
//

#import "UILoginViewController.h"
#import "HttpConnect.h"
#import "CgiStringList.h"
#import "JSON.h"
#import "ImInAppDelegate.h"

#import "UserContext.h"
#import "SnsKeyChain.h"
#import "SnsRegistController.h"
#import "Utils.h"
#import "const.h"
#import "UIPlazaViewController.h"
#import "ViewControllers.h"
#import "CpData.h"
#import "OAuthWebViewController.h"
#import "NSString+URLEncoding.h"
#import "CommonWebViewController.h"
#import "SetAuthTokenEx.h"
#import "SingupViewController.h"
#import "iToast.h"

@implementation UILoginViewController

@synthesize authToken;
@synthesize paranLogin;
@synthesize isPreBtn;
@synthesize setAuthTokenEx;

- (void)dealloc {	
	if (connect1 != nil)
	{
		[connect1 stop];
		[connect1 release];
		connect1 = nil;
	}

	[authToken release];
	[setAuthTokenEx release];
	[super dealloc];
}

#pragma mark -
#pragma mark life cycle

- (void)viewDidLoad {
	animatedImages = nil;
	connect1 = nil;
	
	updateRetryCount = 0;
	
	userID.delegate = self;
	userPW.delegate = self;
	self.authToken = nil;
	[UserContext sharedUserContext].userPhoneNumber = @"";
	[self logViewControllerName];
}

- (void)viewDidUnload {

}

- (void) viewWillAppear:(BOOL)animated
{
	if (paranLogin) {
		MY_LOG(@"paranLogin YES");
		btnTwitter.hidden = YES;
		btnFacebook.hidden = YES;
		otherLoginImg.hidden = YES;
//		GA1(@"아임인로그인");
	}
	else {
		MY_LOG(@"paranLogin NO");
		btnTwitter.hidden = NO;
		btnFacebook.hidden = NO;
		otherLoginImg.hidden = NO;
	}
	
	if (isPreBtn) { // YES
		MY_LOG(@"이전버튼 보임");
		btnPre.hidden = NO;
	}
	else { // NO
		MY_LOG(@"이전버튼 숨김");
		btnPre.hidden = YES;
	}
}


- (void) viewWillDisappear:(BOOL)animated
{

	if (connect1 != nil) {
		[connect1 stop];
		[connect1 release];
		connect1 = nil;
	}
}

- (void) setParanLogin
{
	btnTwitter.hidden = YES;
	btnFacebook.hidden = YES;
}

#pragma mark -
#pragma mark 로그인 클릭 혹은 자동 로그인

- (IBAction) doLogin:(id)sender  { 
	if (paranLogin) {
		GA3(@"아임인로그인", @"로그인2", nil);
	}
	
	[UserContext sharedUserContext].lastMsg = nil;
	self.authToken = nil;
	
	[self backgroundTap:sender];
	if([userID.text isEqualToString:@""] || [userPW.text isEqualToString:@""]) {
		[CommonAlert alertWithTitle:@"에러" message:@"아이디와 패스워드를 입력해주세요"];

		return;
	}
	
	CgiStringList* strPostData=[[CgiStringList alloc]init:@"&"];
	[strPostData setMapString:@"ct" keyvalue:@"json"];
	[strPostData setMapString:@"cskey" keyvalue:SNS_CONSUMER_KEY];
	
	NSString* tempID;
	NSString* tempDomain;
	
	NSRange range = [userID.text rangeOfString:@"@"];
	MY_LOG(@"pos = %d", range.location);
	
	if (range.location != NSNotFound) { // 골뱅이가 있으면 
		tempID = [userID.text substringToIndex:range.location];
		tempDomain = [userID.text substringFromIndex:range.location+1]; // 지정한 위치에서 부터 끝까지 문자열 가져오기
	}
	else { // 골뱅이가 없으면
		tempID = userID.text;
		tempDomain = @"paran.com";
	}
	
	MY_LOG(@"ID :  %@, DOMAIN : %@", tempID, tempDomain);
	
	[strPostData setMapString:@"userid" keyvalue:tempID];
	[strPostData setMapString:@"domain" keyvalue:tempDomain];
	[strPostData setMapString:@"passwd" keyvalue:userPW.text];
	NSString* sign = [NSString stringWithFormat:@"%@%@%@%@",tempID,tempDomain,SNS_CONSUMER_KEY,SNS_SIGNATURE];
	[strPostData setMapString:@"signature" keyvalue:[Utils digest:sign]];
	if (connect1 != nil)
	{
		[connect1 stop];
		[connect1 release];
		connect1 = nil;
	}
	connect1 = [[HttpConnect alloc] initWithURL:PROTOCOL_USERAUTH
						   postData: [strPostData description]
						   delegate: self
					   doneSelector: @selector(onTransDone:)    
					  errorSelector: @selector(onResultError:)  
				   progressSelector: nil];
	[strPostData release];
	
	MY_LOG(@"---> EncryptString : %@",[Utils encryptString]);
}

- (void) apiFailed {
	UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"알림" message:@"네트워크가 불안정합니다.\n재시도 하시겠습니까?"
													delegate:self cancelButtonTitle:@"재시도" otherButtonTitles:@"앱종료", nil] autorelease];
	
	alert.tag = 100;
	[alert show];
}

- (void) apiDidLoad:(NSDictionary *)result
{
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
}

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
	} 
}

- (void) requestSetAuthTonkenEx
{
    if (setAuthTokenEx) {
        [setAuthTokenEx requestWithAuth:NO withIndicator:YES]; 
    }
}

- (void) onTransDone:(HttpConnect*)up
{
	MY_LOG(@"%@", up.stringReply);
	
	SBJSON* jsonParser = [SBJSON new];
	[jsonParser setHumanReadable:YES];
	[UserContext sharedUserContext].userToken = authToken;
	
	NSDictionary* results = (NSDictionary *)[jsonParser objectWithString:up.stringReply error:NULL];
	[jsonParser release];
	
	if (connect1 != nil)
	{
		[connect1 release];
		connect1 = nil;
	}

	
	if (authToken == nil)
	{		
		NSNumber* resultNumber = (NSNumber*)[results objectForKey:@"rtcode"];
		
		if ([resultNumber intValue] != 0 && [resultNumber intValue] != 222 && [resultNumber intValue] != 225) { //에러처리

			[CommonAlert alertWithTitle:@"로그인 오류" message:[results objectForKey:@"rtmsg"]];
			
			if (connect1 != nil)
			{
				[connect1 release];
				connect1 = nil;
			}
			return;
		}
		self.authToken = [[[NSString alloc] initWithFormat:@"%@",[results objectForKey:@"atkey"]] autorelease];
		[UserContext sharedUserContext].token = authToken;
		[UserContext sharedUserContext].userNo = [results objectForKey:@"userno"];
		[UserContext sharedUserContext].oAuth = @""; // oAuth로그인이 아니기에 oAuth값에 "" 처리
		MY_LOG(@"%@",authToken);
				
		if ([authToken compare:@""] == NSOrderedSame)
		{
			MY_LOG(@"Auth Token == Null String");
			self.authToken = nil;
			return;
		}

		
		self.setAuthTokenEx = [[[SetAuthTokenEx alloc] init] autorelease];
		setAuthTokenEx.delegate = self;
		//여기는 로그인 버튼을 통해 하는 인증이라서 oauth가 아닌 paran인증이라고 본다.
        NSString *appVer = [ApplicationContext appVersion];

		[setAuthTokenEx.params addEntriesFromDictionary:[NSDictionary dictionaryWithObjectsAndKeys:@"3", @"at", 
														 authToken, @"av", 
														 [ApplicationContext sharedApplicationContext].apiVersion, @"ver", 
														 @"ON", @"mode",
														 [UserContext sharedUserContext].deviceToken, @"deviceToken",
                                                         appVer, @"appVer",
														 nil]];
		[setAuthTokenEx requestWithAuth:NO withIndicator:YES];
        
        if (![[UserContext sharedUserContext].deviceToken isEqualToString:@"invalid_device_token"]) {
            //보내는 시점에 invalid_device_token가 아니라 제대로 된 토큰이라면 보내진 것으로 간주한다.
            [UserContext sharedUserContext].deviceTokenSent = YES;
        }
	}
}

- (void) onResultError:(HttpConnect*)up
{	
	MY_LOG(@"Login Error : %@", up.stringError);
	if (up.stringError != nil && [up.stringError compare:@""] != NSOrderedSame ) 
    {
        UIWindow *window = [[[UIApplication sharedApplication] windows] objectAtIndex:0];
        UIView *v = (UIView *)[window viewWithTag:TAG_iTOAST];
        if (!v) {
            iToast *msg = [[iToast alloc] initWithText:up.stringError];
            [msg setDuration:2000];
            [msg setGravity:iToastGravityCenter];
            [msg show];
            [msg release];
        }
        //		[CommonAlert alertWithTitle:@"에러" message:up.stringError];
	}
	if (connect1 != nil)
	{
		[connect1 release];
		connect1 = nil;
	}
}

- (IBAction) doTwitterLogin:(id)sender { // 웹뷰:oAuth 로그인
	GA3(@"아임인로그인", @"트위터", nil);
	NSString* udid = [[ApplicationContext sharedApplicationContext] getDeviceUniqueIdentifier];
	
	NSString* temp = [NSString stringWithFormat:@"loginsitename=twitter.com&loginappname=%@&loginenv=app&loginrturl=%@&logincskey=%@&logindevice=%@", [IMIN_APP_NAME URLEncodedString], [CALLBACK_URL URLEncodedString], [SNS_CONSUMER_KEY  URLEncodedString], [udid URLEncodedString]] ;
	NSString* oAuthUrl = [NSString stringWithFormat:@"%@?%@", OAUTH_LOGIN_URL, temp] ;
	
	OAuthWebViewController* myWebViewController = [[[OAuthWebViewController alloc] init] autorelease];
	myWebViewController.requestInfo = oAuthUrl;
	myWebViewController.webViewTitle = @"twitter 로그인";
	myWebViewController.authType = OAUTH_TYPE;
	
	MY_LOG(@"webViewTitle = %@, myWebViewController.requestInfo = %@",myWebViewController.webViewTitle ,myWebViewController.requestInfo);
	[myWebViewController setHidesBottomBarWhenPushed:YES];
	[self.navigationController pushViewController:myWebViewController animated:YES];		
}

- (IBAction) doFacebookLogin:(id)sender {	// 웹뷰:oAuth 로그인
	GA3(@"아임인로그인", @"페이스북", nil);
	NSString* udid = [[ApplicationContext sharedApplicationContext] getDeviceUniqueIdentifier];	

	NSString* temp = [NSString stringWithFormat:@"loginsitename=facebook.com&loginappname=%@&loginenv=app&loginrturl=%@&logincskey=%@&logindevice=%@", [IMIN_APP_NAME URLEncodedString], [CALLBACK_URL URLEncodedString], [SNS_CONSUMER_KEY  URLEncodedString], [udid URLEncodedString]] ;
	NSString* oAuthUrl = [NSString stringWithFormat:@"%@?%@", OAUTH_LOGIN_URL, temp] ;

	OAuthWebViewController* myWebViewController = [[[OAuthWebViewController alloc] init] autorelease];
	
	myWebViewController.requestInfo = oAuthUrl;
	myWebViewController.webViewTitle = @"facebook 로그인";
	myWebViewController.authType = OAUTH_TYPE;
	MY_LOG(@"webViewTitle = %@, myWebViewController.requestInfo = %@",myWebViewController.webViewTitle ,myWebViewController.requestInfo);
	[myWebViewController setHidesBottomBarWhenPushed:YES];
	[self.navigationController pushViewController:myWebViewController animated:YES];	
}

- (IBAction) doRegister : (id) sender {
	GA3(@"아임인로그인", @"회원가입", nil);
	SingupViewController* singupViewController = [[SingupViewController alloc] initWithNibName:@"SingupViewController" bundle:nil];
	[singupViewController setHidesBottomBarWhenPushed:YES];
	[self.navigationController pushViewController:singupViewController animated:YES];
	[singupViewController release];
//	if (paranLogin) {
//		GA3(@"아임인로그인", @"도움말", nil);
//	}
//	CommonWebViewController* commonWebVC = [[[CommonWebViewController alloc]initWithNibName:@"CommonWebViewController" bundle:nil] autorelease];
//	commonWebVC.showTitle = YES;
//	commonWebVC.titleString = @"도움말";
//	commonWebVC.urlString = HELP_URL;
//	
//	[self presentModalViewController:commonWebVC animated:YES];
}

- (IBAction) doFindId:(id)sender
{
	if (paranLogin) {
		GA3(@"아임인로그인", @"파란아이디찾기", nil);
	}
	NSString* temp = [NSString stringWithFormat:@"env=app&cskey=%@", [SNS_CONSUMER_KEY  URLEncodedString]] ;
	NSString* Url = [NSString stringWithFormat:@"%@?%@", FIND_ID, temp] ;

	CommonWebViewController* commonWebVC = [[[CommonWebViewController alloc] initWithNibName:@"CommonWebViewController" bundle:nil] autorelease];
	commonWebVC.titleString = @"아이디 찾기";
	commonWebVC.urlString = Url;
    commonWebVC.viewType = TITLE_BOTTOM;
	
	[self presentModalViewController:commonWebVC animated:YES];
}
- (IBAction) doFindPassword:(id)sender
{
	if (paranLogin) {
		GA3(@"아임인로그인", @"파란비밀번호찾기", nil);
	}
	NSString* temp = [NSString stringWithFormat:@"env=app&cskey=%@", [SNS_CONSUMER_KEY  URLEncodedString]] ;
	NSString* Url = [NSString stringWithFormat:@"%@?%@", FIND_PW, temp] ;

	CommonWebViewController* commonWebVC = [[[CommonWebViewController alloc] initWithNibName:@"CommonWebViewController" bundle:nil] autorelease];
	commonWebVC.titleString = @"비밀번호 찾기";
	commonWebVC.urlString = Url;
    commonWebVC.viewType = TITLE_BOTTOM;
	
	[self presentModalViewController:commonWebVC animated:YES];
}

- (IBAction) backgroundTap : (id)sender 
{
	[userID resignFirstResponder];
	[userPW resignFirstResponder];
	[userIDimgView setImage:[UIImage imageNamed:@"login_idput_off.png"]];
	[userPWimgView setImage:[UIImage imageNamed:@"login_pwput_off.png"]];
}

#pragma mark -
#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	MY_LOG(@"return");
	[textField resignFirstResponder];
	return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
		
	MY_LOG(@"TextFiled Tag:%d",textField.tag);
	if (textField.tag == 0) 
	{
		[userIDimgView setImage:[UIImage imageNamed:@"login_idput_on.png"]];
		[userPWimgView setImage:[UIImage imageNamed:@"login_pwput_off.png"]];
	}
	
	if (textField.tag == 1)
	{
		[userIDimgView setImage:[UIImage imageNamed:@"login_idput_off.png"]];
		[userPWimgView setImage:[UIImage imageNamed:@"login_pwput_on.png"]];
	}
}


- (IBAction) popViewController {
	[ApplicationContext sharedApplicationContext].preTokenExist = YES;
	[self.navigationController popViewControllerAnimated:YES];
}


@end



