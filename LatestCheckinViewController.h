//
//  LatestCheckinViewController.h
//  ImIn
//
//  Created by Myungjin Choi on 11. 4. 29..
//  Copyright 2011 KTH. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CheckinTableViewController;
@class MemberInfo;

/**
 @brief 최근 발도장 리스트 뷰 컨트롤러
 */
@interface LatestCheckinViewController : UIViewController {
	IBOutlet UIView* listAreaView;
	IBOutlet UILabel* titleLabel;
	
	CheckinTableViewController* checkinTVC;		///< 테이블 뷰 컨트롤러
	MemberInfo* owner;
	
	
}

@property (nonatomic, retain) CheckinTableViewController* checkinTVC;
@property (nonatomic, retain) MemberInfo* owner;


- (IBAction) popVC;

@end
