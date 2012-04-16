//
//  NotiSettingViewController.h
//  ImIn
//
//  Created by park ja young on 11. 2. 14..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImInProtocol.h"

@class SetNoti;
@class GetNoti;
@class iToast;

/**
 @brief 알림 설정
 */
@interface NotiSettingViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, ImInProtocolDelegate> {
    
    IBOutlet UITableView *settingTableView;
    
	int notiBit;
	
	SetNoti* setNoti;
	GetNoti* getNoti;
    UISwitch* totalAlaramSwitch;
}
@property (nonatomic, retain) SetNoti* setNoti;
@property (nonatomic, retain) GetNoti* getNoti;
@property (nonatomic, retain) UISwitch* totalAlaramSwitch;

- (IBAction) popViewController;
- (IBAction) setSave;
- (void) requestGetNoti;
- (void) requestSetNoti;

@end
