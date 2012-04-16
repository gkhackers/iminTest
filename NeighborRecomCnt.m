//
//  NeighborRecomCnt.m
//  ImIn
//
//  Created by ja young park on 11. 9. 23..
//  Copyright 2011년 __MyCompanyName__. All rights reserved.
//

#import "NeighborRecomCnt.h"

@implementation NeighborRecomCnt

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}
#ifdef MOCK_PROTOCOL
-(NSString*) mockJson {
    return @"{\"func\":\"neighborRecomCnt\",\"result\":true,\"description\":\"성공\",\"errCode\":\"0\",\"data\":[{\"recomType\":\"43\",\"recomTypeCnt\":\"2\"},{\"recomType\":\"90\",\"recomTypeCnt\":\"5\"},{\"recomType\":\"82\",\"recomTypeCnt\":\"8\"},{\"recomType\":\"51\",\"recomTypeCnt\":\"12\"},{\"recomType\":\"23\",\"recomTypeCnt\":\"1\"},{\"recomType\":\"81\",\"recomTypeCnt\":\"2\"},{\"recomType\":\"84\",\"recomTypeCnt\":\"1\"}]}";
}
#endif
@end
