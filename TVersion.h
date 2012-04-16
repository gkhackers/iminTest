//
//  TVersion.h
//  ImIn
//
//  Created by edbear on 10. 12. 20..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ISModel.h"

@interface TVersion : ISModel {
	NSNumber* version;
}
@property (nonatomic, retain) NSNumber* version;
@end
