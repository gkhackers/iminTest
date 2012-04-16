//
//  CpData.h
//  ImIn
//
//  Created by choipd on 10. 8. 2..
//  Copyright 2010 edbear. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 @brief SNS 접속 정보 담은 자료구조
 */

@interface CpData : NSObject {
	BOOL isConnected;
	NSString* cpCode;
	NSString* blogId;
	NSString* userName;
	BOOL isDelivery;		// 글 배달 여부
	BOOL isCpNeighbor;		// 친구 추천 사용 여부
}
@property (readwrite) BOOL isConnected;
@property (nonatomic, retain) NSString* cpCode;
@property (nonatomic, retain) NSString* blogId;
@property (nonatomic, retain) NSString* userName;
@property (readwrite) BOOL isDelivery;
@property (readwrite) BOOL isCpNeighbor;

-(void)clearData;
-(id) initWithDictionary:(NSDictionary*) data;
@end
