//
//  SendAuthKey.h
//  ImIn
//
//  Created by edbear on 10. 12. 15..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ImInProtocol.h"
/**
 @brief 아임인 프로토콜
 */

@interface SendAuthKey : ImInProtocol {
	NSString* phoneNo;
}

@property (nonatomic, retain) NSString* phoneNo;

@end
