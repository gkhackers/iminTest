//
//  SetBlock.m
//  ImIn
//
//  Created by park ja young on 11. 3. 7..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SetBlock.h"


@implementation SetBlock
#ifdef MOCK_PROTOCOL
- (NSString*) mockJson {
    return @"{\"func\":\"setBlock\",\"result\":true,\"description\":\"성공\",\"errCode\":\"0\",\"blockSnsId\":\"100000000001\",\"resultBlockFeed\":true,\"resultBlockNoti\":true,\"resultBlockMsg\":true}";
}
#endif
@end
