//
//  MyHomeProfileCell.h
//  ImIn
//
//  Created by oh-sang Kwon, on 12. 3. 28..
//  Copyright (c) 2012년 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyHomeProfileCell : UITableViewCell
{
    IBOutlet UILabel *profileLable;
    IBOutlet UILabel *userInfoLable;
    IBOutlet UILabel *neighborInfoLable;
    
	IBOutlet UILabel *giftCountLabel;
	IBOutlet UILabel *couponCountLabel;
	IBOutlet UILabel *rememberCountLabel;
	IBOutlet UILabel *masterCountLabel;
	IBOutlet UILabel *columbusCountLabel;
	IBOutlet UILabel *badgeCountLabel;
    
    IBOutlet UIButton *giftButton;
    IBOutlet UIButton *couponButton;
    
    IBOutlet UIButton *rememberButton;
    IBOutlet UIButton *masterButton;
    IBOutlet UIButton *columbusButton;
    IBOutlet UIButton *badgeButton;
    
    IBOutlet UIButton *facebookButton;
    IBOutlet UIButton *twitterButton;
    IBOutlet UIButton *me2dayButton;
    
    IBOutlet UIButton *topButton;
    
	NSInteger giftCount;
	NSInteger couponCount;
	NSInteger rememberCount;
	NSInteger masterCount;
	NSInteger columbusCount;
	NSInteger badgeCount;
}

- (IBAction)fold:(id)sender;

@end
