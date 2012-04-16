//
//  RankingViewController.h
//  ImIn
//
//  Created by edbear on 10. 9. 2..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CommonWebViewController;
/**
 @brief 랭킹을 보여주는 화면
 */
@interface RankingViewController : UIViewController {
	
	// UI 
	NSMutableArray* masterViews;		///< UIView 목록
	NSMutableArray* graphs;				///< 그래프를 목록
	NSMutableArray* profileImages;		///< 프로필이미지 목록
	NSMutableArray* nickNames;			///< 닉네임 레이블 목록
	NSMutableArray* points;				///< 점수 레이블 목록
	IBOutlet UILabel* mastersMessage;	///< 마스터 한마디
	IBOutlet UILabel* myStatusMessage;	///< 내가 이 곳에 발도장을 찍은 적이 있는지 여부를 나타내는 메시지
	
	IBOutlet UILabel* masterNickname;	///< 마스터의 닉네임
	IBOutlet UIButton* masterWordWriteBtn; ///< 마스터 한마디 쓰기 버튼
	
	IBOutlet UIView* contentsView;		///< 랭킹 컨텐츠 뷰 컨테이너
	IBOutlet UILabel* poiName;			///< POI이름 레이블
	
	// BO
	NSArray* masterList;				///< 마스터 목록
	NSMutableString* mastersComment;	///< 마스터 한마디
	NSString* poiNameString;			///< POI이름
	NSString* userPoint;				///< POI에서 받은 점수
	NSString* poiKey;
	BOOL isMaster;						///< 내가 마스터인지 아닌지
	NSInteger isMyStatus;				///< 내가 이곳에 다녀간 적이 있는지 없는지
	
	CommonWebViewController* commonWebVC;
}

@property (nonatomic, retain) NSArray* masterList;
@property (nonatomic, retain) NSMutableString* mastersComment;
@property (nonatomic, retain) NSString* userPoint;
@property (nonatomic, retain) NSString* poiNameString;
@property (readwrite) BOOL isMaster;
@property (readwrite) NSInteger isMyStatus;

@property (nonatomic, retain) NSMutableArray* masterViews;
@property (nonatomic, retain) NSMutableArray* graphs;
@property (nonatomic, retain) NSMutableArray* profileImages;
@property (nonatomic, retain) NSMutableArray* nickNames;
@property (nonatomic, retain) NSMutableArray* points;
@property (nonatomic, retain) CommonWebViewController* commonWebVC;
@property (nonatomic, retain) NSString* poiKey;



- (IBAction) popVC;
- (IBAction) openProfile:(UIButton*) sender;	///< 프로필 사진을 연다
- (IBAction) openMasterWord;					///< 마스터 한마디를 등록 화면을 연다

@end
