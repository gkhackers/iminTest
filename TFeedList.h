//
//  TFeedList.h
//  ImIn
//
//  Created by edbear on 10. 9. 10..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ISModel.h"

@interface TFeedList : ISModel {
	NSString* feedId;
	NSString* snsId;
	NSString* msg;
	NSString* postId;
	NSString* evtId;
	NSString* poiKey;
	NSString* regDate;
	NSNumber* read;
	NSString* nickName;
	NSString* profileImageUrl;
	NSString* hasDeleted;
	NSString* badgeId;
	NSString* evtUrl;
	NSString* reserved1; // goURL로 사용하기로함. 1.3.0 버전부터
	NSString* reserved2;
	NSString* reserved3;
	NSString* reserved4;
	NSString* reserved5;
	NSString* reserved6;
	NSString* reserved7;
	NSString* reserved8;
	NSString* reserved9;
	NSString* reserved0;
}

@property (nonatomic, retain) NSString* feedId;
@property (nonatomic, retain) NSString* snsId;
@property (nonatomic, retain) NSString* msg;
@property (nonatomic, retain) NSString* postId;
@property (nonatomic, retain) NSString* evtId;
@property (nonatomic, retain) NSString* poiKey;
@property (nonatomic, retain) NSString* regDate;
@property (nonatomic, retain) NSNumber* read;
@property (nonatomic, retain) NSString* nickName;
@property (nonatomic, retain) NSString* profileImageUrl;
@property (nonatomic, retain) NSString* hasDeleted;
@property (nonatomic, retain) NSString* badgeId;
@property (nonatomic, retain) NSString* evtUrl;
@property (nonatomic, retain) NSString* reserved1;
@property (nonatomic, retain) NSString* reserved2;
@property (nonatomic, retain) NSString* reserved3;
@property (nonatomic, retain) NSString* reserved4;
@property (nonatomic, retain) NSString* reserved5;
@property (nonatomic, retain) NSString* reserved6;
@property (nonatomic, retain) NSString* reserved7;
@property (nonatomic, retain) NSString* reserved8;
@property (nonatomic, retain) NSString* reserved9;
@property (nonatomic, retain) NSString* reserved0;

@end
