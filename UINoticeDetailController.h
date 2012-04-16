//
//  UINoticeDetailController.h
//  ImIn
//
//  Created by mandolin on 10. 7. 21..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HttpConnect.h"
#import "ImInProtocol.h"

/**
 @brief '공지/안내' 리스트에서 선택한 공지의 상세 페이지
 */
@class BlogAPI;

@interface UINoticeDetailController : UIViewController <ImInProtocolDelegate>{
	UILabel* titleLabel; 
	UILabel* timeLabel;
	UIWebView* noticeWeb;
	HttpConnect* connect;
	NSString* postId;
    BlogAPI* blogAPI;
}

@property (nonatomic, retain) NSString* postId;
@property (nonatomic, retain) BlogAPI* blogAPI;

- (id)initWithPostId:(NSString *)pId;
- (void) requestPostData; ///< 상세 정보 요청
@end
