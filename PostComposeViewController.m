//
//  PostComposeViewController.m
//  ImIn
//
//  Created by choipd on 10. 5. 3..
//  Copyright 2010 edbear. All rights reserved.
//
#import <AudioToolbox/AudioServices.h>
#import <QuartzCore/QuartzCore.h>
#import "PostComposeViewController.h"
#import "UserContext.h"
#import "HttpConnect.h"
#import "CgiStringList.h"
#import "const.h"
#import "JSON.h"
#import "Utils.h"
#import "WriteResultViewController.h"
#import "Uploader.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "ViewControllers.h"
#import "UIPlazaViewController.h"
#import "iToast.h"

#import "CpData.h"
#import "OAuthWebViewController.h"
#import "NSString+URLEncoding.h"
#import "Me2dayViewController.h"
#import "AddLink.h"
#import "AlbumPreviewViewController.h"
#import "POIListViewController.h"
#import "MapAnnotation.h"
#import "RegexKitLite.h"
#import "PostWrite.h"
#import "ASIFormDataRequest.h"

static float kOFFSET_FOR_KEYBOARD = 0.0f;
static int kMAX_CHARACTER_LENGTH = 140;

#define PROGRESS_BAR	999

@interface PostComposeViewController() {
@private
    
}
- (BOOL) startCameraControllerFromViewController: (UIViewController*) controller
                                   usingDelegate: (id <UIImagePickerControllerDelegate,
                                                   UINavigationControllerDelegate>) delegate;
- (BOOL) startMediaBrowserFromViewController: (UIViewController*) controller
                               usingDelegate: (id <UIImagePickerControllerDelegate,
                                               UINavigationControllerDelegate>) delegate;
@end

@implementation PostComposeViewController

@synthesize poiData;
@synthesize uploadSheet, currentTextColor;
@synthesize imageToUpload, savedText;
@synthesize addLink, matchArray,lastContentText;
@synthesize tmpImageURL;
@synthesize finishState;
@synthesize postWrite;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
        urlStringCnt = 0;
		self.imageToUpload = nil;
		connect = nil;
		upload = nil;
        
        [self.navigationController setNavigationBarHidden:YES];
        
		textLengthRemain.text = [NSString stringWithFormat:@"%d", kMAX_CHARACTER_LENGTH];
		
		onTakingPicture = NO;
		shareMode = YES;
		self.savedText = @"";
		[ApplicationContext sharedApplicationContext].shouldRotate = YES;
		
		isLandscape = NO;
        finishState = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	contentTextView.text = savedText;
    mapView.delegate = self;
    
	self.currentTextColor = textLengthRemain.textColor;
    
	if (isLandscape) {
		writeBtn2.hidden = YES;
	} else {
		writeBtn2.hidden = NO;
	}
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChanged:) name:UITextViewTextDidChangeNotification object:nil];
}                                                                                                       

// 가로모드 지원 안함
// TODO : 소스코드 삭제
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
//    if (interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight || interfaceOrientation == UIInterfaceOrientationPortrait) {
//        return YES;
//    } else {
        return NO;
//    }
}

//- (void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
//	if (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft || toInterfaceOrientation == UIInterfaceOrientationLandscapeRight) {
//		writeBtn2.hidden = YES;
//		isLandscape = YES;
//	} else {
//		writeBtn2.hidden = NO;
//		isLandscape = NO;
//	}
//    
//}

- (void) textChanged:(NSNotification *)notification {
    if([placeholder.text length] == 0)
    {
        return;
    }
    
    if([[contentTextView text] length] == 0)
    {
        [placeholder setHidden:NO];
    }
    else
    {
        [placeholder setHidden:YES];
    }
}

- (IBAction) toggleShareMode {
	UserContext* uc = [UserContext sharedUserContext];
    
	if (shareMode) {
        shareText.text = @"비공개";
        
		shareModeBtn.hidden = YES;
		shareModeBtnOff.hidden = NO;
		
		twitterModeBtn.hidden = YES;
		twitterModeBtnOff.hidden = NO;
		
		facebookModeBtn.hidden = YES;
		facebookModeBtnOff.hidden = NO;
		
		me2dayModeBtn.hidden = YES;
		me2dayModeBtnOff.hidden = NO;
        
		shareMode = NO;
	} else {
        shareText.text = @"공개";
        
		shareModeBtn.hidden = NO;
		shareModeBtnOff.hidden = YES;
		shareMode = YES;
		
		twitterModeBtn.enabled = YES;
		twitterModeBtnOff.enabled = YES;
		facebookModeBtn.enabled = YES;
		facebookModeBtnOff.enabled = YES;
		me2dayModeBtn.enabled = YES;
		me2dayModeBtnOff.enabled = YES;
		
		if (uc.cpTwitter.isDelivery) {
			// turn on
			twitterModeBtn.hidden = NO;
			twitterModeBtnOff.hidden = YES;
		} else {
			// turn off
			twitterModeBtn.hidden = YES;
			twitterModeBtnOff.hidden = NO;
		}		
        
		if (uc.cpFacebook.isDelivery) {
			// turn on
			facebookModeBtn.hidden = NO;
			facebookModeBtnOff.hidden = YES;
		} else {
			// turn off
			facebookModeBtn.hidden = YES;
			facebookModeBtnOff.hidden = NO;			
		}
		
		if (uc.cpMe2day.isDelivery) {
			// turn on
			me2dayModeBtn.hidden = NO;
			me2dayModeBtnOff.hidden = YES;
		} else {
			// turn off
			me2dayModeBtn.hidden = YES;
			me2dayModeBtnOff.hidden = NO;			
		}		
	}
}

- (IBAction) toggleTwitter:(UIButton*) sender {
    GA3(@"발도장작성", @"SNS연동토글버튼", @"트위터");
    if (!shareMode) {
        return;
    }
    
	UserContext* uc = [UserContext sharedUserContext];
	
	if (!uc.cpTwitter.isConnected) {
		[self goTwitterSetting];
	} else {
		if (sender == twitterModeBtn) { 
			// turn off
			twitterModeBtn.hidden = YES;
			twitterModeBtnOff.hidden = NO;
			uc.cpTwitter.isDelivery = NO;
		} else {
			// turn on
			twitterModeBtn.hidden = NO;
			twitterModeBtnOff.hidden = YES;
			uc.cpTwitter.isDelivery = YES;
		}
	}
}

- (IBAction) toggleFacebook:(UIButton*) sender {
    GA3(@"발도장작성", @"SNS연동토글버튼", @"페이스북");
    if (!shareMode) {
        return;
    }
    
	UserContext* uc = [UserContext sharedUserContext];
	
	if (!uc.cpFacebook.isConnected) {
		[self goFacebookSetting];
	} else {
		if (sender == facebookModeBtn) { 
			// turn off
			facebookModeBtn.hidden = YES;
			facebookModeBtnOff.hidden = NO;
			uc.cpFacebook.isDelivery = NO;
		} else {
			// turn on
			facebookModeBtn.hidden = NO;
			facebookModeBtnOff.hidden = YES;
			uc.cpFacebook.isDelivery = YES;
		}
	}
}

