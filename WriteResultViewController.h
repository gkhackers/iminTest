//
//  WriteResult.h
//  ImIn
//
//  Created by choipd on 10. 5. 13..
//  Copyright 2010 edbear. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WebAppGatewayProtocol.h"
#import "RealtimeBadge.h"

/**
 @brief 발도장 결과 뷰 컨트롤러
 */

@interface WriteResultViewController : UIViewController <UIWebViewDelegate, WebAppGatewayProtocolDelegate, RealtimeBadgeProtocol> {

    NSDictionary* resultData;
    
//    NSUInteger downloadCompleted;
//	NSUInteger totalDownloads;
//	NSUInteger downloadFailed;
    
    RealtimeBadge* realtimeBadge;
    
    WebAppGatewayProtocol* wagw;
    IBOutlet UIWebView* aWebView;
    
    IBOutlet UILabel* titleLabel;
    IBOutlet UIButton* leftBtn;
    
    NSString* left_jscall;
    NSString* urlString;
    
}

@property (nonatomic, retain) NSDictionary* resultData;
@property (nonatomic, retain) NSString* left_jscall;
@property (nonatomic, retain) NSString* urlString;

- (IBAction) leftBtnClick;
- (IBAction) closeVC;

@end
