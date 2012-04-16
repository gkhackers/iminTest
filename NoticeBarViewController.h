//
//  NoticeBarViewController.h
//  ImIn
//
//  Created by choipd on 10. 5. 25..
//  Copyright 2010 edbear. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 @brief 광장에서 동위치가 바뀔 경우 아래에서 위로 올라오는 공지
 */
@interface NoticeBarViewController : UIViewController {
	IBOutlet UIButton* closeBtn;
	IBOutlet UILabel* noticeMessage;
	BOOL  isShown;
}

@property (nonatomic, retain) IBOutlet UILabel* noticeMessage;

-(IBAction) closeNotice;
-(IBAction) refreshPlaza;
- (void) toggleView;
- (void) viewExplainView:(BOOL)willShow;
@end
