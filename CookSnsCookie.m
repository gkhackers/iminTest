//
//  CookSnsCookie.m
//  ImIn
//
//  Created by Myungjin Choi on 11. 8. 2..
//  Copyright 2011 KTH. All rights reserved.
//

#import "CookSnsCookie.h"


@implementation CookSnsCookie
#ifdef MOCK_PROTOCOL
-(NSString*) mockJson {
    return @"{\"func\":\"cookSnsCookie\",\"result\":true,\"description\":\"성공\",\"errCode\":\"0\",\"SNS01\":\"SNS01=snsId%3D100000000004%26userId%3Dedbear%26userNo%3D620002878900%26shoesNo%3D%26lastPoiKey%3D%26lastPointX%3D%26lastPointY%3D%26lastFeedDate%3D20111011143326%26profileImg%3DSNS_93%252F201109%252F620002878900_1314861093322.jpg%26nickname%3D%25EC%25B5%259C%25ED%2594%25BC%25EB%2594%2594%26snsUrl%3D%25EC%25B5%259C%25ED%2594%25BC%25EB%2594%2594%26bizId%3D0%26bizNickname%3D%26bizType%3D%26userType%3D; Domain=imindev.paran.com; Path=/\",\"SNS02\":\"SNS02=ip%3D127.0.0.1%26code%3D11590%26pointX%3D194999%26pointY%3D443882%26addr%3D%25EA%25B5%25AD%25EB%2582%25B4%2B%25EC%2584%259C%25EC%259A%25B8%25EC%258B%259C%2B%25EB%258F%2599%25EC%259E%2591%25EA%25B5%25AC%2B; Domain=imindev.paran.com; Path=/; expires=Thu, 01 Jan 1970 00:00:00 GMT\",\"SNS03\":\"SNS03=9x5RaVvwTTQ5for0n7ihazDo1i%252FXnEwXgrtYPkEaG3mS2nXwCQCLt029qROer42wDPDXB7v8jJqA3jc%252FfU9s2YClFIe88wwlvvuFnYjWjuNPG7fOdVe%252FfCUh8ubmRKZTcbqChwWj5X5qcUJPeut2cw6EgLOKq1lx; Domain=imindev.paran.com; Path=/\"}";
}
#endif
@end
