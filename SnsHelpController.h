//
//  SnsHelpController.h
//  ImIn
//
//  Created by mandolin on 10. 6. 17..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 @brief 아임인 도움말 보여주기
 */
@interface SnsHelpController : UIViewController {
	IBOutlet UIButton *startBtn ;
	IBOutlet UIWebView *webView ;
	IBOutlet UIButton *backBtn;
	BOOL bEnableBack;
}
@property (readwrite) BOOL bEnableBack;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil;
- (id) initWithEnableBack:(bool)enableBack;
- (IBAction)onClickStart:(id)sender;
- (IBAction)onClickPrev:(id)sender;
@end
