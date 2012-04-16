//
//  UINoticeCatalogController.h
//  ImIn
//
//  Created by mandolin on 10. 7. 19..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HttpConnect.h"
#import "ImInProtocol.h"

@class BlogAPI;
/**
 @brief 설정 리스트 중 '서비스 공지/안내' 페이지
 */
@interface UINoticeCatalogController : UIViewController <UINavigationBarDelegate, UITableViewDelegate, UITableViewDataSource, ImInProtocolDelegate>
{
	UITableView *mainTableView;
	HttpConnect* connect;
	
	UILabel* title;
	UIImageView* nvView;
	UIButton* backButton;
	NSInteger curPageNum;
	
	NSMutableArray* noticeArray; //데이타 리스트 받은정보
    BlogAPI* blogAPI;
	
	BOOL isTop;
	BOOL isEnd;
}

@property (readwrite) NSInteger curPageNum;
@property (nonatomic, retain) NSMutableArray* noticeArray;
@property (nonatomic, retain) BlogAPI* blogAPI;

- (void) getNotice;
- (void) FillCell:(UITableViewCell*)aCell index:(NSInteger)row noticeData:(NSDictionary*)noticeArr redraw:(BOOL)redraw;
- (void) requestLatest;

@end
