//
//  DenyGuestDelete.m
//  ImIn
//
//  Created by Myungjin Choi on 11. 4. 14..
//  Copyright 2011 KTH. All rights reserved.
//

#import "DenyGuestDelete.h"


@implementation DenyGuestDelete
#ifdef MOCK_PROTOCOL
- (NSString*) mockJson {
    return @"{\"func\":\"denyGuestDelete\",\"result\":true,\"description\":\"성공\",\"errCode\":\"0\"}";
}
#endif
@end
