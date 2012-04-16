//
//  FeedClose.m
//  ImIn
//
//  Created by Myungjin Choi on 11. 8. 5..
//  Copyright 2011 KTH. All rights reserved.
//

#import "FeedClose.h"


@implementation FeedClose
#ifdef MOCK_PROTOCOL
- (NSString*) mockJson
{
    return @"{\"func\":\"feedClose\",\"result\":true,\"description\":\"성공\",\"errCode\":\"0\"}";
}
#endif
@end
