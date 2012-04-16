//
//  NeighborRegist.m
//  ImIn
//
//  Created by park ja young on 11. 3. 7..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NeighborRegist.h"


@implementation NeighborRegist
#ifdef MOCK_PROTOCOL
- (NSString*) mockJson {
    return @"{\"func\":\"neighborRegist\",\"result\":true,\"description\":\"성공\",\"errCode\":\"0\",\"regDate\":\"2011.10.24 16:13:04\",\"wvUrl\":\"\"}";
}
#endif
@end
