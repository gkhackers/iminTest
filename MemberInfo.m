//
//  MemberInfo.m
//  ImIn
//
//  Created by edbear on 10. 9. 12..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "MemberInfo.h"


@implementation MemberInfo
@synthesize snsId, nickname, profileImgUrl;

- (void) dealloc
{
	[snsId release];
	[nickname release];
	[profileImgUrl release];
	
	[super dealloc];
}
@end
