//
//  HttpConnect.m
//  ImIn
//
//  Created by mandolin on 10. 6. 7..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "HttpConnect.h"
#import <netdb.h>
#import <arpa/inet.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import <netinet/in.h>
#import <QuartzCore/QuartzCore.h>
#import "const.h"
#import "CgiStringList.h"
#import "Utils.h"

@implementation HttpConnect
@synthesize stringReply;
@synthesize stringError;
@synthesize errorCode;
@synthesize delegate;

- (id)initWithURL: (NSString *)aServerURL   
         postData: (NSString *)aPostStr
		 delegate: (id)aDelegate         
     doneSelector: (SEL)aDoneSelector    
    errorSelector: (SEL)anErrorSelector  
 progressSelector: (SEL)anProgressSelector 
{
	
	return [self initWithURL: aServerURL
					postData: aPostStr
					delegate: aDelegate
				doneSelector: aDoneSelector
			   errorSelector: anErrorSelector
			progressSelector: anProgressSelector
		  isIndicatorVisible: YES];
}

- (id)initWithURL: (NSString *)aServerURL
		 postData: (NSString *)aPostStr
		 delegate: (id)aDelegate
	 doneSelector: (SEL)aDoneSelector
	errorSelector: (SEL)anErrorSelector
 progressSelector: (SEL)anProgressSelector
isIndicatorVisible: (BOOL) isVisible
{
	if ((self = [self init])) {
		//ASSERT(aServerURL);
		//ASSERT(aFilePath);
		//ASSERT(aDelegate);
		//ASSERT(aDoneSelector);
		//ASSERT(anErrorSelector);
		isVisibleIndicator = isVisible;
		serverURL = [aServerURL retain];
		postStr = [aPostStr retain];
		headerStr = nil;
		//stringError=@"";
		//stringReply=@"";
		self.delegate = aDelegate;
		doneSelector = aDoneSelector;
		errorSelector = anErrorSelector;
		progressSelector = anProgressSelector;
		//[self upload];
		[self connectWithHTTP:serverURL withPost:postStr];
		
	}
	return self;
}

- (id)initWithURL: (NSString *)aServerURL
		 postData: (NSString *)aPostStr
	   headerData: (NSString *)aHeaderData
		 delegate: (id)aDelegate
	 doneSelector: (SEL)aDoneSelector
	errorSelector: (SEL)anErrorSelector
 progressSelector: (SEL)anProgressSelector
isIndicatorVisible: (BOOL) isVisible
{	
	if ((self = [self init])) {
		isVisibleIndicator = isVisible;
		serverURL = [aServerURL retain];
		postStr = [aPostStr retain];
		headerStr = [aHeaderData retain];
		//stringError=@"";
		//stringReply=@"";
		self.delegate = aDelegate;
		doneSelector = aDoneSelector;
		errorSelector = anErrorSelector;
		progressSelector = anProgressSelector;
		//[self upload];
		[self connectWithHTTP:serverURL withPost:postStr];
		
	}
	return self;
}


- (id) init {
	self = [super init];
	if (self != nil) {
		hostStr=@"";
		postStr=@"";
		stringError=nil;
		stringReply=nil;
		
		connection=nil;
		data=nil;
        nRetry = 1;
		
		self.delegate = nil;
		doneSelector = nil;
		errorSelector = nil;
		progressSelector = nil;
		
		tOut = nil;
	}
	return self;
}

- (void) dealloc {
	delegate = nil;
	doneSelector=nil;
	errorSelector=nil;
	progressSelector=nil;

    [ApplicationContext stopActivity];
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	
	if (connection != nil)
	{
		[connection cancel];
		[connection release];
		connection = nil;
	}
	
	if (data != nil)
	{
		[data release];
		data = nil;
	}
	
	if (tOut != nil)
	{
		[tOut invalidate];
		tOut = nil;
	}
	[hostStr release];
	[postStr release];
	if (headerStr != nil)
		[headerStr release];
	
	if (stringReply != nil)
	{
		[stringReply release];
		stringReply = nil;
	}
	if (stringError != nil)
	{
		[stringError release];
		stringError = nil;
	}
	[serverURL release];
	serverURL = nil;
	
	[super dealloc];
}

