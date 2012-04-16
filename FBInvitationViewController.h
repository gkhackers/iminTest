//
//  FBInvitationViewController.h
//  ImIn
//
//  Created by choipd on 10. 7. 30..
//  Copyright 2010 edbear. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNSInvitationViewController.h"

/**
 @brief 페이스북 기반의 이웃추천
 */
@interface FBInvitationViewController : SNSInvitationViewController {

}

- (IBAction) popViewController;
- (IBAction) refreshFacebookList;

@end
