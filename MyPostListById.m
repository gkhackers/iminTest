//
//  PostListById.m
//  ImIn
//
//  Created by edbear on 10. 9. 10..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "MyPostListById.h"


@implementation MyPostListById
@synthesize postIdList;

- (CgiStringList*) prepare {
	CgiStringList* strPostData = [super prepare];
	[strPostData setMapString:@"postIdList" keyvalue:self.postIdList];
	[strPostData setMapString:@"isSkip" keyvalue:@"1"];
	[strPostData setMapString:@"scale" keyvalue:@"25"];

	return strPostData;
}

- (void) dealloc {
	// custom dealloc
	[postIdList release];
	[super dealloc];
}
#ifdef MOCK_PROTOCOL
- (NSString*) mockJson
{
    return @"{\"func\":\"myPostListById\",\"result\":true,\"description\":\"성공\",\"errCode\":\"0\",\"data\":[{\"postId\":\"2011043919190\",\"snsId\":\"100000330628\",\"nickname\":\"최피디101\",\"snsUrl\":\"최피디101\",\"profileImg\":\"http://i.kthimg.com/TOP/svc/imin/v1/img/no_prf_d1.gif\",\"shoesNo\":\"07\",\"post\":\"이웃님께 기분 좋은 선물을 받았어요~\",\"device\":\"01\",\"deviceName\":\"Web\",\"isBlind\":\"0\",\"isPolice\":\"0\",\"imgUrl\":\"http://211.113.4.83/TOP/svc/imin/v1/img/badgeG/301_std1.png\",\"cmtCnt\":\"1\",\"poiKey\":\"\",\"poiName\":\"비타민 C\",\"pointX\":\"0\",\"pointY\":\"0\",\"addr0\":\"\",\"addr1\":\"\",\"addr2\":\"\",\"addr3\":\"\",\"poiPhoneNo\":\"\",\"isBadge\":\"0\",\"postType\":\"2\",\"badgeId\":\"301\",\"badgeName\":\"비타민 C\",\"badgeMsg\":\"힘내세요! 파이팅! 당신을 응원하는 이웃님이 선물해서 새콤달콤 활력충전 비타민 C 뱃지 획득\",\"regDate\":\"2011.10.24 13:59:23\",\"scrapCnt\":0,\"isOpenScrap\":\"0\",\"bizType\":\"\",\"userType\":\"\"}],\"currPage\":1,\"scale\":25}";
}
#endif
@end
