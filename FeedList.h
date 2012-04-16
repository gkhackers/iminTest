//
//  FeedList.h
//  ImIn
//
//  Created by edbear on 10. 9. 10..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ImInProtocol.h"

/**
 @brief 아임인 프로토콜
 */

@interface FeedList : ImInProtocol {
	NSString* feedType;
	NSString* currPage;
	NSString* lastFeedDate;
}
@property (nonatomic, retain) NSString* feedType;
@property (nonatomic, retain) NSString* currPage;
@property (nonatomic, retain) NSString* lastFeedDate;
@end
