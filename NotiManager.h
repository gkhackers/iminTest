//
//  NotiContext.h
//  ImIn
//
//  Created by KYONGJIN SEO on 11/2/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

@protocol IminNotificationDelegate <NSObject>

@optional
- (void) didFinishedUpdateNotifications:(NSDictionary *) result;
@end

@class UpdateNotificationView;

/**
 @brief 뱃지 업데이트 notification 관리
 */
@interface NotiManager : NSObject {
    
    id <IminNotificationDelegate> delegate;
    UpdateNotificationView* updateNotiView;
}
@property (assign) id <IminNotificationDelegate> delegate;
@property (nonatomic, retain) UpdateNotificationView* updateNotiView;

- (void) showUpdateNotification:(NSMutableArray *) resultArray;
- (void) removeUpdateNotification:(NSDictionary *) result;
- (void) hideUpdateNotification:(BOOL) hidden;
- (void) sendDataToViewController:(NSDictionary *) result;
@end
