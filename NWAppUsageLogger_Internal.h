/*
 *  NWAppUsageLogger_Internal.h
 *  
 *  NWAppUsageLogger 인터페이스에 공개(Open)되지 않는 내부 메소드에 대한 정의
 *	
 *  #Log Format
 *  1 : Application Name
 *  2 : XTVID
 *	3 : XTLID
 *	4 : Event Type
 *	5 : Event Description
 *	6 : Category
 *
 *  Created by 선구 김 on 10. 5. 12..
 *  Copyright 2010 넥스트웹. All rights reserved.
 *
 */

// 기본 이용로그 수집 웹 URL
#define DEFAULT_WEB_URL @"http://mstatlog.paran.com/usagelog.html"
// 필드값 Delimiter
#define FIELD_DELI @";"
// 이용로그 데이터 필드 KEY Name
#define USAGE_LOG_KEY_NAME @"log"
// Application 이용종료 이벤트 유형
#define APP_FINISH @"APP_FINISH"

#import "NWAppUsageLogger.h"
#import <CommonCrypto/CommonDigest.h>

@interface NWAppUsageLogger(Internal)

// Singleton으로 NWAppUsageLogger 객체 생성
+ (void)createNewUsageLoggerInstance;

// 이용로그 수집 웹 URL 설정
- (void)setUrl:(NSString *)value;

// i-Phone Device로부터 장치 고유 아이디(UDID) 획득
- (NSString *)getDeviceUniqueIdentifier;

// GET 방식 이용로그 수집 URL 문자열 포맷 생성
- (NSString *)createUsageLogGETURLFormat:(NSString *)eventType andEventDesc:(NSString*)eventDesc andCategoryId:(NSString *)category;

// MD5 해쉬함수 알고리즘 적용
- (NSString *) encryptMD5:(NSString *)str;

@end