//
//  UIPostReportViewController.h
//  ImIn
//
//  Created by mandolin on 10. 9. 1..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HttpConnect.h"

/**
 @brief 문제 글 신고하기 기능
 */
@interface UIPostReportViewController : UIViewController <UINavigationBarDelegate, UINavigationBarDelegate, UITableViewDelegate, UITableViewDataSource>
{
	UITableView *mainTableView;
	NSMutableArray *reportContent;
	
	UILabel* title;
	UIImageView* nvView;
	UIButton* doneButton;
	UIButton* backButton;
	NSString* strPostNum;
	NSInteger catIndex;
	HttpConnect* connect;
	NSString* postId;
	NSString* cmtId;
}
@property (retain,nonatomic) NSMutableArray *reportContent;

- (void) setPostId:(NSString*)pId;
- (void) setCmtId:(NSString*)cId;
- (void) FillCell:(UITableViewCell*) aCell withSender:(NSString*)sender redraw:(BOOL)redraw;

@end