- (bool) connectWithHTTP:(NSString*)string withPost:(NSString*)post
{
    NSLog(@"API:%d번째시도  %@?%@", nRetry, string, post);
	[stringReply release];
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	
	if (![self bNetworkAvailable])
	{	
		stringError = [[NSString alloc] initWithFormat:NETWORK_MSG_NOCONNECTION];
		errorCode = NETWORK_ERROR_NOCONNECT;
		if (errorSelector != nil)
			[self uploadSucceeded:NO];
		return YES;
	}
	
	//NSString *post = @"key1=val1&key2=val2";
	NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
	//	MY_LOG(@"Connect To Host : %@?%@", string, post);
	NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
	
	NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] init] autorelease];
	
	
	
	//[request setTimeoutInterval:10];
	[request setURL:[NSURL URLWithString:string]];
	
	if (headerStr == nil)
	{
		headerStr = [[NSString alloc] initWithString:[Utils headerString]];
		[request setHTTPShouldHandleCookies:YES];
	} 
	if (headerStr != nil)
	{
		CgiStringList* headerCgi=[[CgiStringList alloc]init:@"&"];
		[headerCgi setCgiString:headerStr];
		for (id key in headerCgi.mTable)
		{
			NSString* keyStr = [NSString stringWithFormat:@"%@",key];
			NSString* packet = [headerCgi getValue:keyStr]; //[headerCgi.mTable objectForKey:key];
			if (packet != nil)
			{
				[request setValue:packet forHTTPHeaderField:keyStr];
			}			
		}
		[headerCgi release];
		
	}
	if ([postData length] > 0)
	{
		[request setHTTPMethod:@"POST"];
		[request setValue:postLength forHTTPHeaderField:@"Content-Length"];
		[request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
		[request setValue:@"gzip" forHTTPHeaderField:@"Accept-Encoding"];
		[request setHTTPBody:postData];
	}
	
	
	// Indicator
	if(isVisibleIndicator == YES) {
        [ApplicationContext runActivity];
	}	
	else
		[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	
    connection = [[NSURLConnection alloc]
				  initWithRequest:request delegate:self];
	if (tOut != nil)
	{
		[tOut invalidate];
		tOut = nil;
	}
	if (tOut == nil)
		tOut = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(timeOutConnection) userInfo:nil repeats:NO];
	[pool release];
	return YES;
}

- (void) timeOutConnection
{
	[self stop];
	if (nRetry >= 3)
    {
        stringError = [[NSString alloc] initWithFormat:NETWORK_MSG_TIMOUT];
        errorCode = NETWORK_ERROR_TIMEOUT;
        if (errorSelector != nil)
            [self uploadSucceeded:NO];
    }
    else
    {
        nRetry++;
        [self connectWithHTTP:serverURL withPost:postStr];
    }
    
	
}	



- (bool) bNetworkAvailable
{
	// 0.0.0.0 주소를 만든다.
    struct sockaddr_in zeroAddress;
    bzero(&zeroAddress, sizeof(zeroAddress));
    zeroAddress.sin_len = sizeof(zeroAddress);
    zeroAddress.sin_family = AF_INET;
	
    // Reachability 플래그를 설정한다.
    SCNetworkReachabilityRef defaultRouteReachability = SCNetworkReachabilityCreateWithAddress(NULL, (struct sockaddr *)&zeroAddress);
    SCNetworkReachabilityFlags flags;
	
    BOOL didRetrieveFlags = SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags);
    CFRelease(defaultRouteReachability);
	
    if (!didRetrieveFlags)
    {
        //printf("Error. Could not recover network reachability flags\n");
        //return 0;
		return NO;
    }
	
	// 플래그를 이용하여 각각의 네트워크 커넥션의 상태를 체크한다.
    BOOL isReachable = flags & kSCNetworkFlagsReachable;
    BOOL needsConnection = flags & kSCNetworkFlagsConnectionRequired;
	BOOL nonWiFi = flags & kSCNetworkReachabilityFlagsTransientConnection;
	
	return ((isReachable && !needsConnection) || nonWiFi) ? YES : NO;
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
	stringError = [[NSString alloc] initWithFormat:NETWORK_MSG_TIMOUT];
	errorCode = NETWORK_ERROR_NORMAL;
	
	[self stop];
	if (errorSelector != nil)
		[self uploadSucceeded:NO];
	
	
	
}

- (void)uploadSucceeded: (BOOL)success // IN
{
	if (self.delegate != nil)
	{
		BOOL hasDoneSelector = NO;
		BOOL hasErrorSelector = NO;
		
		@try {
			//			if( [MySuperclass instancesRespondToSelector:@selector(aMethod)] ) {
			//				// invoke the inherited method
			//				[super aMethod];
			//			}
			
			if (success) {
				hasDoneSelector = [self.delegate respondsToSelector:doneSelector];				
				
				
				if (hasDoneSelector) {
					[self.delegate performSelector:doneSelector withObject:self];
				}
			} else {
				
				hasErrorSelector = [self.delegate respondsToSelector:errorSelector];
				
				if (hasErrorSelector) {
					[self.delegate performSelector:errorSelector withObject:self];
				}
			}
		}
		@catch (NSException *exception)
		{
			MY_LOG(@"main: Caught %@: %@", [exception name], [exception reason]);
		}
	}
	
}

