//
//  UILoginViewController.h
//
//  Created by choipd on 10. 4. 19..
//  Copyright 2010 edbear. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "HttpConnect.h"

@class SetAuthTokenEx;
/**
 @brief 로그인 창
 */
@interface UILoginViewController : UIViewController <UITextFieldDelegate, ImInProtocolDelegate> {
	IBOutlet UITextField* userID;
	IBOutlet UITextField* userPW;
	IBOutlet UIImageView* userIDimgView;
	IBOutlet UIImageView* userPWimgView;
	IBOutlet UIButton* btnLogin;
	IBOutlet UIButton* btnRegist;
	IBOutlet UIButton* btnFindId;
	IBOutlet UIButton* btnFindPw;
	IBOutlet UIButton* btnTwitter;
	IBOutlet UIButton* btnFacebook;
	IBOutlet UIImageView* otherLoginImg;
	IBOutlet UIButton* btnPre;

	
	NSString* authToken;
	
	HttpConnect* connect1;
	SetAuthTokenEx* setAuthTokenEx;
	
	
	/// Animated Intro
	NSMutableArray *introArray;
	UIImageView *animatedImages;
	
	int updateRetryCount;
	BOOL paranLogin;
	BOOL isPreBtn;
}

@property (nonatomic, retain) NSString* authToken;
@property (readwrite)BOOL paranLogin;
@property (readwrite)BOOL isPreBtn;
@property (nonatomic, retain) SetAuthTokenEx* setAuthTokenEx;

- (IBAction) doLogin:(id)sender;
- (IBAction) doRegister:(id)sender;
- (IBAction) backgroundTap : (id)sender;
- (IBAction) doFindId:(id)sender;
- (IBAction) doFindPassword:(id)sender;
- (IBAction) popViewController;
- (IBAction) doTwitterLogin:(id)sender;
- (IBAction) doFacebookLogin:(id)sender;


- (void) onTransDone:(HttpConnect*)up;
- (void) onResultError:(HttpConnect*)up;
- (void) setParanLogin;


/*//아래부터는 로그인 가능하게 하기 위해 추가한 함수
-(void) getNoticeCount;
*/




@end
