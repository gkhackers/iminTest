//
//  DenyGuestList.m
//  ImIn
//
//  Created by Myungjin Choi on 11. 4. 14..
//  Copyright 2011 KTH. All rights reserved.
//

#import "DenyGuestList.h"


@implementation DenyGuestList
#ifdef MOCK_PROTOCOL
-(NSString*) mockJson {
    return @"{\"func\":\"denyGuestList\",\"result\":true,\"description\":\"성공\",\"errCode\":\"0\",\"data\":[{\"denySnsId\":\"100000077871\",\"denyNickname\":\"dookam\",\"denyProfileImg\":\"http://snsfile.paran.com/SNS_61725/201105/620003804482_1306551984184_thumb1.jpg.jpg\",\"bizType\":\"\",\"userType\":\"\"},{\"denySnsId\":\"100000000141\",\"denyNickname\":\"고고고\",\"denyProfileImg\":\"http://snsfile.paran.com/SNS_5383/201105/620000682471_1305733082823_thumb1.jpg.jpg\",\"bizType\":\"\",\"userType\":\"\"},{\"denySnsId\":\"100000097260\",\"denyNickname\":\"전뚱\",\"denyProfileImg\":\"http://snsfile.paran.com/SNS_87116/201106/620006596520_1307934001070_thumb1.jpg.jpg\",\"bizType\":\"\",\"userType\":\"\"}],\"currPage\":1,\"scale\":25,\"totalCnt\":3}";
}
#endif
@end
