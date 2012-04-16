//
//  HomeInfo.m
//  ImIn
//
//  Created by edbear on 10. 9. 10..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "HomeInfo.h"


@implementation HomeInfo
@synthesize snsId;

- (CgiStringList*) prepare {
	CgiStringList* strPostData = [super prepare];
	[strPostData setMapString:@"snsId" keyvalue:self.snsId];

	return strPostData;
}

- (void) dealloc {
	// custom dealloc
	[snsId release];
	[super dealloc];
}
#ifdef MOCK_PROTOCOL
- (NSString*) mockJson
{
    return @"{\"func\":\"homeInfo\",\"result\":true,\"description\":\"성공\",\"errCode\":\"0\",\"isPerm\":\"NONE\",\"snsUrl\":\"sf10\",\"nickname\":\"sf10\",\"profileImg\":\"http://snsfile.paran.com/SNS_223729/201107/620018825604_1310031576907_thumb1.jpg.jpg\",\"isOpenHome\":\"9\",\"poiCnt\":39,\"poiCnt4Broad\":0,\"neighborCnt\":82,\"captainCnt\":4,\"columbusCnt\":12,\"badgeCnt\":6,\"msgCnt\":0,\"isNewMsg\":false,\"isMsgPerm\":\"1\",\"md5phoneNo\":\"\",\"isPrNew\":\"0\",\"prUpdDate\":\"2011.07.07 18:39:38\",\"totalScrapCnt\":38,\"totalScrappedCnt\":4,\"cpInfo\":[{\"cpCode\":\"51\",\"cpUrl\":\"http://twitter.com/mrsuh\",\"cpName\":\"mrsuh\"}],\"bizId\":0,\"bizType\":\"\",\"userType\":\"\",\"bizNickname\":\"\",\"logoImg\":\"\",\"bgImg\":\"http://i.kthimg.com/TOP/svc/imin/v1/img/no_prf_a3.gif\",\"bgImg4App\":\"http://i.kthimg.com/TOP/svc/imin/v1/img/no_prf_a3.gif\",\"lastPostDate\":\"2011.10.20 18:14:06\",\"snsId\":\"100000302281\"}";
}
#endif
@end
