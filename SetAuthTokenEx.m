//
//  SetAuthTokenEx.m
//  ImIn
//
//  Created by Myungjin Choi on 11. 7. 4..
//  Copyright 2011 KTH. All rights reserved.
//

#import "SetAuthTokenEx.h"


@implementation SetAuthTokenEx
#ifdef MOCK_PROTOCOL
- (NSString*) mockJson {
    NSString* jsonString = @"{\
    \"func\": \"setAuthTokenEx\",\
    \"result\": true,\
    \"description\": \"성공\",\
    \"errCode\": \"0\",\
    \"setAuthToken\": {\
    \"snsId\": \"100000000004\",\
    \"nickname\": \"최피디\",\
    \"profileImg\": \"http://snsfile.paran.com/SNS_93/201109/620002878900_1314861093322_thumb1.jpg.jpg\",\
    \"currAppVer\": \"1.8.1\",\
    \"appUpdateUrl\": \"http://itunes.apple.com/kr/app/id378485209\",\
    \"msg\": \"\",\
    \"hasPhoneNo\": \"1\",\
    \"bizType\": \"\",\
    \"userType\": \"\",\
    \"errType\": \"0\"\
    },\
    \"registerDevice\": {\
    \"errType\": \"1024\"\
    },\
    \"getDelivery\": {\
    \"data\": [\
    {\
    \"cpCode\": \"50\",\
    \"blogId\": \"choipd\",\
    \"userName\": \"choipd\",\
    \"isDelivery\": \"1\",\
    \"isCpNeighbor\": \"1\"\
    },\
    {\
    \"cpCode\": \"51\",\
    \"blogId\": \"mjchoi_test\",\
    \"userName\": \"174160043-8wNL0yjUFVIrwS6LHuYI57rTC4TghssDw9HOCqSp\",\
    \"isDelivery\": \"1\",\
    \"isCpNeighbor\": \"1\"\
    },\
    {\
    \"cpCode\": \"52\",\
    \"blogId\": \"100001451321567\",\
    \"userName\": \"Mj Choi\",\
    \"isDelivery\": \"1\",\
    \"isCpNeighbor\": \"1\"\
    }\
    ],\
    \"errType\": \"0\"\
    },\
    \"feedCount\": {\
    \"postCnt\": 4,\
    \"cmtCnt\": 0,\
    \"neighborCnt\": 0,\
    \"systemCnt\": 0,\
    \"recmtCnt\": 0,\
    \"captainCnt\": 0,\
    \"badgeCnt\": 0,\
    \"eventCnt\": 0,\
    \"isNew\": \"1\",\
    \"errType\": \"0\"\
    },\
    \"profileInfo\": {\
    \"isPerm\": \"OWNER\",\
    \"phoneNo\": \"\",\
    \"useNPhoneNo\": \"0\",\
    \"isOpenHome\": \"9\",\
    \"poiCnt\": 691,\
    \"neighborCnt\": 83,\
    \"captainCnt\": 56,\
    \"columbusCnt\": 186,\
    \"badgeCnt\": 20,\
    \"md5phoneNo\": \"\",\
    \"errType\": \"0\"\
    }\
    }\
";
    return jsonString;
}
#endif
@end
