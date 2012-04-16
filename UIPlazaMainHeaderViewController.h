//
//  UIPlazaMainHeaderViewController.h
//
//  Created by choipd on 10. 4. 20..
//  Copyright 2010 edbear. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
/**
 @brief 광장의 헤더 영역
 */
@interface UIPlazaMainHeaderViewController : UIViewController {
	IBOutlet UILabel* poiName;
	IBOutlet UIButton* sliderToggleButton;
	BOOL bTogleSearch;
	// Notification Center (by momo)
	NSNotificationCenter *center;
}

- (IBAction) toggleMenu;
- (IBAction) toggleRadius;
- (IBAction) doPostWrite;
-(void) redrawUI;

@end
