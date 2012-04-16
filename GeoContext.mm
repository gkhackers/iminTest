//
//  GeoContext.m
//  ImIn
//
//  Created by choipd on 10. 5. 7..
//  Copyright 2010 edbear. All rights reserved.
//

#import "GeoContext.h"
#import "UserContext.h"
#import "CoordTrans.h"
#import "const.h"
#import "CommonAlert.h"

#import "XyToAddr.h"

@implementation GeoContext

@synthesize locationManager;
@synthesize lastGPSActiveTime, lastXyToAddrActiveTime;
@synthesize lastTmX, lastTmY, cntNoGPSrecv;
@synthesize lastFullAddress, lastDongAddress;
@synthesize xyToAddr;
//
// singleton stuff
//
static GeoContext *_sharedGeoContext = nil;


+ (GeoContext *)sharedGeoContext
{
    if (_sharedGeoContext == nil) {
        _sharedGeoContext = [[super allocWithZone:NULL] init];
        [_sharedGeoContext init];
    }
    return _sharedGeoContext;    
}

+ (id)allocWithZone:(NSZone *)zone
{
    return [[self sharedGeoContext] retain];
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

- (id)retain
{
    return self;
}

- (NSUInteger)retainCount
{
    return NSUIntegerMax;  //denotes an object that cannot be released
}

- (oneway void)release
{
    //do nothing
}

- (id)autorelease
{
    return self;
}

- (id) init
{
	self = [super init];
	if (self != nil) {
		self.locationManager = nil;
        self.lastTmX = [NSNumber numberWithInt:DEFAULT_POSITION_X];
        self.lastTmY = [NSNumber numberWithInt:DEFAULT_POSITION_Y];
		[self initLocationManager];
	}
	return self;
}


-(void)dealloc
{
	[bestEffortAtLocation release];
	if (retryTimer != nil)
	{
		[retryTimer invalidate];
		retryTimer = nil;
	}
	if (stopTimer != nil)
	{
		[stopTimer invalidate];
		stopTimer = nil;
	}
	
	[xyToAddr release];
	
	[super dealloc];
}

- (void) refresh {
	self.cntNoGPSrecv = 0;
	[self retryGPS];
}


- (void) initLocationManager {
	
	// add by momo
	if (self.locationManager != nil) return;
	
	bestEffortAtLocation = nil;
	retryTimer = nil;
	stopTimer = nil;
	
	self.locationManager = [[[CLLocationManager alloc] init] autorelease];
	
	self.locationManager.delegate = self;		
	[self.locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
	self.locationManager.distanceFilter = 10.0f; 
	
	self.cntNoGPSrecv = 0;
	
	if (![self.locationManager locationServicesEnabled])
	{
		MY_LOG(@"로케이션 서비스가 꺼져 있음");
		[CommonAlert alertWithTitle:@"알림" message:GPS_MSG_NOGPS];
		
		// GPS수신에 문제가 있다면 가장 최근에 저장된 위치를 돌려준다.
		NSMutableDictionary* setting = [UserContext sharedUserContext].setting;
		NSNumber* posX = [setting objectForKey:@"lastX"];
		NSNumber* posY = [setting objectForKey:@"lastY"];
		
		if (posX == nil || posY == nil) {
			self.lastTmX = [NSNumber numberWithInt:DEFAULT_POSITION_X];
			self.lastTmY = [NSNumber numberWithInt:DEFAULT_POSITION_Y];
		} else {
			self.lastTmX = posX;
			self.lastTmY = posY;
		}
		
		self.cntNoGPSrecv = 1;
		return;
	}
	
	[self.locationManager startUpdatingLocation];
}

#pragma mark -
#pragma mark CLLocationManagerDelegate
static int nCntGPScall = 0;

- (void)locationManager: (CLLocationManager *)manager
	didUpdateToLocation: (CLLocation *)newLocation
		   fromLocation:(CLLocation *)oldLocation
{
	if (stopTimer != nil)
	{
		[stopTimer invalidate];
		stopTimer = nil;
	}
	stopTimer = [NSTimer scheduledTimerWithTimeInterval:15 target:self selector:@selector(stopGPS) userInfo:nil repeats:NO];
		
	nCntGPScall++;
	MY_LOG(@"Call From GPS : %d", nCntGPScall);

	bestEffortAtLocation = newLocation;
//    // test the measurement to see if it is more accurate than the previous measurement
//    if (bestEffortAtLocation == nil || newLocation == nil || bestEffortAtLocation.horizontalAccuracy > newLocation.horizontalAccuracy) {
//        // store the location as the "best effort"
//        bestEffortAtLocation = newLocation;
//        
//        if (newLocation.horizontalAccuracy < locationManager.desiredAccuracy) {
//			nCntGPScall = 0;
//			self.cntNoGPSrecv = 0;  // GPS상태 정상
//			[self.locationManager stopUpdatingLocation];
//			if (retryTimer == nil)
//				retryTimer = [NSTimer scheduledTimerWithTimeInterval:2*60 target:self selector:@selector(retryGPS) userInfo:nil repeats:NO];
//			//bestEffortAtLocation = nil;
//        }
//    } else 
//	{
//		if (nCntGPScall > 3)
//		{
//			nCntGPScall = 0;
//			self.cntNoGPSrecv = 0;  // GPS상태 정상
//			[self.locationManager stopUpdatingLocation];
//			if (retryTimer == nil)
//				retryTimer = [NSTimer scheduledTimerWithTimeInterval:2*60 target:self selector:@selector(retryGPS) userInfo:nil repeats:NO];
//			//bestEffortAtLocation = nil;			
//		}
//		return;
//	}
//
//	if (bestEffortAtLocation == nil) return;
	
	MY_LOG(@"current location: %@", [[NSString alloc] 
									 initWithFormat:@"Latitude = %f, Longitude = %f", 
									 bestEffortAtLocation.coordinate.latitude,
                                     bestEffortAtLocation.coordinate.longitude
                                     ]);
	
	TM tmpos = CCoordTrans::convLLToTM(LonAndLat(bestEffortAtLocation.coordinate.longitude,bestEffortAtLocation.coordinate.latitude), WGS84, TM_M);
    
    MY_LOG(@"재변환 = %@",[GeoContext tm2gws84WithTmX:tmpos._x withTmY:tmpos._y]);

	self.lastTmX = [NSNumber numberWithInt:(long)tmpos.getX()];
	self.lastTmY = [NSNumber numberWithInt:(long)tmpos.getY()];
	
	if ([self.lastTmX intValue] < MIN_TM_POSITION_X || [self.lastTmX intValue] > MAX_TM_POSITION_X || 
		[self.lastTmY intValue] < MIN_TM_POSITION_Y || [self.lastTmY intValue] > MAX_TM_POSITION_Y) 
	{
		[CommonAlert alertWithTitle:@"알림" message:GPS_MSG_OUTOFBOUND];
		self.lastTmX = [NSNumber numberWithInt:DEFAULT_POSITION_X];
		self.lastTmY = [NSNumber numberWithInt:DEFAULT_POSITION_Y];
	}
	if ([UserContext sharedUserContext].isLogin) {
		MY_LOG(@"현위치를 저장함");
		NSMutableDictionary* setting = [UserContext sharedUserContext].setting;
		[setting setObject:self.lastTmX forKey:@"lastX"];
		[setting setObject:self.lastTmY forKey:@"lastY"];
		[[UserContext sharedUserContext] saveSettingToFile];		
	}
	
	[self requestXyToAddr];
	
	if (nCntGPScall > 3)
	{
		nCntGPScall = 0;
		self.cntNoGPSrecv = 0;  // GPS상태 정상
		[self.locationManager stopUpdatingLocation];
		if (retryTimer == nil)
			retryTimer = [NSTimer scheduledTimerWithTimeInterval:2*60 target:self selector:@selector(retryGPS) userInfo:nil repeats:NO];
		bestEffortAtLocation = nil;
		//nCntGPScall = 0;
		return;
	}

}

- (void) stopGPS
{
	if (stopTimer != nil)
	{
		[stopTimer invalidate];
		stopTimer = nil;
	}
	if (retryTimer != nil)
	{
		[retryTimer invalidate];
		retryTimer = nil;
	}
	nCntGPScall = 0;
	self.cntNoGPSrecv = 0;  // GPS상태 정상
	[self.locationManager stopUpdatingLocation];
	if (retryTimer == nil)
		retryTimer = [NSTimer scheduledTimerWithTimeInterval:2*60 target:self selector:@selector(retryGPS) userInfo:nil repeats:NO];
	bestEffortAtLocation = nil;
}

- (void) retryGPS
{
	if (retryTimer != nil)
	{
		[retryTimer invalidate];
		retryTimer = nil;
	}
	if (stopTimer != nil)
	{
		[stopTimer invalidate];
		stopTimer = nil;
	}
	nCntGPScall = 0;
	self.cntNoGPSrecv = 0;
	[self.locationManager startUpdatingLocation];
	
}

- (void)locationManager: (CLLocationManager *)manager
	   didFailWithError: (NSError *)error
{
	self.cntNoGPSrecv++;
	
	if (self.cntNoGPSrecv == 1)
	{
		MY_LOG(@"로케이션 서비스에서 실패했음");
		[CommonAlert alertWithTitle:@"알림" message:GPS_MSG_NOGPS];

		// GPS수신에 문제가 있다면 가장 최근에 저장된 위치를 돌려준다.
		NSMutableDictionary* setting = [UserContext sharedUserContext].setting;
		NSNumber* posX = [setting objectForKey:@"lastX"];
		NSNumber* posY = [setting objectForKey:@"lastY"];
		
		if (posX == nil || posY == nil) {
			self.lastTmX = [NSNumber numberWithInt: DEFAULT_POSITION_X];
			self.lastTmY = [NSNumber numberWithInt: DEFAULT_POSITION_Y];
		} else {
			self.lastTmX = posX;
			self.lastTmY = posY;
		}
	}
	
	if (self.cntNoGPSrecv==1000)
		self.cntNoGPSrecv=2;
	
	MY_LOG(@"location manager report error!");
}


- (void) requestXyToAddr {
	self.xyToAddr = [[[XyToAddr alloc] init] autorelease];
	xyToAddr.delegate = self;
	
	NSArray* keys = [NSArray arrayWithObjects:@"pointX", @"pointY", nil];
	NSArray* values = [NSArray arrayWithObjects:[lastTmX stringValue], [lastTmY stringValue], nil];
	
	NSDictionary* params = [NSDictionary dictionaryWithObjects:values forKeys:keys];
	[xyToAddr.params addEntriesFromDictionary:params];
	
//	xyToAddr.pointX = self.lastTmX;
//	xyToAddr.pointY = self.lastTmY;
	[xyToAddr requestWithAuth:NO withIndicator:NO];
}

- (void) apiFailed {
	MY_LOG(@"API Failed");
}

- (void) apiDidLoad:(NSDictionary *)result
{
	if ([[result objectForKey:@"func"] isEqualToString:@"xyToAddr"]) {
		if ([[result objectForKey:@"result"] boolValue] == NO) {
			MY_LOG(@"xyToAddr 실패: %@", [result objectForKey:@"description"]);
		}
		
		NSString* address = [result objectForKey:@"addr"];
		
		NSArray* addressList = [address componentsSeparatedByString:@" "];
		
		NSString* area = [addressList lastObject];
		
		if ([self.lastFullAddress isEqualToString:address]) {
			return;
		}
		
		self.lastFullAddress = address;
		self.lastDongAddress = area;
		
		MY_LOG(@"현주소:%@", address);

		if ([UserContext sharedUserContext].isLogin) {
			MY_LOG(@"현재 동이름을 저장함");
			NSMutableDictionary* setting = [UserContext sharedUserContext].setting;
			[setting setObject:self.lastDongAddress forKey:@"lastDongAddress"];
			[[UserContext sharedUserContext] saveSettingToFile];			
		}

		// Notification Related
		NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
		NSDictionary* recvPacket = [NSDictionary dictionaryWithObjectsAndKeys:address,@"GeoInfo", area, @"localArea", nil];
		[center postNotificationName:@"geoPositionChange" object:nil userInfo:recvPacket];
		[center removeObserver:self];

	}
}

+ (CLLocation*) tm2gws84WithTmX:(double)tmx withTmY:(double)tmy
{
    TM* inputT = new TM(tmx, tmy);
    LonAndLat output = CCoordTrans::convTMToLL(*inputT, TM_M, WGS84);
    MY_LOG(@"latitude = %f, longitude = %f", output._lat, output._lon);
    return [[[CLLocation alloc] initWithLatitude:output._lat longitude:output._lon] autorelease];
}

@end
