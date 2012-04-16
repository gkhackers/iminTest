//
//  PoiInfoViewController.h
//  ImIn
//
//  Created by Myungjin Choi on 11. 10. 20..
//  Copyright (c) 2011년 KTH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImInProtocol.h"

@class PoiInfoDetail;
/**
 @brief POI 상세 정보 페이지 뷰컨트롤러
 */
@interface PoiInfoViewController : UIViewController <ImInProtocolDelegate, UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate> {
    /// a NSString to hand over params
    NSString* poiKey;
    /// a main tableView
    IBOutlet UITableView *mainTableView;
    /// tableView cells
    IBOutlet UITableViewCell *cellGeneral;
    IBOutlet UITableViewCell *cellMap;
    IBOutlet UITableViewCell *cellCoverTop;
    IBOutlet UITableViewCell *cellDetail;
    IBOutlet UITableViewCell *cellCoverBottom;
    IBOutlet UITableViewCell *cellReportButton;
    
    /// outlets
    IBOutlet UIImageView *profileImageView;
    IBOutlet UIImageView *brandmarkImageView;
    IBOutlet UIImageView *categoryIconImageView;
    IBOutlet UILabel *categoryLabel;
    IBOutlet UILabel *poiNameLabel;
    IBOutlet UILabel *addressLabel;
    IBOutlet UILabel *introMsgLabel;
    IBOutlet UIImageView *mapImageView;
    IBOutlet UIButton *phoneNumberButton;
    IBOutlet UIButton *homepageButton;
    IBOutlet UILabel *promotionLabel;
    IBOutlet UIView *shopInfoView;
    IBOutlet UITextView *shopInfoTextView;
    IBOutlet MKMapView *smallMap;

    /// a dictionary of poi data source
    NSDictionary* poiInfoResult;
    
    /// a object to request current POI information
    PoiInfoDetail* poiInfoDetail;
}
@property (nonatomic, retain) NSString* poiKey;
@property (nonatomic, retain) NSDictionary* poiInfoResult;
@property (nonatomic, retain) PoiInfoDetail* poiInfoDetail;
- (IBAction)popVC:(id)sender;
- (IBAction)goReportVC:(id)sender;
- (IBAction)openHomepage:(id)sender;
- (IBAction)openPhonecall:(id)sender;
- (IBAction)openLargeMap:(id)sender;
- (IBAction)openPhoto:(id)sender;

@end
