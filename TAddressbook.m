//
//  TAddresbook.m
//  ImIn
//
//  Created by edbear on 10. 11. 30..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "TAddressbook.h"


@implementation TAddressbook

@synthesize name, phone, md5;

- (void)dealloc
{
	[name release];
	[phone release];
	[md5 release];
	
	[super dealloc];
}

@end
