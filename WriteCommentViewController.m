//
//  WriteCommentViewController.m
//  ImIn
//
//  Created by choipd on 10. 5. 20..
//  Copyright 2010 edbear. All rights reserved.
//

#import "WriteCommentViewController.h"
#import "const.h"
#import "HttpConnect.h"
#import "UserContext.h"
#import "CgiStringList.h"
#import "JSON.h"

#import "CommonAlert.h"

#import "ViewControllers.h"
#import "UIPlazaViewController.h"
#import "ReplyCellData.h"
#import "CmtWrite.h"

@implementation WriteCommentViewController
@synthesize poiData;
@synthesize parentId;
@synthesize currentTextColor;
@synthesize replyCellData;
@synthesize cmtWrite;

static const int kMAX_CHARACTER_LENGTH = 140;
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
    [super viewDidLoad];
	
	[ApplicationContext sharedApplicationContext].shouldRotate = YES;
	
	connect = nil;
	
	UIImage *image = [UIImage imageNamed:@"round_input_box.png"]; 
	UIImage *strImage = [image stretchableImageWithLeftCapWidth:12 topCapHeight:12]; 
	textViewBgImage.image = strImage;
	[contentTextView becomeFirstResponder];
	if (parentId == nil) {
		parentId = @"";
	}
	
	if (![parentId isEqualToString:@""]) {
		titleLabel.text = @"대댓글 쓰기";
	}
	
	self.currentTextColor = textLengthRemain.textColor;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

- (void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	
	CGRect f = textAreaView.frame;
	CGRect labelFrame = textLengthRemain.frame;
	
	if (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft || toInterfaceOrientation == UIInterfaceOrientationLandscapeRight) {
		f.size.height = 120;
		labelFrame.origin.y = 12;
		
	} else {
		f.size.height = 182;
		labelFrame.origin.y = 145;
	}
	textAreaView.frame = f;
	textLengthRemain.frame = labelFrame;

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
	[ApplicationContext sharedApplicationContext].shouldRotate = NO;
}

- (void)dealloc {
	if (connect != nil)
	{
		[connect stop];
		[connect release];
		connect = nil;
	}
	[parentId release];
	[currentTextColor release];
    [cmtWrite release];
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
	textLengthRemain.text = [NSString stringWithFormat:@"%d", kMAX_CHARACTER_LENGTH - [contentTextView.text length]];
	if ([contentTextView.text length] > kMAX_CHARACTER_LENGTH) {
		textLengthRemain.textColor = [UIColor redColor];
	} else {
		textLengthRemain.textColor = currentTextColor;
	}
}


#pragma mark -
#pragma mark navigation 

- (IBAction) popViewController {
	[self.navigationController dismissModalViewControllerAnimated:YES];
}


#pragma mark =
#pragma mark query to server
/**
 @brief 요청을 보내기 전에 글자수 제한을 체크함
 */
- (IBAction) doRequest {
	writeBtn.enabled = NO;
	if ([contentTextView.text length] > kMAX_CHARACTER_LENGTH) {
		[CommonAlert alertWithTitle:@"알림" message:@"140글자를 초과하셨습니다."];
		writeBtn.enabled = YES;
		return;
	}
	[self request];
}

#pragma mark -
#pragma mark iminprotocol
- (void) apiFailed {
    writeBtn.enabled = YES;
}

