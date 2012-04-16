//
//  UITabBarItem+WithImage.h
//  ImIn
//
//  Created by choipd on 10. 4. 15..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 @brief 탭 바 아이템에 이미지 추가 가능하게 하는 카테고리
 */

@interface UITabBarItem (WithImage)
- (void) resetWithNormalImage:(UIImage *) normal selectedImage:(UIImage *) selected;
@end
