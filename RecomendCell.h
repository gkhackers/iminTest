//
//  RecomendCell.h
//  ImIn
//
//  Created by 태한 김 on 10. 6. 11..
//  Copyright 2010 kth. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RecomendCellData.h"
#import "HttpConnect.h"

@class HomeInfo;
/**
 @brief 이웃추천 셀 디자인
 */
@interface RecomendCell : UITableViewCell <ImInProtocolDelegate>{
	IBOutlet UILabel* nickName;
	IBOutlet UIImageView* profileImg;
	IBOutlet UILabel *nameLabel;
	IBOutlet UILabel *latestPoiName;
	IBOutlet UIButton *setBtn;
    IBOutlet UIButton *rejectBtn;
	IBOutlet UIView* mainView;
	IBOutlet UILabel* cpNameLabel;
	IBOutlet UIImageView* cpTypeImg;
    IBOutlet UIButton *goHomeBtn;

	NSInteger cellDataListIndex;
	NSMutableArray* cellDataList;
	
	NSString* snsID;
    NSString* recomType;
	NSString* imageUrlStr;

	RecomendCellData *cellData;
	
	NSInteger cellType;
	
	HttpConnect* connect;
    HomeInfo* homeInfo;
    
    BOOL friendSet;
}

@property (nonatomic, retain) RecomendCellData *cellData;
@property (nonatomic, retain) NSMutableArray* cellDataList;
@property (readwrite) NSInteger cellDataListIndex;
@property (readwrite) NSInteger cellType;
@property (nonatomic, retain) HomeInfo* homeInfo;

- (IBAction)profileClicked:(id)sender;
- (IBAction)friendSetClicked:(id)sender;
- (IBAction)friendRejectClicked:(id)sender;

- (void) redrawMainThreadCellWithCellData: (RecomendCellData*) myCellData;
- (NSDictionary *) indexKeyedDictionaryFromArray:(NSArray *)array;

@end
