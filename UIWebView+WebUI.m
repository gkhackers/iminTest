//
//  UIWebView+JSReform.m
//  ImIn
//
//  Created by ja young park on 11. 10. 12..
//  Copyright 2011년 __MyCompanyName__. All rights reserved.
//

#import "UIWebView+WebUI.h"

//// 자바스크립트 페이지 안에서 알러트가 뜰때 알러트 타이틀에 url 정보가 아닌 그냥 nil값 처리
@implementation UIWebView (WebUI)

static BOOL alertClickIndex = NO;

- (void)webView:(UIWebView *)sender runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(CGRect *)frame {
    
    [ApplicationContext stopActivity];
    
    UIAlertView *jsAlert = [[UIAlertView alloc] initWithTitle:nil message:message delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil];
    [jsAlert show];

    //알러트 확인버튼 누를때 까지 진행 안되도록 처리
    while (jsAlert.hidden == NO && jsAlert.superview != nil)
        [[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.01f]];
    
    [jsAlert release];
}

- (BOOL)webView:(UIWebView *)sender runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WebFrame *)frame {
    
    [ApplicationContext stopActivity];
    
    UIAlertView *confirm = [[UIAlertView alloc] initWithTitle:nil message:message delegate:self cancelButtonTitle:@"취소" otherButtonTitles:@"확인", nil];
    
    [confirm show];
    
    while (confirm.hidden == NO && confirm.superview != nil)
        [[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.01f]];
    
    [confirm release];
    
    return alertClickIndex;
}

- (void)alertView:(UIAlertView*)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        alertClickIndex = NO;
    } else {
        alertClickIndex = YES;
    }
}

@end