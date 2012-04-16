//
//  UIPhoneNumEditController.h
//  ImIn
//
//  Created by mandolin on 10. 7. 20..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HttpConnect.h"

/**
 @brief 내 폰번호 확인 선택 시(내 폰 인증 받기가 끝난경우) 
 */
@interface UIPhoneNumEditController : UIViewController <UITextFieldDelegate>
{
	IBOutlet UILabel *userPhone;
	IBOutlet UIButton *customBackBtn;
	IBOutlet UIButton *customDoneBtn;
	HttpConnect* connect;
	NSString* phoneNo;
}

- (void) setPnumber:(NSString*) pNumber;
- (IBAction) backgroundTap : (id)sender;
- (IBAction) onClickCustomBack : (id)sender ;
- (IBAction) onClickCustomDone : (id)sender ;
- (void)setFieldText:(NSString*)str target:(UITextField*)tField; ///< 내 폰번호를 휴대전화 필드에 넣어줌

@end