- (IBAction) toggleMe2day:(UIButton*) sender {
    GA3(@"발도장작성", @"SNS연동토글버튼", @"미투데이");
    if (!shareMode) {
        return;
    }
    
	UserContext* uc = [UserContext sharedUserContext];
	
	if (!uc.cpMe2day.isConnected) {
		[self goMe2daySetting];
	} else {
		if (sender == me2dayModeBtn) { 
			// turn off
			me2dayModeBtn.hidden = YES;
			me2dayModeBtnOff.hidden = NO;
			uc.cpMe2day.isDelivery = NO;
		} else {
			// turn on
			me2dayModeBtn.hidden = NO;
			me2dayModeBtnOff.hidden = YES;
			uc.cpMe2day.isDelivery = YES;
		}
	}
}


- (void) goTwitterSetting {
	NSString* temp = [NSString stringWithFormat:@"sitename=twitter.com&appname=%@&env=app&rturl=%@&cskey=%@&atkey=%@", [IMIN_APP_NAME URLEncodedString], [CALLBACK_URL URLEncodedString], [SNS_CONSUMER_KEY  URLEncodedString], [[UserContext sharedUserContext].token URLEncodedString]] ;
	
	OAuthWebViewController* webViewCtrl = [[[OAuthWebViewController alloc] init] autorelease];
	webViewCtrl.requestInfo = [NSString stringWithFormat:@"%@?%@", OAUTH_URL, temp] ;
	webViewCtrl.webViewTitle = @"twitter 설정";
	webViewCtrl.authType = TWITTER_TYPE;
	
	[webViewCtrl setHidesBottomBarWhenPushed:YES];
	[self.navigationController pushViewController:webViewCtrl animated:YES];
}


- (void) goFacebookSetting {
	NSString* temp = [NSString stringWithFormat:@"sitename=facebook.com&appname=%@&env=app&rturl=%@&cskey=%@&atkey=%@", [IMIN_APP_NAME URLEncodedString], [CALLBACK_URL URLEncodedString], [SNS_CONSUMER_KEY  URLEncodedString], [[UserContext sharedUserContext].token URLEncodedString]] ;
	
	OAuthWebViewController* webViewCtrl = [[[OAuthWebViewController alloc] init] autorelease];
	webViewCtrl.requestInfo = [NSString stringWithFormat:@"%@?%@", OAUTH_URL, temp] ;
	webViewCtrl.webViewTitle = @"facebook 설정";
	webViewCtrl.authType = FB_TYPE;
	
	[self.navigationController pushViewController:webViewCtrl animated:YES];
}

- (void) goMe2daySetting {
	Me2dayViewController *me2dayViewCtrl = [[Me2dayViewController alloc] init];
	[self.navigationController pushViewController:me2dayViewCtrl animated:YES];
	[me2dayViewCtrl release];	
}

- (void) didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}

- (void) viewDidUnload {
	self.savedText = contentTextView.text;
    [contentTextView release];
    contentTextView = nil;
    [noMapViewImgView release];
    noMapViewImgView = nil;
    [footContainer release];
    footContainer = nil;
    [foot release];
    foot = nil;
    [dust1 release];
    dust1 = nil;
    [dust2 release];
    dust2 = nil;
    [innerView release];
    innerView = nil;
    mapView.delegate = nil;
    [mapView release];
    mapView = nil;
    [placeholder release];
    placeholder = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void) dealloc {
	if (upload != nil)
	{
		[upload release];
		upload = nil;
	}
	if (connect != nil) {
		[connect stop];
		[connect release];
		connect = nil;
	}
	[currentTextColor release];
	[poiData release];
	[imageToUpload release];
    [addLink release];
    [matchArray release];
    [lastContentText release];
    [tmpImageURL release];
    [noMapViewImgView release];
    [footContainer release];
    [foot release];
    [dust1 release];
    [dust2 release];
    [innerView release];
    [poiName release];
    [shareText release];
    mapView.delegate = nil;
    [mapView release];
    [postWrite release];
    [placeholder release];
    [super dealloc];
}

- (void) viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];	
	if ( [contentTextView isFirstResponder] && self.view.frame.origin.y < 0)
    {
        [self setViewMovedUp:NO];
		[contentTextView resignFirstResponder];
    }
	
	if (connect != nil) {
		[connect stop];
		[connect release];
		connect = nil;
	}
}

- (void) viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
    self.hidesBottomBarWhenPushed = YES;
    dust1.hidden = YES;
    dust2.hidden = YES;
    
    [[UserContext sharedUserContext] recordKissMetricsWithEvent:@"Check-in Page" withInfo:nil];
	
	//사진을 찍거나 할때 사진 페이지가 닫히면서 textLengthRemain.text가 갱신되지 않고 xib에 초기 설정된 값이 보여지는 현상 아래 코드로 수정
	textLengthRemain.text = [NSString stringWithFormat:@"%d", kMAX_CHARACTER_LENGTH - [contentTextView.text length]];
	
	[self logViewControllerName];	
    
	if (imageToUpload != nil) {
		photoSelected.image = imageToUpload;
	}
	
	if ( [UserContext sharedUserContext].cpTwitter.isDelivery ) {
		twitterModeBtn.hidden = NO; 
		twitterModeBtnOff.hidden = YES;
	} else {
		twitterModeBtn.hidden = YES;
		twitterModeBtnOff.hidden = NO;
	}
    
	if ( [UserContext sharedUserContext].cpFacebook.isDelivery ) {
		facebookModeBtn.hidden = NO; 
		facebookModeBtnOff.hidden = YES;
	} else {
		facebookModeBtn.hidden = YES;
		facebookModeBtnOff.hidden = NO;
	}
	
	if ( [UserContext sharedUserContext].cpMe2day.isDelivery ) {
		me2dayModeBtn.hidden = NO; 
		me2dayModeBtnOff.hidden = YES;
	} else {
		me2dayModeBtn.hidden = YES;
		me2dayModeBtnOff.hidden = NO;
	}
	
	if (shareMode) {
        shareText.text = @"공개";
		shareModeBtn.hidden = NO;
		shareModeBtnOff.hidden = YES;
	} else {
        shareText.text = @"비공개";
		shareModeBtn.hidden = YES;
		shareModeBtnOff.hidden = NO;
        facebookModeBtn.hidden = YES;
        facebookModeBtnOff.hidden = NO;
        twitterModeBtn.hidden = YES;
        twitterModeBtnOff.hidden = NO;
        me2dayModeBtn.hidden = YES;
        me2dayModeBtnOff.hidden = NO;
	}
    
    [self setWriteButtonEnabled:YES];
    [self setMapPOI];
}

#pragma mark -
#pragma mark navigation 

- (IBAction) popViewController {
	[ApplicationContext sharedApplicationContext].shouldRotate = NO;
	[self.navigationController dismissModalViewControllerAnimated:YES];
}

- (IBAction) openImagePicker {
	[self presentSelectImageSourceSheet];
}

#pragma mark -
#pragma mark 키보드 처리

