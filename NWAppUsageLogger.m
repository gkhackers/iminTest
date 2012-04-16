//
//  NWAppUsageLogger.m
//  MyHello
//
//  Created by 선구 김 on 10. 5. 11..
//  Copyright 2010 넥스트웹. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "NWAppUsageLogger_Internal.h"
#import "NSDataAdditions.h"

// Singleton 생성 NWAppUsageLogger 객체
static NWAppUsageLogger *usageLogger;

@implementation NWAppUsageLogger

// Singleton으로 NWAppUsageLogger 객체 생성
+ (void)createNewUsageLoggerInstance{
	if (usageLogger == nil) {
		usageLogger = [[NWAppUsageLogger alloc] init];
		[usageLogger init];
	}
}

// 사용자 이용로그 모듈객체 생성
// Singleton으로 생성, Application 내에서 공유해 공통으로 사용
+ (NWAppUsageLogger*)logger{
	[NWAppUsageLogger createNewUsageLoggerInstance];
	[usageLogger setUrl:DEFAULT_WEB_URL];
	return usageLogger;
}

// 사용자 이용로그 모듈객체 생성
// Singleton으로 생성, Application 내에서 공유해 공통으로 사용
// 이용로그 수집을 위한 웹 URL 지정
+ (NWAppUsageLogger*)loggerWithUsageWebURL: (NSString *)webUrl{
	[NWAppUsageLogger createNewUsageLoggerInstance];
	[usageLogger setUrl:webUrl];
	return usageLogger;
}

// 사용자 이용로그 모듈객체 생성
// Singleton으로 생성, Application 내에서 공유해 공통으로 사용
// 이용로그 수집을 위한 웹 URL 및 Application Name 지정
+ (NWAppUsageLogger*)loggerWithUsageWebURL:(NSString *)webUrl andAppName:(NSString *)nameValue{
	[NWAppUsageLogger createNewUsageLoggerInstance];
	[usageLogger setUrl:webUrl];
	[usageLogger setApplicationName:nameValue];
	return usageLogger;
}

// override...
- (id)init{
	self = [super init];
	if(self){
		pool = [[NSAutoreleasePool alloc] init];
		vid = [[self getDeviceUniqueIdentifier] copy];
	}
	return self;
}

// 이용로그 수집 웹 URL 설정
- (void)setUrl:(NSString *)value{
	url = value;
}

// 사용자 회원아이디 설정
- (void)setLID: (NSString *) value{
	lid = value;
}

// Application Name 설정
- (void)setApplicationName: (NSString *) value{
	appName = value;
}

// 사용자 이용 이벤트 로그 발생
// URL Connection시 비동기식(Asynchronous) 연결을 수행하므로, Thread 처리하면 안됨
// (Thread 종료되면 URL Connection 수행 안함)
// 단, 어플리케이션 종료시 비동기식 처리하면 종료 이벤트가 발생 안하므로, 종료시에는 동기식 통신 처리
- (void)fireUsageLog: (NSString *)eventType andEventDesc:(NSString*)eventDesc andCategoryId:(NSString *)category{
	NSString *usageUrl = [self createUsageLogGETURLFormat:eventType andEventDesc:eventDesc andCategoryId:category];
	if (usageUrl == nil) {
		return;
	}
	
	NSURLConnection *connection;
	@try {
		NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:usageUrl]
															cachePolicy:NSURLRequestUseProtocolCachePolicy
														   timeoutInterval:15.0];
		[request setHTTPMethod:@"GET"];
		
		// 비동기식 통신시 Finish 이벤트 처리가 안됨
		// 동기식 통신으로 전환
		if ([eventType isEqualToString:APP_FINISH]) {
			NSURLResponse* response;
			NSError* error;
			NSData* result = nil;
			@try {
				[request setTimeoutInterval:5]; // add by momo
				result = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
				if ( result != nil ) {
					// result 객체 미사용 경고 처리용...
					MY_LOG(@"[NWAppUsageLogger]Application is closed... : %@",[result description]);
				}				
			}
			@catch (NSError * e) {
				MY_LOG(@"[NWAppUsageLogger]Caught %@", [e localizedDescription]);
			}
		}
		else{
			connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:TRUE];
			if(&connection != nil){
				@try {
					[connection release];
				} @catch (NSException *e) {
				}
			}
		}
	}
	@catch (NSException * e) {
		MY_LOG(@"[NWAppUsageLogger]Caught %@%@", [e name], [e reason]);
	}
	@finally {
	}
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)aResponse
{
}

// GET 방식 이용로그 수집 URL 문자열 포맷 생성
- (NSString *)createUsageLogGETURLFormat:(NSString *)eventType andEventDesc:(NSString*)eventDesc andCategoryId:(NSString *)category{
	NSString *logString;
	if (lid == nil) {
		lid = @"";
	}
	if (eventType == nil) {
		eventType = @"";
	}
	if (eventDesc == nil) {
		eventDesc = @"";
	}
	if (category == nil) {
		category = @"";
	}
	
	// URL 통한 한글 파라메터 데이터 전송 위한 인코딩
	eventDesc = [eventDesc stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	NSString *logFormat = [NSString	stringWithFormat:@"%@%@%@%@%@%@%@%@%@%@%@"
						   ,appName,FIELD_DELI,vid,FIELD_DELI,lid,FIELD_DELI,eventType,FIELD_DELI,eventDesc,FIELD_DELI,category];
	@try {
		logString = [NSString stringWithFormat:@"%@?%@=%@",url,USAGE_LOG_KEY_NAME,logFormat];
	}
	@catch (NSException * e) {
		MY_LOG(@"[NWAppUsageLogger]Caught %@%@", [e name], [e reason]);
	}
	@finally {
		return logString;
	}
}

// i-Phone Device로부터 장치 고유 아이디(UDID) 획득
- (NSString *)getDeviceUniqueIdentifier {
	UIDevice *device = [UIDevice currentDevice];
	NSString *deviceId = [device uniqueIdentifier];
	//Base64 Encoding 수행
	//NSData *srcData = [deviceId dataUsingEncoding:NSUTF8StringEncoding];
	//NSString *encData = [srcData base64Encoding];
	
	// 해쉬함수 알고리즘(MD5) 적용
	NSString *encData = [self encryptMD5:deviceId];
	
	return encData;
}

// MD5 해쉬함수 알고리즘 적용
- (NSString *) encryptMD5:(NSString *)str {
	const char *cStr = [str UTF8String];	
	unsigned char result[CC_MD5_DIGEST_LENGTH];
	CC_MD5( cStr, strlen(cStr), result );
	return [NSString stringWithFormat: @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
			result[0], result[1], result[2], result[3], result[4], result[5], result[6], result[7],
			result[8], result[9], result[10], result[11], result[12], result[13], result[14], result[15] ];	
}

// override...
- (void)dealloc {
	[vid release];
	[pool drain];
	[usageLogger release];
	[super dealloc];
}
@end
