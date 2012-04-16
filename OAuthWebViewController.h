//
//  OAuthWebViewController.h
//  ImIn
//
//  Created by park ja young on 11. 4. 12..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@class HttpConnect;
@class SetAuthTokenEx;
@class SetDelivery;

/**
 @brief OAuth 인증 웹 뷰 컨트롤러
 */
@interface OAuthWebViewController : UIViewController <UIWebViewDelegate, ImInProtocolDelegate>{

	UIWebView	*oAuthWebView;
	NSString* requestInfo;
	NSString* webViewTitle;
	NSInteger authType;
	HttpConnect* connect1;
	UIActivityIndicatorView *indicator;
	SetAuthTokenEx* setAuthTokenEx;
	
	NSString *jsRtcode;
	NSString *jsRtmsg;
    
    SetDelivery* setDelivery;
}

@property (nonatomic, retain)NSString* requestInfo;
@property (nonatomic, retain)NSString* webViewTitle;
@property (readwrite)NSInteger authType;
@property (nonatomic, retain) UIActivityIndicatorView *indicator;
@property (nonatomic, retain) NSString *jsRtcode;
@property (nonatomic, retain) NSString *jsRtmsg;
@property (nonatomic, retain) SetAuthTokenEx* setAuthTokenEx;
@property (nonatomic, retain) SetDelivery* setDelivery;

- (void) processAuth: (UIWebView *) webView;
- (void) processDelivery: (UIWebView *) webView;

- (NSString*)parsedString:(NSString*)rtMsg findString:(NSString*)findString;

@end
