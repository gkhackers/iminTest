//
//  AdminRecomList.m
//  ImIn
//
//  Created by Myungjin Choi on 11. 1. 18..
//  Copyright 2011 KTH. All rights reserved.
//

#import "AdminRecomList.h"


@implementation AdminRecomList

@synthesize currPage, scale;

- (CgiStringList*) prepare {
	CgiStringList* strPostData = [super prepare];
	[strPostData setMapString:@"currPage" keyvalue:currPage];
	
	return strPostData;
}

- (void) dealloc {
	[currPage release];
	[scale release];

	[super dealloc];
}


@end
