//
//  NSObject.m
//  iKorway
//
//  Created by SUNG WOOK MOON on 09. 10. 15..
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "NSCustomLibrary.h"

#pragma mark NSDictionary Custom Keys
#define __Key_X @"__CK_X"
#define __Key_Y @"__CK_Y"
#define __Key_Width @"__CK_Width"
#define __Key_Height @"__CK_Height"
#define __Key_Origin @"__CK_Origin"
#define __Key_Size @"__CK_Size"

@implementation  NSDictionary (NS_Custom)
+ (NSDictionary *)dictionaryWithCGPoint:(CGPoint)point {
	return [NSDictionary dictionaryWithObjectsAndKeys:
			[NSNumber numberWithFloat:point.x],__Key_X,
			[NSNumber numberWithFloat:point.y],__Key_Y,
			nil];
}
- (CGPoint)CGPointValue {
	return CGPointMake([[self objectForKey:__Key_X] floatValue], [[self objectForKey:__Key_Y] floatValue]);
}

+ (NSDictionary *)dictionaryWithCGSize:(CGSize)size {
	return [NSDictionary dictionaryWithObjectsAndKeys:
			[NSNumber numberWithFloat:size.width],__Key_Width,
			[NSNumber numberWithFloat:size.height],__Key_Height,
			nil];
}
- (CGSize)CGSizeValue {
	return CGSizeMake([[self objectForKey:__Key_Width] floatValue], [[self objectForKey:__Key_Height] floatValue]);
}

+ (NSDictionary *)dictionaryWithCGRect:(CGRect)rect {
	return [NSDictionary dictionaryWithObjectsAndKeys:
			[self dictionaryWithCGPoint:rect.origin],__Key_Origin,
			[self dictionaryWithCGSize:rect.size],__Key_Size,
			nil];

}
- (CGRect)CGRectValue {
	CGRect _r;
	_r.origin = [[self objectForKey:__Key_Origin] CGPointValue];
	_r.size = [[self objectForKey:__Key_Size] CGSizeValue];
    

	return _r;
}

#pragma mark -
#pragma mark Sample
- (void)sample {
	NSMutableArray *a = [NSMutableArray array];
	
	CGPoint p = CGPointMake(5.0, 6.0);
	NSDictionary *pointObject = [NSDictionary dictionaryWithCGPoint:p];
	[a addObject:pointObject];
	
	[a addObject:[NSDictionary dictionaryWithCGSize:CGSizeMake(50.0, 60.0)]];
	
	CGRect rect = CGRectMake(20.0, 40.0, 100.0, 60.0);
	[a addObject:[NSDictionary dictionaryWithCGRect:rect]];
	
	NSLog(@"%@",a);
	
	
	CGPoint point = [pointObject CGPointValue];
	CGSize size = [[a objectAtIndex:1] CGSizeValue];
	CGRect rect2 = [[a objectAtIndex:2] CGRectValue];
	
	NSLog(@"point: %f,%f",point.x,point.y);
	NSLog(@"size: %f,%f",size.width,size.height);
	NSLog(@"rect: %f,%f,%f,%f",rect2.origin.x,rect2.origin.y,rect2.size.width,rect2.size.height);
}
@end