//
//  BadgeDetailViewController.h
//  ImIn
//
//  Created by Myungjin Choi on 11. 2. 14..
//  Copyright 2011 KTH. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 @brief 뱃지 상세 보기
 */
@interface BadgeDetailViewController : UIViewController {
	NSDictionary* badgeInfo;
	MemberInfo* owner;
}

@property (nonatomic, retain) NSDictionary* badgeInfo;
@property (nonatomic, retain) MemberInfo* owner;

@end
