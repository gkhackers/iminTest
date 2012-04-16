//
//  ImInProtocol.m
//  ImIn
//
//  Created by edbear on 10. 9. 9..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ImInProtocol.h"
#import "iToast.h"
@implementation ImInProtocol

@synthesize resultDictionary;
@synthesize delegate;
@synthesize params;


#define DEFAULT_PARAM_CAPACITY 20

- (id) init
{
	self = [super init];
	if (self != nil) {
		// init
		self.params = [NSMutableDictionary dictionaryWithCapacity:DEFAULT_PARAM_CAPACITY];
	}
	return self;
}

#ifdef  MOCK_PROTOCOL
- (void) initMock {
    SBJSON* jsonParser = [SBJSON new];
    [jsonParser setHumanReadable:YES];
    NSError* e = nil;
    self.resultDictionary = (NSDictionary *)[jsonParser objectWithString:[self mockJson] error:&e];
    if (e != nil) {
        MY_LOG(@"[%@] json error: %@", NSStringFromClass([self class]), e);
    }
}
#endif    

- (void) dealloc {
	self.delegate = nil;
	if (connect != nil) {
		[connect stop];
		[connect release];
		connect = nil;
	}
	[resultDictionary release];
	[params release];
	[super dealloc];
}

// 유저인증
- (CgiStringList*) prepare
{
	CgiStringList* strPostData=[[[CgiStringList alloc]init:@"&"] autorelease];
	
	[strPostData setMapString:@"svcId" keyvalue:SNS_IPHONE_SVCID];
	[strPostData setMapString:@"device" keyvalue:SNS_DEVICE_MOBILE_APP];	
	[strPostData setMapString:@"av" keyvalue:[UserContext sharedUserContext].snsID];
	[strPostData setMapString:@"at" keyvalue:@"1"];
	[strPostData setMapString:@"ver" keyvalue:[ApplicationContext sharedApplicationContext].apiVersion];
    [strPostData setMapString:@"appVer" keyvalue:[ApplicationContext appVersion]];
	
	for (id key in params) {
		if ([params objectForKey:key] == nil) {
			continue;
		}
		MY_LOG(@"%@ = %@", key, [params objectForKey:key]);
		[strPostData setMapString:key keyvalue:[params objectForKey:key]];
	}
	
	return strPostData;
}

// 접근인증
- (CgiStringList*) access
{
	CgiStringList* strPostData=[[[CgiStringList alloc]init:@"&"] autorelease];
	
	[strPostData setMapString:@"svcId" keyvalue:SNS_IPHONE_SVCID];
	[strPostData setMapString:@"device" keyvalue:SNS_DEVICE_MOBILE_APP];
	[strPostData setMapString:@"ver" keyvalue:[ApplicationContext sharedApplicationContext].apiVersion];
    [strPostData setMapString:@"appVer" keyvalue:[ApplicationContext appVersion]];
	
	for (id key in params) {
		if ([params objectForKey:key] == nil) {
			continue;
		}		
		[strPostData setMapString:key keyvalue:[params objectForKey:key]];
	}
	
	return strPostData;	
}

- (NSString*) url
{
	NSString* className = [[self class] description];
	NSString *firstLowChar = [[className substringToIndex:1] lowercaseString];
	NSString *lowerizedString = [className stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:firstLowChar];
	
#ifdef APP_STORE_FINAL	
	NSString* toReturn = [NSString stringWithFormat:@"http://snsgw.paran.com/sns-gw/api/%@.kth", lowerizedString];
#else
	NSString* toReturn = [NSString stringWithFormat:@"http://imindev.paran.com/sns-gw/api/%@.kth", lowerizedString];
#endif
	
//	MY_LOG(@"API URL: %@", toReturn);
	return toReturn;
	
}

- (void) requestWithAuth:(BOOL) auth withIndicator:(BOOL) indicator
{
#ifdef MOCK_PROTOCOL
    [self initMock];
    @try {
		if( [self.delegate respondsToSelector:@selector(apiDidLoad:)] )
		{
			[self.delegate apiDidLoad:resultDictionary];
		} else if ( [self.delegate respondsToSelector:@selector(apiDidLoadWithResult:whichObject:)] ) {
			[self.delegate apiDidLoadWithResult:resultDictionary whichObject:self];
		}
	}
	@catch (NSException *exception)
	{
		MY_LOG(@"main: Caught %@: %@", [exception name], [exception reason]);
	}
#else
	if (auth) {
		connect = [[HttpConnect alloc] initWithURL: [self url]
										  postData: [[self prepare] description]
										  delegate: self
									  doneSelector: @selector(onSuccess:)
									 errorSelector: @selector(onFail:)
								  progressSelector: nil 
								isIndicatorVisible: indicator];	
		
	} else {
		connect = [[HttpConnect alloc] initWithURL: [self url]
										  postData: [[self access] description]
										  delegate: self
									  doneSelector: @selector(onSuccess:)
									 errorSelector: @selector(onFail:)
								  progressSelector: nil 
								isIndicatorVisible: indicator];		
	}    
#endif
}

- (void) requestWithoutIndicator 
{
#ifdef MOCK_PROTOCOL
    [self initMock];
    @try {
		if( [self.delegate respondsToSelector:@selector(apiDidLoad:)] )
		{
			[self.delegate apiDidLoad:resultDictionary];
		} else if ( [self.delegate respondsToSelector:@selector(apiDidLoadWithResult:whichObject:)] ) {
			[self.delegate apiDidLoadWithResult:resultDictionary whichObject:self];
		}
	}
	@catch (NSException *exception)
	{
		MY_LOG(@"main: Caught %@: %@", [exception name], [exception reason]);
	}
#else
	connect = [[HttpConnect alloc] initWithURL: [self url]
									  postData: [[self prepare] description]
									  delegate: self
								  doneSelector: @selector(onSuccess:)
								 errorSelector: @selector(onFail:)
							  progressSelector: nil 
							isIndicatorVisible: NO];
#endif
}

