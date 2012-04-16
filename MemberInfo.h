//
//  MemberInfo.h
//  ImIn
//
//  Created by edbear on 10. 9. 12..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 @brief 마이홈 호출을 위한 정보
 */

@interface MemberInfo : NSObject {
	NSString* snsId;
	NSString* nickname;
	NSString* profileImgUrl;
}
@property (nonatomic, retain) NSString* snsId;
@property (nonatomic, retain) NSString* nickname;
@property (nonatomic, retain) NSString* profileImgUrl;

@end
