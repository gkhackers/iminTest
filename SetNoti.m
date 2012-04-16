//
//  SetNoti.m
//  ImIn
//
//  Created by Myungjin Choi on 11. 2. 16..
//  Copyright 2011 KTH. All rights reserved.
//

#import "SetNoti.h"


@implementation SetNoti
#ifdef MOCK_PROTOCOL
- (NSString*) mockJson
{
    return @"{\"func\":\"setNoti\",\"result\":true,\"description\":\"성공\",\"errCode\":\"0\"}";
}
#endif
@end