- (void) request
{
#ifdef MOCK_PROTOCOL
    [self initMock];
    @try {
		if( [self.delegate respondsToSelector:@selector(apiDidLoad:)] )
		{
			[self.delegate apiDidLoad:resultDictionary];
		} else if ( [self.delegate respondsToSelector:@selector(apiDidLoadWithResult:whichObject:)] ) {
			[self.delegate apiDidLoadWithResult:resultDictionary whichObject:self];
		}
	}
	@catch (NSException *exception)
	{
		MY_LOG(@"main: Caught %@: %@", [exception name], [exception reason]);
	}
#else

	connect = [[HttpConnect alloc] initWithURL: [self url]
									  postData: [[self prepare] description]
									  delegate: self
								  doneSelector: @selector(onSuccess:)
								 errorSelector: @selector(onFail:)
							  progressSelector: nil];
#endif	
}

- (void) requestTest
{
#ifdef MOCK_PROTOCOL
    [self initMock];
    @try {
		if( [self.delegate respondsToSelector:@selector(apiDidLoad:)] )
		{
			[self.delegate apiDidLoad:resultDictionary];
		} else if ( [self.delegate respondsToSelector:@selector(apiDidLoadWithResult:whichObject:)] ) {
			[self.delegate apiDidLoadWithResult:resultDictionary whichObject:self];
		}
	}
	@catch (NSException *exception)
	{
		MY_LOG(@"main: Caught %@: %@", [exception name], [exception reason]);
	}
#else
    
	connect = [[HttpConnect alloc] initWithURL: [self url]
									  postData: [self test]
									  delegate: self
								  doneSelector: @selector(onSuccess:)
								 errorSelector: @selector(onFail:)
							  progressSelector: nil];
#endif	
}

- (NSString*) test {
    NSString* strPostData = nil;
    for (id key in params) {
		if ([params objectForKey:key] == nil) {
			continue;
		}
		MY_LOG(@"%@ = %@", key, [params objectForKey:key]);
		strPostData = [NSString stringWithFormat:@"%@=%@", key, [params objectForKey:key]];
	}
	
	return strPostData;
}

- (void) onSuccess:(HttpConnect*) con
{
//	SBJSON* jsonParser = [SBJSON new];
//	[jsonParser setHumanReadable:YES];
//	
//	self.resultDictionary = (NSDictionary *)[jsonParser objectWithString:con.stringReply error:NULL];
//	[jsonParser release];

    self.resultDictionary = [con.stringReply objectFromJSONString];

#ifdef LOG_API_RESULT
	MY_LOG(@">>%@<<", con.stringReply);
#endif
	
	if (connect != nil)
	{
		[connect stop];
		[connect release];
		connect = nil;
	}
	if (self.delegate == nil) return;
	// api에서 에러를 보내주면 찍어준다.
	if (![[resultDictionary objectForKey:@"result"] boolValue]) {
		if (!([[resultDictionary objectForKey:@"func"] isEqualToString:@"postList"] || 
			  [[resultDictionary objectForKey:@"func"] isEqualToString:@"setAuthTokenEx"] || 
              [[resultDictionary objectForKey:@"func"] isEqualToString:@"autoSearch"] ||
              [[resultDictionary objectForKey:@"func"] isEqualToString:@"registerDevice"] ||
              [[resultDictionary objectForKey:@"func"] hasPrefix:@"http://"] || //BlogAPI(서비스공지목록) func : URL로 들어옴
              [[resultDictionary objectForKey:@"func"] isEqualToString:@"feedClose"] ||
			  [[resultDictionary objectForKey:@"func"] isEqualToString:@"homeInfo"]) ) {
            UIWindow *window = [[[UIApplication sharedApplication] windows] objectAtIndex:0];
            UIView *v = (UIView *)[window viewWithTag:TAG_iTOAST];
            if (!v) {
                iToast *msg = [[iToast alloc] initWithText:[self.resultDictionary objectForKey:@"description"]];
                [msg setDuration:2000];
                [msg setGravity:iToastGravityCenter];
                [msg show];
                [msg release];
            }		
		}
	}
	//	MY_LOG(@"%@", [self.delegate description]);
	@try {
		if( [self.delegate respondsToSelector:@selector(apiDidLoad:)] )
		{
			[self.delegate apiDidLoad:self.resultDictionary];
		} else if ( [self.delegate respondsToSelector:@selector(apiDidLoadWithResult:whichObject:)] ) {
			[self.delegate apiDidLoadWithResult:self.resultDictionary whichObject:self];
		}
	}
	@catch (NSException *exception)
	{
		MY_LOG(@"main: Caught %@: %@", [exception name], [exception reason]);
	}
	
}

- (void) onFail:(HttpConnect*) con
{
	if (connect != nil) {
		[connect stop];
		[connect release];
		connect = nil;
	}
	if (self.delegate == nil) return;
	@try {
		if( [self.delegate respondsToSelector:@selector(apiFailed)] )
		{
			[self.delegate apiFailed];
		} else if ([self.delegate respondsToSelector:@selector(apiFailedWhichObject:)]) {
			[self.delegate apiFailedWhichObject:self];
		}
	}
	@catch (NSException *exception)
	{
		MY_LOG(@"main: Caught %@: %@", [exception name], [exception reason]);
	}
}

- (NSString*) mockJson {
    return @"";
}

@end
