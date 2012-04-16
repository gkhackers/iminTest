//
//  SNSConnectionViewController.h
//  ImIn
//
//  Created by choipd on 10. 7. 30..
//  Copyright 2010 edbear. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImInProtocol.h"

@class HttpConnect;
@class CpData;
@class GetDelivery;
@class DelDelivery;
/**
 @brief 글 내보내기 설정페이지
 */
@interface SNSConnectionViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, ImInProtocolDelegate> {
	HttpConnect* connect1;
	IBOutlet UITableView* myTableView;
    GetDelivery* getDelivery;
    DelDelivery* delDelivery;
}

@property (nonatomic, retain) GetDelivery* getDelivery;
@property (nonatomic, retain) DelDelivery* delDelivery;

- (IBAction) popViewController;
- (IBAction) getDeriveryInfo;  
- (IBAction) delDeriveryWithCpData:(CpData*) cpData;
- (IBAction) delDeriveryTwitter;
- (IBAction) delDeriveryFacebook;
- (IBAction) delDeriveryMe2day;
@end
