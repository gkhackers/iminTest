//
//  DenyGuestRegist.m
//  ImIn
//
//  Created by Myungjin Choi on 11. 4. 13..
//  Copyright 2011 KTH. All rights reserved.
//

#import "DenyGuestRegist.h"


@implementation DenyGuestRegist
#ifdef MOCK_PROTOCOL
-(NSString*) mockJson {
    return @"{\"func\":\"denyGuestRegist\",\"result\":true,\"description\":\"성공\",\"errCode\":\"0\"}";
}
#endif
@end
