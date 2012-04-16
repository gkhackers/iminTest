//
//  GA20.m
//  ImIn
//
//  Created by Myungjin Choi on 11. 5. 17..
//  Copyright 2011 KTH. All rights reserved.
//	File created using Singleton XCode Template by Mugunth Kumar (http://mugunthkumar.com
//  Permission granted to do anything, commercial/non-commercial with this file apart from removing the line/URL above

#import "GA20.h"


static GA20 *_instance;
@implementation GA20


+ (GA20 *)sharedInstance
{
    if (_instance == nil) {
        _instance = [[super allocWithZone:NULL] init];
    }
    return _instance;    
}

+ (id)allocWithZone:(NSZone *)zone
{
    return [[self sharedInstance] retain];
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

- (id)retain
{
    return self;
}

- (NSUInteger)retainCount
{
    return NSUIntegerMax;  //denotes an object that cannot be released
}

- (oneway void)release
{
    //do nothing
}

- (id)autorelease
{
    return self;
}



+ (void) gaTrackEventWithCategory:(NSString*) category 
					   withAction:(NSString*) action 
						withLabel:(NSString*)label 
						withValue:(int)value
{
	NSError *error;
	if (![[GANTracker sharedTracker] trackEvent:category
										 action:action
										  label:label
										  value:value
									  withError:&error]) {
		// Handle error here
	}	
}


+ (void) gaTrackPageview:(NSString*) pageId
{
	MY_LOG(@"GA LOG: %@", pageId);
	NSError *error;
	if (![[GANTracker sharedTracker] trackPageview:[NSString stringWithFormat:@"/%@", pageId]
										 withError:&error]) {
		// Handle error here
	}	
}


@end
