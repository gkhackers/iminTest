//
//  FeedCount.m
//  ImIn
//
//  Created by edbear on 10. 9. 10..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FeedCount.h"


@implementation FeedCount

@synthesize lastFeedDate;

- (CgiStringList*) prepare {
	CgiStringList* strPostData = [super prepare];
	
	if (self.lastFeedDate != nil) {
		[strPostData setMapString:@"lastFeedDate" keyvalue:self.lastFeedDate];
	}
	
	return strPostData;
}

- (void) dealloc {
	// custom dealloc
	[lastFeedDate release];
	[super dealloc];
}
#ifdef MOCK_PROTOCOL
- (NSString*) mockJson
{
    return @"{\"func\":\"feedCount\",\"result\":true,\"description\":\"성공\",\"errCode\":\"0\",\"postCnt\":7,\"cmtCnt\":0,\"neighborCnt\":2,\"systemCnt\":0,\"recmtCnt\":0,\"captainCnt\":0,\"badgeCnt\":0,\"eventCnt\":0,\"giftCnt\":0,\"scrapCnt\":0,\"isNew\":\"1\"}";
}
#endif
@end
