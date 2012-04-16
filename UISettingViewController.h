//
//  UISettingViewController.h
//  ImIn
//
//  Created by 태한 김 on 10. 6. 3..
//  Copyright 2010 kth. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ManageTableViewController.h"
#import "SnsKeyChain.h"
#import "HttpConnect.h"


@class FeedCounter;
@class ProfileInfo;

/**
 @brief 설정 탭
 */
@interface UISettingViewController : UIViewController <UIAlertViewDelegate, ImInProtocolDelegate> {
	ManageTableViewController *tableViewController;
	UILabel	*HeadStr;
	// PhoneNumber Setting용
	HttpConnect* connect2;
    FeedCount* feedCount;
    ProfileInfo* profileInfo;
}

@property (nonatomic, retain) FeedCount* feedCount;
@property (nonatomic, retain) ProfileInfo* profileInfo;

-(void) requestProfileInfo;
- (void) requestGiftInfo;

@end
