//
//  SnsKeyChain.m
//  ImIn
//
//  Created by mandolin on 09. 04. 13.
//  Copyright 2009 KTH(주). All rights reserved.
//

#import "SnsKeyChain.h"
#import "UserContext.h"
#import "HttpConnect.h"

#import "CgiStringList.h"
#import "const.h"
#import "RegisterDevice.h"

@implementation SnsKeyChain
@synthesize registerDevice;
static SnsKeyChain *sharedInstance = nil;

+(SnsKeyChain *) sharedInstance {
    if(!sharedInstance) {
		sharedInstance = [[self alloc] init];
    }
    return sharedInstance;
}

- (void) dealloc {
	if (connect != nil)
	{	
		[connect stop];
		[connect release];
		connect = nil;
	}
	
    [registerDevice release];
	[super dealloc];
}

// Translate status messages into return strings
- (NSString *) fetchStatus : (OSStatus) status
{
	if		(status == 0) return(@"Success!");
	else if (status == errSecNotAvailable) return(@"No trust results are available.");
	else if (status == errSecItemNotFound) return(@"The item cannot be found.");
	else if (status == errSecParam) return(@"Parameter error.");
	else if (status == errSecAllocate) return(@"Memory allocation error. Failed to allocate memory.");
	else if (status == errSecInteractionNotAllowed) return(@"User interaction is not allowed.");
	else if (status == errSecUnimplemented ) return(@"Function is not implemented");
	else if (status == errSecDuplicateItem) return(@"The item already exists.");
	else if (status == errSecDecode) return(@"Unable to decode the provided data.");
	else 
		return([NSString stringWithFormat:@"Function returned: %d", status]);
}

#define	ACCOUNT	@"ParanSNS Account"
#define	SERVICE	@"ParanSNS Service"
#define PWKEY	@"ParanSNS Passwd data Encapsulation"
#define DEBUG	YES

// Return a base dictionary
- (NSMutableDictionary *) baseDictionary
{
	NSMutableDictionary *md = [[NSMutableDictionary alloc] init];
	
	// Password identification keys
	NSData *identifier = [PWKEY dataUsingEncoding:NSUTF8StringEncoding];
	[md setObject:identifier forKey:(id)kSecAttrGeneric];
	[md setObject:ACCOUNT forKey:(id)kSecAttrAccount];
    [md setObject:SERVICE forKey:(id)kSecAttrService];
	[md setObject:(id)kSecClassGenericPassword forKey:(id)kSecClass];
	
	return [md autorelease];
}

// Return a keychain-style dictionary populated with the password
- (NSMutableDictionary *) buildDictForPassword:(NSString *) password
{
	
	NSMutableDictionary *passwordDict = [self baseDictionary];
	
	// Add the password
	NSData *passwordData = [password dataUsingEncoding:NSUTF8StringEncoding];
    [passwordDict setObject:passwordData forKey:(id)kSecValueData]; // password 
	
	return passwordDict;
}

// Build a search query based
- (NSMutableDictionary *) buildSearchQuery
{
	NSMutableDictionary *genericPasswordQuery = [self baseDictionary];
	
	// Add the search constraints
	[genericPasswordQuery setObject:(id)kSecMatchLimitOne forKey:(id)kSecMatchLimit];
	[genericPasswordQuery setObject:(id)kCFBooleanTrue
							 forKey:(id)kSecReturnAttributes];
	[genericPasswordQuery setObject:(id)kCFBooleanTrue
							 forKey:(id)kSecReturnData];
	
	return genericPasswordQuery;
}

// retrieve data dictionary from the keychain
- (NSMutableDictionary *) fetchDictionary
{
	NSMutableDictionary *genericPasswordQuery = [self buildSearchQuery];
	
	NSMutableDictionary *outDictionary = nil;
	OSStatus status = SecItemCopyMatching((CFDictionaryRef)genericPasswordQuery, (CFTypeRef *)&outDictionary);
	if (DEBUG) printf("FETCH: %s\n", [[self fetchStatus:status] UTF8String]);
	
	if (status == errSecItemNotFound) return NULL;
	return outDictionary;
}	

