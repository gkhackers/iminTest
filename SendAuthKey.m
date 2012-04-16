//
//  SendAuthKey.m
//  ImIn
//
//  Created by edbear on 10. 12. 15..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SendAuthKey.h"


@implementation SendAuthKey

@synthesize phoneNo;

- (CgiStringList*) prepare {
	CgiStringList* strPostData = [super prepare];
	[strPostData setMapString:@"phoneNo" keyvalue:self.phoneNo];

	return strPostData;
}

- (void) dealloc {
	// custom dealloc
	[phoneNo release];
	
	[super dealloc];
}

#ifdef MOCK_PROTOCOL
- (NSString*) mockJson {
    return @"{\"func\":\"sendAuthKey\",\"result\":true,\"description\":\"성공\",\"errCode\":\"0\",\"authKey\":\"342\"}";
}
#endif

@end
