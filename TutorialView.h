//
//  TutorialView.h
//  ImIn
//
//  Created by KYONGJIN SEO on 12/20/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 @brief 데이터 없을  경우 활동을 유도하는 튜토리얼 뷰
 */
@interface TutorialView : UIView {
    
    IBOutlet UIImageView *blankImageView;   ///< 튜토리얼 마크 이미지
    IBOutlet UIButton *rememberBtn; ///< 기억하기 버튼
    IBOutlet UILabel *mainString;          ///< 큰 문구
    IBOutlet UILabel *subString;            ///< 작은 문구
    
    id delegate;    ///< For Action
    
    NSString *nickname; ///< 표시해 줄 닉네임
}
@property (retain, nonatomic) IBOutlet UIView *baseView;
@property (nonatomic, retain) id delegate;
@property (nonatomic, retain) NSString *nickname;
- (void) createTutorialView:(NSDictionary *)data;
@end
