//
//  TScrap.m
//  ImIn
//
//  Created by edbear on 11. 09. 08..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TScrap.h"


@implementation TScrap

@synthesize postId, regDate;

- (void)dealloc
{
	[postId release];
	[regDate release];
	
	[super dealloc];
}

@end
