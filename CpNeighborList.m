//
//  CpNeighborList.m
//  ImIn
//
//  Created by ja young park on 11. 9. 19..
//  Copyright 2011년 __MyCompanyName__. All rights reserved.
//

#import "CpNeighborList.h"

@implementation CpNeighborList

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}
#ifdef MOCK_PROTOCOL
- (NSString*) mockJson
{
    return @"{\"func\":\"cpNeighborList\",\"result\":true,\"description\":\"성공\",\"errCode\":\"0\",\"data\":[{\"postId\":\"\",\"snsId\":\"\",\"snsUrl\":\"\",\"nickname\":\"\",\"gender\":\"\",\"profileImg\": \"\" ,\"post\": \"\" ,\"poiKey\":\"\",\"poiName\":\"\",\"poiAliasName\":\"\",\"pointX\":\"0\",\"pointY\":\"0\",\"addr0\":\"\",\"addr1\":\"\",\"addr2\":\"\",\"addr3\":\"\",\"poiPhoneNo\":\"\",\"device\":\"\",\"deviceName\":\" \",\"imgUrl\":\"\",\"cmtCnt\":0,\"isFriend\":\"\",\"isBlockFeed\":\"\",\"isBlockNoti\":\"\",\"isBlockMsg\":\"\",\"shoesNo\":\"\",\"totalColumbusCnt\":0,\"totalNeighborCnt\":0,\"totalPoiCnt\":0,\"totalCaptainCnt\":0,\"regDate\":\"\",\"cpIdx\":\"355905\",\"cpCode\":\"52\",\"cpId\":\"604873340\",\"cpProfileImg\":\"https://graph.facebook.com/604873340/picture\",\"cpName\":\"Min Eunkyung\",\"cpIsFriend\":\"1\",\"isInvite\":\"0\",\"totalScrapCnt\":0,\"totalScrappedCnt\":0,\"scrapCnt\":0,\"isOpenScrap\":\"\",\"bizType\":\"\",\"userType\":\"\"},{\"postId\":\"\",\"snsId\":\"\",\"snsUrl\":\"\",\"nickname\":\"\",\"gender\":\"\",\"profileImg\": \"\" ,\"post\": \"\" ,\"poiKey\":\"\",\"poiName\":\"\",\"poiAliasName\":\"\",\"pointX\":\"0\",\"pointY\":\"0\",\"addr0\":\"\",\"addr1\":\"\",\"addr2\":\"\",\"addr3\":\"\",\"poiPhoneNo\":\"\",\"device\":\"\",\"deviceName\":\" \",\"imgUrl\":\"\",\"cmtCnt\":0,\"isFriend\":\"\",\"isBlockFeed\":\"\",\"isBlockNoti\":\"\",\"isBlockMsg\":\"\",\"shoesNo\":\"\",\"totalColumbusCnt\":0,\"totalNeighborCnt\":0,\"totalPoiCnt\":0,\"totalCaptainCnt\":0,\"regDate\":\"\",\"cpIdx\":\"355906\",\"cpCode\":\"52\",\"cpId\":\"1074172256\",\"cpProfileImg\":\"https://graph.facebook.com/1074172256/picture\",\"cpName\":\"Kora Kay\",\"cpIsFriend\":\"1\",\"isInvite\":\"0\",\"totalScrapCnt\":0,\"totalScrappedCnt\":0,\"scrapCnt\":0,\"isOpenScrap\":\"\",\"bizType\":\"\",\"userType\":\"\"},{\"postId\":\"\",\"snsId\":\"\",\"snsUrl\":\"\",\"nickname\":\"\",\"gender\":\"\",\"profileImg\": \"\" ,\"post\": \"\" ,\"poiKey\":\"\",\"poiName\":\"\",\"poiAliasName\":\"\",\"pointX\":\"0\",\"pointY\":\"0\",\"addr0\":\"\",\"addr1\":\"\",\"addr2\":\"\",\"addr3\":\"\",\"poiPhoneNo\":\"\",\"device\":\"\",\"deviceName\":\" \",\"imgUrl\":\"\",\"cmtCnt\":0,\"isFriend\":\"\",\"isBlockFeed\":\"\",\"isBlockNoti\":\"\",\"isBlockMsg\":\"\",\"shoesNo\":\"\",\"totalColumbusCnt\":0,\"totalNeighborCnt\":0,\"totalPoiCnt\":0,\"totalCaptainCnt\":0,\"regDate\":\"\",\"cpIdx\":\"355907\",\"cpCode\":\"52\",\"cpId\":\"1365422283\",\"cpProfileImg\":\"https://graph.facebook.com/1365422283/picture\",\"cpName\":\"김동욱\",\"cpIsFriend\":\"1\",\"isInvite\":\"0\",\"totalScrapCnt\":0,\"totalScrappedCnt\":0,\"scrapCnt\":0,\"isOpenScrap\":\"\",\"bizType\":\"\",\"userType\":\"\"},{\"postId\":\"\",\"snsId\":\"\",\"snsUrl\":\"\",\"nickname\":\"\",\"gender\":\"\",\"profileImg\": \"\" ,\"post\": \"\" ,\"poiKey\":\"\",\"poiName\":\"\",\"poiAliasName\":\"\",\"pointX\":\"0\",\"pointY\":\"0\",\"addr0\":\"\",\"addr1\":\"\",\"addr2\":\"\",\"addr3\":\"\",\"poiPhoneNo\":\"\",\"device\":\"\",\"deviceName\":\" \",\"imgUrl\":\"\",\"cmtCnt\":0,\"isFriend\":\"\",\"isBlockFeed\":\"\",\"isBlockNoti\":\"\",\"isBlockMsg\":\"\",\"shoesNo\":\"\",\"totalColumbusCnt\":0,\"totalNeighborCnt\":0,\"totalPoiCnt\":0,\"totalCaptainCnt\":0,\"regDate\":\"\",\"cpIdx\":\"355908\",\"cpCode\":\"52\",\"cpId\":\"1558626327\",\"cpProfileImg\":\"https://graph.facebook.com/1558626327/picture\",\"cpName\":\"윤경환\",\"cpIsFriend\":\"1\",\"isInvite\":\"0\",\"totalScrapCnt\":0,\"totalScrappedCnt\":0,\"scrapCnt\":0,\"isOpenScrap\":\"\",\"bizType\":\"\",\"userType\":\"\"},{\"postId\":\"\",\"snsId\":\"\",\"snsUrl\":\"\",\"nickname\":\"\",\"gender\":\"\",\"profileImg\": \"\" ,\"post\": \"\" ,\"poiKey\":\"\",\"poiName\":\"\",\"poiAliasName\":\"\",\"pointX\":\"0\",\"pointY\":\"0\",\"addr0\":\"\",\"addr1\":\"\",\"addr2\":\"\",\"addr3\":\"\",\"poiPhoneNo\":\"\",\"device\":\"\",\"deviceName\":\" \",\"imgUrl\":\"\",\"cmtCnt\":0,\"isFriend\":\"\",\"isBlockFeed\":\"\",\"isBlockNoti\":\"\",\"isBlockMsg\":\"\",\"shoesNo\":\"\",\"totalColumbusCnt\":0,\"totalNeighborCnt\":0,\"totalPoiCnt\":0,\"totalCaptainCnt\":0,\"regDate\":\"\",\"cpIdx\":\"355909\",\"cpCode\":\"52\",\"cpId\":\"1604228541\",\"cpProfileImg\":\"https://graph.facebook.com/1604228541/picture\",\"cpName\":\"Hojoon Im\",\"cpIsFriend\":\"1\",\"isInvite\":\"1\",\"totalScrapCnt\":0,\"totalScrappedCnt\":0,\"scrapCnt\":0,\"isOpenScrap\":\"\",\"bizType\":\"\",\"userType\":\"\"},{\"postId\":\"\",\"snsId\":\"\",\"snsUrl\":\"\",\"nickname\":\"\",\"gender\":\"\",\"profileImg\": \"\" ,\"post\": \"\" ,\"poiKey\":\"\",\"poiName\":\"\",\"poiAliasName\":\"\",\"pointX\":\"0\",\"pointY\":\"0\",\"addr0\":\"\",\"addr1\":\"\",\"addr2\":\"\",\"addr3\":\"\",\"poiPhoneNo\":\"\",\"device\":\"\",\"deviceName\":\" \",\"imgUrl\":\"\",\"cmtCnt\":0,\"isFriend\":\"\",\"isBlockFeed\":\"\",\"isBlockNoti\":\"\",\"isBlockMsg\":\"\",\"shoesNo\":\"\",\"totalColumbusCnt\":0,\"totalNeighborCnt\":0,\"totalPoiCnt\":0,\"totalCaptainCnt\":0,\"regDate\":\"\",\"cpIdx\":\"355910\",\"cpCode\":\"52\",\"cpId\":\"100000040955258\",\"cpProfileImg\":\"https://graph.facebook.com/100000040955258/picture\",\"cpName\":\"이귀복\",\"cpIsFriend\":\"1\",\"isInvite\":\"0\",\"totalScrapCnt\":0,\"totalScrappedCnt\":0,\"scrapCnt\":0,\"isOpenScrap\":\"\",\"bizType\":\"\",\"userType\":\"\"},{\"postId\":\"\",\"snsId\":\"\",\"snsUrl\":\"\",\"nickname\":\"\",\"gender\":\"\",\"profileImg\": \"\" ,\"post\": \"\" ,\"poiKey\":\"\",\"poiName\":\"\",\"poiAliasName\":\"\",\"pointX\":\"0\",\"pointY\":\"0\",\"addr0\":\"\",\"addr1\":\"\",\"addr2\":\"\",\"addr3\":\"\",\"poiPhoneNo\":\"\",\"device\":\"\",\"deviceName\":\" \",\"imgUrl\":\"\",\"cmtCnt\":0,\"isFriend\":\"\",\"isBlockFeed\":\"\",\"isBlockNoti\":\"\",\"isBlockMsg\":\"\",\"shoesNo\":\"\",\"totalColumbusCnt\":0,\"totalNeighborCnt\":0,\"totalPoiCnt\":0,\"totalCaptainCnt\":0,\"regDate\":\"\",\"cpIdx\":\"355911\",\"cpCode\":\"52\",\"cpId\":\"100000888566957\",\"cpProfileImg\":\"https://graph.facebook.com/100000888566957/picture\",\"cpName\":\"Ks Kim\",\"cpIsFriend\":\"1\",\"isInvite\":\"0\",\"totalScrapCnt\":0,\"totalScrappedCnt\":0,\"scrapCnt\":0,\"isOpenScrap\":\"\",\"bizType\":\"\",\"userType\":\"\"},{\"postId\":\"\",\"snsId\":\"\",\"snsUrl\":\"\",\"nickname\":\"\",\"gender\":\"\",\"profileImg\": \"\" ,\"post\": \"\" ,\"poiKey\":\"\",\"poiName\":\"\",\"poiAliasName\":\"\",\"pointX\":\"0\",\"pointY\":\"0\",\"addr0\":\"\",\"addr1\":\"\",\"addr2\":\"\",\"addr3\":\"\",\"poiPhoneNo\":\"\",\"device\":\"\",\"deviceName\":\" \",\"imgUrl\":\"\",\"cmtCnt\":0,\"isFriend\":\"\",\"isBlockFeed\":\"\",\"isBlockNoti\":\"\",\"isBlockMsg\":\"\",\"shoesNo\":\"\",\"totalColumbusCnt\":0,\"totalNeighborCnt\":0,\"totalPoiCnt\":0,\"totalCaptainCnt\":0,\"regDate\":\"\",\"cpIdx\":\"355912\",\"cpCode\":\"52\",\"cpId\":\"100000987847453\",\"cpProfileImg\":\"https://graph.facebook.com/100000987847453/picture\",\"cpName\":\"김주성\",\"cpIsFriend\":\"1\",\"isInvite\":\"0\",\"totalScrapCnt\":0,\"totalScrappedCnt\":0,\"scrapCnt\":0,\"isOpenScrap\":\"\",\"bizType\":\"\",\"userType\":\"\"},{\"postId\":\"\",\"snsId\":\"\",\"snsUrl\":\"\",\"nickname\":\"\",\"gender\":\"\",\"profileImg\": \"\" ,\"post\": \"\" ,\"poiKey\":\"\",\"poiName\":\"\",\"poiAliasName\":\"\",\"pointX\":\"0\",\"pointY\":\"0\",\"addr0\":\"\",\"addr1\":\"\",\"addr2\":\"\",\"addr3\":\"\",\"poiPhoneNo\":\"\",\"device\":\"\",\"deviceName\":\" \",\"imgUrl\":\"\",\"cmtCnt\":0,\"isFriend\":\"\",\"isBlockFeed\":\"\",\"isBlockNoti\":\"\",\"isBlockMsg\":\"\",\"shoesNo\":\"\",\"totalColumbusCnt\":0,\"totalNeighborCnt\":0,\"totalPoiCnt\":0,\"totalCaptainCnt\":0,\"regDate\":\"\",\"cpIdx\":\"355913\",\"cpCode\":\"52\",\"cpId\":\"100001756587111\",\"cpProfileImg\":\"https://graph.facebook.com/100001756587111/picture\",\"cpName\":\"H.j. Oh\",\"cpIsFriend\":\"1\",\"isInvite\":\"0\",\"totalScrapCnt\":0,\"totalScrappedCnt\":0,\"scrapCnt\":0,\"isOpenScrap\":\"\",\"bizType\":\"\",\"userType\":\"\"},{\"postId\":\"\",\"snsId\":\"\",\"snsUrl\":\"\",\"nickname\":\"\",\"gender\":\"\",\"profileImg\": \"\" ,\"post\": \"\" ,\"poiKey\":\"\",\"poiName\":\"\",\"poiAliasName\":\"\",\"pointX\":\"0\",\"pointY\":\"0\",\"addr0\":\"\",\"addr1\":\"\",\"addr2\":\"\",\"addr3\":\"\",\"poiPhoneNo\":\"\",\"device\":\"\",\"deviceName\":\" \",\"imgUrl\":\"\",\"cmtCnt\":0,\"isFriend\":\"\",\"isBlockFeed\":\"\",\"isBlockNoti\":\"\",\"isBlockMsg\":\"\",\"shoesNo\":\"\",\"totalColumbusCnt\":0,\"totalNeighborCnt\":0,\"totalPoiCnt\":0,\"totalCaptainCnt\":0,\"regDate\":\"\",\"cpIdx\":\"355914\",\"cpCode\":\"52\",\"cpId\":\"100001875615451\",\"cpProfileImg\":\"https://graph.facebook.com/100001875615451/picture\",\"cpName\":\"Myoung Sin Kim\",\"cpIsFriend\":\"1\",\"isInvite\":\"0\",\"totalScrapCnt\":0,\"totalScrappedCnt\":0,\"scrapCnt\":0,\"isOpenScrap\":\"\",\"bizType\":\"\",\"userType\":\"\"}],\"nickname\":\"\",\"isCpNeighborAnalysis\":\"1\",\"lastCpIdx\":\"355914\",\"currPage\":1,\"scale\":25,\"totalCnt\":10}";
}
#endif
@end