//
//  UIMasterViewController.h
//  ImIn
//
//  Created by mandolin on 10. 9. 8..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HttpConnect.h"
#import "MasterViewCell.h"

@class TutorialView;
/**
 @brief 마스터 뷰 컨트롤러
 */
@interface UIMasterViewController : UIViewController <UINavigationBarDelegate, UINavigationBarDelegate, UITableViewDelegate, UITableViewDataSource>
{
	UITableView *mainTableView;
	NSMutableArray *masterContent;
	
	UILabel* title;
	UIImageView* nvView;
	NSString* strSnsId;
	NSInteger pageIndex;
	HttpConnect* connect;
	bool isEnd;
	bool isMyMaster;
	
	NSString* strNick;
//	UIView* nonItemView;
	TutorialView *tutorial;
    
	CGRect tableRect;
}
@property (retain,nonatomic) NSMutableArray *masterContent;
@property (readwrite) CGRect tableRect;
@property (retain, nonatomic) TutorialView *tutorial;
- (id)initWithUserNick:(NSString*)nick withSNSid:(NSString*)snsId;
- (void) requestCaptainList;
- (void) FillCell:(UITableViewCell*)aCell idx:(NSInteger)row onMasterData:(NSDictionary*) mt redraw:(BOOL)redraw;
@end
