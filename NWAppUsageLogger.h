//
//  NWAppUsageLogger.h
//  사용자 모바일 Application 이용로그를 수집하기 위한 클래스
//
//  Created by 선구 김 on 10. 5. 11..
//  Copyright 2010 넥스트웹. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NWAppUsageLogger : NSObject {
@private
	// 이용로그 수집 Web URL
	NSString *url;
	// 사용자 가상아이디(Virtual ID)
	NSString *vid;
	// 사용자 회원아이디(Login ID)
	NSString *lid;
	// Application Name
	NSString *appName;
	
	// 지역변수의 Garbage Collection
	NSAutoreleasePool *pool;
}
// 사용자 이용로그 모듈객체 생성
// Singleton으로 생성, Application 내에서 공유해 공통으로 사용
+ (NWAppUsageLogger*)logger;

// 사용자 이용로그 모듈객체 생성
// Singleton으로 생성, Application 내에서 공유해 공통으로 사용
// 이용로그 수집을 위한 웹 URL 지정
+ (NWAppUsageLogger*)loggerWithUsageWebURL: (NSString *)webUrl;

// 사용자 이용로그 모듈객체 생성
// Singleton으로 생성, Application 내에서 공유해 공통으로 사용
// 이용로그 수집을 위한 웹 URL 및 Application Name 지정
+ (NWAppUsageLogger*)loggerWithUsageWebURL:(NSString *)webUrl andAppName:(NSString *)nameValue;

// 사용자 회원아이디 설정
- (void)setLID: (NSString *) value;

// Application Name 설정
- (void)setApplicationName: (NSString *) value;

// 사용자 이용 이벤트 로그 발생
- (void)fireUsageLog: (NSString *)eventType andEventDesc:(NSString*)eventDesc andCategoryId:(NSString *)category;

@end
