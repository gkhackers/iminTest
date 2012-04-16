//
//  AgreementSns.h
//  ImIn
//
//  Created by mandolin on 10. 6. 13..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 @brief 아임IN 가입 동의 처리
 */

@interface AgreementSns : UIViewController {
	IBOutlet UIButton *customBackBtn ;
	IBOutlet UIWebView *webView;
    IBOutlet UILabel *titleLabel;
    NSString* urlString;
    NSString* agreementTitle;
}

@property (nonatomic, retain) NSString* urlString;
@property (nonatomic, retain) NSString* agreementTitle;
@property (nonatomic, retain) IBOutlet UIWebView *webView;

- (IBAction)onClickNavigationBarBackBtn:(id)sender ;
@end
