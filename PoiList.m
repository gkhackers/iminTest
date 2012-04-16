//
//  PoiList.m
//  ImIn
//
//  Created by Myungjin Choi on 11. 4. 25..
//  Copyright 2011 KTH. All rights reserved.
//

#import "PoiList.h"


@implementation PoiList
#ifdef MOCK_PROTOCOL
-(NSString*) mockJson {
    return @"{\"func\":\"poiList\",\"result\":true,\"description\":\"성공\",\"errCode\":\"0\",\"data\":[{\"postId\":\"2011043919186\",\"snsId\":\"100000000004\",\"nickname\":\"최피디\",\"snsUrl\":\"최피디\",\"profileImg\":\"http://snsfile.paran.com/SNS_96/201110/620006111429_1318383973121_thumb1.jpg.jpg\",\"shoesNo\":\"00\",\"post\":\"빵빵빵~!\",\"device\":\"12\",\"deviceName\":\"iPhone\",\"isBlind\":\"0\",\"isPolice\":\"0\",\"isFriend\":\"9\",\"isOpen\":\"9\",\"isPolicePerm\":\"0\",\"imgUrl\":\"\",\"cmtCnt\":\"0\",\"poiKey\":\"U10000386572\",\"poiName\":\"파리바게뜨 카페신사점\",\"poiAliasName\":\"\",\"pointX\":\"201642\",\"pointY\":\"445895\",\"addr0\":\"국내\",\"addr1\":\"서울특별시\",\"addr2\":\"서초구\",\"addr3\":\"잠원동\",\"poiPhoneNo\":\"\",\"evtId\":\"\",\"evtBlogPostId\":\"\",\"evtUrl\":\"\",\"evtMsg\":\"\",\"regDate\":\"2011.10.24 13:48:24\",\"scrapCnt\":0,\"isOpenScrap\":\"1\",\"poiKeyList\":\"\",\"bizType\":\"\",\"userType\":\"\",\"category\":\"\",\"categoryImg\":\"http://snsfile.paran.com/SNS_96/201110/620006111429_1318383973121_thumb1.jpg.jpg\",\"bizPostId\":\"-1\",\"isBrandPoi\":\"1\"},{\"postId\":\"2011043902750\",\"snsId\":\"100000000004\",\"nickname\":\"최피디\",\"snsUrl\":\"최피디\",\"profileImg\":\"http://snsfile.paran.com/SNS_93/201109/620002878900_1314861093322_thumb1.jpg.jpg\",\"shoesNo\":\"00\",\"post\":\"\",\"device\":\"12\",\"deviceName\":\"iPhone\",\"isBlind\":\"0\",\"isPolice\":\"0\",\"isFriend\":\"9\",\"isOpen\":\"9\",\"isPolicePerm\":\"0\",\"imgUrl\":\"\",\"cmtCnt\":\"0\",\"poiKey\":\"U10000559430\",\"poiName\":\"ㄹ혼ㄹㅇㅎㄴㄹㅇ\",\"poiAliasName\":\"\",\"pointX\":\"202363\",\"pointY\":\"443977\",\"addr0\":\"국내\",\"addr1\":\"서울특별시\",\"addr2\":\"서초구\",\"addr3\":\"서초4동\",\"poiPhoneNo\":\"\",\"evtId\":\"\",\"evtBlogPostId\":\"\",\"evtUrl\":\"\",\"evtMsg\":\"\",\"regDate\":\"2011.10.18 18:08:49\",\"scrapCnt\":1,\"isOpenScrap\":\"1\",\"poiKeyList\":\"\",\"bizType\":\"\",\"userType\":\"\",\"category\":\"\", \"categoryImg\":\"http://211.113.4.83/TOP/svc/imin/v1/img/bizcate/9000000_38x38@2x_1.png\",	\"bizPostId\":\"-1\",\"isBrandPoi\":\"0\"},{\"postId\":\"2011043902749\",\"snsId\":\"100000000004\",\"nickname\":\"최피디\",\"snsUrl\":\"최피디\",\"profileImg\":\"http://snsfile.paran.com/SNS_93/201109/620002878900_1314861093322_thumb1.jpg.jpg\",\"shoesNo\":\"00\",\"post\":\"\",\"device\":\"12\",\"deviceName\":\"iPhone\",\"isBlind\":\"0\",\"isPolice\":\"0\",\"isFriend\":\"9\",\"isOpen\":\"9\",\"isPolicePerm\":\"0\",\"imgUrl\":\"\",\"cmtCnt\":\"0\",\"poiKey\":\"U10000559431\",\"poiName\":\"ㄴㅇㄹㄴㅇㄹㄴ\",\"poiAliasName\":\"\",\"pointX\":\"202363\",\"pointY\":\"443977\",\"addr0\":\"국내\",\"addr1\":\"서울특별시\",\"addr2\":\"서초구\",\"addr3\":\"서초4동\",\"poiPhoneNo\":\"\",\"evtId\":\"\",\"evtBlogPostId\":\"\",\"evtUrl\":\"\",\"evtMsg\":\"\",\"regDate\":\"2011.10.18 18:08:29\",\"scrapCnt\":0,\"isOpenScrap\":\"1\",\"poiKeyList\":\"\",\"bizType\":\"\",\"userType\":\"\",\"category\":\"\", \"categoryImg\":\"http://211.113.4.83/TOP/svc/imin/v1/img/bizcate/9000000_38x38@2x_1.png\",	\"bizPostId\":\"-1\",\"isBrandPoi\":\"0\"}],\"viewPointX\":\"202363\",\"viewPointY\":\"443977\",\"viewLevel\":\"10\"}";
}
#endif
@end
