//
//  ColumbusItem.h
//  ImIn
//
//  Created by 태한 김 on 10. 5. 13..
//  Copyright 2010 kth. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 @brief 콜럼버스 정보
 */
@interface ColumbusItem : NSObject {
	NSString	*poiKey;
	NSString	*poiName;
	NSInteger	point;
	NSString	*regDate;
}

@property (nonatomic, retain) NSString *poiKey;
@property (nonatomic, retain) NSString *poiName;
@property (nonatomic) NSInteger point;
@property (nonatomic, retain) NSString *regDate;

-(id) initWithName:(NSString*)name key:(NSString*)key date:(NSString*)date;

@end
