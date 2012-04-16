//
//  NeighborRecomReject.m
//  ImIn
//
//  Created by ja young park on 11. 9. 16..
//  Copyright 2011년 __MyCompanyName__. All rights reserved.
//

#import "NeighborRecomReject.h"

@implementation NeighborRecomReject

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
    return @"{\"func\":\"neighborRecomReject\",\"result\":true,\"description\":\"성공\",\"errCode\":\"0\"}";
}
#endif

@end
