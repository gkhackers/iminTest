//
//  BadgeAcquisitionViewController.h
//  ImIn
//
//  Created by Myungjin Choi on 11. 2. 14..
//  Copyright 2011 KTH. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 @brief 뱃지 획득 시 보여주기
 */
@interface BadgeAcquisitionViewController : UIViewController {
	//IB 
	IBOutlet UIScrollView* badgeScrollView;
	
	NSArray* badgeList;				///< 획득한 뱃지 리스트
	NSInteger currentBadgeIndex;	///< 현재 뱃지의 array index
}

@property (nonatomic, retain) NSArray* badgeList;

@end
