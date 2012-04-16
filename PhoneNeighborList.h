//
//  PhoneNeighborList.h
//  ImIn
//
//  Created by edbear on 10. 12. 7..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ImInProtocol.h"
/**
 @brief 아임인 프로토콜
 */

@interface PhoneNeighborList : ImInProtocol {
	NSString* phoneNo;
	NSString* isResetNeighbor;
	NSString* currPage;
	NSString* scale;
}

@property (nonatomic, retain) NSString* phoneNo;
@property (nonatomic, retain) NSString* isResetNeighbor;
@property (nonatomic, retain) NSString* currPage;
@property (nonatomic, retain) NSString* scale;


@end
