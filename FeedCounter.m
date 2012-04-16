//
//  FeedCounter.m
//  ImIn
//
//  Created by edbear on 10. 9. 9..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FeedCounter.h"
#import "FeedList.h"
#import "TFeedList.h"
#import "UIFeedViewController.h"


@implementation FeedCounter
@synthesize appCnt, lastFeedDate;
@synthesize pointerArray;
@synthesize newFeedCount;

- (id) init
{
	self = [super init];
	if (self != nil) {
        appCnt = 0;
        
		self.pointerArray = [[[NSMutableArray alloc] initWithCapacity:20] autorelease];
	}
	return self;
}

- (int) total {
	return appCnt;
}

- (void) reset {
    appCnt = 0;
}

// 한 달이 지난 피드는 제거한다
- (void) deleteExpired {
	[[TFeedList database] executeSql:@"update tfeedlist set hasDeleted = 1 where regdate < strftime('%Y.%m.%d %H:%M:%S', 'now', '+9 hour', '-30 day')"];
}

// 1일이 지난 피드는 모두 읽음처리한다.  
- (void) updateReadFlag {
	[[TFeedList database] executeSql:@"update tfeedlist set read = 1 where regdate < strftime('%Y.%m.%d %H:%M:%S', 'now', '+9 hour', '-1 day')"];
}

- (void) saveToDatabase {
	NSString* feedDate = [Utils lastFeedDate];
    
	if (appCnt > 0) {
		for (int i=0; i < appCnt / 100 + 1 ; i++) {
			FeedList* afeedList = [[[FeedList alloc] init] autorelease];
			afeedList.delegate = self;
			afeedList.feedType = @"31";
			afeedList.currPage = [NSString stringWithFormat:@"%d", i+1];
			afeedList.lastFeedDate = feedDate;
			[afeedList request];
			[pointerArray addObject:afeedList];
		}
	}
}

- (void) saveToDatabase:(NSDictionary*) feedData {
    NSInteger newFeedCnt = [[feedData objectForKey:@"totalCnt"] intValue];
    NSArray* feedListData = [feedData objectForKey:@"data"];
    
    for (NSDictionary* feed in feedListData) {
        TFeedList* tableFeed = [[[TFeedList alloc] init] autorelease];
        tableFeed.feedId = [feed objectForKey:@"feedId"];
        tableFeed.evtId = [feed objectForKey:@"evtId"];
        tableFeed.snsId = [feed objectForKey:@"orgSnsId"];
        tableFeed.msg = [feed objectForKey:@"msg"];
        tableFeed.postId = [feed objectForKey:@"postId"];
        tableFeed.poiKey = [feed objectForKey:@"poiKey"];
        tableFeed.regDate = [feed objectForKey:@"regDate"];
        tableFeed.badgeId = [feed objectForKey:@"badgeId"];
        tableFeed.evtUrl = [feed objectForKey:@"evtUrl"];
        tableFeed.reserved0 = [feed objectForKey:@"goUrl"];
        tableFeed.hasDeleted = @"0";
        
        tableFeed.read = [NSNumber numberWithInt:0];
        tableFeed.nickName = [feed objectForKey:@"orgNickname"];
        tableFeed.profileImageUrl = [feed objectForKey:@"profileImg"];
        [tableFeed save];
    }
    
    [UIApplication sharedApplication].applicationIconBadgeNumber = newFeedCnt;
    MY_LOG(@"[UIApplication sharedApplication].applicationIconBadgeNumber = %d", [UIApplication sharedApplication].applicationIconBadgeNumber);
    
    [ViewControllers sharedViewControllers].feedViewController.tabBarItem.badgeValue = newFeedCnt > 0 ? [NSString stringWithFormat:@"%d", newFeedCnt] : nil;
    MY_LOG(@"[ViewControllers sharedViewControllers].feedViewController.tabBarItem.badgeValue = %@", [ViewControllers sharedViewControllers].feedViewController.tabBarItem.badgeValue);
    
    [[ViewControllers sharedViewControllers].feedViewController viewWillAppear:YES];
}

-(void) apiDidLoadWithResult:(NSDictionary*)result whichObject:(NSObject*) theObject;
{
	NSArray* feedList = [result objectForKey:@"data"];
	
	for (NSDictionary* feed in feedList) {
		TFeedList* tableFeed = [[[TFeedList alloc] init] autorelease];
		tableFeed.feedId = [feed objectForKey:@"feedId"];
		tableFeed.evtId = [feed objectForKey:@"evtId"];
		tableFeed.snsId = [feed objectForKey:@"orgSnsId"];
		tableFeed.msg = [feed objectForKey:@"msg"];
		tableFeed.postId = [feed objectForKey:@"postId"];
		tableFeed.poiKey = [feed objectForKey:@"poiKey"];
		tableFeed.regDate = [feed objectForKey:@"regDate"];
		tableFeed.badgeId = [feed objectForKey:@"badgeId"];
		tableFeed.evtUrl = [feed objectForKey:@"evtUrl"];
        tableFeed.reserved0 = [feed objectForKey:@"goUrl"];
		tableFeed.hasDeleted = @"0";
		
		tableFeed.read = [NSNumber numberWithInt:0];
		tableFeed.nickName = [feed objectForKey:@"orgNickname"];
		tableFeed.profileImageUrl = [feed objectForKey:@"profileImg"];
		[tableFeed save];
	}
    
    //    if ([feedList count] > 0) {
    //        UINavigationController* feedNavigationController = (UINavigationController*)[ViewControllers sharedViewControllers].feedViewController;
    //        if ([[feedNavigationController viewControllers] count] > 0) {
    //            UIFeedViewController* feedVC = (UIFeedViewController*)[[feedNavigationController viewControllers] objectAtIndex:0];
    //            [feedVC.feedTVC reloadData];            
    //        }
    //    }
    
    [UIApplication sharedApplication].applicationIconBadgeNumber = newFeedCount;
    MY_LOG(@"[UIApplication sharedApplication].applicationIconBadgeNumber = %d", [UIApplication sharedApplication].applicationIconBadgeNumber);
    
    [ViewControllers sharedViewControllers].feedViewController.tabBarItem.badgeValue = newFeedCount > 0 ? [NSString stringWithFormat:@"%d", newFeedCount] : nil;
    MY_LOG(@"[ViewControllers sharedViewControllers].feedViewController.tabBarItem.badgeValue = %@", [ViewControllers sharedViewControllers].feedViewController.tabBarItem.badgeValue);
    
    if ([feedList count] > 0) {
        [[ViewControllers sharedViewControllers].feedViewController viewWillAppear:YES];
    }
    
    [pointerArray removeObject:theObject];
	MY_LOG(@"남은 FeedList api object : %d", [pointerArray count]);
    
}


- (void) apiFailed {
	//
}

- (void) setBadgeNum : (NSInteger) newFeed {
    newFeedCount = newFeed;
    MY_LOG(@"newFeedCount = %d", newFeedCount);
    
}

- (void) dealloc {
	[lastFeedDate release];
	[pointerArray release];
	[super dealloc];
}

@end
