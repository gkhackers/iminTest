//
//  SearchUser.m
//  ImIn
//
//  Created by ja young park on 11. 9. 22..
//  Copyright 2011년 __MyCompanyName__. All rights reserved.
//

#import "SearchUser.h"

@implementation SearchUser

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}
#ifdef MOCK_PROTOCOL
-(NSString*) mockJson {
    return @"{\"func\":\"searchUser\",\"result\":true,\"description\":\"성공\",\"errCode\":\"0\",\"data\":[{\"snsId\":\"100000003308\",\"nickname\":\"고압선\",\"profileImg\":\"http://snsfile.paran.com/SNS_8267/201007/620000245026_1278673802077_thumb1.jpg.jpg\",\"snsUrl\":\"고압선\",\"poiKey\":\"\",\"poiName\":\"\",\"poiAliasName\":\"\",\"pointX\":\"0\",\"pointY\":\"0\",\"cmtCnt\":0,\"totalColumbusCnt\":0,\"totalNeighborCnt\":0,\"totalPoiCnt\":0,\"totalCaptainCnt\":0,\"gender\":1,\"email\":\"\",\"isFriend\":\"2\",\"totalScrapCnt\":0,\"totalScrappedCnt\":0,\"scrapCnt\":0,\"isOpenScrap\":\"\",\"bizType\":\"\",\"userType\":\"\",\"cpInfo\":[]},{\"snsId\":\"100000107030\",\"nickname\":\"고압선색시\",\"profileImg\":\"http://snsfile.paran.com/SNS_140520/201109/620013944409_1317190250056_thumb1.jpg.jpg\",\"snsUrl\":\"고압선색시\",\"poiKey\":\"800100063874\",\"poiName\":\"삼성보라매옴니타워\",\"poiAliasName\":\"\",\"pointX\":\"193176\",\"pointY\":\"443379\",\"cmtCnt\":1,\"totalColumbusCnt\":127,\"totalNeighborCnt\":72,\"totalPoiCnt\":239,\"totalCaptainCnt\":14,\"gender\":0,\"email\":\"\",\"isFriend\":\"2\",\"totalScrapCnt\":15,\"totalScrappedCnt\":5,\"scrapCnt\":0,\"isOpenScrap\":\"1\",\"bizType\":\"\",\"userType\":\"\",\"cpInfo\":[{\"cpCode\":\"52\",\"cpUrl\":\"http://www.facebook.com/profile.php?id=100002338776630\",\"cpName\":\"Ja Young Park\"}]}],\"currPage\":1,\"scale\":25,\"totalCnt\":2}";
}
#endif
@end
