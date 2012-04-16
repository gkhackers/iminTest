//
//  HomeInfo.h
//  ImIn
//
//  Created by edbear on 10. 9. 10..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ImInProtocol.h"

/**
 @brief 아임인 프로토콜
 */

@interface HomeInfo : ImInProtocol {
	NSString* snsId;
}
@property (nonatomic, retain) NSString* snsId;

@end
