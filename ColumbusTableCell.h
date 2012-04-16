//
//  ColumbusTableCell.h
//  ImIn
//
//  Created by 태한 김 on 10. 5. 17..
//  Copyright 2010 kth. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 @brief 콜럼버스 테이블 뷰 셀
 */
@interface ColumbusTableCell : UITableViewCell {
	UILabel *poiName;
	UILabel *description;
	UIImageView *redFlag;
}

@property (nonatomic, retain) UILabel *poiName;
@property (nonatomic, retain) UILabel *description;
@property (nonatomic, retain) UIImageView *redFlag;

@end
