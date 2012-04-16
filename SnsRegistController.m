//
//  SnsRegistController.m
//  ImIn
//
//  Created by mandolin on 10. 5. 28..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SnsRegistController.h"
#import "SnsKeyChain.h"
#import "UserContext.h"
#import "CommonAlert.h"
#import "json.h"
#import "HttpConnect.h"
#import "const.h"
#import "CgiStringList.h"
#import "AgreementSns.h"
#import "SetAuthTokenEx.h"
#import "iToast.h"
#import "util.h"



@implementation SnsRegistController
@synthesize setAuthTokenEx;
@synthesize badgeList;
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
	GA1(@"아임인시작페이지");
	
	[self.navigationController setNavigationBarHidden:YES animated:NO];
	isAgree1 = NO;
    isAgree2 = NO;
	userNick.delegate = self;
	
	connect = nil;
	
	NSString* regPhoneNum = [NSString stringWithFormat:@"%@",[UserContext sharedUserContext].userPhoneNumber];
	if ([regPhoneNum compare:@""] != NSOrderedSame)
	{	
		[self setFieldText:regPhoneNum target:userPhone];//  userPhone.text = regPhoneNum;
		userPhone.userInteractionEnabled = NO;
	}
	
	userPhone.delegate = self;
    
    realtimeBadge = [[RealtimeBadge alloc] init];
    realtimeBadge.delegate = self;
	
    [super viewDidLoad];
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
    [friendNick release];
    friendNick = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
	if (connect != nil)
	{	
		[connect stop];
		[connect release];
		connect = nil;
	}
	
	[setAuthTokenEx release];
    [badgeList release];
	
    [friendNick release];
    [super dealloc];
}

- (IBAction) backgroundTap : (id)sender 
{	
	// DH : backgroud 를 탭 할 시 키보드를 사라지게 한다.
	[userNick resignFirstResponder] ;
	[userPhone resignFirstResponder];
	//[registerNumBackTextField resignFirstResponder];
	// END DH
	
}


- (void) agreeIdCannotModify {
	UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"알림" message:@"한 번 입력하신 닉네임은 변경하실 수 없으니 신중하게 만들어주세요~"
													delegate:self cancelButtonTitle:@"취소" otherButtonTitles:@"계속", nil] autorelease];
	alert.tag = 100;
	[alert show];
}


