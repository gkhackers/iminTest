//
//  PlazaSliderViewController.h
//  ImIn
//
//  Created by choipd on 10. 4. 21..
//  Copyright 2010 edbear. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 @brief 광장의 반경 게이지 영역
 */
@interface PlazaSliderViewController : UIViewController {
    IBOutlet UILabel *radiusLabel;
	IBOutlet UISlider *radiusSlider;
	
	BOOL pressed;
    float range;
}

@property (readwrite) float range;

- (IBAction)sliderChanged:(id)sender;
- (IBAction)sliderTouchUpInside:(id)sender;
- (IBAction)touchDown;
- (IBAction)touchUp;
@end
