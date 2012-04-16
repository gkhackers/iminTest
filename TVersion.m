//
//  TVersion.m
//  ImIn
//
//  Created by edbear on 10. 12. 20..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "TVersion.h"


@implementation TVersion

@synthesize version;

- (void) dealloc {
	// custom dealloc
	[version release];
	[super dealloc];
}

@end
