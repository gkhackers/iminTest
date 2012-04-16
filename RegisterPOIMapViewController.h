//
//  RegisterPOIMapViewController.h
//  ImIn
//
//  Created by KYONGJIN SEO on 12/6/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "MapAnnotation.h"

/**
 @brief 직접찍기 발도장 위치 설정 페이지 (큰 구글맵)
 */
@interface RegisterPOIMapViewController : UIViewController <MKMapViewDelegate> {

    IBOutlet MKMapView *poiMapView; ///< 구글 맵뷰    
    UIImageView *aPoiMark;  ///< 고정된 핀 이미지 뷰
    CLLocationCoordinate2D poiCoordinate;   ///< poi 위치
}

@property (nonatomic, assign) CLLocationCoordinate2D poiCoordinate;
- (void) setPOIMap;
@end
