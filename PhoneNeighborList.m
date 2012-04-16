//
//  PhoneNeighborList.m
//  ImIn
//
//  Created by edbear on 10. 12. 7..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PhoneNeighborList.h"


@implementation PhoneNeighborList

@synthesize phoneNo, isResetNeighbor, currPage, scale;

- (CgiStringList*) prepare {
	CgiStringList* strPostData = [super prepare];
	[strPostData setMapString:@"phoneNo" keyvalue:self.phoneNo];
	[strPostData setMapString:@"isResetNeighbor" keyvalue:self.isResetNeighbor];
	[strPostData setMapString:@"currPage" keyvalue:self.currPage];
	[strPostData setMapString:@"scale" keyvalue:self.scale];
	
	return strPostData;
}


- (void) dealloc {
	[phoneNo release];
	[isResetNeighbor release];
	[currPage release];
	[scale release];
	
	[super dealloc];
}

@end
