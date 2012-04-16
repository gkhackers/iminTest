//
//  CaptainAreaListByPoi.m
//  ImIn
//
//  Created by edbear on 10. 9. 14..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "CaptainAreaListByPoi.h"


@implementation CaptainAreaListByPoi
#ifdef MOCK_PROTOCOL
- (NSString*) mockJson {
    return @"{\"func\":\"captainAreaListByPoi\",\"result\":true,\"description\":\"성공\",\"errCode\":\"0\",\"data\":[{\"rank\":1,\"snsId\":\"100000330744\",\"nickname\":\"긴아이디테스트\",\"profileImg\":\"http://snsfile.paran.com/SNS_340403/201110/620019235787_1318426330989_thumb1.jpg.jpg\",\"point\":14,\"poiKey\":\"U10000559540\",\"poiName\":\"마스터테스트1\",\"poiAliasName\":\"\",\"pointX\":193145,\"pointY\":443351,\"addr0\":\"국내\",\"addr1\":\"서울특별시\",\"addr2\":\"동작구\",\"addr3\":\"신대방2동\",\"poiPhoneNo\":\"\",\"updDate\":\"2011.10.25 14:10:27\"}],\"msg\":\"\",\"myPoint\":0,\"isMyStatus\":2,\"month\":\"\",\"isCaptain\":\"0\"}";
}
#endif
@end