- (void) setViewMovedUp:(BOOL)movedUp
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    // Make changes to the view's frame inside the animation block. They will be animated instead
    // of taking place immediately.
    CGRect rect = self.view.frame;
    if (movedUp)
    {
        // If moving up, not only decrease the origin but increase the height so the view 
        // covers the entire screen behind the keyboard.
        rect.origin.y -= kOFFSET_FOR_KEYBOARD;
        rect.size.height += kOFFSET_FOR_KEYBOARD;
		[headerView setFrame:CGRectMake(0.0f, 0.0f+kOFFSET_FOR_KEYBOARD, rect.size.width, 43)];
    }
    else
    {
        // If moving down, not only increase the origin but decrease the height.
        rect.origin.y += kOFFSET_FOR_KEYBOARD;
        rect.size.height -= kOFFSET_FOR_KEYBOARD;
		[headerView setFrame:CGRectMake(0.0f, 0.0f, rect.size.width, 43)];
    }
    self.view.frame = rect;
    
    [UIView commitAnimations];
}

#pragma mark -
#pragma mark TextViewDelegate 구현
- (BOOL)textViewShouldBeginEditing:(UITextView *)aTextView { 
    /*
     키보드 완료 버튼 추가
     */
//    placeholder.hidden = YES;
    if (aTextView.inputAccessoryView == nil) {         
        UIView *keyboardAccessoryView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 36.0f)];
        [keyboardAccessoryView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"keypad_bar.png"]]];   
        aTextView.inputAccessoryView = keyboardAccessoryView;
        [keyboardAccessoryView release];
        
        UIButton *completionBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [completionBtn setFrame:CGRectMake(262.0f, 5.0f, 48.0f, 28.0f)];
        [completionBtn setTitle:@"완료" forState:UIControlStateNormal];
        [completionBtn setImage:[UIImage imageNamed:@"keypad_confirm.png"] forState:UIControlStateNormal];
        [completionBtn addTarget:self action:@selector(completionPost:) forControlEvents:UIControlEventTouchUpInside];
        [keyboardAccessoryView addSubview:completionBtn];
    } 
    return YES; 
} 

- (BOOL)textViewShouldEndEditing:(UITextView *)aTextView {  
    [aTextView resignFirstResponder]; 
    return YES;  
} 

- (void)textViewDidEndEditing:(UITextView *)aTextView
{

}

- (BOOL) textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range 
  replacementText:(NSString *)text
{
    MY_LOG(@"%d, %@, %@", range.length, text, textView.text);
    // Any new character added is passed in as the "text" parameter
//    if ([text isEqualToString:@"\n"]) {
//        // Be sure to test for equality using the "isEqualToString" message
//        [textView resignFirstResponder];
//		
//        // Return FALSE so that the final '\n' character doesn't get added
//        return FALSE;
//    }
    // For any other character return TRUE so that the text gets added to the view
    return TRUE;
}

- (void) textViewDidChange:(UITextView *)aTextView {
	textLengthRemain.text = [NSString stringWithFormat:@"%d", kMAX_CHARACTER_LENGTH - [contentTextView.text length]];
	if ([contentTextView.text length] > kMAX_CHARACTER_LENGTH) {
		textLengthRemain.textColor = [UIColor redColor];
	} else {
		textLengthRemain.textColor = self.currentTextColor;
	}
}

//- (void) onResultErrorWithMessage:(NSString*)errorMessage
//{
//    [CommonAlert alertWithTitle:@"안내" message:errorMessage];
//    [self setWriteButtonEnabled:YES];
//}

//- (void) onResultError:(HttpConnect*)up
//{
//    MY_LOG(@"%@", up.stringReply);
//	NSString* errorMessage = @"네트웍 접속이 원활하지 않습니다.\n잠시후 다시 시도해주세요.";
//    
//    [CommonAlert alertWithTitle:@"안내" message:errorMessage];
//    
//    if (connect != nil)
//	{
//		[connect release];
//		connect = nil;
//	}
//	
//    [self setWriteButtonEnabled:YES];
//}
//
//- (void) onTransDone:(HttpConnect*)up
//{
//	AudioServicesPlaySystemSound (kSystemSoundID_Vibrate);
//	//plaza 업데이트 해주도록 설정
//	UIPlazaViewController* plaza = (UIPlazaViewController*)[ViewControllers sharedViewControllers].plazaViewController;
//	plaza.needToUpdate = YES;
//	
//	MY_LOG(@"<!-- PostWrite");
//	MY_LOG(@"%@", up.stringReply);
//	MY_LOG(@"PostWrite -->");
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
//	
//	NSNumber* resultNumber = (NSNumber*)[results objectForKey:@"result"];
//	
//	if ([resultNumber intValue] == 0) { //에러처리
//		[self onResultErrorWithMessage:[results objectForKey:@"description"]];
//        [self setWriteButtonEnabled:YES];
//		return;
//	}
//    
//	//마이홈을 갱신
//	[UserContext sharedUserContext].needMyHomeToRefresh = YES;
//
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"moveToTop" object:nil];
//    [self performSelector:@selector(openWebViewResult:) withObject:results afterDelay:0.1];
//}

- (void) openWebViewResult:(NSDictionary*) results
{
    //  웹뷰로 결과 화면 띄어라
	WriteResultViewController* writeResultViewController = [[[WriteResultViewController alloc] 
                                                             initWithNibName:@"WriteResultViewController" bundle:nil] autorelease];
	writeResultViewController.resultData = results;
	[self.navigationController pushViewController:writeResultViewController animated:YES];
}

#pragma mark -
#pragma mark 글쓰기 요청

- (NSString*) localIPAddress
{
	return @"127.0.0.1";
}

