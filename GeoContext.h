//
//  GeoContext.h
//  ImIn
//
//  Created by choipd on 10. 5. 7..
//  Copyright 2010 edbear. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@class XyToAddr;

@interface GeoContext : NSObject <CLLocationManagerDelegate, ImInProtocolDelegate> {

	CLLocationManager* locationManager;
	CLLocation *bestEffortAtLocation;
	NSTimer* retryTimer;
	NSTimer* stopTimer;
	
	NSDate* lastGPSActiveTime;		// 마지막으로 GPS에서 수신한 시간.
	NSDate* lastXyToAddrActiveTime;	// 마지막으로 xyToAddr API호출이 성공한 시간.
	
	NSNumber* lastTmX;		// 마지막 수신된 위치정보를 변환한 중부원점 좌표 x
	NSNumber* lastTmY;		// 좌표 y
	
	NSInteger cntNoGPSrecv;	// GPS수신 실패 횟수
	
	NSString* lastFullAddress;	// xyToAddr로 알아온 주소정보 (full address)
	NSString* lastDongAddress;	// 주소 정보 중에 말단 동정보
	
	XyToAddr* xyToAddr;
}

@property (nonatomic, retain) CLLocationManager* locationManager;
@property (nonatomic, retain) NSDate* lastGPSActiveTime;
@property (nonatomic, retain) NSDate* lastXyToAddrActiveTime;
@property (nonatomic, retain) NSNumber* lastTmX;
@property (nonatomic, retain) NSNumber* lastTmY;
@property (readwrite) NSInteger cntNoGPSrecv;
@property (nonatomic, retain) NSString* lastFullAddress;
@property (nonatomic, retain) NSString* lastDongAddress;
@property (nonatomic, retain) XyToAddr* xyToAddr;

+(GeoContext *)sharedGeoContext;

- (void) initLocationManager;
- (void) stopGPS;
- (void) retryGPS;
- (void) requestXyToAddr;
- (void) refresh;

+ (CLLocation*) tm2gws84WithTmX:(double)tmx withTmY:(double)tmy;
@end
