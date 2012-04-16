//
//  UIMasterWriteController.m
//  ImIn
//
//  Created by mandolin on 10. 9. 10..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "UIMasterWriteController.h"
#import "const.h"
#import "HttpConnect.h"
#import "UserContext.h"
#import "CgiStringList.h"
#import "JSON.h"
#import "iToast.h"
@implementation UIMasterWriteController
@synthesize poiKey;
@synthesize currentTextColor;
@synthesize stringWillChangeWithNewTitle;

static const int kMAX_CHARACTER_LENGTH = 20;

- (void) calculateRemainLength
{
	//self.currentTextColor = textLengthRemain.textColor;
	textLengthRemain.text = [NSString stringWithFormat:@"%d", kMAX_CHARACTER_LENGTH - [contentTextView.text length]];
	if ([contentTextView.text length] > kMAX_CHARACTER_LENGTH) {
		textLengthRemain.textColor = [UIColor redColor];
	} else {
		textLengthRemain.textColor = self.currentTextColor;
	}
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}



- (void)viewDidLoad {
    [super viewDidLoad];
	
	connect = nil;
	
	UIImage *image = [UIImage imageNamed:@"round_input_box.png"]; 
	UIImage *strImage = [image stretchableImageWithLeftCapWidth:12 topCapHeight:12]; 
	textViewBgImage.image = strImage;
	[contentTextView becomeFirstResponder];
	contentTextView.text = stringWillChangeWithNewTitle;
	self.currentTextColor = textLengthRemain.textColor;
	[self calculateRemainLength];
}



// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return [ApplicationContext sharedApplicationContext].shouldRotate;
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewWillAppear:(BOOL)animated
{
	[self logViewControllerName];
	[super viewWillAppear:animated];
}


- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewDidDisappear:(BOOL)animated {
	//[[OperationQueue queue] cancelAllOperations];
}

- (void)viewWillDisappear:(BOOL)animated {
	if (connect != nil) {
		[connect stop];
		[connect release];
		connect = nil;
	}
}

- (void)dealloc {
	if (connect != nil)
	{
		[connect stop];
		[connect release];
		connect = nil;
	}
	[poiKey release];
	[currentTextColor release];
	[stringWillChangeWithNewTitle release];
    [super dealloc];
}


#pragma mark -
#pragma mark Keyboard event 처리

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range 
 replacementText:(NSString *)text
{
    // Any new character added is passed in as the "text" parameter
    if ([text isEqualToString:@"\n"]) {
        // Be sure to test for equality using the "isEqualToString" message
        [textView resignFirstResponder];
		
        // Return FALSE so that the final '\n' character doesn't get added
        return FALSE;
    }
    // For any other character return TRUE so that the text gets added to the view
    return TRUE;
}

- (void)textViewDidChange:(UITextView *)textView {
	[self calculateRemainLength];
}


#pragma mark -
#pragma mark navigation 

- (IBAction) popViewController {
	[self.navigationController dismissModalViewControllerAnimated:YES];
}


#pragma mark =
#pragma mark query to server

- (IBAction) doRequest {
	if ([contentTextView.text length] > kMAX_CHARACTER_LENGTH) 
	{
		[CommonAlert alertWithTitle:@"알림" message:@"20글자를 초과하셨습니다."];
		return;
	}

	[self request];
}

#pragma mark -
#pragma mark 글쓰기 요청

- (void) onResultError:(HttpConnect*)up
{
    //itoast
    UIWindow *window = [[[UIApplication sharedApplication] windows] objectAtIndex:0];
    UIView *v = (UIView *)[window viewWithTag:TAG_iTOAST];
    if (!v) {
        iToast *msg = [[iToast alloc] initWithText:@"네트워크가 불안합니다. \n잠시 후 다시 시도해 주세요~"];
        [msg setDuration:2000];
        [msg setGravity:iToastGravityCenter];
        [msg show];
        [msg release];
    }
//	[CommonAlert alertWithTitle:@"안내" message:@"단말의 네트워크 전송에 문제가 있습니다."];
	if (connect != nil)
	{
		[connect release];
		connect = nil;
	}
}

- (void) onTransDone:(HttpConnect*)up
{
	//	MY_LOG(@"<!-- CmtWrite");
		MY_LOG(@"%@", up.stringReply);
	//	MY_LOG(@"CmtWrite -->");
	
	SBJSON* jsonParser = [SBJSON new];
	[jsonParser setHumanReadable:YES];
	
	NSDictionary* results = (NSDictionary *)[jsonParser objectWithString:up.stringReply error:NULL];
	[jsonParser release];
	
	if (connect != nil)
	{
		[connect release];
		connect = nil;
	}
	NSNumber* resultNumber = (NSNumber*)[results objectForKey:@"result"];
	
	if ([resultNumber intValue] == 0) { //에러처리
		[CommonAlert alertWithTitle:@"안내" message:[results objectForKey:@"description"]];
		return;
	}
	
	[CommonAlert alertWithTitle:@"안내" message:@"마스터 한마디를 등록 하였습니다."];

	// 이전 뷰컨트롤러에서 넘겨준 스트링이 있다면 값을 새로운 한마디로 바꾼다.
	if (self.stringWillChangeWithNewTitle != nil) {
		[self.stringWillChangeWithNewTitle setString:contentTextView.text];
	}
	[self popViewController];
}


- (void) request
{
	if (poiKey == nil || [poiKey compare:@""] == NSOrderedSame)
	{
		[self.navigationController popViewControllerAnimated:YES];
		return;
	}
	//if ([contentTextView.text compare:@""] == NSOrderedSame) return;
	UserContext* userContext = [UserContext sharedUserContext];
	
	CgiStringList* strPostData=[[CgiStringList alloc]init:@"&"];
	[strPostData setMapString:@"svcId" keyvalue:SNS_IPHONE_SVCID];
    [strPostData setMapString:@"appVer" keyvalue:[ApplicationContext appVersion]];
	[strPostData setMapString:@"device" keyvalue:SNS_DEVICE_MOBILE_APP];	
	[strPostData setMapString:@"at" keyvalue:@"1"];
	[strPostData setMapString:@"av" keyvalue:userContext.snsID];
	[strPostData setMapString:@"poiKey" keyvalue:poiKey];
	[strPostData setMapString:@"msg" keyvalue:contentTextView.text];
	
	if (connect != nil)
	{
		[connect stop];
		[connect release];
		connect = nil;
	}
	
	connect = [[HttpConnect alloc] initWithURL:PROTOCOL_CAPTAIN_MSG_WRITE
									  postData: [strPostData description]
									  delegate: self
								  doneSelector: @selector(onTransDone:)    
								 errorSelector: @selector(onResultError:)  
							  progressSelector: nil];
	[strPostData release];
}



@end
