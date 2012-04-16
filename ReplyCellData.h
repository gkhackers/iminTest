//
//  ReplyCellData.h
//  ImIn
//
//  Created by choipd on 10. 5. 17..
//  Copyright 2010 edbear. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 @brief 댓글 셀을 채울 자료구조
 */
@interface ReplyCellData : NSObject {
	NSString* cmtID;
	NSString* parentID;
	NSString* postID;
	NSString* snsID;
	NSString* nickName;
	NSString* profileImgURL;
	NSString* comment;
	NSString* device;
	BOOL isBlind;
	BOOL isPolicePerm;
	NSString* imgURL;
	NSString* regDate;
	NSString* description;
	NSString* status;
    NSString* bizType;
    NSString* userType;
}

@property (nonatomic, retain) NSString* cmtID;
@property (nonatomic, retain) NSString* parentID;
@property (nonatomic, retain) NSString* postID;
@property (nonatomic, retain) NSString* snsID;
@property (nonatomic, retain) NSString* nickName;
@property (nonatomic, retain) NSString* profileImgURL;
@property (nonatomic, retain) NSString* comment;
@property (nonatomic, retain) NSString* device;
@property (readonly) BOOL isBlind;
@property (readonly) BOOL isPolicePerm;
@property (nonatomic, retain) NSString* imgURL;
@property (nonatomic, retain) NSString* regDate;
@property (nonatomic, retain) NSString* description;
@property (nonatomic, retain) NSString* status;
@property (nonatomic, retain) NSString* bizType;
@property (nonatomic, retain) NSString* userType;


- (id) initWithDictionary: (NSDictionary*) jsonData;
- (BOOL) isBrandUser;
@end
