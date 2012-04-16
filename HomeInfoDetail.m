//
//  HomeInfoDetail.m
//  ImIn
//
//  Created by Myungjin Choi on 11. 4. 4..
//  Copyright 2011 KTH. All rights reserved.
//

#import "HomeInfoDetail.h"


@implementation HomeInfoDetail
#ifdef MOCK_PROTOCOL
-(NSString*) mockJson {
    return @"{\"func\":\"homeInfoDetail\",\"result\":true,\"description\":\"성공\",\"errCode\":\"0\",\"isPerm\":\"NEIGHBOR_YOU\",\"snsUrl\":\"예리한여자\",\"nickname\":\"예리한여자\",\"realName\":\"예리예리리\",\"profileImg\":\"http://snsfile.paran.com/SNS_199/201109/620002619311_1317187672082_thumb1.jpg.jpg\",\"isOpenHome\":\"9\",\"poiCnt\":387,\"captainCnt\":19,\"columbusCnt\":45,\"badgeCnt\":24,\"neighborCnt\":245,\"calleeNeighborCnt\":1579,\"msgCnt\":0,\"isNewMsg\":false,\"isMsgPerm\":\"1\",\"md5phoneNo\":\"8b0845d4f2ff2b91537b01cd801d2e82\",\"isPrNew\":\"0\",\"prUpdDate\":\"2011.09.28 14:30:37\",\"email\":\"\",\"cpInfo\":[{\"cpCode\":\"51\",\"cpUrl\":\"http://twitter.com/kyl0612\",\"cpName\":\"kyl0612\"},{\"cpCode\":\"52\",\"cpUrl\":\"http://m.facebook.com/profile.php?id=690298518\",\"cpName\":\"Yelee Kwak\"}],\"prMsg\":\"안녕하세요. 예리한여자 예리입니다 ^_^안녕하세요. 예리한여자 예리입니다 ^_^안녕하세요. 예리한여자 예리입니다 ^_^안녕하세요. 예리한여자 예리입니다 ^_^안녕하세요. 예리한여자 예리입니다 ^_^안녕하세요. 예리한여자 예리입니다 ^_^안녕하세요. 예\",\"isBirth\":\"0\",\"isOpenPrBirth\":\"1\",\"prBirth\":\"0612\",\"prBirthType\":\"1\",\"relationType\":\"4\",\"regDate\":\"2010.07.04 16:28:01\",\"oPoiList\":[{\"poiKey\":\"U10000061017\",\"poiName\":\"아스트랄\",\"poiCnt\":\"55\"},{\"poiKey\":\"U10000000001\",\"poiName\":\"3층303호\",\"poiCnt\":\"21\"},{\"poiKey\":\"U10000126875\",\"poiName\":\"보리랑설기랑\",\"poiCnt\":\"19\"},{\"poiKey\":\"U10000378113\",\"poiName\":\"보리랑설기랑\",\"poiCnt\":\"11\"},{\"poiKey\":\"800100017167\",\"poiName\":\"보라매공원\",\"poiCnt\":\"10\"},{\"poiKey\":\"U10000027057\",\"poiName\":\"새벽의 에스프레소\",\"poiCnt\":\"9\"}],\"neighborList\":[{\"snsId\":\"\",\"profileImg\":\"https://graph.facebook.com/1074172256/picture\",\"md5phoneNo\":\"\",\"nickname\":\"\",\"cpCode\":\"52\",\"cpUrl\":\"http://m.facebook.com/profile.php?id=1074172256\",\"cpName\":\"Kora Kay\",\"regDate\":\"\"}],\"oColumbusPoiList\":[],\"isDenyGuest\":\"0\",\"bizId\":0,\"bizType\":\"\",\"bizNickname\":\"\",\"logoImg\":\"\",\"bizIntro\":\"\",\"snsTwit\":\"\",\"snsFace\":\"\",\"snsMe\":\"\",\"bizPhoneNo\":\"\",\"bizEmail\":\"\",\"homepage\":\"\",\"totalShopCnt\":0,\"postImg\":[],\"sinceDate\":\"\"}";
}
#endif

@end
