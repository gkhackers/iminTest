//
//  Uploader.m
//  HelloWorld
//
//  Created by mandolin on 10. 3. 2..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//
#import "Uploader.h"
#import "zlib.h"
#import "ASIFormDataRequest.h"

static NSString * const BOUNDRY = @"0xKhTmLbOuNdArY";
static NSString * const FORM_FLE_INPUT = @"imgFile";
static const NSString* CONTENT_TYPE = @"image/jpeg";

#define ASSERT(x) NSAsert(x, @"")
#define Log(x,y)

/**
 @class Uploader
 @brief ASIHTTPRequest 코드 추가
 @brief 기존 메소드 삭제 미정
 */

@interface Uploader (Private)

- (void)upload;
- (NSURLRequest *)postRequestWithURL: (NSURL *)url
                             boundry: (NSString *)boundry
                                data: (NSData *)data;
- (NSData *)compress: (NSData *)data;
- (void)uploadSucceeded: (BOOL)success;
- (void)connectionDidFinishLoading:(NSURLConnection *)connection;

@end


@implementation Uploader

@synthesize stringReply, theConnection;


/**
 *-----------------------------------------------------------------------------
 *
 * -[Uploader initWithURL:filePath:delegate:doneSelector:errorSelector:progressView:parameters:] --
 *
 *  Initializer. Kicks off the upload. Note that upload will happen on a
 *      separate thread.
 *
 * Results:
 *      An instance of Uploader.
 *
 * Side effects:
 *      None
 *
 *-----------------------------------------------------------------------------
 */

- (id)initWithURL: (NSURL *)aServerURL   // IN
         filePath: (NSString *)aFilePath // IN
         delegate: (id)aDelegate         // IN
     doneSelector: (SEL)aDoneSelector    // IN
    errorSelector: (SEL)anErrorSelector  // IN
     progressView:(UIProgressView*)aProgressView 
	   parameters: (NSDictionary*) aParams // IN
{
	if ((self = [super init])) {
		//ASSERT(aServerURL);
		//ASSERT(aFilePath);
		//ASSERT(aDelegate);
		//ASSERT(aDoneSelector);
		//ASSERT(anErrorSelector);
		
		serverURL = [aServerURL retain];
		filePath = [aFilePath retain];
		delegate = [aDelegate retain];
		doneSelector = aDoneSelector;
		errorSelector = anErrorSelector;
		params = aParams;
        progressVIew = aProgressView;
		[self upload];
    }
	return self;
}


/*
 *-----------------------------------------------------------------------------
 *
 * -[Uploader dealloc] --
 *
 *      Destructor.
 *
 * Results:
 *      None
 *
 * Side effects:
 *      None
 *
 *-----------------------------------------------------------------------------
 */

- (void)dealloc
{
	[serverURL release];
	serverURL = nil;
	[filePath release];
	filePath = nil;
	[delegate release];
	delegate = nil;
	doneSelector = NULL;
	errorSelector = NULL;
	[stringReply release];
	stringReply = nil;
    [theConnection release];
    
	[super dealloc];
}


/*
 *-----------------------------------------------------------------------------
 *
 * -[Uploader filePath] --
 *
 *      Gets the path of the file this object is uploading.
 *
 * Results:
 *      Path to the upload file.
 *
 * Side effects:
 *      None
 *
 *-----------------------------------------------------------------------------
 */

- (NSString *)filePath
{
	return filePath;
}

- (NSInteger) getTransFileByte
{ 
	return totalTransByte;
}

- (NSInteger) getTransTotalFileByte
{
	return totalFileByte;
}

@end // Uploader


@implementation Uploader (Private)


/*
 *-----------------------------------------------------------------------------
 *
 * -[Uploader(Private) upload] --
 *
 *      Uploads the given file. The file is compressed before beign uploaded.
 *      The data is uploaded using an HTTP POST command.
 *
 * Results:
 *      None
 *
 * Side effects:
 *      None
 *
 *-----------------------------------------------------------------------------
 */

