//
//  FeedCell.h
//  ImIn
//
//  Created by edbear on 10. 9. 9..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 @brief 마이홈의 리스트의 각 셀 정보
 */
@interface FeedCell : UITableViewCell {
	IBOutlet UIImageView* feedTypeIcon; ///< 새소식 타입별 아이콘
	IBOutlet UILabel* feedContent;  ///< 새소식 내용
	IBOutlet UIImageView* aNewIcon;     ///< 새글 아이콘
}
@property (nonatomic, retain) UIImageView* feedTypeIcon; ///< 발도장, 새소식에 따라 이미지 변경
@property (nonatomic, retain) UILabel* feedContent;
@property (nonatomic, retain) UIImageView* aNewIcon;	

@end
