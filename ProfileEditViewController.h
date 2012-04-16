//
//  ProfileEditViewController.h
//  ImIn
//
//  Created by Myungjin Choi on 11. 4. 15..
//  Copyright 2011 KTH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImInProtocol.h"
#import "RealtimeBadge.h"
@class ProfileUpdate;
@class Uploader;

/**
 @brief 프로필 편집 뷰 컨트롤러
 */
@interface ProfileEditViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate, ImInProtocolDelegate, UITextViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate, UIActionSheetDelegate, RealtimeBadgeProtocol> {
	
	IBOutlet UIScrollView* settingScrollView;
	
	IBOutlet UITextView* introduceTextView;
	IBOutlet UIImageView* textViewBgImage;
	IBOutlet UILabel* textLengthRemain;
	
	// 실명
	IBOutlet UIImageView* realnameBgImage;
	IBOutlet UITextField* realnameTextField;
	IBOutlet UIView* profileImageChangeArea;
	IBOutlet UIImageView* profileImageChangeViewBgImage;
	IBOutlet UIImageView* profileImageView;
	
	IBOutlet UIImageView* birthBgImageView;
	IBOutlet UILabel* birthdayLabel;
	IBOutlet UIView* birthdayArea;
	IBOutlet UIPickerView* birthdayPickerView;
	
	IBOutlet UISwitch* isOpenPrBirthSwith;
	
	NSDictionary* homeInfoDetailResult;

	NSString* aNewProfileImgURL;
	NSString* tmpProfileImageURL;
	
	// profile update packet
	ProfileUpdate* profileUpdate;
	
	Uploader* upload;
	UIActionSheet* baseSheet;
    
    RealtimeBadge* realtimeBadge;
}

@property (nonatomic, retain) NSDictionary* homeInfoDetailResult;
@property (nonatomic, retain) ProfileUpdate* profileUpdate;
@property (nonatomic, retain) UIActionSheet* baseSheet;
@property (nonatomic, retain) NSString* tmpProfileImageURL;

- (IBAction) popVC:(id)sender;
- (IBAction) showBirthdayPickerView;
- (IBAction) disappearBirthdayPickerView;
- (IBAction) saveBirthdayInfo;
- (IBAction) requestProfileUpdate;
- (IBAction) changeProfileImage;
- (IBAction) closeKeyboard;
@end