//- (void)upload
//{
//	NSData *data = [NSData dataWithContentsOfFile:filePath];
//	//ASSERT(data);
//	if (!data) {
//		[self uploadSucceeded:NO];
//		return;
//	}
//	if ([data length] == 0) {
//		MY_LOG(@"NoData~~~~");
//		[self uploadSucceeded:YES];
//		return;
//	}
//	
//	NSURLRequest *urlRequest = [self postRequestWithURL:serverURL
//												boundry:BOUNDRY
//												   data:data];
//	/*NSData *compressedData = [self compress:data];
//	//ASSERT(compressedData && [compressedData length] != 0);
//	if (!compressedData || [compressedData length] == 0) {
//		[self uploadSucceeded:NO];
//		return;
//	}
//	
//	NSURLRequest *urlRequest = [self postRequestWithURL:serverURL
//												boundry:BOUNDRY
//												   data:compressedData];
//	*/ 
//	if (!urlRequest) {
//		MY_LOG(@"Request Failed!!");
//		[self uploadSucceeded:NO];
//		return;
//	}
//	
//    self.theConnection =
//	[[[NSURLConnection alloc] initWithRequest:urlRequest delegate:self] autorelease];
//	if (!theConnection) {
//		[self uploadSucceeded:NO];
//	}
//	
//	// Now wait for the URL connection to call us back.
//}

- (void)upload
{
	NSData *data = [NSData dataWithContentsOfFile:filePath];
	//ASSERT(data);
	if (!data) {
		[self performSelector:errorSelector];
		return;
	}
	if ([data length] == 0) {
		MY_LOG(@"NoData~~~~");
		[self performSelector:doneSelector];
		return;
	}
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:serverURL];
    [request setRequestMethod:@"POST"];
	[request setPostFormat:ASIMultipartFormDataPostFormat];
    [request setDelegate:delegate];
    if (params) {
        for (NSString *key in [params keyEnumerator]) {
            [request setPostValue:[params objectForKey:key] forKey:key];
        }
    }
    [request setData:data withFileName:@"fileToUpload.jpg" andContentType:@"image/jpeg" forKey:FORM_FLE_INPUT];
    [request setDidFinishSelector:doneSelector];
    [request setDidFailSelector:errorSelector];
    [request setTimeOutSeconds:10];
    [request setNumberOfTimesToRetryOnTimeout:3];
    [request setUploadProgressDelegate:progressVIew];
    [request startAsynchronous];
}

/*
 *-----------------------------------------------------------------------------
 *
 * -[Uploader(Private) postRequestWithURL:boundry:data:] --
 *
 *      Creates a HTML POST request.
 *
 * Results:
 *      The HTML POST request.
 *
 * Side effects:
 *      None
 *
 *-----------------------------------------------------------------------------
 */

- (NSURLRequest *)postRequestWithURL: (NSURL *)url        // IN
                             boundry: (NSString *)boundry // IN
                                data: (NSData *)data      // IN
{
	// from http://www.cocoadev.com/index.pl?HTTPFileUpload
	NSMutableURLRequest *urlRequest =
	[NSMutableURLRequest requestWithURL:url];
	[urlRequest setHTTPMethod:@"POST"];
	[urlRequest setValue:
	 [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundry]
      forHTTPHeaderField:@"Content-Type"];
	
	NSMutableData *postData =
	[NSMutableData dataWithCapacity:[data length] + 512];
	
	
	for(id key in params) {
		MY_LOG(@"key: %@, value: %@", key, [params objectForKey:key]);
        
		[postData appendData:
		 [[NSString stringWithFormat:@"--%@\r\n", boundry] dataUsingEncoding:NSUTF8StringEncoding]];
		
		[postData appendData:
		 [[NSString stringWithFormat:
		   @"Content-Disposition: form-data; name=\"%@\"; \r\n\r\n%@\r\n", key, [params objectForKey:key]]
		  dataUsingEncoding:NSUTF8StringEncoding]];
		
	}
	
	[postData appendData:
	 [[NSString stringWithFormat:@"--%@\r\n", boundry] dataUsingEncoding:NSUTF8StringEncoding]];
    
	[postData appendData:
	 [[NSString stringWithFormat:
	   @"Content-Disposition: form-data; name=\"%@\"; filename=\"fileToUpload.jpg\"\r\nContent-Type: %@\r\n\r\n", FORM_FLE_INPUT, CONTENT_TYPE]
	  dataUsingEncoding:NSUTF8StringEncoding]];
	[postData appendData:data];
	[postData appendData:
	 [[NSString stringWithFormat:@"\r\n--%@--\r\n", boundry] dataUsingEncoding:NSUTF8StringEncoding]];
    
	[urlRequest setHTTPBody:postData];
	return urlRequest;
}

/*
 *-----------------------------------------------------------------------------
 *
 * -[Uploader(Private) compress:] --
 *
 *      Uses zlib to compress the given data.
 *
 * Results:
 *      The compressed data as a NSData object.
 *
 * Side effects:
 *      None
 *
 *-----------------------------------------------------------------------------
 */

