/*
 // 사용법
 NSString *sourceString = @"username:password";  
 MY_LOG(@"Original string: %@", sourceString);  
 NSData *sourceData = [sourceString dataUsingEncoding:NSUTF8StringEncoding];  
 
 NSString *base64EncodedString = [sourceData base64Encoding];  
 MY_LOG([NSString stringWithFormat:@"Encoded form: %@", base64EncodedString]);  
 
 NSData *decodedData = [NSData dataWithBase64EncodedString:base64EncodedString];  
 NSString *decodedString = [[[NSString alloc] initWithData:decodedData encoding:NSUTF8StringEncoding] autorelease];  
 MY_LOG([NSString stringWithFormat:@"Decoded again: %@",decodedString]);
 */

#import <Foundation/Foundation.h>

@interface NSData (NSDataAdditions)
+ (NSData *) dataWithBase64EncodedString:(NSString *) string;
- (id) initWithBase64EncodedString:(NSString *) string;

- (NSString *) base64Encoding;
- (NSString *) base64EncodingWithLineLength:(NSUInteger) lineLength;

- (BOOL) hasPrefix:(NSData *) prefix;
- (BOOL) hasPrefixBytes:(const void *) prefix length:(NSUInteger) length;

- (BOOL) hasSuffix:(NSData *) suffix;
- (BOOL) hasSuffixBytes:(const void *) suffix length:(NSUInteger) length;
@end
