//
//  ValidNeighborCoupon.m
//  ImIn
//
//  Created by edbear on 11. 9. 9..
//  Copyright 2011년 __MyCompanyName__. All rights reserved.
//

#import "ValidNeighborCoupon.h"

@implementation ValidNeighborCoupon
#ifdef MOCK_PROTOCOL
- (NSString*) mockJson
{
    return @"{\"func\":\"validNeighborCoupon\",\"result\":true,\"description\":\"성공\",\"errCode\":\"0\",\"api\":\"couponInfo\",\"hasCoupon\":false,\"couponId\":\"\"}";
}
#endif
@end
