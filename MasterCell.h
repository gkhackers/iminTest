//
//  MasterCell.h
//  ImIn
//
//  Created by ja young park on 11. 10. 25..
//  Copyright 2011년 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 @brief 마스터 셀
 */
@interface MasterCell : UITableViewCell {
    IBOutlet UIImageView* profileImg;
    IBOutlet UILabel* nickname;
    NSDictionary* masterInfo;
    NSMutableArray* masterList;
    NSDictionary* poiData;
    NSString* curPosition;
}

@property (nonatomic, retain) NSDictionary* masterInfo;
@property (nonatomic, retain) NSMutableArray* masterList;
@property (nonatomic, retain) NSDictionary* poiData;
@property (nonatomic, retain) NSString* curPosition;

- (IBAction)rankingClick;
- (void) redrawCellWithCellData: (NSDictionary *) cellData : (NSDictionary *) poiInfo ;
@end
