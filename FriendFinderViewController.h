//
//  FriendFinderViewController.h
//  ImIn
//
//  Created by Myungjin Choi on 11. 9. 20..
//  Copyright 2011년 KTH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImInProtocol.h"

@class NeighborRecomList;

/**
 @brief 이웃 찾기
 */
@interface FriendFinderViewController : UIViewController <ImInProtocolDelegate, UITableViewDelegate, UITableViewDataSource> {
    NSMutableArray* youKnows;       // 내가 아는 친구 목록 저장
    NSMutableArray* youMayKnows;    // 내가 알수도 있는 친구 목록 저장
    NeighborRecomList* neighborRecomList;
    
    IBOutlet UITableView *mainTableView;
    IBOutlet UITableView *bottomTableView;
    IBOutlet UIView *recomSectionHeader;
    IBOutlet UILabel *recomSectionHeaderTitle;
    IBOutlet UIView *secondSectionHeaderView;
    IBOutlet UIButton *nextBtn;
    IBOutlet UILabel *titleLabel;
    
    NSInteger friendType;
    NSInteger retryCnt;
}

@property (nonatomic, retain) NSMutableArray* youKnows;
@property (nonatomic, retain) NSMutableArray* youMayKnows;
@property (nonatomic, retain) NeighborRecomList* neighborRecomList;
@property (readwrite) NSInteger friendType;

-(void) reloadVC;

@end
