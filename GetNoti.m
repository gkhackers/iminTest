//
//  GetNoti.m
//  ImIn
//
//  Created by Myungjin Choi on 11. 2. 16..
//  Copyright 2011 KTH. All rights reserved.
//

#import "GetNoti.h"


@implementation GetNoti
#ifdef MOCK_PROTOCOL
- (NSString*) mockJson {
    return @"{\"func\":\"getNoti\",\"result\":true,\"description\":\"성공\",\"errCode\":\"0\",\"appNotiType\":\"333\",\"emailNotiType2\":\"9\"}";
}
#endif
@end
