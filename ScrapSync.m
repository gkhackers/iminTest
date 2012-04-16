//
//  ScrapSync.m
//  ImIn
//
//  Created by edbear on 11. 9. 9..
//  Copyright 2011년 __MyCompanyName__. All rights reserved.
//

#import "ScrapSync.h"

@implementation ScrapSync
#ifdef MOCK_PROTOCOL
- (NSString*) mockJson
{
    return @"{\"func\":\"scrapSync\",\"result\":true,\"description\":\"성공\",\"errCode\":\"0\",\"addedPostId\":\"2011043889565|2011043891969|2011043902750\",\"deletedPostId\":\"2011033876365|2011043889833\"}";
}
#endif
@end
