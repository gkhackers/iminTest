//
//  IntroViewController.h
//  ImIn
//
//  Created by park ja young on 11. 4. 1..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HttpConnect;
@class SetAuthTokenEx;
/**
 @brief 어플 첫 구동 시 노출되는 페이지
 @brief 가이드 노출
 */
@interface IntroViewController : UIViewController <ImInProtocolDelegate> {
	IBOutlet UIView *preView;   ///< 가입 버튼 첫 페이지
	IBOutlet UIView *afterView; ///< 신발이미지 뷰
	NSString* authToken;    ///< 인증 토큰
	
	HttpConnect* connect1;
	SetAuthTokenEx* setAuthTokenEx;
	BOOL isGuideShow;
	//NSTimer* tOut;
	
}

@property (nonatomic, retain) NSString* authToken;
@property (nonatomic, retain) SetAuthTokenEx* setAuthTokenEx;


- (void) isTokenExist;
- (NSString*) getToken;
- (IBAction)goLogin;
- (IBAction)goRegister;
- (void)moveView;


@end
