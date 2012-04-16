//
//  TwitterInvitationViewController.h
//  ImIn
//
//  Created by choipd on 10. 7. 30..
//  Copyright 2010 edbear. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNSInvitationViewController.h"
@class HttpConnect;
/**
 @brief 트위터 기반의 이웃 추천
 */
@interface TwitterInvitationViewController : SNSInvitationViewController {
}

- (IBAction) popViewController;
- (IBAction) refreshTwitterList;

@end
