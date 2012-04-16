//
//  ColumbusCell.h
//  ImIn
//
//  Created by park ja young on 11. 2. 9..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 @brief 콜럼버스 나타내는 영역
 */
@interface ColumbusCell : UITableViewCell {

	IBOutlet UIImageView* profileImage;
	IBOutlet UIImageView* columbusImg;
	IBOutlet UILabel* nickname;
	IBOutlet UILabel* writeDate;
	IBOutlet UIButton* areaBtn;
	IBOutlet UILabel* noColumbus;
	IBOutlet UILabel* preColumbusInfo;
	NSInteger columbusCnt;
	NSString* snsID;
	NSString* columbusProfileImgURL;
	BOOL isColumbus;
	
	NSDictionary* cellData;
}

@property (nonatomic, retain)IBOutlet UIImageView* profileImage;
@property (nonatomic, retain)IBOutlet UIImageView* columbusImg;
@property (nonatomic, retain)IBOutlet UILabel* nickname;
@property (nonatomic, retain)IBOutlet UILabel* writeDate;
@property (nonatomic, retain)IBOutlet UIButton* areaBtn;
@property (nonatomic, retain)IBOutlet UILabel* noColumbus;
@property (nonatomic, retain)IBOutlet UILabel* preColumbusInfo;
@property (nonatomic, retain)NSDictionary* cellData;
@property (nonatomic, retain)NSString* columbusProfileImgURL;
@property (nonatomic, retain)NSString* snsID;

- (IBAction) columbusCellClicked;
- (void) redrawColumbusCellWithCellData: (NSDictionary*) columbusCellData : (NSInteger)isRequestDone;
@end
