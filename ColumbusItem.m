//
//  ColumbusItem.m
//  ImIn
//
//  Created by 태한 김 on 10. 5. 13..
//  Copyright 2010 kth. All rights reserved.
//

#import "ColumbusItem.h"


@implementation ColumbusItem

@synthesize poiKey;
@synthesize poiName;
@synthesize point;
@synthesize regDate;


-(id) initWithName:(NSString*)name key:(NSString*)key date:(NSString*)date
{
	self = [super init];
	
	if( self != nil ) {
		self.poiName = name;
		self.poiKey = key;
		self.regDate = date;
	}
	
	return self;
}

-(void) dealloc {
	[poiName release];
	[poiKey release];
	[regDate release];
	[super dealloc];
}

@end
