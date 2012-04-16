//
//  BadgeImageView.h
//  ImIn
//
//  Created by Myungjin Choi on 11. 2. 21..
//  Copyright 2011 KTH. All rights reserved.
//

/**
 @brief 뱃지 이미지
 */
@interface BadgeImageView : UIImageView {
    
    CGPoint tapLocation;
	NSDictionary* badgeData;
}
@property (nonatomic, retain) NSDictionary* badgeData;

@end
