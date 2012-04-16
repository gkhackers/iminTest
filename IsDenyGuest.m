//
//  IsDenyGuest.m
//  ImIn
//
//  Created by Myungjin Choi on 11. 4. 25..
//  Copyright 2011 KTH. All rights reserved.
//

#import "IsDenyGuest.h"


@implementation IsDenyGuest
#ifdef MOCK_PROTOCOL
-(NSString*) mockJson {
    return @"{\"func\":\"isDenyGuest\",\"result\":true,\"description\":\"성공\",\"errCode\":\"0\",\"isDenyGuest\":\"0\"}";
}
#endif
@end
