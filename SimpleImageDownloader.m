//
//  SimpleAsyncImageCache.m
//  ImIn
//
//  Created by Myungjin Choi on 11. 2. 17..
//  Copyright 2011 KTH. All rights reserved.
//

#import "SimpleImageDownloader.h"


@implementation SimpleImageDownloader
@synthesize image, filename, urlString;

- (id) initWithURLString:(NSString*) aUrlString delegate:(id)aDelegate doneSelector: (SEL)aDoneSelector errorSelector: (SEL)anErrorSelector
{
	self = [super init];
	if (self != nil) {
		delegate = aDelegate;
		doneSelector = aDoneSelector;
		errorSelector = anErrorSelector;
		self.urlString = aUrlString;
		NSURL* url = [NSURL URLWithString:urlString];
		self.filename = [[urlString componentsSeparatedByString:@"/"] lastObject];
		
		if (filename != nil) {
			[self loadImageFromURL:url];			
		} else {
            MY_LOG(@"파일명이 존재하지 않음");
		}
	}
	return self;
}

- (void) dealloc
{
	[con cancel];
	[con release];
	[receivedData release];
	[image release];
	[filename release];
	[urlString release];
	
	[super dealloc];
}

- (void) loadImageFromURL:(NSURL*)url {
	
	if (con != nil) {
		[con release];
	}
	
	if (receivedData != nil) {
		[receivedData release];
	}
	
	NSURLRequest* request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
	con = [[NSURLConnection alloc] initWithRequest:request delegate:self];
	// TODO: connection이 만들어지지 않으면??
}

- (void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	if (receivedData == nil) {
		receivedData = [[NSMutableData alloc] initWithCapacity:2048];
	}
	[receivedData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    if ([response respondsToSelector:@selector(statusCode)])
    {
        int statusCode = [((NSHTTPURLResponse *)response) statusCode];
        if (statusCode >= 400)
        {
			MY_LOG(@"이미지 다운로드 실패 statusCode: %d URL:%@", statusCode, urlString);
			
			if(delegate != nil && [delegate respondsToSelector:errorSelector])
				[delegate performSelector:errorSelector withObject:urlString];
			[connection cancel];
        }
    }
}

- (void) connectionDidFinishLoading:(NSURLConnection *)connection {
	[con release];
	con = nil;
	
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *badgeFolderPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"ImInBadge"];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:badgeFolderPath])
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:badgeFolderPath
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:NULL];
    }

    [receivedData writeToFile:[badgeFolderPath stringByAppendingPathComponent:filename] atomically:YES];
		
	if(delegate != nil && [delegate respondsToSelector:doneSelector])
		[delegate performSelector:doneSelector withObject:urlString];
	
}

- (void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	// TODO: 예외처리
	MY_LOG(@"이미지 다운로드 실패");
		
	if(delegate != nil && [delegate respondsToSelector:errorSelector])
		[delegate performSelector:errorSelector withObject:urlString];
}

@end
