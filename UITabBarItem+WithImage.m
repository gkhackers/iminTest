//
//  UITabBarItem+WithImage.m
//  ImIn
//
//  Created by choipd on 10. 4. 15..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "UITabBarItem+WithImage.h"

@interface UITabBarItem (Private)
@property(nonatomic, retain) UIImage* selectedImage;
@end


@implementation UITabBarItem (WithImage)

- (void) resetWithNormalImage:(UIImage *) normal 
				selectedImage:(UIImage *) selected 
{
	self.image = normal;
	self.selectedImage = selected;
}

@end
