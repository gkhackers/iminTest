//
//  AutoSearch.h
//  ImIn
//
//  Created by ja young park on 11. 12. 20..
//  Copyright 2011년 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ImInProtocol.h"

@interface AutoSearch : ImInProtocol {
    NSDictionary* data;
}

@property (nonatomic, retain) NSDictionary* data;

@end
