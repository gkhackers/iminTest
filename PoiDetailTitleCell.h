//
//  PoiDetailTitleCell.h
//  ImIn
//
//  Created by ja young park on 11. 10. 25..
//  Copyright 2011년 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 @brief POI 상세 페이지 POI 정보 셀
 */
@interface PoiDetailTitleCell : UITableViewCell {
    IBOutlet UIImageView* categoryImg;
    IBOutlet UIImageView* brandMarkImg;
    IBOutlet UILabel* poiName;
    IBOutlet UILabel* poiAddress;
    IBOutlet UIButton* brandProfileBtn;

    NSDictionary* poiData;
    NSDictionary* poiUserData;
    
    BOOL isLoadFinish;
    
}

@property(nonatomic, retain) NSDictionary* poiData;
@property(nonatomic, retain) NSDictionary* poiUserData;
@property(readwrite) BOOL isLoadFinish;

- (IBAction)brandProfileClick;

- (void) redrawCellWithCellData: (NSDictionary *) cellData : (NSDictionary*) poiUser;
@end
