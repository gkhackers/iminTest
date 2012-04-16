//
//  Utils.m
//  ImIn
//
//  Created by choipd on 10. 5. 11..
//  Copyright 2010 edbear. All rights reserved.
//

#import "const.h"
#import "Utils.h"
#import <CommonCrypto/CommonDigest.h>
#import "NSString+URLEncoding.h"
#import "UserContext.h"
#import <AddressBook/AddressBook.h>
#import "TAddressbook.h"
#import "TFeedList.h"
#import "SimpleImageDownloader.h"
#import "macro.h"

@implementation Utils

+ (CGSize) getWrapperSizeWithLabel:(UILabel*) aLabel 
					fixedWidthMode:(BOOL) fixedWidth
				   fixedHeightMode:(BOOL) fixedHeight
{

	if (aLabel == nil) {
		return CGSizeZero;
	}

	NSString* labelText = aLabel.text;
	
	CGSize boundingSize = CGSizeMake(fixedWidth ? aLabel.frame.size.width : CGFLOAT_MAX, 
									 fixedHeight ? aLabel.frame.size.height : CGFLOAT_MAX);
	
	CGSize requiredSize = [labelText sizeWithFont:aLabel.font 
								constrainedToSize:boundingSize
									lineBreakMode:UILineBreakModeWordWrap];
	
	return requiredSize;
}

+ (CGSize) getWrapperSizeWithLabel:(UILabel*) aLabel {
	return [self getWrapperSizeWithLabel:aLabel fixedWidthMode:NO fixedHeightMode:NO];
}


+ (NSDate*) convertToUTC:(NSDate*)sourceDate
{
    NSTimeZone* currentTimeZone = [NSTimeZone localTimeZone];
    NSTimeZone* utcTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
    
    NSInteger currentGMTOffset = [currentTimeZone secondsFromGMTForDate:sourceDate];
    NSInteger gmtOffset = [utcTimeZone secondsFromGMTForDate:sourceDate];
    NSTimeInterval gmtInterval = gmtOffset - currentGMTOffset;
    
    NSDate* destinationDate = [[[NSDate alloc] initWithTimeInterval:gmtInterval sinceDate:sourceDate] autorelease];     
    return destinationDate;
}

+ (NSDate*) convertToLocale:(NSDate *)sourceDate
{
    NSTimeZone* currentTimeZone = [NSTimeZone localTimeZone];
    NSTimeZone* utcTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
    
    NSInteger currentGMTOffset = [currentTimeZone secondsFromGMTForDate:sourceDate];
    NSInteger gmtOffset = [utcTimeZone secondsFromGMTForDate:sourceDate];
    NSTimeInterval gmtInterval = gmtOffset + currentGMTOffset;
    
    NSDate* destinationDate = [[[NSDate alloc] initWithTimeInterval:gmtInterval sinceDate:sourceDate] autorelease];     
    return destinationDate;
    
}
 
+ (NSString*) getDescriptionWithString:(NSString*) regDateString

{
	// 19자랑 같지 않다면 빈문장을 내보냄.
	if ([regDateString length] != 19) {
		return @"";
	}
	
	NSString* timeDesc;
	NSDateFormatter* dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
	[dateFormatter setDateFormat:@"yyyy.MM.dd HH:mm:ss"];
    NSDate* regDate = [dateFormatter dateFromString:regDateString];
	NSDate* regDateUTC = [regDate dateByAddingTimeInterval:-9*60*60];
    // 서버에서 보내주는 시간은 언제나 utc+9 이므로 -9하면 UTC로 변경됨
    
    NSDate* nowUTC = [Utils convertToUTC:[NSDate date]];
	NSTimeInterval interval = ABS([regDateUTC timeIntervalSinceDate:nowUTC]);
	
	if (interval < 60 * 60 * 24) {
		if (interval > 60 * 60) {
			timeDesc = [NSString stringWithFormat: @"%d시간전", (int) interval / 3600 ];	
		} else {
			timeDesc = [NSString stringWithFormat: @"%d분전", (int) interval / 60 ];
			if ((int)interval / 60 == 0) {
				timeDesc = @"지금";
			}
		}
		
	} else {
		[dateFormatter setDateFormat:@"yyyy.MM.dd"];
        
		timeDesc = [dateFormatter stringFromDate:[Utils convertToLocale:regDateUTC]];
	}
	
	return timeDesc;
}

