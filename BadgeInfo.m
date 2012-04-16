//
//  BadgeInfo.m
//  ImIn
//
//  Created by Myungjin Choi on 11. 2. 9..
//  Copyright 2011 KTH. All rights reserved.
//

#import "BadgeInfo.h"


@implementation BadgeInfo
#ifdef MOCK_PROTOCOL
- (NSString*) mockJson {
    return @"{\"func\":\"badgeInfo\",\"result\":true,\"description\":\"성공\",\"errCode\":\"0\",\"badgeId\":\"27\",\"badgeName\":\"Vampire\",\"badgeGetMsg\":\"축하해요~ Vampire 뱃지를 획득하셨어요~!\",\"badgeMsg\":\"깊고 푸른밤에 발도장 쿡! %BADGENAME% 뱃지 획득\",\"badgeGuideMsg\":\"깊고 푸른밤에 발도장을 찍으면 획득 할 수 있어요~\",\"badgeTipMsg\":\"\",\"historyMsg\":\"Since 2011.10.18\r\n2011.10.18 00시 07분에 gfggjk, 2011.10.18 00시 07분에 ghjj에 발도장을 찍어서 Vampire 뱃지를 획득하셨어요~\",\"imgUrl\":\"http://211.113.4.83/TOP/svc/imin/v1/img/badge/27_126x126_f_1.png\",\"level\":\"1\",\"difficulty\":\"2\",\"type\":\"A\",\"badgeDesc\":\"exInfo\",\"actionType\":\"1\",\"userCnt\":3445,\"memberCnt\":0,\"getMemberCnt\":0,\"regDate\":\"2011.10.18 02:01:08\",\"data\":[{\"snsId\":\"100000007341\",\"profileImg\":\"http://snsfile.paran.com/SNS_134821/201110/620015239110_1318411073600_thumb1.jpg.jpg\",\"nickname\":\"세상끝에\"},{\"snsId\":\"100000000005\",\"profileImg\":\"http://snsfile.paran.com/SNS_96/201110/620006111429_1318255005810_thumb1.jpg.jpg\",\"nickname\":\"구리구리\"},{\"snsId\":\"100000193394\",\"profileImg\":\"http://snsfile.paran.com/SNS_166578/201106/620018635612_1307731517089_thumb1.jpg.jpg\",\"nickname\":\"뽀공쥬\"},{\"snsId\":\"100000297316\",\"profileImg\":\"http://snsfile.paran.com/SNS_259313/201106/620018828503_1307533687836_thumb1.jpg.jpg\",\"nickname\":\"밍키랑나랑\"}]}";
}
#endif

@end
