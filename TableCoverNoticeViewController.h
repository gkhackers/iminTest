//
//  TableCoverNoticeViewController.h
//  ImIn
//
//  Created by edbear on 10. 9. 16..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
@brief 테이블 뷰 내용이 없을 경우 cover 영역
 */
@interface TableCoverNoticeViewController : UIViewController {
	IBOutlet UILabel* line1;
	IBOutlet UILabel* line2;
	IBOutlet UIImageView* faceIcon;
	IBOutlet UIView* bgView;
}

@property (nonatomic, retain) IBOutlet UILabel* line1;
@property (nonatomic, retain) IBOutlet UILabel* line2;
@property (nonatomic, retain) IBOutlet UIImageView* faceIcon;
@property (nonatomic, retain) IBOutlet UIView* bgView;


@end
