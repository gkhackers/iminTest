//
//  UIColumbusViewController.h
//  ImIn
//
//  Created by 태한 김 on 10. 5. 13..
//  Copyright 2010 kth. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImInProtocol.h"

/**
 @brief 콜럼버스 리스트 뷰 컨트롤러
 */
@interface UIColumbusViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, ImInProtocolDelegate, UIScrollViewDelegate> {
    
	NSMutableArray	*cellDataList;

	NSString	*snsId;
	NSString	*nickname;
    
    NSInteger currColListPage, totalCnt;
    
    NSString* tableCoverNoticeMessage;
    
	BOOL isTop;
	BOOL isEnd;
	BOOL isLoading;

	
    IBOutlet UILabel *titleLabel;
    IBOutlet UITableView *mainTableView;
}
@property (nonatomic, retain) NSString* snsId;
@property (nonatomic, retain) NSString* nickname;
@property (nonatomic, retain) NSMutableArray *cellDataList;
@property (nonatomic, retain) NSString* tableCoverNoticeMessage;

- (IBAction)closeVC:(id)sender;

- (void) requestColumbusList;

@end
