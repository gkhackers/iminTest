//
//  PoiInfoDetail.m
//  ImIn
//
//  Created by Myungjin Choi on 11. 10. 28..
//  Copyright (c) 2011년 KTH. All rights reserved.
//

#import "PoiInfoDetail.h"

@implementation PoiInfoDetail
#ifdef MOCK_PROTOCOL
- (NSString*) mockJson
{
    return @"{\"func\":\"poiInfoDetail\",\"result\":true,\"description\":\"성공\",\"errCode\":\"0\",\"bizId\":\"123\" ,\"poiKey\":\"U10000000403\",\"poiName\":\"한화콘도\",\"pointX\":\"202363\",\"pointY\":\"443977\",\"addr0\":\"국내\",\"addr1\":\"서울특별시\",\"addr2\":\"서초구\",\"addr3\":\"서초4동\",\"shopPhoneNo\":\"02-5555-5555\",\"category\":\"\",\"categoryImg\":\"\",\"categoryName\":\"먹거리 > 술집 > 소주방\",\"shopIntro\":\"Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.\",\"shopHome\":\"http://google.com\",\"shopOpen\":\"17:00 ~ 익일 02:30\",\"shopClose\":\"연중무휴\",\"shopImg01\":\"http://c.ask.nate.com/imgs/qrsi.php/11437953/19673646/0/1/A/스타벅스.jpg\",\"shopImg02\":\"http://c.ask.nate.com/imgs/qrsi.php/11437953/19673646/0/1/A/스타벅스.jpg\",\"shopImg03\":\"http://c.ask.nate.com/imgs/qrsi.php/11437953/19673646/0/1/A/스타벅스.jpg\",\"svcIntro\":\"칠리해물 철판 16,000원 (치츠 추가 2,000원)\",\"shopParking\":\"불가\",\"shopRoute\":\"Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam\"}";
}
#endif
@end