- (void)connection:(NSURLConnection *)theConnection
	didReceiveData:(NSData *)incrementalData {
    
	if (data==nil) {
		
		
		data = [[NSMutableData alloc] initWithCapacity:0];
    }
    [data appendData:incrementalData];
	if (tOut != nil)
    {
        [tOut invalidate];
        tOut = nil;
    }
    // 수신 시작시에도 timeout 추가 : 5초동안 데이타 다 못받으면 Fail뜨게 됨
    tOut = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(timeOutConnection) userInfo:nil repeats:NO];
    
	/* NSString* stringMiddle = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	 
	 MY_LOG(@"Socket Received Data (Middle): %@", stringMiddle);
	 [stringMiddle release];*/
}

- (void)connectionDidFinishLoading:(NSURLConnection*)theConnection {
	if (tOut != nil)
	{
		[tOut invalidate];
		tOut = nil;
	}
	
    if (connection != nil)
	{
		[connection release];
		connection = nil;
	}
	
    nRetry = 1;
    
	[stringReply release];
	stringReply = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	
	// json 문자열의 syntax를 검증한다. 
	SBJSON* jsonParser = [SBJSON new];
	[jsonParser setHumanReadable:YES];
	
	NSError *error = nil;
	[jsonParser objectWithString:stringReply error:&error];
	[jsonParser release];
	
	if (doneSelector != nil) {
		if (error == nil) { // 파싱중 에러가 발생하지 않았다면
			[self uploadSucceeded:YES];
		} else {
			// 파싱중 에러가 발생했다면
			stringError = @"데이터 해석 중 오류가 발견되었습니다. 잠시후 다시 시도해주세요.";
			MY_LOG(@"JSON Parsing Error: %@", stringReply);
#ifndef APP_STORE_FINAL
            [CommonAlert alertWithTitle:@"JSON parsing Error" message:[NSString stringWithFormat:@"JSON Parsing Error: %@", serverURL]];
#endif
			[self uploadSucceeded:NO];
		}
	}
	
    [data release];
    data=nil;
	[self stop]; 
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    if ([response respondsToSelector:@selector(statusCode)])
    {
        int statusCode = [((NSHTTPURLResponse *)response) statusCode];
		MY_LOG(@"NSHTTPURLResponse statusCode: %d: url:%@", statusCode, [[response URL] absoluteString]);
        if (statusCode >= 400)
        {
			//[connection cancel];  // stop connecting; no more delegate messages
			stringError = [[NSString alloc] initWithFormat:NETWORK_MSG_SERVERERROR];
			errorCode = NETWORK_ERROR_SERVER;
			if (tOut != nil)
			{
				[tOut invalidate];
				tOut = nil;
			}
            
            if (nRetry >= 3)
            {
                if (errorSelector != nil)
                    [self uploadSucceeded:NO];			
                [self stop];
            }
            else
            {
                [self stop];
                nRetry++;
                [self connectWithHTTP:serverURL withPost:postStr];
            }
        }
    }
}
/*- (void)start  
 {  
 if ([self isCancelled])  
 {  
 [self willChangeValueForKey:@"isFinished"];  
 finished = YES;  
 [self didChangeValueForKey:@"isFinished"];  
 }  
 else  
 {  
 [self willChangeValueForKey:@"isExecuting"];  
 executing = YES;  
 [self didChangeValueForKey:@"isExecuting"];  
 
 [connection scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];  
 [connection start];  
 }  
 }  */

#pragma mark others  



/* 
 * executing과 finished property를 종료 상태로 바꿔주기 위한 편의성 메소드 
 */  
- (void)stop  
{  
	if (tOut != nil)
	{
		[tOut invalidate];
		tOut = nil;
	}
	if (connection)
	{
		[connection cancel];
		[connection release];
		connection = nil;
	}

    [ApplicationContext stopActivity];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
}  

@end

// this is kind of a hack job to allow bad certs

@implementation NSURLRequest(NSHTTPURLRequestFix)

+ (BOOL)allowsAnyHTTPSCertificateForHost:(NSString *)host
{
	//	MY_LOG(@"AllowAnyHTTPSCertificateForHost YES");
	//ENTRY(( @"entered +allowsAnyHTTPSCertificateForHost: %@", host ));
	//might want to allow for a preference instead of assuming yes
	return YES; // Or whatever logic
}



@end
