//
//  BadgePictureViewController.h
//  ImIn
//
//  Created by park ja young on 11. 2. 18..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 @brief 뱃지 이미지 상세 페이지 뷰 컨트롤러
 */
@interface BadgePictureViewController : UIViewController {
	IBOutlet UIImageView* pictureImageView; ///< 뱃지이미지
	NSString* pictureUrl;   ///< 이미지 URL
    NSString* postType; ///< 뱃지타입
}

@property (nonatomic, retain) IBOutlet UIImageView* pictureImageView;
@property (nonatomic, retain) NSString* pictureUrl;
@property (nonatomic, retain) NSString* postType;

- (IBAction) goPopView;
- (void) errorAlert;

@end
