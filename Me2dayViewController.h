//
//  Me2dayViewController.h
//  ImIn
//
//  Created by park ja young on 11. 1. 14..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HttpConnect.h"
@class SetDelivery;

/**
 @brief 미투데이 인증
 */
@interface Me2dayViewController : UIViewController <UIWebViewDelegate, ImInProtocolDelegate> {
	UIWebView* me2WebView;
	HttpConnect* connect;
	NSString* authURL;
	NSString* me2dayToken;
	NSString* userID;
	NSString* authToken;
    SetDelivery* setDelivery;

}

- (void) locateAuthMetaInWebView: (UIWebView *) webView;
- (IBAction) setDerivery;
- (IBAction) popView;

@property(nonatomic, retain)UIWebView* me2WebView;
@property(nonatomic, retain)HttpConnect* connect;
@property(nonatomic, retain)NSString* authURL;
@property(nonatomic, retain)NSString* me2dayToken;
@property(nonatomic, retain)NSString* userID;
@property(nonatomic, retain)NSString* authToken;
@property(nonatomic, retain)SetDelivery* setDelivery;


@end
