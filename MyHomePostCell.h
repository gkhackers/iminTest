//
//  MyHomePostCell.h
//  ImIn
//
//  Created by KYONGJIN SEO on 3/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 @brief 마이홈/타인홈
 */
typedef enum UserType {
    USERTYPEISMINE = 0,
    USERTYPEISOTHER
} USERTYPES;

/**
 @brief 브랜드/기타(소상공인,일반)
 */
typedef enum BrandType {
    BRANDTYPEISBRAND = 0,
    BRANDTYPEISOWNER,
    BRANDTYPEISDEFAULT
} BRANDTYPES;

/**
 @brief 뱃지/하트콘/일반
 */
typedef enum PostType {
    POSTTYPEISBADGE = 0,
    POSTTYPEISHEARTCON,
    POSTTYPEISPICTURES
} POSTTYPES;

/**
 @brief 홈에서의 발도장 cell
 */
@interface MyHomePostCell : UITableViewCell
{
    BRANDTYPES _brandType;
    USERTYPES _userType;
    POSTTYPES _postType;
    BOOL _isNeighbor;
    NSDictionary *_cellData;
    NSString *_snsId;    
    NSString *_imageUrlStr;
}
@property (nonatomic, assign) USERTYPES userType;
@property (nonatomic, retain) NSDictionary *cellData;   ///< cell data
@property (nonatomic, retain) NSString *snsId;

///< UI variables
@property (retain, nonatomic) IBOutlet UIImageView *profileImg;
@property (retain, nonatomic) IBOutlet UILabel *nickname;
@property (retain, nonatomic) IBOutlet UILabel *description;
@property (retain, nonatomic) IBOutlet UILabel *poiName;
@property (retain, nonatomic) IBOutlet UILabel *post;
@property (retain, nonatomic) IBOutlet UIImageView *lockIcon;
@property (retain, nonatomic) IBOutlet UIImageView *postImg;
@property (retain, nonatomic) IBOutlet UIButton *profileButton;
@property (retain, nonatomic) IBOutlet UIButton *postImgButton;
@property (retain, nonatomic) IBOutlet UIImageView *eventIcon;
@property (retain, nonatomic) IBOutlet UIImageView *seperator;
@property (retain, nonatomic) IBOutlet UIImageView *brandMarkImg;

- (void) redrawMyHomePostCellWithCellData: (NSDictionary*) myCellData;
- (void) drawSeperatorLine: (float) currPosition;
- (IBAction) profileClicked:(id)sender;
- (IBAction) postImageClicked:(id)sender;
+ (CGSize) requiredLabelSize:(NSDictionary*) cellData withType:(BOOL) isBadge;
+ (NSString*) getDescriptionWithDictionary:(NSDictionary*) data;
+ (NSString*) getPostWithDictionary:(NSDictionary*) data;
+ (NSString*) removeCRLFWithString:(NSString*) srcString;
@end
