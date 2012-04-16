//
//  FeedCounter.h
//  ImIn
//
//  Created by edbear on 10. 9. 9..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ImInProtocol.h"

@class FeedList;
/**
 @brief 새소식 요청 관리 모델
 */

@interface FeedCounter : NSObject<ImInProtocolDelegate> {
    int appCnt; // app에서 노출할 cnt
	
	NSString* lastFeedDate;
		
	NSMutableArray* pointerArray;
    NSInteger newFeedCount;
	
}

@property (readwrite) int appCnt;
@property (readwrite) NSInteger newFeedCount;

@property (retain, nonatomic) NSString* lastFeedDate;

@property (retain, nonatomic) NSMutableArray* pointerArray;


- (int) total;
- (void) saveToDatabase;
- (void) saveToDatabase:(NSDictionary*) feedData;
- (void) reset;
- (void) deleteExpired;
- (void) updateReadFlag;
- (void) setBadgeNum : (NSInteger)newFeed;
@end
