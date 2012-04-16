//
//  TScrap.h
//  ImIn
//
//  Created by edbear on 11. 09. 08..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ISModel.h"

@interface TScrap : ISModel {
	NSString* postId;
	NSDate* regDate;
}

@property (nonatomic, retain) NSString* postId;
@property (nonatomic, retain) NSDate* regDate;

@end