// create a new keychain entry
- (BOOL) createKeychainValue:(NSString *) password
{
	NSMutableDictionary *md = [self buildDictForPassword:password];
	OSStatus status = SecItemAdd((CFDictionaryRef)md, NULL);
	if (DEBUG) printf("CREATE: %s\n", [[self fetchStatus:status] UTF8String]);
	
	if (status == noErr) return YES; else return NO;
}

// remove a keychain entry
- (void) clearKeychain
{
	NSMutableDictionary *genericPasswordQuery = [self baseDictionary];
	
	OSStatus status = SecItemDelete((CFDictionaryRef) genericPasswordQuery);
	if (DEBUG) printf("DELETE: %s\n", [[self fetchStatus:status] UTF8String]);
}

// update a keychaing entry
- (BOOL) updateKeychainValue:(NSString *)password
{
	NSMutableDictionary *genericPasswordQuery = [self baseDictionary];
	
	NSMutableDictionary *attributesToUpdate = [[NSMutableDictionary alloc] init];
	NSData *passwordData = [password dataUsingEncoding:NSUTF8StringEncoding];
	[attributesToUpdate setObject:passwordData forKey:(id)kSecValueData];
	
	OSStatus status = SecItemUpdate((CFDictionaryRef)genericPasswordQuery, (CFDictionaryRef)attributesToUpdate);
	if (DEBUG) printf("UPDATE: %s\n", [[self fetchStatus:status] UTF8String]);
	[attributesToUpdate release];
	if (status == 0) return YES; else return NO;
}

// fetch a keychain value
- (NSString *) fetchPassword
{
	NSMutableDictionary *outDictionary = [self fetchDictionary];
	
	if (outDictionary)
	{
		NSString *password = [[NSString alloc] initWithData:[outDictionary objectForKey:(id)kSecValueData] encoding:NSUTF8StringEncoding];
		return [password autorelease];
	} else return NULL;
}

- (void) setPassword: (NSString *) thePassword
{
	if (![self createKeychainValue:thePassword]) 
		[self updateKeychainValue:thePassword];
}

- (bool) setParanId:(NSString*) theId
{
	CFStringRef cfDomain = CFSTR("com.paran.sns");
	CFStringRef cfValue = (CFStringRef)theId;
	CFStringRef cfKey = CFSTR("paranid");
	MY_LOG(@"SetParanID into Keychain:%@", theId);
	CFPreferencesSetValue(cfKey,cfValue, cfDomain, kCFPreferencesAnyUser,kCFPreferencesCurrentHost);
	CFPreferencesSynchronize(cfDomain, kCFPreferencesAnyUser, kCFPreferencesCurrentHost);
	return true;
}

- (NSString*) fetchParanId
{
	CFStringRef cfDomain = CFSTR("com.paran.sns");
	CFStringRef cfKey = CFSTR("paranid");
	CFStringRef cfResult = (CFStringRef)CFPreferencesCopyValue(cfKey, cfDomain, kCFPreferencesAnyUser,kCFPreferencesCurrentHost);
	MY_LOG(@"ID Result:%@",cfResult);
	if (cfResult == nil) return @"";
	NSString* tempResult = [[[NSString alloc] initWithFormat:@"%@",cfResult] autorelease];
	if (cfResult != nil)
		CFRelease(cfResult);
	return tempResult;
	//return (NSString*)cfResult;
}

