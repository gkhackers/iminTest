//
//  POIListCell.h
//  ImIn
//
//  Created by choipd on 10. 5. 3..
//  Copyright 2010 edbear. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 @brief 발도장 검색 테이블뷰의 셀
 */
@interface POIListCell : UITableViewCell {
	IBOutlet UILabel* poiName;
	IBOutlet UILabel* captainPoiName;
	IBOutlet UILabel* description;
	IBOutlet UIImageView* eventIcon;
    IBOutlet UIImageView* footIcon;
    IBOutlet UILabel* addr;
    IBOutlet UILabel* poiCnt;
    IBOutlet UIButton* goBtn;
    NSDictionary* poiData;
    
    UIImageView* categoryIcon;
    NSInteger currSelectedTabInt;
    NSInteger currPostWriteFlow;
    id vcDelegate;
//    BOOL isPoiList;
}

@property (nonatomic, retain) IBOutlet UIImageView* categoryIcon;
@property (nonatomic, retain) NSDictionary* poiData;
@property (readwrite) NSInteger	currSelectedTabInt;
@property (nonatomic, assign) id vcDelegate;
@property (readwrite) NSInteger currPostWriteFlow;

//@property (readwrite) BOOL isPoiList;
- (void) populateCellWithData:(NSDictionary*) aData;
- (IBAction)poiGoHome:(id)sender;


@end
