//
//  CheckMyPhoneViewController.m
//  ImIn
//
//  Created by edbear on 10. 12. 15..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "CheckMyPhoneViewController.h"
#import "SendAuthKey.h"
#import "ProfileUpdate.h"
#import "iToast.h"
@implementation CheckMyPhoneViewController

@synthesize sendAuthKey, authKey, profileUpdate;

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

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/

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
	[sendAuthKey release];
	[authKey release];
	
    [super dealloc];
}

- (IBAction) popVC {
	[self.navigationController popViewControllerAnimated:YES];
}

- (IBAction) requestSendAuthKey {
	self.sendAuthKey = [[[SendAuthKey alloc] init] autorelease];
	self.sendAuthKey.delegate = self;
	
	NSString* strTextField = phoneNumberTextField.text;
	if ([ strTextField isEqualToString:@"" ] || [strTextField length] < 4) {
		[CommonAlert alertWithTitle:@"안내" message:@"전화번호를 입력해주세요~"];
		return;
	}

    self.sendAuthKey.phoneNo = phoneNumberTextField.text;
    [self.sendAuthKey request];
}

- (IBAction) requestProfileUpdate {	
	
	if ([authValueTextField.text isEqualToString:@""]) {
		[CommonAlert alertWithTitle:@"안내" message:@"인증번호를 입력해주세요."];
		return;
	}
	
	if ([phoneNumberTextField.text isEqualToString:@""]) {
		[CommonAlert alertWithTitle:@"안내" message:@"전화번호를 입력해주세요."];
		return;
	}
	
	self.profileUpdate = [[[ProfileUpdate alloc] init] autorelease];
	profileUpdate.delegate = self;
	
	[profileUpdate.params addEntriesFromDictionary:
	 [NSDictionary dictionaryWithObjectsAndKeys:
	  [phoneNumberTextField.text stringByReplacingOccurrencesOfString:@"-" withString:@""], @"phoneNo",
	  authValueTextField.text, @"authValue",
	  authKey, @"authKey",
	  [UserContext sharedUserContext].userProfile, @"profileImg",
	  nil]];
	[profileUpdate request];
}


- (void) apiFailed {
	MY_LOG(@"API 에러");
    UIWindow *window = [[[UIApplication sharedApplication] windows] objectAtIndex:0];
    UIView *v = (UIView *)[window viewWithTag:TAG_iTOAST];
    if (!v) {
        iToast *msg = [[iToast alloc] initWithText:@"인터넷 연결에 실패하였습니다. 네트워크 설정을 확인하거나, \n잠시 후 다시 시도해주세요~"];
        [msg setDuration:2000];
        [msg setGravity:iToastGravityCenter];
        [msg show];
        [msg release];
    }

//    [CommonAlert alertWithTitle:@"알림" message:@"네트웍 연결을 확인해주세요."];
}

- (void) apiDidLoad:(NSDictionary *)result {
		
	if ([[result objectForKey:@"func"] isEqualToString:@"sendAuthKey"]) {
		if ([[result objectForKey:@"result"] boolValue]) {
			[CommonAlert alertWithTitle:@"안내" message:@"인증번호가 발송되었습니다."];
			
			self.authKey = [result objectForKey:@"authKey"];
			
		} // 에러인 경우는 이미 경고창을 띄웠기 때문에 띄워주지 않음
	}

	if ([[result objectForKey:@"func"] isEqualToString:@"profileUpdate"]) {
		if ([[result objectForKey:@"result"] boolValue]) {
			[CommonAlert alertWithTitle:@"안내" message:@"인증에 성공했습니다."];
			[UserContext sharedUserContext].cpPhone.isConnected = YES;
			[UserContext sharedUserContext].cpPhone.cpCode = @"-1";
			[UserContext sharedUserContext].cpPhone.blogId = [result objectForKey:@"phoneNo"];
			[self.navigationController popViewControllerAnimated:YES];
		} // 에러인 경우는 이미 경고창을 띄웠기 때문에 띄워주지 않음
	}
}

#pragma mark -
#pragma mark IBAction처리

- (IBAction) backgroundTap : (id)sender 
{	
	
	[phoneNumberTextField resignFirstResponder];
	[authValueTextField resignFirstResponder];
}

- (void)setFieldText:(NSString*)str target:(UITextField*)tField
{
	tField.text = [Utils addDashToPhoneNumber:str];
}

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



@end
