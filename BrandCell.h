//
//  BrandCell.h
//  ImIn
//
//  Created by KYONGJIN SEO on 9/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 @brief 브랜드 정보 나타내는 셀
 */
@interface BrandCell : UITableViewCell {
    
    NSDictionary*   cellData;
    
    IBOutlet UILabel *brandLabel;
    IBOutlet UILabel *brandName;
    IBOutlet UIImageView *logoImage;
    IBOutlet UIImageView *arrow;
    BOOL isBrand;
    
    NSString*   snsId;
    NSString*   nickname;
}

@property (nonatomic, retain) NSDictionary* cellData;
@property (nonatomic, retain) IBOutlet UILabel *brandLabel;
@property (nonatomic, retain) IBOutlet UILabel *brandName;
@property (nonatomic, retain) IBOutlet UIImageView *logoImage;
@property (nonatomic, retain) IBOutlet UIImageView *arrow;
@property (nonatomic, retain) NSString* snsId;    
@property (nonatomic, retain) NSString* nickname;

- (void)redrawCellWithCellData: (NSDictionary*) brandCellData;
- (IBAction)clickBrandCell;
- (void)moveToBrandHome;
@end
