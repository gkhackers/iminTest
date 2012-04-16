//
//  AboutViewController.h
//  ImIn
//
//  Created by choipd on 10. 7. 8..
//  Copyright 2010 edbear. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 @brief '아임IN 정보' 페이지
 */
@interface AboutViewController : UIViewController {
	IBOutlet UILabel* versionLabel;
}

- (IBAction) goMail;
- (IBAction) goCall;
- (IBAction) popViewController:(id)sender;

@end
