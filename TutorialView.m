//
//  TutorialView.m
//  ImIn
//
//  Created by KYONGJIN SEO on 12/20/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "TutorialView.h"

enum TUTORIAL_STATUS {  ///< 튜토리얼 페이지별 타입

    FOOTPRINTS  = 0,
    REMEMBERS,
    MASTER,
    NEW,
    FRIEND_BT,
    FRIEND_NOBT,
    FOOTPRINTS_OTHER,
    REMEMBERS_OTHER,
    FRIEND_OTHER_NOBT,
    MASTER_OTHER = 9
};

@implementation TutorialView
@synthesize baseView, delegate, nickname;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void) createTutorialView:(NSDictionary *)data {

    NSUInteger status = [[data objectForKey:@"status"] intValue];
    self.nickname = [data objectForKey:@"nickname"];
    CGFloat topHeight = 0.0f;
    
    switch (status) {
        case FOOTPRINTS:
        {
            topHeight = 43.0f;
            [blankImageView setImage:[UIImage imageNamed:@"blank_img_shoes.png"]];
            [rememberBtn setAlpha:0.0f];
            mainString.text = @"발도장으로 이야기를 시작하세요!";
            subString.text = @"주변의 다양한 친구를 사귈 수 있어요~";
            CGRect frame = subString.frame;
            frame.size.height = 12.0f;
            subString.frame = frame;
        }
            break;
            
        case REMEMBERS:
        {
            topHeight = 43.0f;
            [blankImageView setImage:[UIImage imageNamed:@"blank_img_memory.png"]];
            [rememberBtn setImage:[UIImage imageNamed:@"btn_memory.png"] forState:UIControlStateDisabled];
            [rememberBtn setFrame:CGRectMake(143.0f, 113.0f, 58, 19)];
            rememberBtn.enabled = NO;
            mainString.text = @"기억하고 싶은 발도장이 있다면?";
            subString.text = @"발도장을 지금                  해보세요!";
            CGRect frame = subString.frame;
            frame.size.height = 12.0f;
            subString.frame = frame;
        }
            break;
            
        case MASTER:
        {
            topHeight = 104.0f;
            [blankImageView setImage:[UIImage imageNamed:@"blank_img_master.png"]];
            [rememberBtn setAlpha:0.0f];
            mainString.text = @"\"마스터에 도전해보세요!\"";
            subString.text = @"한 장소에 발도장을 찍어 가장 많은 \n포인트를 획득한 분이 마스터가 됩니다";
        }
            break;
            
        case NEW:
        {
            topHeight = 84.0f;  
            [blankImageView setImage:[UIImage imageNamed:@"blank_img_new.png"]];
            [rememberBtn setAlpha:0.0f];
            mainString.text = @"도착한 새소식이 없어요~";
            [subString setAlpha:0.0f];
            CGRect frame = mainString.frame;
            frame.origin.y = 91.0f;
            mainString.frame = frame;
        }
            break;
            
        case FRIEND_BT:
        {
            topHeight = 84.0f;
            [blankImageView setImage:[UIImage imageNamed:@"blank_img_friend.png"]];
            [rememberBtn setImage:[UIImage imageNamed:@"btn_find_friend.png"] forState:UIControlStateNormal];
            [rememberBtn addTarget:self action:@selector(findFriendBtnClicked) forControlEvents:UIControlEventTouchUpInside];
            [rememberBtn setFrame:CGRectMake(117.0f, 150.f, 87.0f, 34.0f)];
            mainString.text = @"지금 내 친구를 찾아보세요!";
            subString.text = @"이웃을 만들면 아임IN이 더욱 즐거워집니다.";
            CGRect frame = subString.frame;
            frame.size.height = 12.0f;
            subString.frame = frame;
        }
            break;
            
        case FRIEND_NOBT:
        {
            topHeight = 84.0f;
            [blankImageView setImage:[UIImage imageNamed:@"blank_img_friend.png"]];
            [rememberBtn setHidden:YES];
            mainString.text = @"지금 내 친구를 찾아보세요!";
            subString.text = @"이웃을 만들면 아임IN이 더욱 즐거워집니다.";
            CGRect frame = subString.frame;
            frame.size.height = 12.0f;
            subString.frame = frame;
        }
            break;
            
        case FOOTPRINTS_OTHER:
        {
            topHeight = 43.0f;
            [blankImageView setImage:[UIImage imageNamed:@"blank_img_shoes.png"]];
            [rememberBtn setAlpha:0.0f];
            mainString.text = [NSString stringWithFormat:@"아직 발도장이 없어요~", self.nickname];
            subString.text = @"첫 발도장을 기대해주세요~!";
            CGRect frame = subString.frame;
            frame.size.height = 12.0f;
            subString.frame = frame;
        }
            break;
            
        case REMEMBERS_OTHER:
        {
            topHeight = 43.0f;
            [blankImageView setImage:[UIImage imageNamed:@"blank_img_memory.png"]];
            [rememberBtn setHidden:YES];
            mainString.text = @"아직 기억한 발도장이 없어요~";
            [subString setAlpha:0.0f];
            CGRect frame = subString.frame;
            frame.size.height = 12.0f;
            subString.frame = frame;
        }
            break;
            
        case FRIEND_OTHER_NOBT:
        {
            topHeight = 84.0f;
            [blankImageView setImage:[UIImage imageNamed:@"blank_img_friend.png"]];
            [rememberBtn setHidden:YES];
            mainString.text = [NSString stringWithFormat:@"아직 이웃이 없어요~", self.nickname];
            subString.text = @"먼저 이웃이 되어 주세요~!";
            CGRect frame = subString.frame;
            frame.size.height = 12.0f;
            subString.frame = frame;
        }
            break;
            
        case MASTER_OTHER:
        {
            topHeight = 104.0f;
            [blankImageView setImage:[UIImage imageNamed:@"blank_img_master.png"]];
            [rememberBtn setAlpha:0.0f];
            mainString.text = [NSString stringWithFormat:@"아직 마스터인 곳이 없어요~", self.nickname];
            subString.text = @"";
        }
            break;
            
        default:
            break;
    }
    CGRect frame = baseView.frame;
    frame.origin.y = topHeight;
    baseView.frame = frame;
}

- (IBAction)findFriendBtnClicked {
    
    if ([delegate respondsToSelector:@selector(tutorialBtnClicked)]) {
        [delegate performSelector:@selector(tutorialBtnClicked)];
    }
}

- (void)dealloc {
    [baseView release];
    [blankImageView release];
    [rememberBtn release];
    [mainString release];
    [subString release];
    [delegate release];
    [super dealloc];
}
@end
