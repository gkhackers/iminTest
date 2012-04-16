//
//  FeedList.m
//  ImIn
//
//  Created by edbear on 10. 9. 10..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FeedList.h"


@implementation FeedList

@synthesize feedType, currPage, lastFeedDate;

- (CgiStringList*) prepare {
	CgiStringList* strPostData = [super prepare];
	[strPostData setMapString:@"feedType" keyvalue:self.feedType];
	[strPostData setMapString:@"currPage" keyvalue:self.currPage];
	[strPostData setMapString:@"scale" keyvalue:@"100"];
	[strPostData setMapString:@"lastFeedDate" keyvalue:self.lastFeedDate];
	
	return strPostData;
}

- (void) dealloc {
	// custom dealloc
	[lastFeedDate release];
	[feedType release];
	[currPage release];
	[super dealloc];
}
#ifdef MOCK_PROTOCOL
- (NSString*) mockJson
{
    return @"";
}
#endif
@end
