//
//  RecomendCellData.h
//  ImIn
//
//  Created by 태한 김 on 10. 6. 11..
//  Copyright 2010 kth. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 @brief 이웃추천 셀 자료구조
 */
@interface RecomendCellData : NSObject {
	NSString	*snsId;
	NSString	*nickName;
	NSString	*profileImgURL;
	NSNumber	*columbusNum;
	NSNumber	*neighborNum;
	NSString	*latestPoiName;
	NSString	*md5phoneNumber;
	BOOL needToDelete;
	NSString* isFriend;
	NSString* recomType;
	NSString* cpName;
    NSNumber    *recomCnt;
    NSString    *cpNeighborName;
    NSString    *knownType;
    NSNumber    *scrapCnt;
    NSString    *comment;
}

@property (nonatomic, retain) NSString *snsId;
@property (nonatomic, retain) NSString *nickName;
@property (nonatomic, retain) NSString *profileImgURL;
@property (nonatomic, retain) NSNumber *columbusNum;
@property (nonatomic, retain) NSNumber *neighborNum;
@property (nonatomic, retain) NSString *latestPoiName;
@property (nonatomic, retain) NSString* md5phoneNumber;
@property (readwrite) BOOL needToDelete;
@property (nonatomic, retain) NSString* isFriend;
@property (nonatomic, retain) NSString* recomType;
@property (nonatomic, retain) NSString* cpName;

@property (nonatomic, retain) NSNumber *recomCnt;
@property (nonatomic, retain) NSString *cpNeighborName;
@property (nonatomic, retain) NSString *knownType;
@property (nonatomic, retain) NSNumber *scrapCnt;
@property (nonatomic, retain) NSString *comment;


- (id) initWithDictionary: (NSDictionary*) poiData;
- (void) updateDescription;

@end
