//
//  PoiPolice.m
//  ImIn
//
//  Created by Myungjin Choi on 11. 10. 20..
//  Copyright (c) 2011년 KTH. All rights reserved.
//

#import "PoiPolice.h"

@implementation PoiPolice
#ifdef MOCK_PROTOCOL
-(NSString*) mockJson {
    return @"{\"func\":\"poiPolice\",\"result\":true,\"description\":\"성공\",\"errCode\":\"0\"}";
}
#endif
@end