- (void) sendDeviceTokenInfo:(BOOL)bEnable
{
	if ([UserContext sharedUserContext].snsID == nil || 
		[UserContext sharedUserContext].deviceToken== nil || 
		[[UserContext sharedUserContext].snsID compare:@""] == NSOrderedSame || 
		[[UserContext sharedUserContext].deviceToken compare:@""] ==NSOrderedSame ||
        [UserContext sharedUserContext].deviceTokenSent == YES
        )
		return;

    [UserContext sharedUserContext].deviceTokenSent = YES;
    
    self.registerDevice = [[[RegisterDevice alloc] init] autorelease];
    registerDevice.delegate = self;
    
    [registerDevice.params addEntriesFromDictionary:[NSDictionary dictionaryWithObject:@"json" forKey:@"ct"]];
    [registerDevice.params addEntriesFromDictionary:[NSDictionary dictionaryWithObject:[UserContext sharedUserContext].deviceToken forKey:@"deviceToken"]];
    if (bEnable) {
        [registerDevice.params addEntriesFromDictionary:[NSDictionary dictionaryWithObject:@"ON" forKey:@"mode"]];
    } else {
        [registerDevice.params addEntriesFromDictionary:[NSDictionary dictionaryWithObject:@"OFF" forKey:@"mode"]];
    }
    
    [registerDevice request];
     
    
//    [UserContext sharedUserContext].deviceTokenSent = YES;
//    
//	MY_LOG(@"Send DeviceToken to Server"); 
//	CgiStringList* strPostData=[[CgiStringList alloc]init:@"&"];
//	
//	[strPostData setMapString:@"svcId" keyvalue:SNS_IPHONE_SVCID];
//    [strPostData setMapString:@"appVer" keyvalue:[ApplicationContext appVersion]];
//	[strPostData setMapString:@"device" keyvalue:SNS_DEVICE_MOBILE_APP];
//	[strPostData setMapString:@"ct" keyvalue:@"json"];
//	[strPostData setMapString:@"deviceToken" keyvalue:[UserContext sharedUserContext].deviceToken];
//        
//	if (bEnable)
//		[strPostData setMapString:@"mode" keyvalue:@"ON"];
//	else
//		[strPostData setMapString:@"mode" keyvalue:@"OFF"];
//	[strPostData setMapString:@"at" keyvalue:@"1"];
//	[strPostData setMapString:@"av" keyvalue:[UserContext sharedUserContext].snsID];
//	
//	if (connect != nil) {
//		[connect stop];
//		[connect release];
//		connect = nil;
//	}
//
//	connect = [[HttpConnect alloc] initWithURL: PROTOCOL_REGISTER_DEVICE
//						   postData: [strPostData description]
//						   delegate: self
//					   doneSelector: @selector(TransDone:)
//					  errorSelector: @selector(TransFail:)
//				   progressSelector: nil
//					isIndicatorVisible:NO ];
//	[strPostData release];
}

- (void) apiFailed {
    
}

- (void) apiDidLoad:(NSDictionary *)result {
    
}

//- (void) TransDone:(HttpConnect*)up
//{
//	if (connect != nil)
//	{
//		[connect release];
//		connect = nil;
//	}	
//	MY_LOG(@"%@", up.stringReply);
//}
//
//- (void) TransFail:(HttpConnect*)up
//{
//	if (connect != nil)
//	{
//		[connect release];
//		connect = nil;
//	}	
//	
//	MY_LOG(@"%@", up.stringError);
//}

///// 검색 반경 KM저장용
- (bool) setSearchKM:(NSString*) theId
{
	CFStringRef cfDomain = CFSTR("com.paran.sns");
	CFStringRef cfValue = (CFStringRef)theId;
	CFStringRef cfKey = CFSTR("searchKM");
	MY_LOG(@"Set Search KM into Keychain:%@", theId);
	CFPreferencesSetValue(cfKey,cfValue, cfDomain, kCFPreferencesAnyUser,kCFPreferencesCurrentHost);
	CFPreferencesSynchronize(cfDomain, kCFPreferencesAnyUser, kCFPreferencesCurrentHost);
	return true;
}

- (NSString*) fetchSearchKM
{
	CFStringRef cfDomain = CFSTR("com.paran.sns");
	CFStringRef cfKey = CFSTR("searchKM");
	CFStringRef cfResult = (CFStringRef)CFPreferencesCopyValue(cfKey, cfDomain, kCFPreferencesAnyUser,kCFPreferencesCurrentHost);
	MY_LOG(@"Set Search KM Result:%@",cfResult);
	if (cfResult == nil) return @"";
	NSString* tempResult = [[[NSString alloc] initWithFormat:@"%@",cfResult] autorelease];
	if (cfResult != nil)
		CFRelease(cfResult);
	//return (NSString*)cfResult;
	return tempResult;
}

