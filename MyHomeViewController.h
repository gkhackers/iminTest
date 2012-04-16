//
//  MyHomeViewController.h
//  ImIn
//
//  Created by ja young park on 12. 3. 26..
//  Copyright (c) 2012년 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HomeInfo;
@class HomeInfoDetail;

@interface MyHomeViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, ImInProtocolDelegate>{
    IBOutlet UITableView *myHomeTableView;
    
    IBOutlet UILabel *postCntLabel;
    IBOutlet UILabel *followerCntLabel;
    IBOutlet UILabel *followingCntLabel;
    IBOutlet UILabel *nickNameLabel;
    IBOutlet UILabel *titleLabel;
    IBOutlet UILabel *setTitle;
    IBOutlet UIImageView *profileImg;
    IBOutlet UIImageView *setImg;
    
    IBOutlet UIImageView* arrow;
    IBOutlet UILabel* lastUpdate;
    
    BOOL isTop;
	BOOL isEnd;
    BOOL isProfileOpen;
    
    MemberInfo* owner;
    
    HomeInfo *homeInfo;
    NSDictionary* homeInfoResult;
    NSInteger friendCodeInt;
    
    HomeInfoDetail *homeInfoDetail;
    NSDictionary* homeInfoDetailResult;
}

@property (nonatomic, retain) HomeInfo *homeInfo;
@property (nonatomic, retain) MemberInfo *owner;
@property (nonatomic, retain) NSDictionary* homeInfoResult;
@property (nonatomic, retain) HomeInfoDetail *homeInfoDetail;
@property (nonatomic, retain) NSDictionary* homeInfoDetailResult;


- (IBAction)goFoots;
- (IBAction)goFollower;
- (IBAction)goFollowing;
- (IBAction)setBtn:(UIButton*) sender;
- (IBAction)foGift;
- (IBAction)goBack;

- (void) requestHomeInfo;
- (void) processHomeInfo:(NSDictionary*) result;
- (void) requestHomeInfoDetail;


@end
