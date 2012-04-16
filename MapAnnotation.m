//
//  MapAnnotation.m
//  ImIn
//
//  Created by Myungjin Choi on 11. 10. 21..
//  Copyright (c) 2011년 KTH. All rights reserved.
//

#import "MapAnnotation.h"

@implementation MapAnnotation

@synthesize coordinate;

- (id) initWithCoordinate:(CLLocationCoordinate2D)coord
{
    coordinate = coord;
    return self;
}

/// @brief 제목 표시
/// @todo 사용안하는지 체크
- (NSString *)subtitle
{
    return @"이 장소까지 네비게이션";
}

- (NSString *)title
{
    return @"GO!";
}
@end
