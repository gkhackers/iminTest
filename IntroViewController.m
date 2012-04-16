//
//  IntroViewController.m
//  ImIn
//
//  Created by park ja young on 11. 4. 1..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "IntroViewController.h"
#import "UILoginViewController.h"
#import "SingupViewController.h"
#import "SnsKeyChain.h"
#import "HttpConnect.h"
#import "SnsRegistController.h"
#import "UIPlazaViewController.h"
#import "SnsHelpController.h"
#import "SetAuthTokenEx.h"

@implementation IntroViewController
@synthesize authToken;
@synthesize setAuthTokenEx;


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
    [super viewDidLoad];
	
	CGRect viewFrame = CGRectMake(320,245,320,215);
	afterView.frame = viewFrame;
	
	isGuideShow = FALSE;
}

- (BOOL) isFirstLogin {
	NSString* visitResult = [[SnsKeyChain sharedInstance] fetchFirstVisit];
	MY_LOG(@"visitResult = %@", visitResult);
	if (visitResult == nil || [visitResult compare:@""] == NSOrderedSame) {
		return YES;
	} else {
		return NO;
	}
}
 
- (void) showGuide {
	isGuideShow = TRUE;
	SnsHelpController* snsHelp = [[SnsHelpController alloc] initWithNibName:@"SnsHelpController" bundle:nil];
	snsHelp.bEnableBack = YES;
	[self.navigationController pushViewController:snsHelp animated:YES];
	[snsHelp release];
}

- (void)viewWillAppear:(BOOL)animated {
	if ([self isFirstLogin]) { //처음 구동의 경우에만 회원가입 화면을 보이게 한다.	
        [[UserContext sharedUserContext] recordKissMetricsWithEvent:@"First Visits" withInfo:nil];
		if (!isGuideShow) { //가이드화면도 안본경우 FALSE인경우
			[self showGuide];
		}
		else { //가이드화면은 보였으나 처음이신가요 페이지가 안보인 경우
			[self moveView];
		}
	} else { //처음 구동이 아니면 토큰존재 여부 체크
		[self isTokenExist];
	}
}

- (void)viewWillDisappear:(BOOL)animated {

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
	

- (void) isTokenExist {
	NSString* tokenRet = [self getToken];
	if (tokenRet == nil || [tokenRet compare:@""] == NSOrderedSame) { // 토큰이 없으면 로그인창을 띄어준다.
		//토큰이 없으면 로그인 창을 보이게 한다.
		UILoginViewController* loginViewController = [[UILoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
		loginViewController.paranLogin = NO;
		loginViewController.isPreBtn = NO;
		[loginViewController setHidesBottomBarWhenPushed:YES];
		[self.navigationController pushViewController:loginViewController animated:NO];
		[loginViewController release];		
	}
	else { // 토큰이 있으면 아임인 인증을 한다.
		[UserContext sharedUserContext].token = tokenRet;
		NSString* oAuthResult = [[SnsKeyChain sharedInstance] fetchoAuth];
		
		self.setAuthTokenEx = [[[SetAuthTokenEx alloc] init] autorelease];
		setAuthTokenEx.delegate = self;
        
        NSString *appVer = [ApplicationContext appVersion];
		
		if ([oAuthResult isEqualToString:@""]) {
			[setAuthTokenEx.params addEntriesFromDictionary:[NSDictionary dictionaryWithObjectsAndKeys:@"3", @"at", 
															 tokenRet, @"av", 
															 [ApplicationContext sharedApplicationContext].apiVersion, @"ver", 
															 @"ON", @"mode",
															 [UserContext sharedUserContext].deviceToken, @"deviceToken",
                                                             appVer, @"appVer",
															 nil]];

		}
		else {
			[setAuthTokenEx.params addEntriesFromDictionary:[NSDictionary dictionaryWithObjectsAndKeys:@"3", @"at", 
															 tokenRet, @"av", 
															 [ApplicationContext sharedApplicationContext].apiVersion, @"ver", 
															 @"ON", @"mode",
															 [UserContext sharedUserContext].deviceToken, @"deviceToken",
                                                             appVer, @"appVer",
															 oAuthResult, @"oauth",
															 nil]];
		}

		[setAuthTokenEx requestWithAuth:NO withIndicator:YES];		
	}
	return;
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
				UILoginViewController* loginViewController = [[UILoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
				loginViewController.paranLogin = NO;
				loginViewController.isPreBtn = NO;
				[loginViewController setHidesBottomBarWhenPushed:YES];
				[self.navigationController pushViewController:loginViewController animated:NO];
				[loginViewController release];
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

- (void)requestSetAuthTonkenEx
{
    if (setAuthTokenEx) {
        [setAuthTokenEx requestWithAuth:NO withIndicator:YES];
    }
}

- (NSString*) getToken {
	NSString* tokenResult = [[SnsKeyChain sharedInstance] fetchToken];
	return tokenResult;
}


- (IBAction)goLogin
{
	GA3(@"가입", @"로그인", nil);
	UILoginViewController* loginViewController = [[UILoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
	loginViewController.paranLogin = NO;
	//loginViewController.isPreBtn = YES;
    loginViewController.isPreBtn = NO;
	[loginViewController setHidesBottomBarWhenPushed:YES];
	[self.navigationController pushViewController:loginViewController animated:YES];
	[loginViewController release];
}

- (IBAction)goRegister // 회원가입창
{
	GA3(@"가입", @"처음이신가요", nil);
	SingupViewController* singupViewController = [[SingupViewController alloc] initWithNibName:@"SingupViewController" bundle:nil];
	[singupViewController setHidesBottomBarWhenPushed:YES];
	[self.navigationController pushViewController:singupViewController animated:YES];
	[singupViewController release];
}

- (void)moveView {
	CGRect viewFrame = CGRectMake(0,245,320,215);
	preView.frame = viewFrame;
	
	viewFrame = CGRectMake(320,245,320,215);
	afterView.frame = viewFrame;
	
	preView.transform = CGAffineTransformMakeTranslation(0, 0);
	afterView.transform = CGAffineTransformMakeTranslation(0, 0);

	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.7];
	[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:preView cache:YES];
	[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:afterView cache:YES];
	
	preView.transform = CGAffineTransformMakeTranslation(-320, 0);
	afterView.transform = CGAffineTransformMakeTranslation(-320, 0);

	[UIView commitAnimations];
	[[SnsKeyChain sharedInstance] setFirstVisit:@"YES"];
}

@end
