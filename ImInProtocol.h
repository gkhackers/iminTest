//
//  ImInProtocol.h
//  ImIn
//
//  Created by edbear on 10. 9. 9..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
@protocol ImInProtocolDelegate <NSObject>
@optional
-(void) apiDidLoad:(NSDictionary*) result;
-(void) apiFailed;
-(void) apiDidLoadWithResult:(NSDictionary*)result whichObject:(NSObject*) theObject;
-(void) apiFailedWhichObject:(NSObject*)theObject;
@end

@protocol ImInMockProtocol <NSObject>
@required
-(NSString*) mockJson;
@end

@class HttpConnect;
@class CgiStringList;
/**
 @brief 아임인 API 프로토콜
 */
#ifdef MOCK_PROTOCOL
@interface ImInProtocol : NSObject <ImInMockProtocol> {
#else
@interface ImInProtocol : NSObject {
#endif
	id<ImInProtocolDelegate> delegate;
	NSDictionary* resultDictionary;
	HttpConnect* connect;
	NSMutableDictionary* params;
}
@property (nonatomic, retain) NSDictionary* resultDictionary;
@property (nonatomic, retain) NSMutableDictionary* params;
@property (assign) id<ImInProtocolDelegate> delegate;

- (CgiStringList*) prepare;
- (CgiStringList*) access;
- (void) request;
- (void) requestWithoutIndicator;
- (void) requestWithAuth:(BOOL) auth withIndicator:(BOOL) indicator;
- (NSString*) url;
- (void) requestTest;
- (NSString*) test;
@end
