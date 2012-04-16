//
//  PoiInfo.m
//  ImIn
//
//  Created by edbear on 10. 9. 14..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PoiInfo.h"


@implementation PoiInfo

@synthesize poiKey;


- (CgiStringList*) prepare {
	CgiStringList* strPostData = [super prepare];
	[strPostData setMapString:@"poiKey" keyvalue:self.poiKey];

	return strPostData;
}

- (void) dealloc {
	// custom dealloc
	[poiKey release];
	[super dealloc];
}
#ifdef MOCK_PROTOCOL
- (NSString*) mockJson
{
    return @"{\"func\":\"poiInfo\",\"result\":true,\"description\":\"성공\",\"errCode\":\"0\",\"poiKey\":\"U10000000403\",\"poiName\":\"한화콘도\",\"pointX\":\"202363\",\"pointY\":\"443977\",\"addr0\":\"국내\",\"addr1\":\"서울특별시\",\"addr2\":\"서초구\",\"addr3\":\"서초4동\",\"poiPhoneNo\":\"\",\"poiCnt\":251,\"userCnt\":163,\"evtId\":\"\",\"evtBlogPostId\":\"\",\"evtUrl\":\"\",\"evtMsg\":\"\",\"currPoint\":6,\"evtPoint\":0,\"poiUser\":[{\"sndId\":\"12345\", \"nickname\":\"choipd\",\"bizId\":\"1234\", \"bizType\":\"1\",\"bizNickname\":\"himart\",\"profileImg\":\"\"}]}";
}
#endif

@end