- (void) request
{
    // 일단 글 쓰기 transaction이 시작되면 로테이션 시키지 않도록 수정하자
    [ApplicationContext sharedApplicationContext].shouldRotate = shareMode;
    UserContext* userContext = [UserContext sharedUserContext];
    
    self.postWrite = [[[PostWrite alloc] init] autorelease];
    postWrite.delegate = self;
    
    //calc toCpInfo
	int toCpInfo = userContext.cpTwitter.isDelivery ? 2 : 0;
	toCpInfo += userContext.cpFacebook.isDelivery ? 4 : 0;
	toCpInfo += userContext.cpMe2day.isDelivery ? 1 : 0; //me2day는 1
    
    NSString* shareCode = shareMode ? @"9" : @"0";
    
    MY_LOG(@"lastContentText2 = %@", lastContentText);

    [postWrite.params addEntriesFromDictionary:[NSDictionary dictionaryWithObjectsAndKeys:[self localIPAddress], @"ip",
                                                [poiData objectForKey:@"poiName"], @"poiName",
                                                [poiData objectForKey:@"pointX"], @"pointX",
                                                [poiData objectForKey:@"pointY"], @"pointY",
                                                @"대한민국", @"addr1",
                                                shareCode, @"isOpen",
                                                [poiData objectForKey:@"category"], @"category",
                                                [[GeoContext sharedGeoContext].lastTmX stringValue], @"realPointX",
                                                [[GeoContext sharedGeoContext].lastTmY stringValue], @"realPointY",
                                                [NSString stringWithFormat:@"%d", toCpInfo], @"toCpInfo",
                                                lastContentText, @"post",
                                                userContext.snsID, @"snsId",
                                                nil]];
    
    if ([poiData objectForKey:@"phoneNum"]) { //phoneNum 라는 키가 있긴 하면
        [postWrite.params addEntriesFromDictionary:[NSDictionary dictionaryWithObject:[poiData objectForKey:@"phoneNum"] forKey:@"poiPhoneNo"]];
    }
    
    NSString* poiKey = [poiData objectForKey:@"poiKey"];
	
	if (poiKey != nil && ![poiKey isEqualToString:@""]) {
        [postWrite.params addEntriesFromDictionary:[NSDictionary dictionaryWithObject:poiKey forKey:@"poiKey"]];
	}
    
    MY_LOG(@"poiData = %@", poiData);
	if (![poiData objectForKey:@"addr"]) { //addr 라는 키가 아예 없으면
        [postWrite.params addEntriesFromDictionary:[NSDictionary dictionaryWithObject:[poiData objectForKey:@"addr2"] forKey:@"addr2"]];
        [postWrite.params addEntriesFromDictionary:[NSDictionary dictionaryWithObject:[poiData objectForKey:@"addr3"] forKey:@"addr3"]];
	} else {
        [postWrite.params addEntriesFromDictionary:[NSDictionary dictionaryWithObject:[poiData objectForKey:@"addr"] forKey:@"addr"]];
	}
        
    if ([GeoContext sharedGeoContext].cntNoGPSrecv > 0) { // GPS 비활성
        [postWrite.params addEntriesFromDictionary:[NSDictionary dictionaryWithObject:@"2" forKey:@"isH"]];
		MY_LOG(@"위치 꺼져있어요");
	} else {
		if ([ApplicationContext isHacked]) {
			if ([ApplicationContext isFakeLocationInstalled]) {
                [postWrite.params addEntriesFromDictionary:[NSDictionary dictionaryWithObject:@"4" forKey:@"isH"]]; // 탈옥 + 좌표조작앱 설치
			} else {
                [postWrite.params addEntriesFromDictionary:[NSDictionary dictionaryWithObject:@"3" forKey:@"isH"]]; // 탈옥
			}
		}
	}

    MY_LOG(@"tmpImageURL = %@", tmpImageURL);
	if (tmpImageURL != nil) {
        [postWrite.params addEntriesFromDictionary:[NSDictionary dictionaryWithObject:tmpImageURL forKey:@"imgUrl"]];
	}
    
    [postWrite request];
    
//	UserContext* userContext = [UserContext sharedUserContext];
//	NSString* shareCode = shareMode ? @"9" : @"0";
//    
//	CgiStringList* strPostData=[[CgiStringList alloc]init:@"&"];
//	[strPostData setMapString:@"svcId" keyvalue:SNS_IPHONE_SVCID];
//    [strPostData setMapString:@"appVer" keyvalue:[ApplicationContext appVersion]];
//	[strPostData setMapString:@"at" keyvalue:@"1"];
//	[strPostData setMapString:@"av" keyvalue:userContext.snsID];
//    
//	[strPostData setMapString:@"ip" keyvalue:[self localIPAddress]];
//	[strPostData setMapString:@"poiName" keyvalue:[poiData objectForKey:@"poiName"]];
//	
//	NSString* poiKey = [poiData objectForKey:@"poiKey"];
//	
//	if (poiKey != nil && ![poiKey isEqualToString:@""]) {
//		[strPostData setMapString:@"poiKey" keyvalue:poiKey];		
//	}
//	
//    [strPostData setMapString:@"pointX" keyvalue:[poiData objectForKey:@"pointX"]];
//	[strPostData setMapString:@"pointY" keyvalue:[poiData objectForKey:@"pointY"]];
//	[strPostData setMapString:@"addr1" keyvalue:@"대한민국"];
//    
//	NSString* addr = [poiData objectForKey:@"addr"];
//	NSString* addr2 = [poiData objectForKey:@"addr2"];
//	NSString* addr3 = [poiData objectForKey:@"addr3"];
//	
//	if (![addr isEqualToString:@""]) {
//		[strPostData setMapString:@"addr" keyvalue:addr];
//	} else {
//		[strPostData setMapString:@"addr2" keyvalue:addr2];
//		[strPostData setMapString:@"addr3" keyvalue:addr3];		
//	}
//    
//	[strPostData setMapString:@"poiPhoneNo" keyvalue:[poiData objectForKey:@"phoneNum"]];
//	[strPostData setMapString:@"device" keyvalue:[ApplicationContext deviceId]];
//	[strPostData setMapString:@"isOpen" keyvalue:shareCode];
//	[strPostData setMapString:@"snsId"  keyvalue:userContext.snsID];
//	[strPostData setMapString:@"category" keyvalue:[poiData objectForKey:@"category"]];
//	[strPostData setMapString:@"realPointX" keyvalue:[[GeoContext sharedGeoContext].lastTmX stringValue]];
//	[strPostData setMapString:@"realPointY" keyvalue:[[GeoContext sharedGeoContext].lastTmY stringValue]];
//	
//	if ([GeoContext sharedGeoContext].cntNoGPSrecv > 0) { // GPS 비활성
//		[strPostData setMapString:@"isH" keyvalue:@"2"];
//		MY_LOG(@"위치 꺼져있어요");
//	} else {
//		if ([ApplicationContext isHacked]) {
//			if ([ApplicationContext isFakeLocationInstalled]) {
//				[strPostData setMapString:@"isH" keyvalue:@"4"]; // 탈옥 + 좌표조작앱 설치
//			} else {
//				[strPostData setMapString:@"isH" keyvalue:@"3"]; // 탈옥
//			}
//		}
//	}
//	
//	//calc toCpInfo
//	int toCpInfo = userContext.cpTwitter.isDelivery ? 2 : 0;
//	toCpInfo += userContext.cpFacebook.isDelivery ? 4 : 0;
//	toCpInfo += userContext.cpMe2day.isDelivery ? 1 : 0; //me2day는 1
//	[strPostData setMapString:@"toCpInfo" keyvalue:[NSString stringWithFormat:@"%d", toCpInfo]];
//	[strPostData setMapString:@"ver" keyvalue:[ApplicationContext sharedApplicationContext].apiVersion];
//    MY_LOG(@"tmpImageURL = %@", tmpImageURL);
//	if (tmpImageURL != nil) {
//		[strPostData setMapString:@"imgUrl" keyvalue:tmpImageURL];
//	}
//    
//	[strPostData setMapString:@"post" keyvalue: lastContentText];
//    
//	if (connect != nil)
//	{
//		[connect stop];
//		[connect release];
//		connect = nil;
//	}
//	
//	connect = [[HttpConnect alloc] initWithURL:PROTOCOL_POST_WRITE
//                                      postData: [strPostData description]
//                                      delegate: self
//                                  doneSelector: @selector(onTransDone:)    
//                                 errorSelector: @selector(onResultError:)  
//                              progressSelector: nil];
//	//[[OperationQueue queue] addOperation:conn];
//	//[conn release];
//	[strPostData release];
//    
//    // 일단 글 쓰기 transaction이 시작되면 로테이션 시키지 않도록 수정하자
//    [ApplicationContext sharedApplicationContext].shouldRotate = shareMode;
    
}

