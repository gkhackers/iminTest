//
//  EventCell.h
//  ImIn
//
//  Created by ja young park on 11. 9. 29..
//  Copyright 2011년 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 @brief 이벤트 내용 보여주는 최상단 테이블 뷰 셀
 */
@interface EventCell : UITableViewCell {
    IBOutlet UILabel *eventString;
    IBOutlet UIImageView *eventNumBg;
    IBOutlet UILabel *eventNum;
    IBOutlet UIImageView *eventBg;
    IBOutlet UIImageView *seperator;
    IBOutlet UIImageView *eventIcon;
}

- (void) redrawEventCellWithCellData: (NSDictionary*) eventCellData : (NSInteger)totalEventCnt;
- (void) redrawEventCellWithCellData: (NSDictionary*) eventCellData;
@end
