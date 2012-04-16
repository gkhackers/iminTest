//
//  UITabBarController+BackgroundImage.m
//  ImIn
//
//  Created by choipd on 10. 4. 15..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "UITabBar+BackgroundImage.h"


@implementation UITabBar (UITabBar_BackgroundImage)

-(void)addBackgroundWithImage:(UIImage*) bgImage {
    CGRect frame = CGRectMake(0, 0, 480, 49);
	UIImageView* imageView = [[[UIImageView alloc] initWithImage:bgImage] autorelease];
	[imageView setFrame:frame];
    [self insertSubview:imageView atIndex:0];
}

-(void)addBackgroundWithPattern: (UIImage*) patternImage {
	CGRect frame = CGRectMake(0, 0, 480, 49);
	UIView* v = [[UIView alloc] initWithFrame:frame];
	UIColor* c = [[UIColor alloc] initWithPatternImage:patternImage];
	v.backgroundColor = c;
	[c release];
	[self insertSubview:v atIndex:0];
	[v release];
}

@end
