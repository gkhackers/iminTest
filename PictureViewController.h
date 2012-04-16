//
//  PictureViewController.h
//  ImIn
//
//  Created by choipd on 10. 5. 25..
//  Copyright 2010 edbear. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 @brief 사진을 크게 보여주는 뷰컨트롤러
 */

@interface PictureViewController : UIViewController {
	IBOutlet UIImageView* picture; ///< 사진
	IBOutlet UIScrollView* scrollView; ///< 사진을 스크롤 시킬 수 있는 컨테이너
	NSString* pictureURL; ///< 사진의 URL
}

@property (nonatomic, retain) NSString* pictureURL;

-(IBAction) popWindow;

@end