+ (NSDate*) getDateWithString:(NSString*) regDateString
{
	if (regDateString == nil || [regDateString isEqualToString:@""]) {
		// 만약 시간 문자열을 받지 못했다면 현재 시간을 리턴하라
		return [NSDate date];
	}
	
	NSDateFormatter* dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
	NSLocale* enUSPOSIXLocale = [[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"] autorelease];
	
	[dateFormatter setLocale:enUSPOSIXLocale];	
	[dateFormatter setDateFormat:@"yyyy.MM.dd HH:mm:ss"];
	return [dateFormatter dateFromString:regDateString];	
}

+ (NSDate*) getDateWithString:(NSString *)regDateString withStyle:(NSString*)style
{
	if (regDateString == nil || [regDateString isEqualToString:@""]) {
		// 만약 시간 문자열을 받지 못했다면 현재 시간을 리턴하라
		return [NSDate date];
	}

	NSDateFormatter* dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
	NSLocale* enUSPOSIXLocale = [[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"] autorelease];
	
	[dateFormatter setLocale:enUSPOSIXLocale];	
	
	if ([style isEqualToString:@"STRAIGHT"]) {
		[dateFormatter setDateFormat:@"yyyyMMddHHmmss"];	
	} else {
		[dateFormatter setDateFormat:@"yyyy.MM.dd HH:mm:ss"];
	}
	
	return [dateFormatter dateFromString:regDateString];
}


// 서버에서 요구하는 문자열 포맷
+ (NSString*) getISO8601Date {
	NSDateFormatter* dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
	NSLocale* enUSPOSIXLocale = [[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"] autorelease];
	
	[dateFormatter setLocale:enUSPOSIXLocale];
	[dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
	NSString* dateString = [dateFormatter stringFromDate:[NSDate date]];
	return dateString;
}

+ (NSString*) getSimpleDateWithString:(NSString*) regDateString {
	return [regDateString substringToIndex:10];
}

+ (NSString*) stringFromDate:(NSDate*)aDate 
{
	NSDateFormatter* dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
	NSLocale* enUSPOSIXLocale = [[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"] autorelease];
	
	[dateFormatter setLocale:enUSPOSIXLocale];	
	[dateFormatter setDateFormat:@"yyyy.MM.dd HH:mm:ss"];
	NSString* ret = [dateFormatter stringFromDate:aDate];
	return ret;
}

+ (NSString*) getTimeIntervalSinceServerTimeNow:(NSTimeInterval) interval {
	NSDateFormatter* dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
	NSLocale* enUSPOSIXLocale = [[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"] autorelease];
	NSTimeZone *serverTimeZone = [NSTimeZone timeZoneWithName:@"Korea"];	
	[dateFormatter setLocale:enUSPOSIXLocale];	
	[dateFormatter setTimeZone:serverTimeZone];
	[dateFormatter setDateFormat:@"yyyyMMddHHmmss"];
	NSDate* fiveMinAgo = [NSDate dateWithTimeIntervalSinceNow:interval];
	
	NSString* ret = [dateFormatter stringFromDate:fiveMinAgo];
	return ret;
}

+ (NSString*) stringFromDate:(NSDate *)aDate withStyle:(NSString*)style
{
	NSDateFormatter* dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
	NSLocale* enUSPOSIXLocale = [[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"] autorelease];
	
	[dateFormatter setLocale:enUSPOSIXLocale];	
	
	if ([style isEqualToString:@"STRAIGHT"]) {
		[dateFormatter setDateFormat:@"yyyyMMddHHmmss"];	
	} else {
		[dateFormatter setDateFormat:@"yyyy.MM.dd HH:mm:ss"];
	}
	
	NSString* ret = [dateFormatter stringFromDate:aDate];
	return ret;	
}

+ (NSString*) stringFromDevice:(NSString*)deviceID
{
	NSString* retString;

	if( nil == deviceID ) return nil;
	NSNumberFormatter* formatter = [[NSNumberFormatter alloc] init];
	[formatter setNumberStyle:NSNumberFormatterDecimalStyle];
	NSNumber* deviceNumber = [formatter numberFromString:deviceID];
	[formatter release];
	switch ([deviceNumber intValue]) {
		case 1:
			retString = @"Web";
			break;
		case 11:
			retString = @"";	//모바일 웹
			break;
		case 12:
			retString = @"iPhone";
			break;
		case 13:
			retString = @"";	//모바일 MMS
			break;
		case 14:
			retString = @"android";
			break;
		default:
			retString = @"";
			break;
	}
	return retString;
}

#pragma mark -
#pragma mark SHA1
+ (NSString*) digest:(NSString*)input{
	NSData *data = [input dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
	uint8_t digest[CC_SHA1_DIGEST_LENGTH];
	CC_SHA1(data.bytes, data.length, digest);
	NSMutableString* output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
	
	for(int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++)
		[output appendFormat:@"%02x", digest[i]];
	
	return output;
}

+ (NSString*) encryptString
{
	NSString* ts = [NSString stringWithString:[self getISO8601Date]];
	NSString* sign = [NSString stringWithFormat:@"ts=%@&s=%@&",[ts URLEncodedString],[self digest:ts]];
	//MY_LOG(@"Packeted Data : %@",sign);
	return sign;
}

+ (NSString*) encryptStringWithAv:(NSString*) av
{
	NSString* ts = [NSString stringWithString:[self getISO8601Date]];
    NSString* s = nil;
    
    if (av != nil && ![av isEqualToString:@""]) {
        s = [av stringByAppendingString:ts];
    } else {
        s = ts;
    }
    
	NSString* sign = [NSString stringWithFormat:@"ts=%@&s=%@&",[ts URLEncodedString],[self digest:s]];
	//MY_LOG(@"Packeted Data : %@",sign);
	return sign;
}

+ (NSString*) ts
{
	NSString* time = [NSString stringWithString:[self getISO8601Date]];
	return time;
}

+ (NSString*) s
{
	NSString* time = [NSString stringWithString:[self getISO8601Date]];
	return [Utils digest:time];
}

+ (NSString*) sWithAv:(NSString*) av
{
	NSString* time = [NSString stringWithString:[self getISO8601Date]];
    NSString* s = nil;
    
    if (av != nil && ![av isEqualToString:@""]) {
        s = [av stringByAppendingString:time];
    } else {
        s = time;
    }

	return [Utils digest:s];
}


#pragma mark -
#pragma mark 통계용Header 생성

+ (NSString*) getNormalDate {
	NSDateFormatter* dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
	NSLocale* enUSPOSIXLocale = [[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"] autorelease];
	
	[dateFormatter setLocale:enUSPOSIXLocale];
	[dateFormatter setDateFormat:@"YYYYMMddHH"];
	NSString* dateString = [dateFormatter stringFromDate:[NSDate date]];
	return dateString;
}

+ (NSString*) headerString {
	if ([[UserContext sharedUserContext].snsID compare:@""] == NSOrderedSame)
		return @"";
	NSString* cookieStr = [NSString stringWithFormat:@"ccsession=%@%@;ccmedia=%@;ccguid=%@;expires:Fri, 31-Dec-2999 23:59:59 GMT;path=/;domain=.paran.com;",
						   [self getNormalDate],
						   [UserContext sharedUserContext].userNo,
						   [UserContext sharedUserContext].userNo,
						   [UserContext sharedUserContext].snsID
						   ];
	
	NSString* hstr = [NSString stringWithFormat:@"Cookie=%@&"
						,[cookieStr URLEncodedString]];
	
	return hstr;
}

+ (int) calcDistanceFromX:(int)fromx fromY:(int)fromy toX:(int)tox toY:(int)toy
{
	return (int)sqrt(((tox - fromx) * (tox - fromx) + (toy - fromy) * (toy - fromy)));
}


#pragma mark -
#pragma mark 전화번호/이름 딕셔너리 작성
+ (NSDictionary*) getPhoneBook
{
	NSMutableDictionary* phoneNameDictionary = [[[NSMutableDictionary alloc] initWithCapacity:100] autorelease];
/*
#ifndef APP_STORE_FINAL
	NSString* valueString = @"홍길동";
	NSString* keyString = @"01089713956";
	
	[phoneNameDictionary addEntriesFromDictionary:[NSDictionary dictionaryWithObject:valueString
																			  forKey:keyString]];

	MY_LOG(@"name: [%@] plain: [%@] encoded:[%@]", valueString, keyString, [Utils md5:keyString]);
//	[CommonAlert alertWithTitle:@"이상해" message:[Utils md5:keyString]];
	// 전화번호 1000개 테스트
	NSString* nameSeed = @"가나다라마바사아자차카타파하";
	
	for (int i=0; i < 1000; i++) {
		NSString* name = @"";
		for (int j=0; j < 3; j++) {
			[name stringByAppendingString:[nameSeed substringWithRange:NSMakeRange(rand() % nameSeed.length, 1)]];
		}
		NSString* tel = [NSString stringWithFormat:@"010%04d%04d", rand()%10000, rand()%10000];
		[phoneNameDictionary addEntriesFromDictionary:[NSDictionary dictionaryWithObject:name
																				  forKey:tel]];
		NSString* encoded = [Utils md5:tel];
		MY_LOG(@"name: [%@] plain: [%@] encoded:[%@]", name, tel, encoded);
	}
#endif
 */
	
	ABAddressBookRef addressBook = ABAddressBookCreate();
	CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople(addressBook);
	NSInteger size = (NSInteger)ABAddressBookGetPersonCount(addressBook);
	
	[[TAddressbook database] executeSql:@"DELETE FROM TAddressbook"];
	
	[[TAddressbook database] beginTransaction];
	
	for (int i=0; i < size; i++) {

		if (i > 1000) break; // 전화번호가 1000개까지만 보내자.
		
		ABRecordRef ref = CFArrayGetValueAtIndex(allPeople, i);
		ABMutableMultiValueRef multi =  ABRecordCopyValue(ref, kABPersonPhoneProperty);
		NSArray* phoneNumbers = [(id)ABMultiValueCopyArrayOfAllValues(multi) autorelease];
		CFRelease(multi);
		
		NSString *firstName = [(NSString *)ABRecordCopyValue(ref, kABPersonFirstNameProperty) autorelease];
		
		if (firstName == nil) {
			firstName = @"";
		}

		NSString *lastName = [(NSString *)ABRecordCopyValue(ref, kABPersonLastNameProperty) autorelease];
		
		if (lastName == nil) {
			lastName = @"";
		}

		NSString* name = [firstName length] < [lastName length] ? 
				[NSString stringWithFormat:@"%@%@", firstName, lastName] : 
				[NSString stringWithFormat:@"%@%@", lastName, firstName];
				
		if (phoneNumbers != nil) {
			NSString* phoneNum = [phoneNumbers objectAtIndex:0];
			phoneNum = [phoneNum stringByReplacingOccurrencesOfString:@"-" withString:@""];
			phoneNum = [phoneNum stringByReplacingOccurrencesOfString:@" " withString:@""];
			phoneNum = [phoneNum stringByReplacingOccurrencesOfString:@"(" withString:@""];
			phoneNum = [phoneNum stringByReplacingOccurrencesOfString:@")" withString:@""];
			phoneNum = [phoneNum stringByReplacingOccurrencesOfString:@"+" withString:@""];
			phoneNum = [phoneNum stringByReplacingOccurrencesOfString:@"," withString:@""];
			phoneNum = [phoneNum stringByReplacingOccurrencesOfString:@"#" withString:@""];
			
			if ([phoneNum length] < 2) { // prevent crash when rangeOfString below
				continue;
			}
			
			if ([phoneNum rangeOfString:@"01" options:NSCaseInsensitiveSearch range:NSMakeRange(0, 2)].location != NSNotFound && phoneNum.length < 12) {
				
				NSString* md5Encoded = [Utils md5:phoneNum];
				
				
				[phoneNameDictionary addEntriesFromDictionary:[NSDictionary dictionaryWithObject:name forKey:md5Encoded]];
				
				name = [name stringByReplacingOccurrencesOfString:@"'" withString:@""];
				name = [name stringByReplacingOccurrencesOfString:@"\"" withString:@""];
				
				// 디비 추가
				NSString* query = [NSString stringWithFormat:
								   @"insert into TAddressbook values ('%@', '%@', '%@')", 
								   name, phoneNum, md5Encoded];
				
				[[TAddressbook database] executeSql:query];
			}
		}
	}
	CFRelease(addressBook);
	CFRelease(allPeople);
	
	[[TAddressbook database] commit];
	
	return phoneNameDictionary;
}


+ (NSString*) getPhoneAndNameWithMd5:(NSString*) md5
{
	NSArray* addressbook = [TAddressbook findWithSql:[NSString stringWithFormat: 
														   @"select * from TAddressbook where md5 = '%@'", md5]];
	
	NSString* phoneNum = @"";
	
	if ([addressbook count] > 0) {
		TAddressbook* ab = [addressbook lastObject];
		ab.phone = [Utils addDashToPhoneNumber:ab.phone];
		phoneNum = [NSString stringWithFormat:@"%@ (%@)", ab.name, ab.phone];
	}
	
	return phoneNum;
}

+ (NSString*) getNameWithMd5:(NSString*) md5
{
	NSArray* addressbook = [TAddressbook findWithSql:[NSString stringWithFormat: 
													  @"select * from TAddressbook where md5 = '%@'", md5]];
	
	NSString* nameString = @"";
	
	if ([addressbook count] > 0) {
		TAddressbook* ab = [addressbook lastObject];
		nameString = ab.name;
	}
	
	return nameString;
}


+ (NSString*) addDashToPhoneNumber:(NSString*)phoneNo
{
	/*
	NSString* dashedPhoneNo = @"";
	
	if (phoneNo.length > 9 && phoneNo.length < 12) {
		dashedPhoneNo = [phoneNo substringWithRange:NSMakeRange(0, 3)];
		dashedPhoneNo = [dashedPhoneNo stringByAppendingString:@"-"];
		if (phoneNo.length == 10) {
			dashedPhoneNo = [dashedPhoneNo stringByAppendingString:[phoneNo substringWithRange:NSMakeRange(3, 3)]];
			dashedPhoneNo = [dashedPhoneNo stringByAppendingString:@"-"];
			dashedPhoneNo = [dashedPhoneNo stringByAppendingString:[phoneNo substringWithRange:NSMakeRange(6, 4)]];
		}
		if (phoneNo.length == 11) {
			dashedPhoneNo = [dashedPhoneNo stringByAppendingString:[phoneNo substringWithRange:NSMakeRange(3, 4)]];
			dashedPhoneNo = [dashedPhoneNo stringByAppendingString:@"-"];
			dashedPhoneNo = [dashedPhoneNo stringByAppendingString:[phoneNo substringWithRange:NSMakeRange(7, 4)]];			
		}
	}
	return dashedPhoneNo;*/
	NSString* correctText = [phoneNo stringByReplacingOccurrencesOfString:@"-" withString:@""];
	correctText = [correctText stringByReplacingOccurrencesOfString:@"(" withString:@""];
	correctText = [correctText stringByReplacingOccurrencesOfString:@")" withString:@""];
	MY_LOG(@"---TextFieldText : %@",correctText);
	NSInteger tvCount = [correctText length];
	if (tvCount > 11) tvCount=11;
	MY_LOG(@"--Text Count : %d", tvCount);
	NSString* resultNumber;
	if (tvCount >= 11)
	{
		NSString* aNumber = [correctText substringWithRange:NSMakeRange(0,3)];
		NSString* bNumber = [correctText substringWithRange:NSMakeRange(3,4)];
		NSString* cNumber = [correctText substringWithRange:NSMakeRange(7,tvCount-7)];
		resultNumber = [NSString stringWithFormat:@"%@-%@-%@",aNumber,bNumber,cNumber];
	} else if (tvCount >= 7)
	{
		if ([[correctText substringWithRange:NSMakeRange(0,2)] compare:@"02"] == NSOrderedSame) // 서울일때
		{
			if (tvCount >= 10)
			{
				NSString* aNumber = [correctText substringWithRange:NSMakeRange(0,2)];
				MY_LOG(@"ANumber:%@", aNumber);
				NSString* bNumber = [correctText substringWithRange:NSMakeRange(2,4)];
				MY_LOG(@"bNumber:%@", bNumber);
				NSString* cNumber = [correctText substringWithRange:NSMakeRange(6,tvCount-6)];
				MY_LOG(@"cNumber:%@", cNumber);
				resultNumber = [NSString stringWithFormat:@"%@-%@-%@",aNumber,bNumber,cNumber];
			} else
			{
				NSString* aNumber = [correctText substringWithRange:NSMakeRange(0,2)];
				MY_LOG(@"ANumber:%@", aNumber);
				NSString* bNumber = [correctText substringWithRange:NSMakeRange(2,3)];
				MY_LOG(@"bNumber:%@", bNumber);
				NSString* cNumber = [correctText substringWithRange:NSMakeRange(5,tvCount-5)];
				MY_LOG(@"cNumber:%@", cNumber);
				resultNumber = [NSString stringWithFormat:@"%@-%@-%@",aNumber,bNumber,cNumber];
			}
		} else
		{
			NSString* aNumber = [correctText substringWithRange:NSMakeRange(0,3)];
			MY_LOG(@"ANumber:%@", aNumber);
			NSString* bNumber = [correctText substringWithRange:NSMakeRange(3,3)];
			MY_LOG(@"bNumber:%@", bNumber);
			NSString* cNumber = [correctText substringWithRange:NSMakeRange(6,tvCount-6)];
			MY_LOG(@"cNumber:%@", cNumber);
			resultNumber = [NSString stringWithFormat:@"%@-%@-%@",aNumber,bNumber,cNumber];
		}
		
		
	} else if (tvCount > 3)
	{
		NSString* aNumber = [correctText substringWithRange:NSMakeRange(0,3)];
		NSString* bNumber = [correctText substringWithRange:NSMakeRange(3,tvCount-3)];
		resultNumber = [NSString stringWithFormat:@"%@-%@",aNumber,bNumber];
	} else
	{
		resultNumber = correctText;
	}
	MY_LOG(@"---TextFieldText2 : %@",resultNumber); 
	return resultNumber;
}


#pragma mark -
#pragma mark md5

+ (NSString*) md5:(NSString *) plain
{
	const char *cStr = [plain UTF8String];
	unsigned char result[CC_MD5_DIGEST_LENGTH];
	
	CC_MD5( cStr, strlen(cStr), result );
	
	return [[NSString
			 stringWithFormat:@"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
			 result[0], result[1],
			 result[2], result[3],
			 result[4], result[5],
			 result[6], result[7],
			 result[8], result[9],
			 result[10], result[11],
			 result[12], result[13],
			 result[14], result[15]
			 ] lowercaseString];
}


#pragma mark -
#pragma mark database

+ (NSString*) lastFeedDate {
	TFeedList* lastFeed = [[TFeedList findWithSql:@"select * from TFeedList order by regdate desc limit 1"] lastObject];

	NSDate* lastDate;
	
	if (lastFeed != nil) {
		lastDate = [Utils getDateWithString:lastFeed.regDate];	
	} else {
		lastDate = [NSDate dateWithTimeIntervalSinceNow:-60*60*24*3];
	}

	NSString* lastFeedDate = [Utils stringFromDate:[NSDate dateWithTimeInterval:+1 sinceDate:lastDate] withStyle:@"STRAIGHT"]; // 마지막 feed의 regdate +1초	
	
	return lastFeedDate;
}

#pragma mark -
#pragma mark image cache

+ (UIImage*) getImageFromBaseUrl:(NSString*)baseUrl withSize:(NSString*)size withType:(NSString*)type
{
	NSAssert(baseUrl != nil, @"URL은 줘야함.");
	NSString* filename = [[baseUrl componentsSeparatedByString:@"/"] lastObject];
	NSArray* filenameComponentArray = [filename componentsSeparatedByString:@"_"];
	
	if ([filenameComponentArray count] != 4) {
		NSAssert(NO, @"파일명이 이상함");
	}
	
	NSString* badgeId = [filenameComponentArray objectAtIndex:0];
	NSString* ver = [filenameComponentArray lastObject];
	
	NSString* theFilename = [NSString stringWithFormat:@"%@_%@_%@_%@", badgeId, size, type, ver];
	NSString* url = [baseUrl stringByReplacingOccurrencesOfString:filename withString:theFilename];

	return [Utils imageWithURL:url];
}

+ (NSString*) get53ImageFrom:(NSString*)baseURL {
	if ([ApplicationContext isRetina]) {
		baseURL = [baseURL stringByReplacingOccurrencesOfString:@".png" withString:@"@2x.png"];
	}
	return [baseURL stringByReplacingOccurrencesOfString:@"126x126" withString:@"53x53"];
}

+ (NSString*) get84ImageFrom:(NSString*)baseURL {
	if ([ApplicationContext isRetina]) {
		baseURL = [baseURL stringByReplacingOccurrencesOfString:@".png" withString:@"@2x.png"];
	}
	return [baseURL stringByReplacingOccurrencesOfString:@"126x126" withString:@"84x84"];
}

+ (NSString*) get84BgImageFrom:(NSString*)baseURL {
	if ([ApplicationContext isRetina]) {
		baseURL = [baseURL stringByReplacingOccurrencesOfString:@".png" withString:@"@2x.png"];
	}
	return [baseURL stringByReplacingOccurrencesOfString:@"126x126" withString:@"84x84"];
}


+ (NSString*) get168ImageFrom:(NSString*)baseURL {
	if ([ApplicationContext isRetina]) {
		baseURL = [baseURL stringByReplacingOccurrencesOfString:@".png" withString:@"@2x.png"];
	}
	return [baseURL stringByReplacingOccurrencesOfString:@"126x126" withString:@"168x168"];
}

+ (NSString*) get252ImageFrom:(NSString*)baseURL {
	if ([ApplicationContext isRetina]) {
		baseURL = [baseURL stringByReplacingOccurrencesOfString:@".png" withString:@"@2x.png"];
	}
	return [baseURL stringByReplacingOccurrencesOfString:@"126x126" withString:@"252x252"];
}


+ (void) requestImageCacheWithURL:(NSString*) urlString 
						 delegate:(id)aDelegate 
					 doneSelector: (SEL)aDoneSelector 
					errorSelector: (SEL)anErrorSelector
				 cacheHitSelector: (SEL)anCacheHitSelector
{
	if ([ApplicationContext isRetina]) {
		urlString = [urlString stringByReplacingOccurrencesOfString:@".png" withString:@"@2x.png"];
	}
//	MY_LOG(@"requestImageCacheWithURL: %@", urlString);
	NSString* filename = [[urlString componentsSeparatedByString:@"/"] lastObject];

    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    
    NSString* filepath = [[[paths objectAtIndex:0] stringByAppendingPathComponent:@"ImInBadge"] stringByAppendingPathComponent:filename];
//	NSString* filepath = [[[ApplicationContext sharedApplicationContext].documentPath 
//								  stringByAppendingPathComponent:@"imageCache"] stringByAppendingPathComponent:filename];
	if (![[NSFileManager defaultManager] fileExistsAtPath:filepath]) {
		[[[SimpleImageDownloader alloc] initWithURLString:urlString delegate:(id)aDelegate doneSelector: (SEL)aDoneSelector errorSelector: (SEL)anErrorSelector] autorelease];
	} else {
		// 로컬 디스크 캐시에서 찾았냈다면 cache hit selector를 실행시킨다.
		if(aDelegate != nil && [aDelegate respondsToSelector:anCacheHitSelector])
			[aDelegate performSelector:anCacheHitSelector withObject:urlString];
	}
}


+ (UIImage*) imageWithURL: (NSString*) url
{
	if ([ApplicationContext isRetina] && [url rangeOfString:@"@2x.png"].location == NSNotFound) {
		url = [url stringByReplacingOccurrencesOfString:@".png" withString:@"@2x.png"];
	}
	
	NSString* filename = [[url componentsSeparatedByString:@"/"] lastObject];
	
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    
    NSString* filepath = [[[paths objectAtIndex:0] stringByAppendingPathComponent:@"ImInBadge"] stringByAppendingPathComponent:filename];
    
//	NSString* cacheFolderPath = [[ApplicationContext sharedApplicationContext].documentPath stringByAppendingPathComponent:@"imageCache"];
//	NSString* filepath = [cacheFolderPath stringByAppendingPathComponent:filename];
	
	if (![[NSFileManager defaultManager] fileExistsAtPath:filepath]) {
		[[[SimpleImageDownloader alloc] initWithURLString:url delegate:nil doneSelector: nil errorSelector: nil] autorelease];
		[[ApplicationContext sharedApplicationContext] resetUpdateStatus];
		return nil;
	} else {
		return [UIImage imageWithContentsOfFile:filepath];
	}
}

// 거리 계산
+ (float) getDistanceFrom:(CGPoint)point1 to:(CGPoint)point2
{
	CGFloat dx = point2.x - point1.x;
	CGFloat dy = point2.y - point1.y;
	return sqrt(dx*dx + dy*dy);
}

+ (float) getDistanceToHereFrom:(CGPoint) aPoint
{
	CGPoint currPoint = CGPointMake([[GeoContext sharedGeoContext].lastTmX floatValue], 
									[[GeoContext sharedGeoContext].lastTmY floatValue]);
	return [Utils getDistanceFrom:aPoint to:currPoint];
}

// notice view 생성
+ (UIView*) createNoticeViewWithDictionary:(NSDictionary*) data
{
    float width = [[data objectForKey:@"width"] floatValue];
    float height = [[data objectForKey:@"height"] floatValue];
    
    CGRect frame = CGRectMake(0, 0, width, height);
    UIView* retView = [[[UIView alloc] initWithFrame:frame] autorelease];
    [retView setBackgroundColor:IMIN_COLOR_BG];
    UIImageView* faceImageView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"main_noreply_icon.png"]] autorelease];
    faceImageView.center = CGPointMake(width / 2, height / 3);
    
    CGRect aframe = faceImageView.frame;
    float aHeight = aframe.origin.y + aframe.size.height;
    
    UILabel* messageLabel = [[[UILabel alloc] initWithFrame:CGRectMake((width - width * 0.8)/2, aHeight, width * 0.8, 50)] autorelease];
    messageLabel.textColor = RGB(85, 85, 85);
    messageLabel.backgroundColor = [UIColor clearColor];
    messageLabel.font = [UIFont systemFontOfSize:12.0f];
    messageLabel.lineBreakMode = UILineBreakModeWordWrap;
    messageLabel.textAlignment = UITextAlignmentCenter;
    messageLabel.numberOfLines = 10;
    messageLabel.text = [data objectForKey:@"message"];
    
    CGSize size = [Utils getWrapperSizeWithLabel:messageLabel fixedWidthMode:YES fixedHeightMode:YES];
    
    messageLabel.frame = CGRectMake((width - width * 0.8)/2, aHeight, width * 0.8, size.height);
    
    [retView addSubview:faceImageView];
    [retView addSubview:messageLabel];
    
    return retView;
}


+ (BOOL) isValidNeighborRecomWithArray:(NSArray*) list 
{
    int phoneBookCnt = 0;
    int twitterCnt = 0;
    int facebookCnt = 0;
    
    BOOL phoneBookConnected = [UserContext sharedUserContext].cpPhone.isConnected;
    BOOL twitterConnected = [UserContext sharedUserContext].cpTwitter.isConnected;
    BOOL facebookConnected = [UserContext sharedUserContext].cpFacebook.isConnected;
    
    for (NSDictionary* aFriend in list) {
        int knownType = [[aFriend objectForKey:@"knownType"] intValue];
        if (knownType == 1) {
            int recomType = [[aFriend objectForKey:@"recomType"] intValue];
            switch (recomType) {
                case 11:
                    phoneBookCnt++;
                    break;
                case 21:
                    twitterCnt++;
                    break;
                case 23:
                    facebookCnt++;
                    break;
                default:
                    break;
            }
            
            if (phoneBookCnt > 0 && twitterCnt > 0 && facebookCnt > 0) {
                // 세가지 모두 찾은 케이스이므로 제대로 된 리스트라고 판단 하면 된다.
                return YES;
            }
        }
    }
    
    if (phoneBookConnected && phoneBookCnt == 0) {
        return NO;
    }
    if (twitterConnected && twitterCnt == 0) {
        return NO;
    }
    if (facebookConnected && facebookCnt == 0) {
        return NO;
    }
    
    return YES;
}

+ (BOOL) isBrandUser:(NSDictionary *)data
{
    NSString* userType = [data objectForKey:@"userType"];
    NSString* bizType = [data objectForKey:@"bizType"];
    
    if (userType && ![userType isEqualToString:@""]) {
        return ([bizType isEqualToString:@"BT0001"] || [bizType isEqualToString:@"BT0002"]) && [userType isEqualToString:@"UB0001"];
    } else {
        return ([bizType isEqualToString:@"BT0001"] || [bizType isEqualToString:@"BT0002"]);
    }
}


+ (NSString*) convertImgSize70to38:(NSString*) oriImg {
    NSString* convertImg = @"";
    //http://211.113.4.83/TOP/svc/imin/v1/img/bizcate/9000000_70x70_2.png
    if (oriImg != nil) {
        NSRange thumb1Range = [oriImg rangeOfString:@"/" options:NSBackwardsSearch];
        if (thumb1Range.location != NSNotFound) { 
            NSString* temp= [oriImg substringFromIndex:thumb1Range.location+1]; // temp = 9000000_70x70_2.png
            thumb1Range = [temp rangeOfString:@"_"];
            if (thumb1Range.location != NSNotFound) {
                temp= [temp substringFromIndex:thumb1Range.location+1]; // temp = 70x70_2.png
                thumb1Range = [temp rangeOfString:@"_"];
                if (thumb1Range.location != NSNotFound) {
                    temp= [temp substringToIndex:thumb1Range.location]; // temp = 70x70
                    thumb1Range = [oriImg rangeOfString:temp];
                    if (thumb1Range.location != NSNotFound) {
                        convertImg = [oriImg stringByReplacingCharactersInRange:thumb1Range withString:@"38x38"];
                        thumb1Range = [convertImg rangeOfString:@"." options:NSBackwardsSearch];
                        if (thumb1Range.location != NSNotFound) {
                            convertImg = [convertImg stringByReplacingCharactersInRange:thumb1Range withString:@"@2x."];
                        }
                    }
                }
            }
        }
    }
    
    return convertImg;
}

+ (NSString*) convertImgSize70to47:(NSString*) oriImg {
    NSString* convertImg = @"";
    //http://211.113.4.83/TOP/svc/imin/v1/img/bizcate/9000000_70x70_2.png
    if (oriImg != nil) {
        NSRange thumb1Range = [oriImg rangeOfString:@"/" options:NSBackwardsSearch];
        if (thumb1Range.location != NSNotFound) { 
            NSString* temp= [oriImg substringFromIndex:thumb1Range.location+1]; // temp = 9000000_70x70_2.png
            thumb1Range = [temp rangeOfString:@"_"];
            if (thumb1Range.location != NSNotFound) {
                temp= [temp substringFromIndex:thumb1Range.location+1]; // temp = 70x70_2.png
                thumb1Range = [temp rangeOfString:@"_"];
                if (thumb1Range.location != NSNotFound) {
                    temp= [temp substringToIndex:thumb1Range.location]; // temp = 70x70
                    thumb1Range = [oriImg rangeOfString:temp];
                    if (thumb1Range.location != NSNotFound) {
                        convertImg = [oriImg stringByReplacingCharactersInRange:thumb1Range withString:@"47x47"];
                        thumb1Range = [convertImg rangeOfString:@"." options:NSBackwardsSearch];
                        if (thumb1Range.location != NSNotFound) {
                            convertImg = [convertImg stringByReplacingCharactersInRange:thumb1Range withString:@"@2x."];
                        }
                    }
                }
            }
        }
    }
    
    return convertImg;
}

@end
