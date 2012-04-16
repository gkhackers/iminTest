//
//  EventList.m
//  ImIn
//
//  Created by ja young park on 11. 9. 30..
//  Copyright 2011년 __MyCompanyName__. All rights reserved.
//

#import "EventList.h"

@implementation EventList

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

#ifdef MOCK_PROTOCOL
-(NSString*) mockJson
{
    return @"{\"func\":\"eventList\",\"result\":true,\"description\":\"성공\",\"errCode\":\"0\",\"specialEvent\":[	 {\"eventId\":\"341\",\"eventCopy\":\"이웃으로 추가하면 브런치 10%할인권\",\"eventInfoLink\":\"http://imindev.paran.com/sns/mobile/eventInfo.kth?eventId=341\",\"bizId\":\"6\",\"bizType\":\"BT0001\",\"bizNickname\":\"파리바게뜨\",\"poiKey\":\"\",\"poiName\":\"\",\"pointX\":\"\",\"pointY\":\"\",\"distance\":\"\",\"imgUrl\":\"SNS_96/201110/620006111429_1318383973121.jpg\",\"category\":\"\",\"couponName\":\"\",\"couponBenefit\":\"브런치 10%할인권\",\"couponStatus\":\"\"	}	 ], \"freeEvent\":[	 ],\"currPage\":\"1\",\"scale\":\"1\",\"hasMoreItem\":\"true\",\"totalCnt\":\"5\"}";
}
#endif
@end
