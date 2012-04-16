//
//  GoogleMapViewController.h
//  ImIn
//
//  Created by Myungjin Choi on 11. 11. 9..
//  Copyright (c) 2011년 KTH. All rights reserved.
//

#import "ImInProtocol.h"

@interface GoogleMapViewController : UIViewController <UIActionSheetDelegate, ImInProtocolDelegate, MKMapViewDelegate> {

    NSDictionary* mapInfo;
    
    IBOutlet UILabel *titleLabel;
    IBOutlet MKMapView *mapView;
    IBOutlet UIView *infoViewWithoutPhone;
    IBOutlet UIView *infoViewWithPhone;
    IBOutlet UIImageView *profileImageView;
}
@property (nonatomic, retain) NSDictionary* mapInfo;

- (IBAction)closeVC:(id)sender;
- (IBAction)phoneCall:(id)sender;
- (IBAction)reportWrongInfo:(id)sender;

@end
