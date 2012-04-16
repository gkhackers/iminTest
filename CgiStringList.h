//
//  CgiStringList.h
//  testThread
//
//  Created by mandolin on 08. 07. 28.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

//#import <Cocoa/Cocoa.h>
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface CgiStringList : NSObject {
	NSMutableDictionary* mTable;
	NSString* m_strDelemeter;
	
}

- (void) setMapString : (NSString*)key keyvalue:(NSString*)value;
- (NSString*) getValue : (NSString*)key;
- (void) setCgiString : (NSString*)cgiStr;
- (NSString *) urlencode : (NSString *)orgStr;
- (NSString *) urldecode : (NSString *)encodeStr;
- (id)init : (NSString*)delemeter;
- (id)init ;

@property (nonatomic, retain) NSMutableDictionary* mTable;

@end
