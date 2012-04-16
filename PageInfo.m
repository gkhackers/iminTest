//
//  PageInfo.m
//  ImIn
//
//  Created by edbear on 10. 9. 12..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PageInfo.h"


@implementation PageInfo
@synthesize curPage, totalCnt, scale;

- (id) init
{
	self = [super init];
	if (self != nil) {
		curPage = 1;
		totalCnt = 1;
		scale = 25;
	}
	return self;
}


- (BOOL) next {
	if ([self isLastPage]) {
		return NO;
	} else {
		curPage++;
		return YES;
	}
}

- (BOOL) prev {
	if ([self isFirstPage]) {
		return NO;
	} else {
		curPage--;
		return YES;
	}
}

- (BOOL) isLastPage {
	return curPage == (int)ceil(totalCnt / scale);
}

- (BOOL) isFirstPage {
	return curPage == 1;
}


@end
