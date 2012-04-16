//
//  SingupViewController.h
//  ImIn
//
//  Created by park ja young on 11. 4. 11..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 @TODO 클래스명 수정
 @brief 회원가입 페이지 
 */
@interface SingupViewController : UIViewController {
	IBOutlet UIButton* email;   ///< 이메일로 가입하기
	IBOutlet UIButton* paran; ///< 파란메일로 가입하기
	IBOutlet UIButton* twitter; ///< 트위터로 가입하기
	IBOutlet UIButton* facebook;    ///< 페이스북으로 가입하기 
	IBOutlet UIButton* help;
	
	NSString* udid;
	NSString* oAuthUrl;
}

@property (nonatomic, retain) NSString* udid;
@property (nonatomic, retain) NSString* oAuthUrl;

- (IBAction) popViewController;
- (IBAction) goEmail;
- (IBAction) goParan;
- (IBAction) goTwitter;
- (IBAction) goFacebook;
- (IBAction) goHelp;


@end
