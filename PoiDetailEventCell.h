//
//  PoiDetailEventCell.h
//  ImIn
//
//  Created by ja young park on 11. 10. 25..
//  Copyright 2011년 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 @brief POI 상세 페이지 이벤트 셀
 */
@interface PoiDetailEventCell : UITableViewCell{
    IBOutlet UILabel* eventLabel;
    IBOutlet UIImageView* eventBg;
}

- (void) redrawCellWithCellData: (NSDictionary *) cellData;

@end

