//
//  SimpleAsyncImageCache.h
//  ImIn
//
//  Created by Myungjin Choi on 11. 2. 17..
//  Copyright 2011 KTH. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 @brief 뱃지 획득 등 이미지 보여줄 때 다운로드
 */
@interface SimpleImageDownloader : NSObject {
	NSURLConnection* con;
	NSMutableData* receivedData;
	UIImage* image;
	NSString* filename;
	NSString* urlString;
	
	id delegate;
	SEL doneSelector;
	SEL errorSelector;
}
@property (nonatomic, retain) UIImage* image;
@property (nonatomic, retain) NSString* filename;
@property (nonatomic, retain) NSString* urlString;

- (id) initWithURLString:(NSString*) aUrlString delegate:(id)aDelegate doneSelector: (SEL)aDoneSelector errorSelector: (SEL)anErrorSelector;
- (void) loadImageFromURL:(NSURL*)url;

@end