- (IBAction) mapViewSelected:(id)sender {
    GA1(@"발도장작성_장소입력시도");
    
    if (!([[poiData objectForKey:@"poiName"] isEqualToString:@""] || [poiData objectForKey:@"poiName"] == nil)) {
        GA3(@"발도장작성", @"장소입력하기", @"장소 변경");
        [[UserContext sharedUserContext] recordKissMetricsWithEvent:@"Change place" withInfo:nil];
    } else {
        GA3(@"발도장작성", @"장소입력하기", @"최초 장소");
        [[UserContext sharedUserContext] recordKissMetricsWithEvent:@"Input place" withInfo:nil];
    }
    MY_LOG(@"Move to POIList");
    POIListViewController *vc = [[[POIListViewController alloc] initWithNibName:@"POIListViewController" bundle:nil] autorelease];
    vc.rootViewController = @"PostComposeViewController";
    vc.previousVCDelegate = self;
    vc.currPostWriteFlow = NEW_POSTFLOW;
    [self.navigationController pushViewController:vc animated:YES];
}

/**
 @brief 키보드 완료 버튼 SELECTOR
 */
- (void) completionPost:(id)sender {

    if ( [contentTextView isFirstResponder] )
    {
        [self setViewMovedUp:NO];
		[contentTextView resignFirstResponder];
    }

}

- (void) writePost {
    
	if ([contentTextView.text isEqualToString:@""]) {
		MY_LOG(@"빈글 발도장");
	}
    
    [self setWriteButtonEnabled:NO];
    
    urlStringCnt = 0;
    self.lastContentText = contentTextView.text;
    MY_LOG(@"lastContentText1 = %@", lastContentText);
    
    NSString* regexString  = @"(?i)\\b((?:[a-z][\\w-]+:(?:/{1,3}|[a-z0-9%])|www\\d{0,3}[.]|[a-z0-9.\\-]+[.][a-z]{2,4}/)(?:[^\\s()<>]+|\\(([^\\s()<>]+|(\\([^\\s()<>]+\\)))*\\))+(?:\\(([^\\s()<>]+|(\\([^\\s()<>]+\\)))*\\)|[^\\s`!()\\[\\]{};:'\".,<>?≪≫“”‘’]))";
    
    self.matchArray = [contentTextView.text componentsMatchedByRegex:regexString];
    NSString* key = nil;
    if ([matchArray count] == 0) {
        [self request];
    } else {
        key = [matchArray objectAtIndex:0];
        [self addLinkRequest:key];
    }
}

- (void) addLinkRequest:(NSString*)OriUrlString {
    self.addLink = [[[AddLink alloc] init] autorelease];
    addLink.delegate = self;
    [addLink.params addEntriesFromDictionary:[NSDictionary dictionaryWithObject:OriUrlString forKey:@"link"]];
    urlStringCnt++;
    [addLink request];
}

#pragma mark -
#pragma mark iminprotocol
- (void) apiDidLoadWithResult:(NSDictionary *)result whichObject:(NSObject *)theObject {
    if ([[result objectForKey:@"func"] isEqualToString:@"addLink"]) {
        NSArray* dataList = [result objectForKey:@"data"];
		NSString* longUrl;
        NSString* shortUrl;
        NSString* key;
		for (NSDictionary *data in dataList) 
		{
            longUrl = [data objectForKey:@"longUrl"];
            shortUrl = [data objectForKey:@"shortUrl"];
            self.lastContentText = [lastContentText stringByReplacingOccurrencesOfString:longUrl withString:shortUrl ];
		}
        if ( [matchArray count] > urlStringCnt) { //어레이의 카운트 보다 작으면
            key = [matchArray objectAtIndex:urlStringCnt];
            [self addLinkRequest:key];
        } else {
            [self request];
        }
    }
    if ([[result objectForKey:@"func"] isEqualToString:@"postWrite"]) {
        AudioServicesPlaySystemSound (kSystemSoundID_Vibrate);
        //plaza 업데이트 해주도록 설정
        UIPlazaViewController* plaza = (UIPlazaViewController*)[ViewControllers sharedViewControllers].plazaViewController;
        plaza.needToUpdate = YES;
        
         NSNumber* resultNumber = (NSNumber*)[result objectForKey:@"result"];
        
        if ([resultNumber intValue] == 0) { //에러처리
            [CommonAlert alertWithTitle:@"안내" message:[result objectForKey:@"description"]];
            [self setWriteButtonEnabled:YES];
            return;
        }
        
        //마이홈을 갱신
        [UserContext sharedUserContext].needMyHomeToRefresh = YES;
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"moveToTop" object:nil];
        [self performSelector:@selector(openWebViewResult:) withObject:result afterDelay:0.1];
    }
}

- (void) apiFailedWhichObject:(NSObject *)theObject {
    if (theObject == postWrite) {
        [self setWriteButtonEnabled:YES];
    }
}


#pragma mark -
#pragma mark 파일 업로드
- (void) onUploadDone:(ASIFormDataRequest *)request
{
	MY_LOG(@"UploadSuccess");
	[self.uploadSheet dismissWithClickedButtonIndex:0 animated:YES];
    
	NSDictionary* results = [request.responseString objectFromJSONString];
	
	NSNumber* resultNumber = (NSNumber*)[results objectForKey:@"result"];
	
	if ([resultNumber intValue] == 0) { //에러처리
        [CommonAlert alertWithTitle:@"에러" message:[results objectForKey:@"description"]];
		return;
	}
	self.tmpImageURL = [results objectForKey:@"imgUrl"];
	if(upload != nil)
	{
		[upload release];
		upload = nil;
	}
	
	[self writePost];
}

- (void) onUploadError:(ASIFormDataRequest *)request
{
	MY_LOG(@"Error~~~");
    NSString* errorMessage = @"네트워크가 불안하여, \n사진업로드에 실패하였습니다.";
    //itoast?
    UIWindow *window = [[[UIApplication sharedApplication] windows] objectAtIndex:0];
    UIView *v = (UIView *)[window viewWithTag:TAG_iTOAST];
    if (!v) {
        iToast *msg = [[iToast alloc] initWithText:errorMessage];
        [msg setDuration:2000];
        [msg setGravity:iToastGravityCenter];
        [msg show];
        [msg release];
    }
    //    [CommonAlert alertWithTitle:@"에러" message:errorMessage];

	[self.uploadSheet dismissWithClickedButtonIndex:0 animated:YES]; 
	if(upload != nil)
	{
		[upload release];
		upload = nil;
	}
    [self setWriteButtonEnabled:YES];
}

/**
 @brief 현재 사용안하는 method
 */
- (void) onProgress:(Uploader*)up
{
	
	NSString* logFileTrans = [[NSString alloc] initWithFormat:@"Transfer : %d/%d", [up getTransFileByte],[up getTransTotalFileByte]];
	MY_LOG(@"%@", logFileTrans);
	[logFileTrans release];
	
	//amountDone += 1.0f;
	UIProgressView *progbar = (UIProgressView *)[self.uploadSheet viewWithTag:PROGRESS_BAR];
	float progressPercent = (float)[up getTransFileByte] / (float)[up getTransTotalFileByte];
	MY_LOG(@"ProgressPercent : %f",progressPercent);
    [progbar setProgress: progressPercent];
    /* if (amountDone > 20.0) 
	 {
	 [self.baseSheet dismissWithClickedButtonIndex:0 animated:YES]; 
	 [timer invalidate];
	 } */
	
}

