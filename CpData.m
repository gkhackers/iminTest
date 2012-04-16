//
//  CpData.m
//  ImIn
//
//  Created by choipd on 10. 8. 2..
//  Copyright 2010 edbear. All rights reserved.
//

#import "CpData.h"


@implementation CpData
@synthesize cpCode, blogId, userName, isConnected, isDelivery, isCpNeighbor;

- (id) init
{
	self = [super init];
	if (self != nil) {
		self.cpCode = @"";
		self.blogId = @"";
		self.userName = @"";
		isConnected = NO;
		isDelivery = NO;
		isCpNeighbor = NO;
	}
	return self;
}

-(id) initWithDictionary:(NSDictionary*) data
{
	self = [super init];
	if (self != nil) {
		self.cpCode = [data objectForKey:@"cpCode"];
		self.blogId = [data objectForKey:@"blogId"];
		self.userName = [data objectForKey:@"userName"];
		isDelivery = [[data objectForKey:@"isDelivery"] boolValue];
		isCpNeighbor = [[data objectForKey:@"isCpNeighbor"] boolValue];
		isConnected = YES;		
	}
	return self;
}

- (void) dealloc
{
	[cpCode release];
	[blogId release];
	[userName release];
	[super dealloc];
}

-(void)clearData
{
	self.cpCode = @"";
	self.blogId = @"";
	self.userName = @"";
	isConnected = NO;
	isDelivery = NO;
	isCpNeighbor = NO;
}

@end
