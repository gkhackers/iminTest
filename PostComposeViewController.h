//
//  PostComposeViewController.h
//  ImIn
//
//  Created by KYONGJIN SEO on 1/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HttpConnect.h"
#import "Uploader.h"
#import "ImagePickerHandler.h"

@class AddLink;
@class PostWrite;
/**
 @brief 발도장찍기 편집 화면
 */
@interface PostComposeViewController : UIViewController
<UITextViewDelegate, ImagePickerFinishedDelegate, UIActionSheetDelegate, UIAlertViewDelegate, ImInProtocolDelegate, MKMapViewDelegate>
{	
	IBOutlet UIImageView* textViewBgImage;		///< 둥근 테두리 배경 이미지
	IBOutlet UITextView* contentTextView;		///< 발도장 글 내용 입력 영역
	IBOutlet UILabel* textLengthRemain;			///< 남은 글자수
	IBOutlet UIView* headerView;				///< 헤더 영역
	
    IBOutlet UILabel *placeholder;
	IBOutlet UILabel* poiName;					///< POI 명칭
	
	IBOutlet UIButton* twitterModeBtn;			///< 트위터 보내기 버튼 on
	IBOutlet UIButton* twitterModeBtnOff;		///< 트위터 보내기 버튼 off
	IBOutlet UIButton* facebookModeBtn;			///< 페북 보내기 버튼 on
	IBOutlet UIButton* facebookModeBtnOff;		///< 페북 보내기 버튼 off
	IBOutlet UIButton* me2dayModeBtn;			///< 미투데이 보내기 버튼 on
	IBOutlet UIButton* me2dayModeBtnOff;		///< 미투데이 보내기 버튼 off
	
    
	IBOutlet UIButton* shareModeBtn;			///< 공유하기 버튼 on
	IBOutlet UIButton* shareModeBtnOff;			///< 공유하기 버튼 off
	BOOL shareMode;								///< 공유 on/off
    IBOutlet UILabel *shareText;
	
	IBOutlet UIImageView* photoSelected;		///< 선택된 사진
	NSString* tmpImageURL;						///< 임시 이미지 URL 저장
	BOOL onTakingPicture;						///< 지금 찍고 있는 중인지 여부
	
	float			amountDone;					///< 전송된 량
	UIActionSheet	*uploadSheet;
	
	UIColor* currentTextColor;					///< 남은 글자수 표시할 색상
    
    IBOutlet MKMapView *mapView;
    IBOutlet UIImageView *noMapViewImgView;
    BOOL poiAlreadySelected;
    
	IBOutlet UIButton* writeBtn1;				///< 글쓰기 버튼 (상단)
	IBOutlet UIButton* writeBtn2;				///< 글쓰기 버튼 (하단)
    
    //신발 애니메이션
    IBOutlet UIView *footContainer;
    IBOutlet UIImageView *foot;
    IBOutlet UIImageView *dust1;
    IBOutlet UIImageView *dust2;

	HttpConnect* connect;
	Uploader* upload;
	BOOL isLandscape;
	
	UIImage* imageToUpload;
	
	NSString* savedText;
	
	NSDictionary* poiData;
    AddLink* addLink;
    NSArray* matchArray;
    NSString* lastContentText;
    NSInteger urlStringCnt;
    BOOL finishState;
    
    IBOutlet UIView *innerView;
    PostWrite* postWrite;
}

@property (nonatomic, retain) UIActionSheet *uploadSheet;		///< 업로드시 보여주는 액션시트
@property (nonatomic, retain) UIColor* currentTextColor;		///< 남은 글자수 표시할 색상
@property (nonatomic, retain) UIImage* imageToUpload;			///< 업로드 될 이미지
@property (nonatomic, retain) NSString* savedText;				///< 메모리 워닝 상황에서 텍스트 임시 저장용
@property (nonatomic, retain) NSDictionary* poiData;
@property (nonatomic, retain) AddLink* addLink;
@property (nonatomic, retain) NSArray* matchArray;
@property (nonatomic, retain) NSString* lastContentText;
@property (nonatomic, retain) NSString* tmpImageURL;
@property (readwrite) BOOL finishState;
@property (nonatomic, retain) PostWrite* postWrite;

- (IBAction) popViewController;
- (IBAction) openImagePicker;					///< 이미지 피커 열기
- (IBAction) prepareWritePost:(UIButton*)btn;					///< 글 쓰기 준비
- (IBAction) toggleShareMode;					///< 공유모드 설정
- (IBAction) toggleFacebook:(UIButton*) sender;	///< 페북 온오프
- (IBAction) toggleTwitter:(UIButton*) sender;	///< 트위터 온오프
- (IBAction) toggleMe2day:(UIButton*) sender;   ///< 미투데이 온오프
- (void) goTwitterSetting;					///< 트위터 세팅 가기
- (void) goFacebookSetting;					///< 페북 세팅 가기
- (void) goMe2daySetting;					///< 미투데이 세팅 가기

- (IBAction) mapViewSelected:(id)sender;

- (void) writePost;								///< 글쓰기 요청
- (void) presentUploadSheet;					///< 업로드 액션시트 띄우기
- (void) presentSelectImageSourceSheet;			///< 이미지 소스 선택 액션시트 띄우기
- (void) setViewMovedUp:(BOOL)movedUp;			///< 글 쓸 때 헤더뷰 영역만큼 위로 올리기/내리기
- (void) deleteSelectedImage;				///< 선택한 사진 삭제하기
- (void) addLinkRequest:(NSString*)OriUrlString;
-(void) textChanged:(NSNotification*)notification;
//- (void) saveCurrentText:(NSString *)text;
//- (void) getCurrentCheckInContents;
//- (void) deleteCurrentCheckInContents;
- (void) setSmallMap;
- (void) setWriteButtonEnabled:(BOOL)enabled;
- (void) setWriteButtonImageEnabled:(BOOL)enabled;
- (void) setMapPOI;
- (void) initAnimation;
@end
