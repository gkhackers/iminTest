//
//  SnsRegistController.h
//  ImIn
//
//  Created by mandolin on 10. 5. 28..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HttpConnect.h"
#import "RealtimeBadge.h"

@class SetAuthTokenEx;
/**
 @brief 아임IN회원가입
 */
@interface SnsRegistController : UIViewController <UITextFieldDelegate, ImInProtocolDelegate, RealtimeBadgeProtocol> {
	IBOutlet UITextField *userNick;
	IBOutlet UITextField *userPhone;
    IBOutlet UITextField *friendNick;
	
	IBOutlet UIButton *customBackBtn ;
	
	IBOutlet UIButton *joinBtn;
	IBOutlet UIButton *agreementBtn ;
	IBOutlet UISwitch *agreementSwitch ;
	SetAuthTokenEx* setAuthTokenEx;
    
    RealtimeBadge* realtimeBadge;
	
	BOOL isAgree1;
    BOOL isAgree2;
	HttpConnect* connect;
    
    NSArray* badgeList;
}

@property (nonatomic, retain) SetAuthTokenEx* setAuthTokenEx;
@property (nonatomic, retain) NSArray* badgeList;

- (IBAction) onClickJoinBtn : (id)sender ;
- (IBAction) onClickAgreement : (UIButton*)sender ;
- (IBAction) onChangeAgreementSwitch: (UISwitch*)sender;
- (IBAction) backgroundTap : (id)sender;
//- (IBAction) onClickCustomBack : (id)sender ;
- (void)setFieldText:(NSString*)str target:(UITextField*)tField;
- (void) requestSnsJoin;
@end
