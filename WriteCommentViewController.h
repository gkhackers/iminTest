//
//  WriteCommentViewController.h
//  ImIn
//
//  Created by choipd on 10. 5. 20..
//  Copyright 2010 edbear. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HttpConnect.h"
#import "ImInProtocol.h"

@class ReplyCellData;
@class CmtWrite;

/**
 @brief 댓글/대댓글을 쓰는 편집용 뷰컨트롤러
 */
@interface WriteCommentViewController : UIViewController <UITextViewDelegate, ImInProtocolDelegate> {
	IBOutlet UIImageView* textViewBgImage; ///< 텍스트뷰의 모서리를 둥글게 처리하기위한 배경이미지 
	IBOutlet UITextView* contentTextView; ///< 댓글/대댓글 입력 영역
	IBOutlet UILabel* textLengthRemain; ///< 입력가능한 남은 글자 수
	
	IBOutlet UILabel* titleLabel;		///< 제목 댓글쓰기 or 대댓글쓰기
	
	IBOutlet UIButton* writeBtn;		///< 글 쓰기 요청 버튼
	IBOutlet UIView* textAreaView;		///< 글 영역의 컨테이너
	
	NSMutableDictionary* poiData;		///< POI데이터

	NSString* parentId;					///< 부모 덧글의 ID
	
	UIColor* currentTextColor;			///< 남은 글자수의 색상 변경을 위한 색상값
	HttpConnect* connect;				///< http request객체
	ReplyCellData* replyCellData;		///< 댓글 대댓글 셀을 채우기 위한 데이터
    CmtWrite* cmtWrite;
}

@property (nonatomic, retain) NSMutableDictionary* poiData;
@property (nonatomic, retain) NSString* parentId;
@property (nonatomic, retain) UIColor* currentTextColor;
@property (nonatomic, retain) ReplyCellData* replyCellData;
@property (nonatomic, retain) CmtWrite* cmtWrite;

- (void) request;
- (IBAction) popViewController;
- (IBAction) doRequest;

@end
