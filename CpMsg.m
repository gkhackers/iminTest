//
//  CpMsg.m
//  ImIn
//
//  Created by ja young park on 11. 9. 19..
//  Copyright 2011년 __MyCompanyName__. All rights reserved.
//

#import "CpMsg.h"

@implementation CpMsg

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}
#ifdef MOCK_PROTOCOL
- (NSString*) mockJson
{
    return @"{\"func\":\"cpMsg\",\"result\":true,\"description\":\"성공\",\"errCode\":\"0\"}";
}
#endif
@end
