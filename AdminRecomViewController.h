//
//  AdminRecomViewController.h
//  ImIn
//
//  Created by Myungjin Choi on 11. 1. 18..
//  Copyright 2011 KTH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HttpConnect.h"

@class AdminRecomList;
@class HomeInfo;

/**
 @brief 처음 이웃 추천
 */
@interface AdminRecomViewController : UIViewController <ImInProtocolDelegate> {
	
	IBOutlet UIButton* firstNeigborAdd;
	IBOutlet UIButton* secondNeigborAdd;
	IBOutlet UIButton* thirdNeigborAdd;
		
	NSString* profileImageURL;
	NSString* snsId;
	NSString* nickname;
	NSNumber* neigborCnt;
	NSNumber* poiCnt;
	
	AdminRecomList* adminRecomList;
	
	NSArray* resultData;
	NSDictionary* savedData;
	
	HomeInfo* homeInfo;

	NSInteger friendCodeInt;
}

@property (nonatomic, retain)NSString* profileImageURL;
@property (nonatomic, retain)NSString* snsId;
@property (nonatomic, retain)NSString* nickname;
@property (nonatomic, retain)NSNumber* neigborCnt;
@property (nonatomic, retain)NSNumber* poiCnt;
@property (nonatomic, retain)AdminRecomList* adminRecomList;
@property (nonatomic, retain) NSArray* resultData;
@property (nonatomic, retain) HomeInfo* homeInfo;

- (IBAction) closeVC;
- (IBAction) pushFriendSetting:(UIButton*) sender;
- (IBAction) goNeighbor;


@end
