//
//  ScrapDelete.m
//  ImIn
//
//  Created by edbear on 11. 9. 9..
//  Copyright 2011년 __MyCompanyName__. All rights reserved.
//

#import "ScrapDelete.h"

@implementation ScrapDelete
#ifdef MOCK_PROTOCOL
- (NSString*) mockJson
{
    return @"{\"func\":\"scrapDelete\",\"result\":true,\"description\":\"성공\",\"errCode\":\"0\",\"postId\":\"2011043918932\"}";
}
#endif
@end
