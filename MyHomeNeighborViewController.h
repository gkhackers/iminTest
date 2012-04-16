//
//  MyHomeNeighborViewController.h
//  ImIn
//
//  Created by 태한 김 on 10. 6. 14..
//  Copyright 2010 kth. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainThreadTableViewController.h"
#import "HttpConnect.h"
#import "CgiStringList.h"
#import "JSON.h"
#import "UserContext.h"



#define CELLLIST_CAPACITY   25

/**
 @brief 내 이웃 리스트 뷰 컨트롤러
 */
@interface MyHomeNeighborViewController : UIViewController <MainThreadProtocol> {
	UILabel		*headStr;
	NSMutableArray		*cellDataList;
	NSString	*userSnsID;
	NSString	*nickName;
    NSString* listType;

	MainThreadTableViewController	*neighborTableViewController;
	NSInteger	neighborCurrPage;
	
	BOOL hasLoaded;
	
	HttpConnect* connect;
	
	CGRect tableRect;
}

@property (nonatomic, retain) UILabel* headStr;
@property (nonatomic, retain) NSMutableArray* cellDataList;
@property (nonatomic, retain) NSString* userSnsID;
@property (nonatomic, retain) NSString* nickName;
@property (nonatomic, retain) NSString* listType;
@property (nonatomic, retain) MainThreadTableViewController* neighborTableViewController;
@property (nonatomic, retain) HttpConnect* connect;
@property (readwrite) CGRect tableRect;


- (void) requestFriendsList;
- (id) initWithSnsId:(NSString*) snsIdStr nickName:(NSString*)nName;
- (id) initWithSnsId:(NSString*) snsIdStr nickName:(NSString*)nName listType:(NSString*)listType;
@end
