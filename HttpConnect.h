//
//  HttpConnect.h
//  ImIn
//
//  Created by mandolin on 10. 6. 7..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface HttpConnect : NSObject {
	NSMutableData* receivedData;
	NSString* stringReply;
	NSString* stringError;
	int errorCode;
	NSString* hostStr;
	NSString* headerStr;
	BOOL isVisibleIndicator;
	
	NSURLConnection* connection;
	NSMutableData* data;
	
	NSString *serverURL;
	NSString *postStr;
	id delegate;
	SEL doneSelector;
	SEL errorSelector;
	SEL progressSelector;
	
	// TimeOut용
	NSTimer* tOut;
	
    // Retry count
    int nRetry;
}

- (id)initWithURL: (NSString *)aServerURL
		 postData: (NSString *)aPostStr
		 delegate: (id)aDelegate
	 doneSelector: (SEL)aDoneSelector
	errorSelector: (SEL)anErrorSelector
 progressSelector: (SEL)anProgressSelector;

- (id)initWithURL: (NSString *)aServerURL
		 postData: (NSString *)aPostStr
		 delegate: (id)aDelegate
	 doneSelector: (SEL)aDoneSelector
	errorSelector: (SEL)anErrorSelector
 progressSelector: (SEL)anProgressSelector
isIndicatorVisible: (BOOL) isVisible;

- (id)initWithURL: (NSString *)aServerURL
		 postData: (NSString *)aPostStr
	   headerData: (NSString *)aHeaderData
		 delegate: (id)aDelegate
	 doneSelector: (SEL)aDoneSelector
	errorSelector: (SEL)anErrorSelector
 progressSelector: (SEL)anProgressSelector
isIndicatorVisible: (BOOL) isVisible;


- (bool) connectWithHTTP:(NSString*)string withPost:(NSString*)post;
- (bool) bNetworkAvailable;
- (void)uploadSucceeded: (BOOL)success;
- (void) stop;
- (void) timeOutConnection;

@property(copy,readonly) NSString* stringReply;
@property(copy,readonly) NSString* stringError;
@property (assign) id delegate;
@property int errorCode;

@end

