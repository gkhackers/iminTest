//
//  PlazaPostListByPoi.m
//  ImIn
//
//  Created by edbear on 10. 9. 14..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PlazaPostListByPoi.h"


@implementation PlazaPostListByPoi
#ifdef MOCK_PROTOCOL
- (NSString*) mockJson {
    return @"{\"func\":\"plazaPostListByPoi\",\"result\":true,\"description\":\"성공\",\"errCode\":\"0\",\"data\":[{\"postId\":\"2011043919225\",\"snsId\":\"100000330744\",\"nickname\":\"긴아이디테스트\",\"snsUrl\":\"긴아이디테스트\",\"profileImg\":\"http://snsfile.paran.com/SNS_340403/201110/620019235787_1318426330989_thumb1.jpg.jpg\",\"shoesNo\":\"07\",\"post\":\"ㅌㅅㅌ\",\"device\":\"12\",\"deviceName\":\"iPhone\",\"isBlind\":\"0\",\"isPolice\":\"0\",\"isFriend\":\"\",\"isOpen\":\"9\",\"isPolicePerm\":\"1\",\"imgUrl\":\"\",\"cmtCnt\":\"0\",\"poiKey\":\"U10000559540\",\"poiName\":\"마스터테스트1\",\"poiAliasName\":\"\",\"pointX\":\"193145\",\"pointY\":\"443351\",\"addr0\":\"국내\",\"addr1\":\"서울특별시\",\"addr2\":\"동작구\",\"addr3\":\"신대방2동\",\"poiPhoneNo\":\"\",\"regDate\":\"2011.10.25 14:10:27\",\"scrapCnt\":0,\"isOpenScrap\":\"1\",\"poiKeyList\":\"\",\"bizType\":\"\",\"userType\":\"\",\"category\":\"\", \"categoryImg\":\"http://211.113.4.83/TOP/svc/imin/v1/img/bizcate/9000000_38x38@2x_1.png\",	\"bizPostId\":\"-1\",\"isBrandPoi\":\"0\"},{\"postId\":\"2011043919219\",\"snsId\":\"100000330744\",\"nickname\":\"긴아이디테스트\",\"snsUrl\":\"긴아이디테스트\",\"profileImg\":\"http://snsfile.paran.com/SNS_340403/201110/620019235787_1318426330989_thumb1.jpg.jpg\",\"shoesNo\":\"07\",\"post\":\"테스트용\",\"device\":\"12\",\"deviceName\":\"iPhone\",\"isBlind\":\"0\",\"isPolice\":\"0\",\"isFriend\":\"\",\"isOpen\":\"9\",\"isPolicePerm\":\"1\",\"imgUrl\":\"\",\"cmtCnt\":\"0\",\"poiKey\":\"U10000559540\",\"poiName\":\"마스터테스트1\",\"poiAliasName\":\"\",\"pointX\":\"193145\",\"pointY\":\"443351\",\"addr0\":\"국내\",\"addr1\":\"서울특별시\",\"addr2\":\"동작구\",\"addr3\":\"신대방2동\",\"poiPhoneNo\":\"\",\"regDate\":\"2011.10.25 11:07:45\",\"scrapCnt\":0,\"isOpenScrap\":\"1\",\"poiKeyList\":\"\",\"bizType\":\"\",\"userType\":\"\",\"category\":\"\", \"categoryImg\":\"http://211.113.4.83/TOP/svc/imin/v1/img/bizcate/9000000_38x38@2x_1.png\",	\"bizPostId\":\"-1\",\"isBrandPoi\":\"0 \"}],\"lastPostId\":\"2011043919219\"} \
    ";
}
#endif
@end