#pragma mark -
#pragma mark animation

- (void) initAnimation {        
    [foot.layer removeAllAnimations];
    [dust1.layer removeAllAnimations];
    [dust2.layer removeAllAnimations];

    if ( !finishState ) { // 애미메이션 중이다. 아직 제자리로 돌아오지 못했음
        [foot.layer setPosition:CGPointMake(foot.layer.position.x+13, foot.layer.position.y-7.5)];
        [foot.layer setAnchorPoint:CGPointMake(0.5, 0.5)];
    } 

    //[self animationForFoot];
}

- (void) animationForFoot {
    finishState = NO;
    float start = 0;
    float end = 35;
    //float end = 30;
    
    //30도 꺽어짐에 일정한 속도에 의한 것으로 움직이든지..
    //35도 꺽어짐에 kCAMediaTimingFunctionEaseIn(처음에 천천히 시작) 하는 옵션을 쓰던지.. 둘중 하나 선택
    
    CABasicAnimation* spinAnimation = [CABasicAnimation
                                       animationWithKeyPath:@"transform.rotation"]; 
    [spinAnimation setValue:@"spinAni" forKey:@"id"];
    
    
    spinAnimation.fromValue = [NSNumber numberWithInt:start * M_PI / 180.0f];
    spinAnimation.toValue = [NSNumber numberWithFloat:-(end * M_PI / 180.0f)];
    
    spinAnimation.duration = 0.15;
    spinAnimation.delegate = self;
    spinAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    //spinAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:)];
    
    spinAnimation.autoreverses = YES; 
    spinAnimation.repeatCount = 3;
    spinAnimation.fillMode = kCAFillModeForwards;
    spinAnimation.removedOnCompletion = NO;
    
    [foot.layer setPosition:CGPointMake(foot.layer.position.x-13, foot.layer.position.y+7.5)];
    [foot.layer setAnchorPoint:CGPointMake(0, 1)];
    
    [foot.layer addAnimation:spinAnimation forKey:@"transform.rotation"];
}

-(void) animationDidStop:(CAAnimation *)theAnimation2 finished:(BOOL)flag 
{
    if([[theAnimation2 valueForKey:@"id"] isEqual:@"spinAni"]) { 
        dust2.hidden = NO;
        
        CABasicAnimation *theAnimation = [CABasicAnimation animationWithKeyPath:@"transform.translation.y"];
        
        theAnimation.fromValue = [NSNumber numberWithFloat:0];
        theAnimation.toValue = [NSNumber numberWithFloat:-7];
        theAnimation.removedOnCompletion = NO;
        theAnimation.autoreverses = NO;
        theAnimation.repeatCount = 0;
        
        
        CAKeyframeAnimation *opacityAnimation = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
        opacityAnimation.calculationMode = kCAAnimationPaced;
        
        opacityAnimation.duration = 0.4;
        opacityAnimation.values = [NSArray arrayWithObjects:
                                   [NSNumber numberWithFloat:0.5],
                                   [NSNumber numberWithFloat:1.0],
                                   [NSNumber numberWithFloat:0.0], nil];
        opacityAnimation.keyTimes = [NSArray arrayWithObjects:
                                     [NSNumber numberWithFloat:0],
                                     [NSNumber numberWithFloat:0.1],
                                     [NSNumber numberWithFloat:0.4], nil];
        
        
        CAAnimationGroup *group = [CAAnimationGroup animation];
        group.animations = [NSArray arrayWithObjects:theAnimation, opacityAnimation, nil];
        group.duration = 0.4f;
        group.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        group.fillMode = kCAFillModeForwards;
        
        [dust2.layer addAnimation:group forKey:nil];
        dust2.layer.opacity = 0.0;
        ///////////////////////////////////////////////////////////////////////////////
        
        dust1.hidden = NO;
        
        CABasicAnimation *theAnimation1 = [CABasicAnimation animationWithKeyPath:@"transform.translation.y"];
        theAnimation1.fromValue = [NSNumber numberWithFloat:0];
        theAnimation1.toValue = [NSNumber numberWithFloat:-7];
        theAnimation1.removedOnCompletion = NO;
        theAnimation1.autoreverses = NO;
        theAnimation1.repeatCount = 0;
        
        CAKeyframeAnimation *opacityAnimation1 = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
        opacityAnimation1.calculationMode = kCAAnimationPaced;
        
        opacityAnimation1.duration = 0.8;
        opacityAnimation1.values = [NSArray arrayWithObjects:
                                    [NSNumber numberWithFloat:0.0],
                                    [NSNumber numberWithFloat:1.0],
                                    [NSNumber numberWithFloat:0.0], nil];
        opacityAnimation1.keyTimes = [NSArray arrayWithObjects:
                                      [NSNumber numberWithFloat:0],
                                      [NSNumber numberWithFloat:0.5],
                                      [NSNumber numberWithFloat:0.8], nil];
        
        
        CAAnimationGroup *group1 = [CAAnimationGroup animation];
        group1.animations = [NSArray arrayWithObjects:theAnimation1, opacityAnimation1, nil];
        group1.duration = 0.8f;
        group1.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        group1.fillMode = kCAFillModeForwards;
        
        [dust1.layer addAnimation:group1 forKey:nil];
        dust1.layer.opacity = 0.0;
        
        
        [foot.layer setPosition:CGPointMake(foot.layer.position.x+13, foot.layer.position.y-7.5)];
        [foot.layer setAnchorPoint:CGPointMake(0.5, 0.5)];
    }
    finishState = YES;
}


