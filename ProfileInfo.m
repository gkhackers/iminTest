//
//  ProfileInfo.m
//  ImIn
//
//  Created by edbear on 10. 9. 10..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ProfileInfo.h"


@implementation ProfileInfo


- (CgiStringList*) prepare {
	CgiStringList* strPostData = [super prepare];
	//[strPostData setMapString:@"" keyvalue:@""];

	return strPostData;
}

- (void) dealloc {
	// custom dealloc
	[super dealloc];
}
#ifdef MOCK_PROTOCOL
- (NSString*) mockJson
{
    return @"{\"func\":\"profileInfo\",\"result\":true,\"description\":\"성공\",\"errCode\":\"0\",\"snsUrl\":\"최피디\",\"profileImg\":\"http://snsfile.paran.com/SNS_93/201109/620002878900_1314861093322_thumb1.jpg.jpg\",\"phoneNo\":\"\",\"shoesNo\":\"00\",\"useNPhoneNo\":\"0\"}";
}
#endif
@end
