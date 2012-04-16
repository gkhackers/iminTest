//
//  UIMasterWriteController.h
//  ImIn
//
//  Created by mandolin on 10. 9. 10..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HttpConnect.h"

/**
 @brief 마스터 한마디 쓰기
 */
@interface UIMasterWriteController : UIViewController <UITextViewDelegate>
{
	IBOutlet UIImageView* textViewBgImage;
	IBOutlet UITextView* contentTextView;
	IBOutlet UILabel* textLengthRemain;
	IBOutlet UILabel* titleLabel;
	
	NSString* poiKey; 
	
	UIColor* currentTextColor;
	HttpConnect* connect;
	
	NSMutableString* stringWillChangeWithNewTitle;
}
@property (nonatomic, retain) NSString* poiKey;
@property (nonatomic, retain) UIColor* currentTextColor;
@property (nonatomic, retain) NSMutableString* stringWillChangeWithNewTitle;

- (void) request;
- (IBAction) popViewController;
- (IBAction) doRequest;
@end
