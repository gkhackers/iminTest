//
//  PoiDetailCheckInCell.h
//  ImIn
//
//  Created by ja young park on 11. 10. 25..
//  Copyright 2011년 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 @brief POI 상세 페이지 발도장 찍기 버튼 셀
 */
@interface PoiDetailCheckInCell : UITableViewCell {
    NSDictionary* poiData;
}

@property (nonatomic, retain) NSDictionary* poiData;

- (IBAction)checkInClick;
- (void) redrawCellWithCellData: (NSDictionary *) cellData;

@end
