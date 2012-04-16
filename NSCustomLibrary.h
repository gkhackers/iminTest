//
//  NSObject.h
//  iKorway
//
//  Created by SUNG WOOK MOON on 09. 10. 15..
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSDictionary (NS_Custom)
+ (NSDictionary *)dictionaryWithCGPoint:(CGPoint)point;
- (CGPoint)CGPointValue;

+ (NSDictionary *)dictionaryWithCGSize:(CGSize)size;
- (CGSize)CGSizeValue;

+ (NSDictionary *)dictionaryWithCGRect:(CGRect)rect;
- (CGRect)CGRectValue;
@end
