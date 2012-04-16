//
//  UIWebView+JSReform.h
//  ImIn
//
//  Created by ja young park on 11. 10. 12..
//  Copyright 2011년 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 @brief 자바스크립트 알림 처리
 */

@interface UIWebView (WebUI)

- (void)webView:(UIWebView *)sender runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(CGRect *)frame;
- (BOOL)webView:(UIWebView *)sender runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WebFrame *)frame;
@end