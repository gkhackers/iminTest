//
//  CommonWebViewController.h
//  ImIn
//
//  Created by Myungjin Choi on 11. 4. 13..
//  Copyright 2011 KTH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WebAppGatewayProtocol.h"
@class MyPostListById;

@interface CommonWebViewController : UIViewController<UIWebViewDelegate, ImInProtocolDelegate, WebAppGatewayProtocolDelegate> {
	// 웹 view
    IBOutlet UIWebView* aWebView;
	
    // 하단 웹뷰컨트롤러 view
    IBOutlet UIView* bottomView;
	IBOutlet UIButton* backwardBtn;
	IBOutlet UIButton* forwardBtn;
	IBOutlet UIButton* refleshBtn;
	IBOutlet UIButton* closeBtn;

    // 하트콘 상단 타이틀 view
    IBOutlet UIView* heartconTitleView;
    IBOutlet UILabel* heartconTitle;
    IBOutlet UIButton* preBtn;
    IBOutlet UIButton* cancelBtn;
    
    // 일반 웹뷰 상단 타이틀 view
    IBOutlet UIView* titleView;
    IBOutlet UILabel* htmlTitle;
    IBOutlet UIButton* heartconPreBtn;
    
    // 공통 변수
	NSString* titleString;
	NSInteger viewType;
    NSString* urlString;
    NSDictionary* retDictionary;
    NSDictionary* preRetDictionary;
	
    MyPostListById* postListById;
    
    WebAppGatewayProtocol* wagw;
    
}
@property (nonatomic, retain) NSString* urlString;
@property (nonatomic, retain) NSString* titleString;
@property (readwrite) NSInteger viewType;
@property (nonatomic, retain) NSDictionary* retDictionary;
@property (nonatomic, retain) NSDictionary* preRetDictionary;
@property (nonatomic, retain) MyPostListById* postListById;

- (IBAction) closeVC;
- (IBAction) heartconPreBtnClick;
- (void) jaCallWithSchemeKey:(NSString *)retValue;

@end
