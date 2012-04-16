//
//  GetDelivery.m
//  ImIn
//
//  Created by Myungjin Choi on 11. 10. 25..
//  Copyright (c) 2011년 KTH. All rights reserved.
//

#import "GetDelivery.h"

@implementation GetDelivery
#ifdef MOCK_PROTOCOL
-(NSString*) mockJson {
    return @"{\"func\":\"getDelivery\",\"result\":true,\"description\":\"성공\",\"errCode\":\"0\",\"data\":[{\"cpCode\":\"50\",\"blogId\":\"choipd\",\"userName\":\"choipd\",\"isDelivery\":\"1\",\"isCpNeighbor\":\"1\"},{\"cpCode\":\"51\",\"blogId\":\"mjchoi_test\",\"userName\":\"174160043-8wNL0yjUFVIrwS6LHuYI57rTC4TghssDw9HOCqSp\",\"isDelivery\":\"1\",\"isCpNeighbor\":\"1\"},{\"cpCode\":\"52\",\"blogId\":\"100001451321567\",\"userName\":\"Mj Choi\",\"isDelivery\":\"1\",\"isCpNeighbor\":\"1\"}]}";
}
#endif
@end
