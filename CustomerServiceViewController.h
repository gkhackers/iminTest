//
//  CustomerServiceViewController.h
//  ImIn
//
//  Created by Myungjin Choi on 11. 4. 1..
//  Copyright 2011 KTH. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 @brief 고객센터
 */
@interface CustomerServiceViewController : UIViewController <UIWebViewDelegate>{
	IBOutlet UIWebView* webView;
}

- (IBAction) goBack;

@end
