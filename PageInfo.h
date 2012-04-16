//
//  PageInfo.h
//  ImIn
//
//  Created by edbear on 10. 9. 12..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface PageInfo : NSObject {
	NSInteger curPage;
	NSInteger totalCnt;
	NSInteger scale;
}

@property (readwrite) NSInteger curPage;
@property (readwrite) NSInteger totalCnt;
@property (readwrite) NSInteger scale;

- (BOOL) next;
- (BOOL) prev;
- (BOOL) isLastPage;
- (BOOL) isFirstPage;

@end
