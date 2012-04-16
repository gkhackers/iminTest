//
//  PostDetailBrandCell.h
//  ImIn
//
//  Created by KYONGJIN SEO on 10/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MemberInfo;

/**
 @brief 브랜드 발도장 셀
 */
@interface PostDetailBrandCell : UITableViewCell {
    UILabel *postContentLabel;
    IBOutlet UILabel *dateLabel;
    IBOutlet UIImageView *logoImageView;
    IBOutlet UIButton *brandProfileBtn;
    
    MemberInfo *owner;
}

@property (nonatomic, retain) IBOutlet UILabel *postContentLabel;
@property (nonatomic, retain) MemberInfo *owner;

@end
