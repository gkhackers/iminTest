//
//  UpdateNotificationView.h
//  ImIn
//
//  Created by KYONGJIN SEO on 11/2/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 @brief 뱃지 업데이트 알림 뷰
 */
@interface UpdateNotificationView : UIView < UIScrollViewDelegate > {
    
    UIPageControl *pageControl;
    UIScrollView *contentScrollView;
    
    NSMutableArray *notiListArray;
    NSUInteger totalPageCnt;
    NSUInteger currentPosition;

    NSTimer *scrollTimer;
        
    id delegate;
    
    BOOL isEnd;
}
@property (nonatomic, retain) NSMutableArray *notiListArray;
@property (nonatomic, retain) UIScrollView *contentScrollView;
@property (readwrite) NSUInteger currentPosition;
@property (assign) id delegate;

- (void) processNotiList:(NSMutableArray *) resultArray;
- (void) automoveNotifications:(BOOL) move;

@end
