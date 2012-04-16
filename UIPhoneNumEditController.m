//
//  UIPhoneNumEditController.m
//  ImIn
//
//  Created by mandolin on 10. 7. 20..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "UIPhoneNumEditController.h"
#import "JSON.h"
#import "const.h"
#import "UserContext.h"
#import "CgiStringList.h"
#import "Utils.h"
#import "iToast.h"
@implementation UIPhoneNumEditController

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	[self.navigationController setNavigationBarHidden:YES animated:NO];
	
	
	connect = nil;
	//userPhone.delegate = self;
	//[self setFieldText:phoneNo target:userPhone];
	userPhone.text = [Utils addDashToPhoneNumber:phoneNo];

    [super viewDidLoad];
}

- (void) viewWillAppear:(BOOL)animated
{
//	if ([phoneNo isEqualToString:@""]) {
//		[userPhone becomeFirstResponder];	
//	}
}

- (void) setPnumber:(NSString*) pNumber
{
	if (pNumber == nil || [pNumber compare:@""] == NSOrderedSame)
		phoneNo = @"";
	else
		phoneNo = [[NSString alloc] initWithString:pNumber];
}

- (void) viewWillDisappear:(BOOL)animated
{
	if (connect != nil)
	{	
		[connect stop];
		[connect release];
		connect = nil;
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
	if (connect != nil)
	{	
		[connect stop];
		[connect release];
		connect = nil;
	}
	[phoneNo release];

    [super dealloc];
}

- (IBAction) backgroundTap : (id)sender 
{	
	
	[userPhone resignFirstResponder];
	
}

- (IBAction) onClickCustomBack : (id)sender 
{
	[self.navigationController popViewControllerAnimated:NO];
}

- (IBAction) onClickCustomDone : (id)sender 
{
	/*
	NSString* pNumber = [[NSUserDefaults standardUserDefaults] stringForKey:@"SBFormattedPhoneNumber"];
	MY_LOG(@"iPhone Phone Number: %@", pNumber);
	MY_LOG(@"userPhone.text : %@", userPhone.text);
	if (pNumber != nil && [pNumber compare:@""] != NSOrderedSame)
	{
		if ([userPhone.text compare:[pNumber stringByReplacingOccurrencesOfString:@"+82 " withString:@"0"]] != NSOrderedSame)
		{
			[CommonAlert alertWithTitle:@"ImIn가입 오류" message:@"아이폰번호와 입력번호가 일치하지 않습니다."];
			return;
		}
	}
	*/
	
	
	NSString* correctText = [userPhone.text stringByReplacingOccurrencesOfString:@"-" withString:@""];
	correctText = [correctText stringByReplacingOccurrencesOfString:@"(" withString:@""];
	correctText = [correctText stringByReplacingOccurrencesOfString:@")" withString:@""];
	correctText = [correctText stringByReplacingOccurrencesOfString:@"+082" withString:@""];
	
	CgiStringList* strPostData=[[CgiStringList alloc]init:@"&"];
	[strPostData setMapString:@"svcId" keyvalue:SNS_IPHONE_SVCID];
    [strPostData setMapString:@"appVer" keyvalue:[ApplicationContext appVersion]];
	[strPostData setMapString:@"device" keyvalue:SNS_DEVICE_MOBILE_APP];
	[strPostData setMapString:@"profileImg" keyvalue:[UserContext sharedUserContext].userProfile];
	[strPostData setMapString:@"phoneNo" keyvalue:correctText];
	[strPostData setMapString:@"at" keyvalue:@"1"];
	[strPostData setMapString:@"av" keyvalue:[UserContext sharedUserContext].snsID];
	MY_LOG(@"Modify PhoneNumber Protocol for %@", [strPostData description]);
	connect = [[HttpConnect alloc] initWithURL:PROTOCOL_PROFILE_SET
									  postData: [strPostData description]
									  delegate: self
								  doneSelector: @selector(onTransDone:)    
								 errorSelector: @selector(onResultError:)  
							  progressSelector: nil];
	[strPostData release]; 
}

// TextField Delegate
- (BOOL)textField:(UITextField*)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString*)text
{
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
	
	
	return YES;
} 

- (void)setFieldText:(NSString*)str target:(UITextField*)tField
{
	tField.text = [Utils addDashToPhoneNumber:str];
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
		[UserContext sharedUserContext].userPhoneNumber = [results objectForKey:@"phoneNo"];
		[UserContext sharedUserContext].userProfile = [results objectForKey:@"profileImg"];
		[jsonParser release];
		[self.navigationController popViewControllerAnimated:NO];
	} else
	{ //에러처리
		[CommonAlert alertWithTitle:@"에러" message:[results objectForKey:@"description"]];
		[jsonParser release];
		return;
	}
	
	
}

- (void) onResultError:(HttpConnect*)up
{
    //itoast
    UIWindow *window = [[[UIApplication sharedApplication] windows] objectAtIndex:0];
    UIView *v = (UIView *)[window viewWithTag:TAG_iTOAST];
    if (!v) {
        iToast *msg = [[iToast alloc] initWithText:@" 인터넷 연결에 실패하였습니다. 네트워크 설정을 확인하거나, \n잠시 후 다시 시도해주세요~"];
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


@end