///// 첫방문 검사용
- (bool) setFirstVisit:(NSString*) theId
{
	CFStringRef cfDomain = CFSTR("com.paran.sns");
	CFStringRef cfValue = (CFStringRef)theId;
	CFStringRef cfKey = CFSTR("firstVisit");
	MY_LOG(@"Set firstVisit into Keychain:%@", theId);
	CFPreferencesSetValue(cfKey,cfValue, cfDomain, kCFPreferencesAnyUser,kCFPreferencesCurrentHost);
	CFPreferencesSynchronize(cfDomain, kCFPreferencesAnyUser, kCFPreferencesCurrentHost);
	return true;
}

- (NSString*) fetchFirstVisit
{
	CFStringRef cfDomain = CFSTR("com.paran.sns");
	CFStringRef cfKey = CFSTR("firstVisit");
	CFStringRef cfResult = (CFStringRef)CFPreferencesCopyValue(cfKey, cfDomain, kCFPreferencesAnyUser,kCFPreferencesCurrentHost);
	MY_LOG(@"Set firstVisit Result:%@",cfResult);
	if (cfResult == nil) return @"";
	NSString* tempResult = [[[NSString alloc] initWithFormat:@"%@",cfResult] autorelease];
	if (cfResult != nil)
		CFRelease(cfResult);
	//return (NSString*)cfResult;
	return tempResult;
}

///// 인증토큰 검사용
- (bool) setToken:(NSString*) authToken
{
	CFStringRef cfDomain = CFSTR("com.paran.sns");
	CFStringRef cfValue = (CFStringRef)authToken;
	CFStringRef cfKey = CFSTR("token");
	MY_LOG(@"Set authToken into Keychain:%@", authToken);
	CFPreferencesSetValue(cfKey,cfValue, cfDomain, kCFPreferencesAnyUser,kCFPreferencesCurrentHost);
	CFPreferencesSynchronize(cfDomain, kCFPreferencesAnyUser, kCFPreferencesCurrentHost);
	return true;
}

- (NSString*) fetchToken
{
	CFStringRef cfDomain = CFSTR("com.paran.sns");
	CFStringRef cfKey = CFSTR("token");
	CFStringRef cfResult = (CFStringRef)CFPreferencesCopyValue(cfKey, cfDomain, kCFPreferencesAnyUser,kCFPreferencesCurrentHost);
	MY_LOG(@"Set token Result:%@",cfResult);
	if (cfResult == nil) return @"";
	NSString* tempResult = [[[NSString alloc] initWithFormat:@"%@",cfResult] autorelease];
	if (cfResult != nil)
		CFRelease(cfResult);
	return tempResult;
}

///// 토큰정보가 oauth 인증인지 아닌지 검사용
- (bool) setoAuth:(NSString*) oauth  //로그인 타입 -> oAuth : oauth, 그외 : paran
{
	CFStringRef cfDomain = CFSTR("com.paran.sns");
	CFStringRef cfValue = (CFStringRef)oauth;
	CFStringRef cfKey = CFSTR("oauth");
	MY_LOG(@"Set oauth into Keychain:%@", oauth);
	CFPreferencesSetValue(cfKey,cfValue, cfDomain, kCFPreferencesAnyUser,kCFPreferencesCurrentHost);
	CFPreferencesSynchronize(cfDomain, kCFPreferencesAnyUser, kCFPreferencesCurrentHost);
	return true;
}

- (NSString*) fetchoAuth
{
	CFStringRef cfDomain = CFSTR("com.paran.sns");
	CFStringRef cfKey = CFSTR("oauth");
	CFStringRef cfResult = (CFStringRef)CFPreferencesCopyValue(cfKey, cfDomain, kCFPreferencesAnyUser,kCFPreferencesCurrentHost);
	MY_LOG(@"Set oauth Result:%@",cfResult);
	if (cfResult == nil) return @"";
	NSString* tempResult = [[[NSString alloc] initWithFormat:@"%@",cfResult] autorelease];
	if (cfResult != nil)
		CFRelease(cfResult);
	return tempResult;
}


@end
//#endif
