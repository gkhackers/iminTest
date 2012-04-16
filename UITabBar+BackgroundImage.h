//
//  UITabBarController+BackgroundImage.h
//  ImIn
//
//  Created by choipd on 10. 4. 15..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 @brief 탭바 전체에 배경이미지 설정해주는 카테고리
 */

@interface UITabBar (UITabBar_BackgroundImage)
-(void)addBackgroundWithImage:(UIImage*) bgImage;
-(void)addBackgroundWithPattern: (UIImage*) patternImage;
@end
