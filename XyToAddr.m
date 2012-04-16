//
//  XyToAddr.m
//  ImIn
//
//  Created by edbear on 10. 9. 15..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "XyToAddr.h"

@implementation XyToAddr
#ifdef MOCK_PROTOCOL
- (NSString*) mockJson {
    return @"{\"func\":\"xyToAddr\",\"result\":true,\"description\":\"성공\",\"errCode\":\"0\",\"addr\":\"서울특별시 동작구 신대방2동\"}";
}
#endif
@end