- (NSData *)compress: (NSData *)data // IN
{
	if (!data || [data length] == 0)
		return nil;
	
	// zlib compress doc says destSize must be 1% + 12 bytes greater than source.
	uLong destSize = [data length] * 1.001 + 12;
	NSMutableData *destData = [NSMutableData dataWithLength:destSize];
	
	int error = compress([destData mutableBytes],
						 &destSize,
						 [data bytes],
						 [data length]);
	if (error != Z_OK) {
		//MY_LOG(@"%s: self:0x%p, zlib error on compress:%d\n",
        //	__func__, self, error));
		return nil;
	}
	
	[destData setLength:destSize];
	return destData;
}


/*
 *-----------------------------------------------------------------------------
 *
 * -[Uploader(Private) uploadSucceeded:] --
 *
 *      Used to notify the delegate that the upload did or did not succeed.
 *
 * Results:
 *      None
 *
 * Side effects:
 *      None
 *
 *-----------------------------------------------------------------------------
 */

- (void)uploadSucceeded: (BOOL)success // IN
{
	[delegate performSelector:success ? doneSelector : errorSelector
				   withObject:self];
}


/*
 *-----------------------------------------------------------------------------
 *
 * -[Uploader(Private) connectionDidFinishLoading:] --
 *
 *      Called when the upload is complete. We judge the success of the upload
 *      based on the reply we get from the server.
 *
 * Results:
 *      None
 *
 * Side effects:
 *      None
 *
 *-----------------------------------------------------------------------------
 */

- (void)connectionDidFinishLoading:(NSURLConnection *)connection // IN
{
	MY_LOG(@"Connection Finish");
	//LOG(6, ("%s: self:0x%p\n", __func__, self));
	[self uploadSucceeded:uploadDidSucceed];
}


/*
 *-----------------------------------------------------------------------------
 *
 * -[Uploader(Private) connection:didFailWithError:] --
 *
 *      Called when the upload failed (probably due to a lack of network
 *      connection).
 *
 * Results:
 *      None
 *
 * Side effects:
 *      None
 *
 *-----------------------------------------------------------------------------
 */

- (void)connection:(NSURLConnection *)connection // IN
  didFailWithError:(NSError *)error              // IN
{
	MY_LOG(@"ConnectionError:%@",[error description]);
	//LOG(1, ("%s: self:0x%p, connection error:%s\n",
	//		__func__, self, [[error description] UTF8String]));
	[self uploadSucceeded:NO];
}


/*
 *-----------------------------------------------------------------------------
 *
 * -[Uploader(Private) connection:didReceiveResponse:] --
 *
 *      Called as we get responses from the server.
 *
 * Results:
 *      None
 *
 * Side effects:
 *      None
 *
 *-----------------------------------------------------------------------------
 */

-(void)       connection:(NSURLConnection *)connection // IN
      didReceiveResponse:(NSURLResponse *)response     // IN
{
	MY_LOG(@"ReceiveResponse:%@",[response description]);
	//LOG(6, ("%s: self:0x%p\n", __func__, self));
}


/*
 *-----------------------------------------------------------------------------
 *
 * -[Uploader(Private) connection:didReceiveData:] --
 *
 *      Called when we have data from the server. We expect the server to reply
 *      with a "YES" if the upload succeeded or "NO" if it did not.
 *
 * Results:
 *      None
 *
 * Side effects:
 *      None
 *
 *-----------------------------------------------------------------------------
 */

- (void)connection:(NSURLConnection *)connection // IN
    didReceiveData:(NSData *)data                // IN
{
	//LOG(10, ("%s: self:0x%p\n", __func__, self));
	
	stringReply = [[NSString alloc] initWithData:data
                                        encoding:NSUTF8StringEncoding];
	
	//LOG(10, ("%s: data: %s\n", __func__, [stringReply UTF8String]));
	
	MY_LOG(@"ReplyReceive:%@",stringReply);
	if ([stringReply rangeOfString: @"true"].location != NSNotFound) {
		uploadDidSucceed = YES;
	}
}

/*
 *-----------------------------------------------------------------------------
 *
 * -[Uploader(Private) connection:didSendBodyData:totalBytesWritten:totalBytesExpectedToWrite:] --
 *
 *
 * Results:
 *      None
 *
 * Side effects:
 *      None
 *
 *-----------------------------------------------------------------------------
 */

- (void)connection:(NSURLConnection *)connection 
   didSendBodyData:(NSInteger)bytesWritten
 totalBytesWritten:(NSInteger)totalBytesWritten
totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite
{
	NSString* logFileTrans = [[NSString alloc] initWithFormat:@"===Transfer : %d/%d", totalBytesWritten,totalBytesExpectedToWrite];
	MY_LOG(@"%@",logFileTrans);
	[logFileTrans release];
	totalTransByte = totalBytesWritten;
	totalFileByte = totalBytesExpectedToWrite;
}

@end
