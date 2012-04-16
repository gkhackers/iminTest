//
//  PhoneNeighborViewController.h
//  ImIn
//
//  Created by edbear on 10. 12. 7..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNSInvitationViewController.h"

@class PhoneNeighborList;
@class NoListInfoView;
/**
 @brief 폰기반 이웃 추천 뷰컨트롤러
 */
@interface PhoneNeighborViewController : SNSInvitationViewController <ImInProtocolDelegate>{
	PhoneNeighborList* phoneNeighborList;
	NoListInfoView* noListInfoView;
}
@property (nonatomic, retain) PhoneNeighborList* phoneNeighborList;
@property (nonatomic, retain) NoListInfoView* noListInfoView;

@end