- (void) apiDidLoad:(NSDictionary *)result {
    if ([[result objectForKey:@"result"] boolValue] == NO) { //에러처리
		[CommonAlert alertWithTitle:@"안내" message:[result objectForKey:@"description"]];
		writeBtn.enabled = YES;
		return;
	}
    
	UserContext* uc = [UserContext sharedUserContext];
	
	replyCellData.parentID = [result objectForKey:@"parentId"];
	replyCellData.cmtID = [result objectForKey:@"cmtId"];
	replyCellData.nickName = uc.nickName;
	replyCellData.profileImgURL = uc.userProfile;
	replyCellData.comment = contentTextView.text;
	if ([[ApplicationContext deviceId] isEqualToString:SNS_DEVICE_MOBILE_APP_IPAD]) {
		replyCellData.description = @"지금, iPad";
	} else {
		replyCellData.description = @"지금, iPhone";
	}
	replyCellData.snsID = uc.snsID;
	replyCellData.status = @"add";	
	//대글이라면 post 정보(poiData)에 댓글 개수를 하나 증가시켜주자
	if ([parentId isEqualToString:@""]) {
		int newCmtCnt = [[poiData objectForKey:@"cmtCnt"] intValue] + 1;
		[poiData setObject:[NSString stringWithFormat:@"%d", newCmtCnt] forKey:@"cmtCnt"];
        [[UserContext sharedUserContext] recordKissMetricsWithEvent:@"Commented" withInfo:nil];
	} else {
        // 대댓글이라면
        [[UserContext sharedUserContext] recordKissMetricsWithEvent:@"Re-Commented" withInfo:nil];
    }
	
	[self.navigationController dismissModalViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark 글쓰기 요청

//- (void) onResultError:(HttpConnect*)up
//{
//	[CommonAlert alertWithTitle:@"안내" message:@"단말의 네트워크 전송에 문제가 있습니다."];
//	if (connect != nil)
//	{
//		[connect release];
//		connect = nil;
//	}
//	writeBtn.enabled = YES;
//}
///**
// @brief 댓글 쓰기 결과 처리
// */
//- (void) onTransDone:(HttpConnect*)up
//{
////	MY_LOG(@"<!-- CmtWrite");
////	MY_LOG(@"%@", up.stringReply);
////	MY_LOG(@"CmtWrite -->");
//	
//	SBJSON* jsonParser = [SBJSON new];
//	[jsonParser setHumanReadable:YES];
//	
//	NSDictionary* results = (NSDictionary *)[jsonParser objectWithString:up.stringReply error:NULL];
//	[jsonParser release];
//	if (connect != nil)
//	{
//		[connect release];
//		connect = nil;
//	}
//	if ([[results objectForKey:@"result"] boolValue] == NO) { //에러처리
//		[CommonAlert alertWithTitle:@"안내" message:[results objectForKey:@"description"]];
//		writeBtn.enabled = YES;
//		return;
//	}
//	    
//	UserContext* uc = [UserContext sharedUserContext];
//	
//	replyCellData.parentID = [results objectForKey:@"parentId"];
//	replyCellData.cmtID = [results objectForKey:@"cmtId"];
//	replyCellData.nickName = uc.nickName;
//	replyCellData.profileImgURL = uc.userProfile;
//	replyCellData.comment = contentTextView.text;
//	if ([[ApplicationContext deviceId] isEqualToString:SNS_DEVICE_MOBILE_APP_IPAD]) {
//		replyCellData.description = @"지금, iPad";
//	} else {
//		replyCellData.description = @"지금, iPhone";
//	}
//	replyCellData.snsID = uc.snsID;
//	replyCellData.status = @"add";	
//	//대글이라면 post 정보(poiData)에 댓글 개수를 하나 증가시켜주자
//	if ([parentId isEqualToString:@""]) {
//		int newCmtCnt = [[poiData objectForKey:@"cmtCnt"] intValue] + 1;
//		[poiData setObject:[NSString stringWithFormat:@"%d", newCmtCnt] forKey:@"cmtCnt"];
//        [[UserContext sharedUserContext] recordKissMetricsWithEvent:@"Commented" withInfo:nil];
//	} else {
//        // 대댓글이라면
//        [[UserContext sharedUserContext] recordKissMetricsWithEvent:@"Re-Commented" withInfo:nil];
//    }
//	
//
//	
//	[self.navigationController dismissModalViewControllerAnimated:YES];
//}

- (NSString*) localIPAddress
{
	return @"127.0.0.1";
}
/**
 @brief 댓글/대댓글쓰기 요청
 */
- (void) request
{
    self.cmtWrite = [[[CmtWrite alloc] init] autorelease];
    cmtWrite.delegate = self;
    [cmtWrite.params addEntriesFromDictionary:[NSDictionary dictionaryWithObject:[self localIPAddress] forKey:@"ip"]];
    [cmtWrite.params addEntriesFromDictionary:[NSDictionary dictionaryWithObject:[poiData objectForKey:@"postId"] forKey:@"postId"]];
    if(![parentId isEqualToString:@""]) {
        [cmtWrite.params addEntriesFromDictionary:[NSDictionary dictionaryWithObject:parentId forKey:@"parentId"]];
    }
    [cmtWrite.params addEntriesFromDictionary:[NSDictionary dictionaryWithObject:contentTextView.text forKey:@"comment"]];
    [cmtWrite request];
    

//	UserContext* userContext = [UserContext sharedUserContext];
//	
//	CgiStringList* strPostData=[[CgiStringList alloc]init:@"&"];
//	[strPostData setMapString:@"svcId" keyvalue:SNS_IPHONE_SVCID];
//    [strPostData setMapString:@"appVer" keyvalue:[ApplicationContext appVersion]];
//	[strPostData setMapString:@"device" keyvalue:[ApplicationContext deviceId]];	
//	[strPostData setMapString:@"at" keyvalue:@"1"];
//	[strPostData setMapString:@"av" keyvalue:userContext.snsID];
//	
//	[strPostData setMapString:@"ip" keyvalue:[self localIPAddress]];
//	[strPostData setMapString:@"postId" keyvalue:[poiData objectForKey:@"postId"]];
//	if(![parentId isEqualToString:@""]) {
//		[strPostData setMapString:@"parentId" keyvalue:parentId];
//	}
//	[strPostData setMapString:@"comment" keyvalue:contentTextView.text];
//	
//	if (connect != nil)
//	{
//		[connect stop];
//		[connect release];
//		connect = nil;
//	}
//	
//	connect = [[HttpConnect alloc] initWithURL:PROTOCOL_CMT_WRITE
//						   postData: [strPostData description]
//						   delegate: self
//					   doneSelector: @selector(onTransDone:)    
//					  errorSelector: @selector(onResultError:)  
//				   progressSelector: nil];
//	//[[OperationQueue queue] addOperation:conn];
//	//[conn release];
//	[strPostData release];
}



@end
