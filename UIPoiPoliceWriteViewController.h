//
//  UIPoiPoliceWriteViewController.h
//  ImIn
//
//  Created by mandolin on 10. 9. 7..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImInProtocol.h"

@class PoiPolice;

/**
 @brief 잘못된 지역(POI) 신고하기 기능
 */
@interface UIPoiPoliceWriteViewController : UIViewController <UITextViewDelegate, ImInProtocolDelegate>
{
	IBOutlet UIImageView* textViewBgImage;
	IBOutlet UITextView* contentTextView;
    
	PoiPolice* poiPolice;
	NSString* poiId;
	NSString* preString;
}

@property (nonatomic, retain) PoiPolice* poiPolice;
@property (nonatomic, retain) NSString* poiId;
@property (nonatomic, retain) NSString* preString;


- (IBAction) popViewController;
- (IBAction) doRequest;

@end
