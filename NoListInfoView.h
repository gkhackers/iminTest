//
//  NoListInfoView.h
//  ImIn
//
//  Created by 태한 김 on 10. 6. 17..
//  Copyright 2010 kth. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 @brief 폰주소록에 정보가 없을 때
 */
@interface NoListInfoView : UIView {
	UILabel	*label1, *label2;
	UIImageView	*faceImgView;
}

@property (nonatomic, retain) UILabel *label1;
@property (nonatomic, retain) UILabel *label2;
@property (nonatomic, retain) UIImageView *faceImgView;

-(void) removeInfoViewFromSuperview;

@end