- (void)alertView:(UIAlertView*)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (alertView.tag == 100)
	{
		if (buttonIndex == 1)
		{
			// 계속일때  일듯, 0이면 취소일대..
			MY_LOG(@"넘어간다");
			[self requestSnsJoin];
		}
		return;
	}	
	if (alertView.tag == 200)
	{
		if (buttonIndex == 0)
		{// 재시도일때
            [self performSelector:@selector(requestSetAuthTokenEx) withObject:nil afterDelay:0.5];
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

- (IBAction) onClickJoinBtn : (id)sender 
{
	// 7글자 초과 여부 검사
	if (userNick.text.length > 7 || userNick.text.length < 2) {
		[CommonAlert alertWithTitle:@"안내" message:@"닉네임은 2글자 이상 7글자 이하로 입력해주세요~!"];
		return;
	}

	if ([userNick.text compare:@""] == NSOrderedSame)
	{
		[CommonAlert alertWithTitle:@"아임IN가입 오류" message:@"닉네임이 입력되지 않았습니다."];
		return;
	}

	if (isAgree1 == NO || isAgree2 == NO)
	{
		[CommonAlert alertWithTitle:@"아임IN가입 오류" message:@"약관에 동의해 주세요"];
		return;
	}
	
	[self agreeIdCannotModify];
}

- (void) requestSnsJoin {
	CgiStringList* strPostData=[[CgiStringList alloc]init:@"&"];
	[strPostData setMapString:@"at" keyvalue:@"3"];
	[strPostData setMapString:@"av" keyvalue:[UserContext sharedUserContext].token];
	[strPostData setMapString:@"svcId" keyvalue:SNS_IPHONE_SVCID];
    [strPostData setMapString:@"appVer" keyvalue:[ApplicationContext appVersion]];
	[strPostData setMapString:@"ct" keyvalue:@"json"];
	[strPostData setMapString:@"agree" keyvalue:@"1"];
	[strPostData setMapString:@"nickname" keyvalue:userNick.text];
    [strPostData setMapString:@"recomNickname" keyvalue:friendNick.text];
	[strPostData setMapString:@"device" keyvalue:[ApplicationContext deviceId]];
	NSString* oAuthResult = [[SnsKeyChain sharedInstance] fetchoAuth];
	//이것이 추가되어야 할지 말지는 oauth인증이냐 마냐에 따라 틀려짐
	if (![oAuthResult isEqualToString:@""]) {
		[strPostData setMapString:@"oauth" keyvalue:oAuthResult];
	}
	
	MY_LOG(@"Send CreateSNS Protocol for %@", [strPostData description]);
	connect = [[HttpConnect alloc] initWithURL:PROTOCOL_CREATESNS
						   postData: [strPostData description]
						   delegate: self
					   doneSelector: @selector(onTransDone:)    
					  errorSelector: @selector(onResultError:)  
						progressSelector: nil];
	
	
	[strPostData release]; 
}
- (IBAction) onClickAgreement : (UIButton*)sender 
{
	AgreementSns *agreementView = [[[AgreementSns alloc] init] autorelease];
    if (sender.tag == 100) {
        agreementView.agreementTitle = @"아임IN 이용약관";
        agreementView.urlString = @"http://snsgw.paran.com/sns-gw/mTerms.html";
    } else {
        agreementView.agreementTitle = @"개인정보 수집, 이용 약관";
        agreementView.urlString = @"http://snsgw.paran.com/sns-gw/privacy.html";
    }
	[self.navigationController pushViewController:agreementView animated:YES];
}

- (IBAction) onChangeAgreementSwitch: (UISwitch*)sender
{
    if (sender.tag == 200) {
        isAgree1 = sender.on;
    } else {
        isAgree2 = sender.on;
    }
	
}
	 
// TextField Delegate
 - (BOOL)textField:(UITextField*)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString*)text
{
	if (textField.tag == 4) // Nick필드 처리
	{
        if ([text isEqualToString:@"\n"])
		{
			[textField resignFirstResponder];
			return NO;
		}
		return !([textField.text length] > 7 && [text length]> range.length);
	}
	if (textField.tag == 5) // 폰번호 입력필드 처리
	{
		if ([text isEqualToString:@"\n"])
		{
			[textField resignFirstResponder];
			return NO;
		}
		NSString* tempText = [textField.text stringByReplacingCharactersInRange:range withString:text];
		[self setFieldText:tempText target:textField];
		return NO;
	}
    // 초대한 사람 길이 체크
    if (textField.tag == 6) {
        if ([text isEqualToString:@"\n"])
		{
			[textField resignFirstResponder];
			return NO;
		}
        return !([textField.text length] > 7 && [text length]> range.length);
    }
    
	return YES;
} 

- (void)setFieldText:(NSString*)str target:(UITextField*)tField
{
	tField.text = [Utils addDashToPhoneNumber:str];
}

- (void)requestSetAuthToken
{
    [ApplicationContext sharedApplicationContext].theFirstLogin = YES;
    
    //회원가입시 oAuth로그인이나 파란로그인이나 모두 가입시에 토큰이 결과값으로 온다. 일단.. openmainframe에서 해줄꺼라서 이걸 여기에 꼭 해줄필요는 없을듯..
    [[SnsKeyChain sharedInstance] setToken:[UserContext sharedUserContext].token]; 		
    [[SnsKeyChain sharedInstance] setoAuth:[UserContext sharedUserContext].oAuth];
    self.setAuthTokenEx = [[[SetAuthTokenEx alloc] init] autorelease];
    setAuthTokenEx.delegate = self;
    
    NSString* oAuthResult = [[SnsKeyChain sharedInstance] fetchoAuth];
    
    NSString *appVer = [ApplicationContext appVersion];
    
    if ([oAuthResult isEqualToString:@""]) {
        [setAuthTokenEx.params addEntriesFromDictionary:[NSDictionary dictionaryWithObjectsAndKeys:@"3", @"at", 
                                                         [UserContext sharedUserContext].token, @"av", 
                                                         [ApplicationContext sharedApplicationContext].apiVersion, @"ver", 
                                                         @"ON", @"mode",
                                                         [UserContext sharedUserContext].deviceToken, @"deviceToken",
                                                         appVer, @"appVer",
                                                         nil]];
        
    } else {
        [setAuthTokenEx.params addEntriesFromDictionary:[NSDictionary dictionaryWithObjectsAndKeys:@"3", @"at", 
                                                         [UserContext sharedUserContext].token, @"av", 
                                                         [ApplicationContext sharedApplicationContext].apiVersion, @"ver", 
                                                         @"ON", @"mode",
                                                         [UserContext sharedUserContext].deviceToken, @"deviceToken",
                                                         appVer, @"appVer",
                                                         oAuthResult, @"oauth",
                                                         nil]];
    }
    
    [setAuthTokenEx requestWithAuth:NO withIndicator:YES];
}

- (void) onTransDone:(HttpConnect*)up
{	MY_LOG(@"%@", up.stringReply);
	SBJSON* jsonParser = [SBJSON new];
	[jsonParser setHumanReadable:YES];
	NSDictionary* results = (NSDictionary *)[jsonParser objectWithString:up.stringReply error:NULL];
	
	NSNumber* resultNumber = (NSNumber*)[results objectForKey:@"result"];

	if (connect != nil)
	{
		[connect release];
		connect = nil;
	}
    	
	if ([resultNumber intValue] == 1)
	{ // 정상 처리
        self.badgeList = [results objectForKey:@"data"];
        realtimeBadge.badgeList = badgeList;
                
        [self requestSetAuthToken];
	} else
	{ //에러처리
		[CommonAlert alertWithTitle:@"에러" message:[results objectForKey:@"description"]];
	}
	
	[jsonParser release];
	return;
}

- (void) onResultError:(HttpConnect*)up
{
    //itoast
    UIWindow *window = [[[UIApplication sharedApplication] windows] objectAtIndex:0];
    UIView *v = (UIView *)[window viewWithTag:TAG_iTOAST];
    if (!v) {
        iToast *msg = [[iToast alloc] initWithText:@" 인터넷 연결에 실패하였습니다. 네트워크 설정을 확인하거나, \n잠시 후 다시 시도해주세요~다"];
        [msg setDuration:2000];
        [msg setGravity:iToastGravityCenter];
        [msg show];
        [msg release];
    }
    //	[CommonAlert alertWithTitle:@"에러" message:@"네트웍 연결에 실패하였습니다."];
	if (connect != nil)
	{
		[connect release];
		connect = nil;
	}
	
}

- (void) apiFailed {
	UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"알림" message:@"네트워크가 불안정합니다.\n재시도 하시겠습니까?"
													delegate:self cancelButtonTitle:@"재시도" otherButtonTitles:@"앱종료", nil] autorelease];
	
	alert.tag = 200;
	[alert show];
}

- (void) apiDidLoad:(NSDictionary *)result
{
	if ([[result objectForKey:@"func"] isEqualToString:@"setAuthTokenEx"]) {
		
		NSNumber* resultNumber = (NSNumber*)[result objectForKey:@"result"];
		
		if ([resultNumber intValue] == 0) { //에러처리
			[CommonAlert alertWithTitle:@"로그인 에러" message:[result objectForKey:@"description"]];
			return;
		}
		
		[[UserContext sharedUserContext] loginProcess:result];

        [[UserContext sharedUserContext] recordKissMetricsWithEvent:@"Signed Up" withInfo:nil];
        
        if ([badgeList count] > 0) {
            [realtimeBadge downloadImageWithArray:badgeList];
        } else {
            [self.navigationController popToRootViewControllerAnimated:NO];
        }
	}
}

- (void) badgeDownloadCompleted
{
    [[ApplicationContext sharedApplicationContext] badgeAcquisitionViewShow:realtimeBadge.badgeList];
//    [[ApplicationContext sharedApplicationContext] performSelector:@selector(badgeAcquisitionViewShow:) withObject:realtimeBadge.badgeList afterDelay:0.0f];
    [self.navigationController popToRootViewControllerAnimated:NO];
}



@end
