//
//  AddLink.m
//  ImIn
//
//  Created by Myungjin Choi on 11. 8. 2..
//  Copyright 2011 KTH. All rights reserved.
//

#import "AddLink.h"


@implementation AddLink
#ifdef MOCK_PROTOCOL
- (NSString*) mockJson
{
    return @"{\"func\":\"addLink\",\"result\":true,\"description\":\"성공\",\"errCode\":\"0\",\"data\":[{\"longUrl\":\"http://imindev.paran.com/sns-gw/api/sendMsg.kth?device=12&msgType=3&at=1&ver=1d02&cpCode=51&svcId=-73913&msg=publicInvite&\",\"shortUrl\":\"http://bit.ly/nect1a\"}]}";
}
#endif
@end
