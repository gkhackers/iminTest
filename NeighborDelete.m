//
//  NeighborDelete.m
//  ImIn
//
//  Created by park ja young on 11. 3. 7..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NeighborDelete.h"


@implementation NeighborDelete
#ifdef MOCK_PROTOCOL
- (NSString*) mockJson {
    return @"{\"func\":\"neighborDelete\",\"result\":true,\"description\":\"성공\",\"errCode\":\"0\"}";
}
#endif
@end