- (IBAction) prepareWritePost:(UIButton*)btn {	
    
    //장소선택이 안되어있으면 애니메이션 처리
    if ([[poiData objectForKey:@"poiName"] isEqualToString:@""] || [poiData objectForKey:@"poiName"] == nil) {
        [poiName setText:@"장소를 선택해 주세요!"];
        if ( finishState ) {
            [self animationForFoot];
        }
        if (btn == writeBtn1) {
            GA3(@"발도장작성", @"확인버튼(비활성)", @"상단");
        } else {
            GA3(@"발도장작성", @"확인버튼(비활성)", @"하단");
        }
        return;
    } else {
        GA1(@"발도장작성_확인");
        if (btn == writeBtn1) {
            GA3(@"발도장작성", @"확인버튼(활성)", @"상단");
        } else {
            GA3(@"발도장작성", @"확인버튼(활성)", @"하단");
        }
    }
    
     [self setWriteButtonEnabled : NO];
    
	if ([contentTextView.text length] > kMAX_CHARACTER_LENGTH) {
		NSString* errorMessage = [NSString stringWithFormat:@"최대 %d글자 입력가능합니다.", kMAX_CHARACTER_LENGTH];
		[CommonAlert alertWithTitle:@"안내" message:errorMessage];
        [self setWriteButtonEnabled:YES];
		return;
	} 
	
	if(imageToUpload == nil) {                  // 이미지가 없으면 그냥 등록
		[self writePost];
	} else {                                                        // 이미지가 있으면 저장 후 등록
        UIImage* orgImage = imageToUpload;
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        NSString *diskCachePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"ImageCache"];
        NSString *uniquePath = [diskCachePath stringByAppendingPathComponent:@"selectedImage.jpg"];
        MY_LOG(@"prepareWritePost > Writing selected image to ImageCache folder:%@",uniquePath);
        BOOL isSaved = [UIImageJPEGRepresentation(orgImage,85)  writeToFile: uniquePath atomically:YES];
        
        if (!isSaved) {
            MY_LOG(@"저장할 수 없음");
            [self setWriteButtonEnabled:YES];
            return;
        } else {
            [self presentUploadSheet];
            
            NSArray *keys = [NSArray arrayWithObjects:@"svcId", @"at", @"av", @"ts", @"s", @"device", nil];
            NSArray *objects = [NSArray arrayWithObjects:SNS_IPHONE_SVCID, @"1", [UserContext sharedUserContext].snsID, 
                                [Utils ts], [Utils sWithAv:[UserContext sharedUserContext].snsID], SNS_DEVICE_MOBILE_APP, nil];
            NSDictionary *params = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
            if(upload != nil)
            {
                [upload release];
                upload = nil;
            }
            
            UIProgressView *progressView = (UIProgressView *)[self.uploadSheet viewWithTag:PROGRESS_BAR];
            upload = [[Uploader alloc] initWithURL:[NSURL URLWithString:PROTOCOL_TMP_IMG_UPLOAD] 
                                          filePath:uniquePath
                                          delegate:self
                                      doneSelector:@selector(onUploadDone:)
                                     errorSelector:@selector(onUploadError:)
                                      progressView:progressView
                                        parameters:params];
            
        }
    }
}

#pragma mark -
#pragma mark ActionSheet
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        return;
    }
    
    ImagePickerHandler* handler = [[ImagePickerHandler alloc] init];
    handler.delegate = self;
    
	printf("User Pressed Button %d\n", buttonIndex + 1);
	if ([UIImagePickerController isSourceTypeAvailable:
		 UIImagePickerControllerSourceTypeCamera]) {
		if (imageToUpload == nil) {
			if (buttonIndex == 0) { // 사진찍기
                [self startCameraControllerFromViewController:self usingDelegate:handler];                
			} else if (buttonIndex == 1) { // 포토라이브러리에서 불러오기
                [self startMediaBrowserFromViewController:self usingDelegate:handler];
			}		
		} else {
			if (buttonIndex == 0) { // 선택된 사진 삭제 
				[self deleteSelectedImage];
			}
			if (buttonIndex == 1) { // 사진찍기
                [self startCameraControllerFromViewController:self usingDelegate:handler];
			} else if (buttonIndex == 2) { // 사진 앨범에서 불러오기
                [self startMediaBrowserFromViewController:self usingDelegate:handler];
			}
		}		
	} else {
		if (imageToUpload == nil) {
			if (buttonIndex == 0) { // 포토라이브러리에서 불러오기
                [self startMediaBrowserFromViewController:self usingDelegate:handler];
			}
		} else {
			if (buttonIndex == 0) { // 선택된 사진 삭제 
				[self deleteSelectedImage];
			}
			if (buttonIndex == 1) { // 사진 앨범에서 불러오기
                [self startMediaBrowserFromViewController:self usingDelegate:handler];
			}
		}		
	}
}

- (void) presentSelectImageSourceSheet
{
	NSString* deletePictureTitle = imageToUpload != nil ? @"사진 삭제하기" : nil;
	
    UIActionSheet* selectionSheet = nil;
	if ([UIImagePickerController isSourceTypeAvailable:
		 UIImagePickerControllerSourceTypeCamera]) {
        selectionSheet = [[[UIActionSheet alloc]
                           initWithTitle:nil 
                           delegate:self 
                           cancelButtonTitle:@"취소" 
                           destructiveButtonTitle:deletePictureTitle
                           otherButtonTitles:@"사진찍기", @"앨범에서 가져오기", nil] autorelease];
		
	} else {
		selectionSheet = [[[UIActionSheet alloc]
                           initWithTitle:nil 
                           delegate:self 
                           cancelButtonTitle:@"취소" 
                           destructiveButtonTitle:deletePictureTitle
                           otherButtonTitles:@"앨범에서 가져오기", nil] autorelease];
	}
	[selectionSheet showInView:self.view];
}

- (void) presentUploadSheet
{
	if (!self.uploadSheet) {
		uploadSheet = [[UIActionSheet alloc] 
                       initWithTitle:@"잠시만 기다려 주세요"
                       delegate:self 
                       cancelButtonTitle:nil 
                       destructiveButtonTitle: nil
                       otherButtonTitles: nil];
		uploadSheet.title = @"사진을 업로드중입니다.";
		
		UIProgressView *progbar = [[UIProgressView alloc] initWithFrame:CGRectMake(50.0f, 24.0f, 220.0f, 20.0f)];
		
		CGPoint centerPoint = CGPointMake(isLandscape ? 480/2 : 320/2, 40.0f);
		progbar.center = centerPoint;
		
		progbar.tag = PROGRESS_BAR;
		[progbar setProgressViewStyle: UIProgressViewStyleDefault];
		
		[uploadSheet addSubview:progbar];
		[progbar release];
	}
	
	UIProgressView *progbar = (UIProgressView *)[self.view viewWithTag:PROGRESS_BAR];
	[progbar setProgress:(amountDone = 0.0f)];
	//[NSTimer scheduledTimerWithTimeInterval: 0.5 target: self selector: @selector(incrementBar:) userInfo: nil repeats: YES];
	[uploadSheet showInView:self.view];		
}

#pragma mark -
#pragma mark Camera control

- (BOOL) startCameraControllerFromViewController: (UIViewController*) controller
                                   usingDelegate: (id <UIImagePickerControllerDelegate,
                                                   UINavigationControllerDelegate>) delegate {
    
    if (([UIImagePickerController isSourceTypeAvailable:
          UIImagePickerControllerSourceTypeCamera] == NO)
        || (delegate == nil)
        || (controller == nil))
        return NO;
    
    
    UIImagePickerController *cameraUI = [[UIImagePickerController alloc] init];
    cameraUI.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    // Displays a control that allows the user to choose picture or
    // movie capture, if both are available:
    //    cameraUI.mediaTypes =
    //    [UIImagePickerController availableMediaTypesForSourceType:
    //     UIImagePickerControllerSourceTypeCamera];
    
    // Hides the controls for moving & scaling pictures, or for
    // trimming movies. To instead show the controls, use YES.
    cameraUI.allowsEditing = YES;
    
    cameraUI.delegate = delegate;
    
    [controller presentModalViewController: cameraUI animated: YES];
    return YES;
}

