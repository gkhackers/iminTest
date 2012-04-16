//
//  ProfileUpdate.m
//  ImIn
//
//  Created by edbear on 10. 12. 15..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ProfileUpdate.h"


@implementation ProfileUpdate
#ifdef MOCK_PROTOCOL
- (NSString*) mockJson {
    return @"{\"func\":\"profileUpdate\",\"result\":true,\"description\":\"성공\",\"errCode\":\"0\",\"profileImg\":\"http://snsfile.paran.com/SNS_93/201109/620002878900_1314861093322_thumb1.jpg.jpg\",\"phoneNo\":\"\",\"shoesNo\":\"\",\"realName\":\"크핫삿\",\"prMsg\":\"안녕하세요. 최피디입니다.\",\"prBirth\":\"0101\",\"prBirthType\":\"2\",\"isOpenPrBirth\":\"1\",\"data\":[],\"isOpenPostCnt\":\"\"}";
}
#endif
@end
