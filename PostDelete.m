//
//  PostDelete.m
//  ImIn
//
//  Created by ja young park on 11. 8. 12..
//  Copyright 2011년 __MyCompanyName__. All rights reserved.
//

#import "PostDelete.h"

@implementation PostDelete

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}
#ifdef MOCK_PROTOCOL
- (NSString*) mockJson {
    return @"{\"func\":\"postDelete\",\"result\":true,\"description\":\"성공\",\"errCode\":\"0\",\"postId\":\"2011043919192\",\"isDelPost\":\"1\"}";
}
#endif
@end
