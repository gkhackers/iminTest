//
//  AutoCompletion.h
//  ImIn
//
//  Created by KYONGJIN SEO on 12/20/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ImInProtocol.h"

@interface AutoCompletion : ImInProtocol
{
    NSDictionary *data;
}
@property (nonatomic, retain) NSDictionary *data;
@end
