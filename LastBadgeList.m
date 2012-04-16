//
//  LastBadgeList.m
//  ImIn
//
//  Created by Myungjin Choi on 11. 2. 18..
//  Copyright 2011 KTH. All rights reserved.
//

#import "LastBadgeList.h"


@implementation LastBadgeList
#ifdef MOCK_PROTOCOL
- (NSString*) mockJson {
    return @"{\"func\":\"lastBadgeList\",\"result\":true,\"description\":\"성공\",\"errCode\":\"0\",\"data\":[{\"snsId\":\"100000000004\",\"badgeId\":\"45\",\"badgeName\":\"Rider\",\"imgUrl\":\"http://211.113.4.83/TOP/svc/imin/v1/img/badge/45_126x126_f_1.png\",\"isBadge\":\"1\",\"badgeGetMsg\":\"축하해요~ Rider 뱃지를 획득하셨어요~!\",\"badgeMsg\":\"막을 수 없는 질주본능! %BADGENAME% 뱃지 획득\",\"badgeGuideMsg\":\"도전! 치타가 가젤을 잡을 때 뛰는 속도!\",\"badgeTipMsg\":\"\",\"userCnt\":1839,\"badgeDesc\":\"exInfo\",\"actionType\":\"1\",\"type\":\"C\",\"parentBadgeId\":\"0\",\"memberCnt\":0,\"memberOrder\":\"0\",\"badgeOrder\":\"800\",\"regDate\":\"2011.10.18 09:57:02\",\"member\":[]},{\"snsId\":\"100000000004\",\"badgeId\":\"27\",\"badgeName\":\"Vampire\",\"imgUrl\":\"http://211.113.4.83/TOP/svc/imin/v1/img/badge/27_126x126_f_1.png\",\"isBadge\":\"1\",\"badgeGetMsg\":\"축하해요~ Vampire 뱃지를 획득하셨어요~!\",\"badgeMsg\":\"깊고 푸른밤에 발도장 쿡! %BADGENAME% 뱃지 획득\",\"badgeGuideMsg\":\"깊고 푸른밤에 발도장을 찍으면 획득 할 수 있어요~\",\"badgeTipMsg\":\"\",\"userCnt\":3445,\"badgeDesc\":\"exInfo\",\"actionType\":\"1\",\"type\":\"A\",\"parentBadgeId\":\"0\",\"memberCnt\":0,\"memberOrder\":\"0\",\"badgeOrder\":\"500\",\"regDate\":\"2011.10.18 02:01:08\",\"member\":[]},{\"snsId\":\"100000000004\",\"badgeId\":\"78\",\"badgeName\":\"Halloween\",\"imgUrl\":\"http://211.113.4.83/TOP/svc/imin/v1/img/badge/78_126x126_f_1.png\",\"isBadge\":\"1\",\"badgeGetMsg\":\"축하해요~ Halloween 뱃지짠~\",\"badgeMsg\":\"마법이 일어날 것 같은 한 가을의 무섭고 설레는 밤! 할로윈에 발도장 찍어 %BADGENAME% 뱃지 획득\",\"badgeGuideMsg\":\"Trick Or Treat! \",\"badgeTipMsg\":\"\",\"userCnt\":67,\"badgeDesc\":\"exInfo\",\"actionType\":\"1\",\"type\":\"B\",\"parentBadgeId\":\"0\",\"memberCnt\":0,\"memberOrder\":\"1\",\"badgeOrder\":\"60\",\"regDate\":\"2011.10.13 10:41:07\",\"member\":[]}],\"currPage\":1,\"scale\":3,\"badgeCnt\":20,\"totalCnt\":46}";
}
#endif
@end
