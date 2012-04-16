//
//  PoiInfo.h
//  ImIn
//
//  Created by edbear on 10. 9. 14..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ImInProtocol.h"
/**
 @brief 아임인 프로토콜
 */

@interface PoiInfo : ImInProtocol {
	NSString* poiKey;
}

@property (nonatomic, retain) NSString* poiKey;

@end
