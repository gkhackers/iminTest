//
//  FriendFinderSettingViewController.h
//  ImIn
//
//  Created by choipd on 10. 7. 30..
//  Copyright 2010 edbear. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImInProtocol.h"

@class ProfileUpdate;
@class PhoneNeighborList;
@class HttpConnect;
@class CpData;
@class FBInvitationViewController;
@class TwitterInvitationViewController;
@class GetDelivery;
@class DelDelivery;

/**
 @brief 이웃추천 설정 페이지 
 */
@interface FriendFinderSettingViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, ImInProtocolDelegate> {
	HttpConnect* connect1;
	IBOutlet UITableView* myTableView;
	
	FBInvitationViewController* fbVC;
	TwitterInvitationViewController* twVC;

	ProfileUpdate* profileUpdate;
	PhoneNeighborList* phoneNeighborList;
    
    GetDelivery* getDelivery;
    DelDelivery* delDelivery;

}

@property (nonatomic, retain) FBInvitationViewController* fbVC;
@property (nonatomic, retain) TwitterInvitationViewController* twVC;

@property (nonatomic, retain) ProfileUpdate* profileUpdate;
@property (nonatomic, retain) PhoneNeighborList* phoneNeighborList;

@property (nonatomic, retain) GetDelivery* getDelivery;
@property (nonatomic, retain) DelDelivery* delDelivery;



- (IBAction) popViewController;
- (void) getDeriveryInfo; 
- (IBAction) delDeriveryWithCpData:(CpData*) cpData;
- (IBAction) delDeriveryTwitter;
- (IBAction) delDeriveryFacebook;

- (void) refreshPhoneList; ///< 폰 주소록 다시 가져오기 
- (void) deletePhoneNoAndClearPhoneList; ///< 연결 해제하기 ( 연결되어있을 경우 )

@end
