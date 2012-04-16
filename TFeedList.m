//
//  TFeedList.m
//  ImIn
//
//  Created by edbear on 10. 9. 10..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "TFeedList.h"


@implementation TFeedList
@synthesize feedId;
@synthesize snsId;
@synthesize msg;
@synthesize postId;
@synthesize evtId;
@synthesize poiKey;
@synthesize regDate;
@synthesize read;
@synthesize nickName;
@synthesize profileImageUrl;
@synthesize hasDeleted;
@synthesize badgeId;
@synthesize evtUrl;
@synthesize reserved1;
@synthesize reserved2;
@synthesize reserved3;
@synthesize reserved4;
@synthesize reserved5;
@synthesize reserved6;
@synthesize reserved7;
@synthesize reserved8;
@synthesize reserved9;
@synthesize reserved0;

//@synthesize 

- (void) dealloc {
	// custom dealloc
	[feedId release];
	[snsId release];
	[msg release];
	[postId release];
	[evtId release];
	[poiKey release];
	[regDate release];
	[read release];
	[nickName release];
	[profileImageUrl release];
	[hasDeleted release];
	[badgeId release];
	[evtUrl release];
	[reserved0 release];
	[reserved1 release];
	[reserved2 release];
	[reserved3 release];
	[reserved4 release];
	[reserved5 release];
	[reserved6 release];
	[reserved7 release];
	[reserved8 release];
	[reserved9 release];
	
	[super dealloc];
}

@end