- (BOOL) startMediaBrowserFromViewController: (UIViewController*) controller
                               usingDelegate: (id <UIImagePickerControllerDelegate,
                                               UINavigationControllerDelegate>) delegate {
    
    if (([UIImagePickerController isSourceTypeAvailable:
          UIImagePickerControllerSourceTypePhotoLibrary] == NO)
        || (delegate == nil)
        || (controller == nil)) {
        [CommonAlert alertWithTitle:@"안내" message:@"본 장치는 사진 앨범를 지원하지 않습니다."];
        return NO;
    }
    
    UIImagePickerController *mediaUI = [[UIImagePickerController alloc] init];
    mediaUI.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    // Displays saved pictures and movies, if both are available, from the
    // Camera Roll album.
    mediaUI.mediaTypes =
    [UIImagePickerController availableMediaTypesForSourceType:
     UIImagePickerControllerSourceTypePhotoLibrary];
    
    // Hides the controls for moving & scaling pictures, or for
    // trimming movies. To instead show the controls, use YES.
    mediaUI.allowsEditing = YES;
    
    mediaUI.delegate = delegate;
    
    [controller presentModalViewController: mediaUI animated: YES];
    return YES;
}

- (void) returnWithData:(NSDictionary*) data
{
    [photoSelected setImage:[data objectForKey:@"imageToSave"]];
    self.imageToUpload = [data objectForKey:@"imageToSave"];
    // 1.7.0에서는 아래 내용을 따로 처리하지 않기로 결정함.
    //    if([[data objectForKey:@"source"] isEqualToString:@"camera"]) {
    //        [photoSelected setImage:[data objectForKey:@"imageToSave"]];
    //        self.imageToUpload = [data objectForKey:@"imageToSave"];
    //    }
    //
    //    if([[data objectForKey:@"source"] isEqualToString:@"album"]) {
    //        AlbumPreviewViewController* vc = [[[AlbumPreviewViewController alloc] initWithNibName:@"AlbumPreviewViewController" bundle:nil] autorelease];
    //        vc.delegate = self;
    //        vc.image = [data objectForKey:@"imageToSave"];
    //        [self.navigationController pushViewController:vc animated:NO];        
    //    }
}

- (void) returnImage:(UIImage*) image
{
    [photoSelected setImage:image];
    self.imageToUpload = image;
}


- (void) deleteSelectedImage {
	photoSelected.image = [UIImage imageNamed:@"icon_nonphoto.png"];
	self.imageToUpload = nil;
}

/*
#pragma mark -
- (void) saveCurrentText:(NSString *)text {
    if (!(text == nil || [text isEqualToString:@""])) {
        [[NSUserDefaults standardUserDefaults] setValue:text forKey:@"PostCurrentText"];
        MY_LOG(@"The Text has saved in local");
    }
    
    if (imageToUpload != nil) {
        UIImage* orgImage = imageToUpload;
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        NSString *diskCachePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"ImageCache"];
        NSString *uniquePath = [diskCachePath stringByAppendingPathComponent:@"selectedImage.jpg"];
        MY_LOG(@"saveCurrentText >Writing selected image to ImageCache folder:%@",uniquePath);
        BOOL isSaved = [UIImageJPEGRepresentation(orgImage,85)  writeToFile: uniquePath atomically:YES];
        if (isSaved) {
            MY_LOG(@"A Image has saved in local");
        }
    }
    MY_LOG(@"current information has saved in local");
}

- (void) getCurrentCheckInContents {
    contentTextView.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"PostCurrentText"];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *diskCachePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"ImageCache"];
	NSString *uniquePath = [diskCachePath stringByAppendingPathComponent:@"selectedImage.jpg"];
	MY_LOG(@"Getting selected image to ImageCache folder:%@",uniquePath);
    
    NSData *imageData = [NSData dataWithContentsOfFile:uniquePath];
    if (imageData) {
        self.imageToUpload = [UIImage imageWithData:imageData];
    }
}

- (void) deleteCurrentCheckInContents {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"PostCurrentText"];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *diskCachePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"ImageCache"];
    NSString *uniquePath = [diskCachePath stringByAppendingPathComponent:@"selectedImage.jpg"];
    NSFileManager *filemanager = [NSFileManager defaultManager];
    [filemanager removeItemAtPath:uniquePath error:nil];
}
*/

/**
 버튼 이미지 변경
 */
- (void) setWriteButtonImageEnabled:(BOOL)enabled {

    if (enabled) {
        [writeBtn1 setImage:[UIImage imageNamed:@"btntop_confirm.png"] forState:UIControlStateNormal];
        [writeBtn2 setImage:[UIImage imageNamed:@"footcheckwrite_confirm.png"] forState:UIControlStateNormal];
    } else {
        [writeBtn1 setImage:[UIImage imageNamed:@"btntop_confirm_alpha.png"] forState:UIControlStateNormal];
        [writeBtn2 setImage:[UIImage imageNamed:@"footcheckwrite_confirm_non.png"] forState:UIControlStateNormal];
    }
    
    /*
     버튼 이미지 테스트 2 : 알파값 변경 
     //     */
    //    if (enabled) {
    //        [writeBtn1 setAlpha:1.0];
    //        [writeBtn2 setAlpha:1.0];
    //    } else {
    //        [writeBtn1 setAlpha:0.4];
    //        [writeBtn2 setAlpha:0.4];
    //    }

}

/**
 @brief 버튼 활성화
 */
- (void) setWriteButtonEnabled:(BOOL)enabled {
        [writeBtn1 setEnabled:enabled];
        [writeBtn2 setEnabled:enabled];
}

- (void) setMapPOI {
    MY_LOG(@"poiData = %@", poiData);
    if (!([[poiData objectForKey:@"poiName"] isEqualToString:@""] || [poiData objectForKey:@"poiName"] == nil)) {
        [self setWriteButtonImageEnabled:YES];
        [noMapViewImgView setImage:[UIImage imageNamed:@"map_bg_on.png"]];
        [poiName setText:[poiData objectForKey:@"poiName"]];
        [self setSmallMap];
        //map poi setting
    } else {
        [self setWriteButtonImageEnabled:NO];
        [noMapViewImgView setImage:[UIImage imageNamed:@"map_bg_off.png"]];
        [poiName setText:@"지금 어디에 계신가요?"];
    }
}

- (void) setSmallMap {
    // 위치 변환
    CLLocation *poiLocation = [GeoContext tm2gws84WithTmX:[[poiData objectForKey:@"pointX"] doubleValue] withTmY:[[poiData objectForKey:@"pointY"] doubleValue]];
    MY_LOG(@"poi location = %@", poiLocation);
    // annotations 가 존재하면 제거
    [mapView removeAnnotations:mapView.annotations];  
    [mapView setRegion:MKCoordinateRegionMakeWithDistance([poiLocation coordinate], 100, 100)];
    
    //[mapView setCenterCoordinate:CLLocationCoordinate2DMake([poiLocation coordinate].latitude+0.0002, [poiLocation coordinate].longitude)];
    CLLocationCoordinate2D centerCoord = { [poiLocation coordinate].latitude+0.0002, [poiLocation coordinate].longitude };
    [mapView setCenterCoordinate:centerCoord];

    MapAnnotation* annotation = [[MapAnnotation alloc] initWithCoordinate:[poiLocation coordinate]];
    [mapView addAnnotation:annotation];
    [annotation release];
}

#pragma mark - MKMapView delegate
- (MKAnnotationView *) mapView:(MKMapView *) mapView viewForAnnotation:(id ) annotation {
	MKPinAnnotationView *customAnnotationView=[[[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:nil] autorelease];    

    return customAnnotationView;
}

@end
