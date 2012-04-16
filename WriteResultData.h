//
//  WriteResultData.h
//  ImIn
//
//  Created by choipd on 10. 5. 13..
//  Copyright 2010 edbear. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 @brief 발도장 결과값을 저장하는 자료구조
 */

@interface WriteResultData : NSObject {

	NSString* poiName;
	NSString* poiAliasName;
	
	//뱃지
	NSArray* badgeID;
	NSArray* badgeName;
	NSArray* badgeImgURL;
	
	BOOL isCaptain;
	BOOL isNewCaptain;
	BOOL isColumbus;
	
	NSString* columbusNickname;
	NSString* columbusProfileImg;
	NSNumber* columbusTotalPoint;
	
	BOOL isPoiAliasPerm; //발도장 변경권한. 0:없음 1:있음
	NSString* poiKey;
	NSNumber* point;
	NSNumber* poiPoint;
	NSNumber* postPoint;
	NSNumber* imgPoint;
	NSNumber* evtPoint;
	NSNumber* totalPoint;
	NSString* pointDesc;
	NSString* pointDesc2;
	BOOL isDuplPoi;
	NSString* aNewPoiKey;
    NSString* wvUrl;
	
	BOOL isOpen;
}
@property (nonatomic, retain) NSString* poiName;
@property (nonatomic, retain) NSString* poiAliasName;

@property (nonatomic, retain) NSArray* badgeID;
@property (nonatomic, retain) NSArray* badgeName;
@property (nonatomic, retain) NSArray* badgeImgURL;
@property (readwrite) BOOL isCaptain;
@property (readwrite) BOOL isNewCaptain;
@property (readwrite) BOOL isColumbus;
@property (readwrite) BOOL isPoiAliasPerm;
@property (nonatomic, retain) NSString* columbusNickname;
@property (nonatomic, retain) NSString* columbusProfileImg;
@property (nonatomic, retain) NSNumber* columbusTotalPoint;
@property (nonatomic, retain) NSString* poiKey;
@property (nonatomic, retain) NSNumber* point;
@property (nonatomic, retain) NSNumber* evtPoint;
@property (nonatomic, retain) NSNumber* poiPoint;
@property (nonatomic, retain) NSNumber* postPoint;
@property (nonatomic, retain) NSNumber* imgPoint;

@property (nonatomic, retain) NSNumber* totalPoint;
@property (nonatomic, retain) NSString* pointDesc;
@property (nonatomic, retain) NSString* pointDesc2;
@property (readwrite) BOOL isDuplPoi;
@property (nonatomic, retain) NSString* aNewPoiKey;
@property (readwrite) BOOL isOpen;
@property (nonatomic, retain) NSString* wvUrl;

@end
