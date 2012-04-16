//
//  ViewControllers.h
//  ImIn
//
//  Created by choipd on 10. 4. 27..
//  Copyright 2010 edbear. All rights reserved.
//

#import <Foundation/Foundation.h>
/**
 @brief 탭바에 붙어 있는 루트뷰 컨트롤러들의 모음
 */

@interface ViewControllers : NSObject {
	UIViewController* plazaViewController;
	UIViewController* homeViewController;
	UIViewController* neighbersViewController;
	UIViewController* badgeViewController;
	UIViewController* feedViewController;
	UIViewController* settingViewController;

	UITabBarController* tabBarController;
}

@property (nonatomic, retain) UIViewController* plazaViewController;
@property (nonatomic, retain) UIViewController* homeViewController;
@property (nonatomic, retain) UIViewController* neighbersViewController;
@property (nonatomic, retain) UIViewController* badgeViewController;
@property (nonatomic, retain) UIViewController* feedViewController;
@property (nonatomic, retain) UIViewController* settingViewController;
@property (nonatomic, retain) UITabBarController* tabBarController;

+(ViewControllers *)sharedViewControllers;
-(void) refreshAllViewController;
- (void) refreshNeighborVC;
@end
