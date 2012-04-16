//
//  ManageTableViewController.h
//  ImIn
//
//  Created by 태한 김 on 10. 5. 10..
//  Copyright 2010 kth. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SnsHelpController.h"
#import "HttpConnect.h"
#import "uploader.h"

#define PROFILE_ROW 0
#define PHONEEDIT_ROW 1
#define DELIVERY_ROW	2
#define FRIEND_INIVITE_ROW 3
#define NEIGHBOR_ROW 4
#define NOTI_SET_ROW 5
#define PRESENT_ROW 6
#define NEIGHBOR_BLOCK_ROW 7
#define NOTICE_ROW	8
#define INFO_ROW	9
#define HELP_ROW	10
#define PARAN_APP_ROW	11


#define FIRST_ROW_MAX	12

#define LOGOUT_SECTION	5

#define LOGOUT_TAG		1
#define TWITTER_TAG		2
#define SIMPLE_TAG		3
#define EXIT_TAG		4
#define PARAN_APP_TAG	6
#define PROFILE_IMAGEVIEW_TAG 100
#define GIFTNEW_IMAGEVIEW_TAG 101
#define FRIENDINVITE_IMAGEVIEW_TAG 102
#define GIFT_IMAGEVIEW_TAG 103
#define EVENT_IMAGEVIEW_TAG 104

@class HomeInfoDetail;
/**
 @brief 설정 페이지의 설정 정보 리스트
 */
@interface ManageTableViewController : UITableViewController <UINavigationControllerDelegate, ImInProtocolDelegate>
{
	UIAlertView *alertView;

	NSString	*imageUrlStr; 
	
	UIActionSheet	*baseSheet;
	id			alertDelegate;

	Boolean		isTwitterSet;
	UIImage*	imageToReturn;
	UIActionSheet* selectionSheet;
	
	HomeInfoDetail* homeInfoDetail;
	NSDictionary* homeInfoDetailResult;
    NSInteger giftNewCnt;
    
}

@property (nonatomic, retain) HomeInfoDetail* homeInfoDetail;
@property (nonatomic, retain) NSDictionary* homeInfoDetailResult;
@property (readwrite) NSInteger giftNewCnt;

- (void) viewCheckWhenAppear;
- (void) setLogoutAlertDelegate:(id)vc;
- (void) gitfNewImageSet;
- (void) goGiftHome;
- (void) goEvent;


@end
