//
//  TAddressbook.h
//  ImIn
//
//  Created by edbear on 10. 11. 30..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ISModel.h"

@interface TAddressbook : ISModel {
	NSString* name;
	NSString* phone;
	NSString* md5;
}

@property (nonatomic, retain) NSString* name;
@property (nonatomic, retain) NSString* phone;
@property (nonatomic, retain) NSString* md5;

@end
