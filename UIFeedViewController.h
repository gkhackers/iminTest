//
//  FeedViewController.h
//  ImIn
//
//  Created by park ja young on 11. 2. 8..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FeedListTableViewController;
/**
 @brief 새소식 화면
 */
@interface UIFeedViewController : UIViewController {

	IBOutlet UIView* feedListView;  ///< 기본 뷰
	
	FeedListTableViewController* feedTVC;   ///< 새소식 테이블 뷰
}

@property (nonatomic, retain)FeedListTableViewController* feedTVC;

- (IBAction) deleteAllFeed;


@end
