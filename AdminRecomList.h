//
//  AdminRecomList.h
//  ImIn
//
//  Created by Myungjin Choi on 11. 1. 18..
//  Copyright 2011 KTH. All rights reserved.
//
//  See Also: TBD

//  ImInProtocol를 상속받은 네트워크 클래스

/**
 @brief 개설후 첫번째 이웃 추천 API
 */

#import "ImInProtocol.h"

@interface AdminRecomList : ImInProtocol {
	// data to send
	NSString* currPage;
	NSString* scale;
}

@property (nonatomic, retain) NSString* currPage;
@property (nonatomic, retain) NSString* scale;

@end
