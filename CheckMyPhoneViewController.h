//
//  CheckMyPhoneViewController.h
//  ImIn
//
//  Created by edbear on 10. 12. 15..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SendAuthKey;
@class ProfileUpdate;

/**
 @brief 내 폰번호 확인 선택 시(내 폰 인증 받기가 필요한 경우) 
 */
@interface CheckMyPhoneViewController : UIViewController <UITextFieldDelegate, ImInProtocolDelegate>{
	SendAuthKey* sendAuthKey;
	ProfileUpdate* profileUpdate;
	
	NSString* authKey;
	
	IBOutlet UITextField* phoneNumberTextField; ///< 내폰번호 입력창
	IBOutlet UITextField* authValueTextField; ///< 인증번호 입력창
}

@property (nonatomic, retain) SendAuthKey* sendAuthKey;
@property (nonatomic, retain) ProfileUpdate* profileUpdate;
@property (nonatomic, retain) NSString* authKey;

- (IBAction) popVC;
- (IBAction) requestSendAuthKey; ///< SMS인증 버튼을 클릭시 SendAuthKey에 각 값을 세팅
- (IBAction) requestProfileUpdate; ///< 확인 버튼을 클릭시 ProfileUpdata에 각 값을 세팅

- (IBAction) backgroundTap : (id)sender;

@end
