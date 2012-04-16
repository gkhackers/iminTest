//
//  MapAnnotation.h
//  ImIn
//
//  Created by Myungjin Choi on 11. 10. 21..
//  Copyright (c) 2011년 KTH. All rights reserved.
//


/**
 @brief POI 상세 정보 페이지 지도에 표시
 */

@interface MapAnnotation : NSObject <MKAnnotation> {
    CLLocationCoordinate2D coordinate;
}

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;

- (id) initWithCoordinate:(CLLocationCoordinate2D)coord;

- (NSString *)subtitle;
- (NSString *)title;

@end
