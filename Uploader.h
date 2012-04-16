//
//  Uploader.h
//  HelloWorld
//
//  Created by mandolin on 10. 3. 2..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIHTTPRequest.h"

/**
 @brief 이미지 업로더
 */
@interface Uploader : NSObject <ASIProgressDelegate>
{
	NSURL *serverURL;
	NSString *filePath;
	id delegate;
	SEL doneSelector;
	SEL errorSelector;
	BOOL uploadDidSucceed;
	NSInteger totalTransByte;
	NSInteger totalFileByte;
	
	NSDictionary* params;
	NSString* stringReply;
    NSURLConnection * theConnection;
    UIProgressView *progressVIew;   ///< 외부 progressView 객체
}

@property (nonatomic, retain) NSString* stringReply;
@property (nonatomic, retain) NSURLConnection * theConnection;

- (id)initWithURL: (NSURL *)serverURL
         filePath: (NSString *)filePath
         delegate: (id)delegate
     doneSelector: (SEL)doneSelector
    errorSelector: (SEL)errorSelector
     progressView:(UIProgressView*)progressView
	   parameters: (NSDictionary*) params;
- (NSString *)filePath;
- (NSInteger) getTransFileByte;
- (NSInteger) getTransTotalFileByte;

@end