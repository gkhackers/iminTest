//
//  RegisterPOI.h
//  ImIn
//
//  Created by choipd on 10. 6. 2..
//  Copyright 2010 edbear. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "HttpConnect.h"

@class MiddleMapContainerView;
@class RegisterPOIMapViewController;
@class AutoCompletion;
@class IsDenyWord;
/**
 @brief POI(장소)를 직접 등록
 */
@interface RegisterPOI : UIViewController <UITextFieldDelegate, MKMapViewDelegate, ImInProtocolDelegate/*, UITableViewDelegate, UITableViewDataSource*/> {
	IBOutlet UITextField* searchTextField;  ///< 직접찍기 POI명  textfield
	IBOutlet UIView* contentView;
	IBOutlet UIImageView* searchRoundImage; ///< textfield 둥근 테두리 이미지
    IBOutlet UIButton* lMapBtn; ///< 맵뷰 터치 시 큰구글맵으로 이동
    IBOutlet MKMapView *smallMap;   ///< 지정된 위치 표시하는 작은 맵뷰
    UIImageView *titleView; ///< 맵뷰에 표시하는 POI명
    RegisterPOIMapViewController *largeMap; ///< POI 위치 지정 뷰 컨트롤러 
    
	NSString* inputPoiName;
	
	HttpConnect* connect;
	CGPoint curLocation;
    CLLocation* poiLocation;

    NSString *rootViewController;
    UILabel* titleLabel;
    IsDenyWord* isDenyWord;
    
    /* 자동완성 기능 주석처리
    IBOutlet UITableView *poiListTableView;
    NSMutableArray *poiSearchList;
    
    AutoCompletion *autoCompletion;
    NSString *searchText;
     */
}

@property (nonatomic, retain) NSString* inputPoiName;
@property (nonatomic, retain) CLLocation* poiLocation;
@property (nonatomic, retain) IBOutlet MKMapView *smallMap;
@property (nonatomic, retain) NSString *rootViewController;
@property (nonatomic, retain) IsDenyWord* isDenyWord;
//@property (nonatomic, retain) NSMutableArray *poiSearchList;
//@property (nonatomic, retain) AutoCompletion *autoCompletion;
//@property (nonatomic, retain) NSString *searchText;

- (void) setSmallMap;
- (void) setMapTitle:(NSString*)title;
- (void) doRequest;

-(IBAction) popLargeMap;
-(IBAction) popToPrevious;
-(IBAction) checkPoiNameIsValid;

- (CGFloat) distanceBetweenPointsA:(CGPoint)first B:(CGPoint)second;
- (CGPoint) TMPositionForLatitude:(double)lat forLongitude:(double)lon;
- (CGPoint) coordnateForTMX:(NSNumber*)tmx TMY:(NSNumber*)tmy;
@end
