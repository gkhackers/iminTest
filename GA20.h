//
//  GA20.h
//  ImIn
//
//  Created by Myungjin Choi on 11. 5. 17..
//  Copyright 2011 KTH. All rights reserved.
//	File created using Singleton XCode Template by Mugunth Kumar (http://mugunthkumar.com
//  Permission granted to do anything, commercial/non-commercial with this file apart from removing the line/URL above

#import <Foundation/Foundation.h>

#define GA3(category, action, label) [GA20 gaTrackEventWithCategory:category withAction:action withLabel:label withValue:1]
#define GA2(action, label) [GA20 gaTrackEventWithAction withAction:action withLabel:label withValue:1]
#define GA1(pageId) [GA20 gaTrackPageview:pageId]

@interface GA20 : NSObject {

}

+ (GA20*) sharedInstance;
+ (void) gaTrackEventWithCategory:(NSString*) category 
					   withAction:(NSString*) action 
						withLabel:(NSString*)label 
						withValue:(int)value;

+ (void) gaTrackPageview:(NSString*) pageId;

@end

