//
//  MyHomeViewController.m
//  ImIn
//
//  Created by ja young park on 12. 3. 26..
//  Copyright (c) 2012년 __MyCompanyName__. All rights reserved.
//

#import "MyHomeViewController.h"
#import "UITabBarItem+WithImage.h"
#import "UIImageView+WebCache.h"
#import "ProfileEditViewController.h"
#import "iToast.h"
#import "MyHomeNeighborViewController.h"
#import "LatestCheckinViewController.h"

#import "HomeInfo.h"
#import "HomeInfoDetail.h"
#import "MyHomeProfileCell.h"

@interface MyHomeViewController()
//profile
- (UITableViewCell*) createProfileCell:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)profileFold;
@end

@implementation MyHomeViewController

@synthesize owner;
@synthesize homeInfo;
@synthesize homeInfoResult;
@synthesize homeInfoDetail;
@synthesize homeInfoDetailResult;

#define PROFILEEDIT_TEXT_FRAME CGRectMake(255, 36, 53, 28)
#define FRI_TEXT_FRAME CGRectMake(255, 48, 53, 14)

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
		self.title = @"마이홈";
		[self.tabBarItem resetWithNormalImage:[UIImage imageNamed:@"GNB_03_off.png"] 
								selectedImage:[UIImage imageNamed:@"GNB_03_on.png"]];
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)dealloc {
    [owner release];
	[homeInfo release];
    [homeInfoResult release];
    [homeInfoDetail release];
    [homeInfoDetailResult release];
    
    [super dealloc];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	[self.navigationController setNavigationBarHidden:YES animated:NO];
    [myHomeTableView setSeparatorColor:RGB(216, 216, 216)];
    if (owner == nil) { 
		// 나의 홈 정보 초기화
		self.owner = [[[MemberInfo alloc] init] autorelease];
		owner.snsId = [UserContext sharedUserContext].snsID;
		owner.profileImgUrl = [UserContext sharedUserContext].userProfile;
		owner.nickname = [UserContext sharedUserContext].nickName;
	}
    
    // 본인의프로필변경에대한노티받을수있도록등록
    if ([owner.snsId isEqualToString:[UserContext sharedUserContext].snsID]) {
        NSNotificationCenter* dnc = [NSNotificationCenter defaultCenter];
        [dnc addObserver:self selector:@selector(profileUpdateCompleted:) name:@"profileUpdateCompleted" object:nil];
    }

    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(profileFold) 
                                                 name:@"myHomeProfileFold" 
                                               object:nil];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    if ([owner.snsId isEqualToString:[UserContext sharedUserContext].snsID]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"profileUpdateCompleted" object:nil];
    }

    [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                    name:@"myHomeProfileFold" 
                                                  object:nil];
}

- (void) viewWillAppear:(BOOL)animated {
    titleLabel.text = [UserContext sharedUserContext].nickName;
	[self requestHomeInfo];
    
    // 쿠키 정보를 요청한다. (없을 경우에만)
    [[UserContext sharedUserContext] requestSnsCookie];
    [myHomeTableView reloadData];    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark -
#pragma mark TableView data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0: //프로필 상세
            return 1;
            break;
        case 1: //발도장 리스트
            return 1;
            break;
        default:
            return 0;
            break;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        UITableViewCell *cell = [self createProfileCell:tableView cellForRowAtIndexPath:indexPath];
        return cell;
    } else {
        static NSString *cellIdentifier = @"MyHomePostCell";
        MyHomePostCell *cell = (MyHomePostCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
        if (cell == nil) {
            cell = [[[NSBundle mainBundle] loadNibNamed:cellIdentifier owner:nil options:nil] lastObject];
        }
        [cell redrawMyHomePostCellWithCellData:nil];
        
        return cell;
    }
}

#pragma mark -
#pragma mark TableView delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    float currentHeight = 0.0f;
    if (indexPath.section == 0) {
        currentHeight = 32.0f;
        if (isProfileOpen) currentHeight += 428.f;
        
    } else {
        currentHeight = 50.0f;
    }
    return currentHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 & indexPath.row == 0) {
        isProfileOpen = !isProfileOpen;
        
        if (isProfileOpen) {
            [tableView reloadData];
            [tableView setContentOffset:CGPointMake(0, 306)];
        }
    }
}

#pragma mark -
#pragma mark UIScrollView delegate

- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView {
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {  
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	if (scrollView.contentOffset.y < 0) {
		float y = scrollView.contentOffset.y;
		if (y < -60) {
			y = -60;
		}
		CGAffineTransform transform = CGAffineTransformMakeRotation(y * M_PI / 60);
		arrow.transform = transform;
		isTop = YES;
	} else {
		isTop = NO;
	}
    
	if (scrollView.contentOffset.y + myHomeTableView.frame.size.height + 10 > scrollView.contentSize.height) {
		isEnd = YES;
	} else {
		isEnd = NO;
	}

}

#pragma mark -
#pragma mark IminProtocol
- (void) apiFailed {
    MY_LOG(@"api failed!!!!");
    UIWindow *window = [[[UIApplication sharedApplication] windows] objectAtIndex:0];
    UIView *v = (UIView *)[window viewWithTag:TAG_iTOAST];
    if (!v) {
        iToast *msg = [[iToast alloc] initWithText:@" 인터넷 연결에 실패하였습니다. 네트워크 설정을 확인하거나, \n잠시 후 다시 시도해주세요~"];
        [msg setDuration:2000];
        [msg setGravity:iToastGravityCenter];
        [msg show];
        [msg release];
    }
    
    [self performSelector:@selector(closeVC) withObject:nil afterDelay:0.5];
}

- (void) apiDidLoad:(NSDictionary*) result {
    if ([[result objectForKey:@"func"] isEqualToString:@"homeInfo"]) {
		[self processHomeInfo:result];
	} 
    
    if ([[result objectForKey:@"func"] isEqualToString:@"homeInfoDetail"]) {
		self.homeInfoDetailResult = result;
        ProfileEditViewController* vc = [[[ProfileEditViewController alloc] initWithNibName:@"ProfileEditViewController" bundle:nil] autorelease];
        vc.homeInfoDetailResult = homeInfoDetailResult;
        [self.navigationController pushViewController:vc animated:YES];
	}
}

#pragma mark -
#pragma mark IBAction

- (IBAction)goFoots {
    BOOL isMe = [[UserContext sharedUserContext].snsID isEqualToString:owner.snsId];

    if (isMe) {
        GA3(@"마이프로필", @"발도장숫자버튼", @"마이프로필내");
    } else {
        GA3(@"타인프로필", @"발도장숫자버튼", @"타인프로필내");
    }

	int checkinCnt = [[homeInfoDetailResult objectForKey:@"poiCnt"] intValue];
	
	if (checkinCnt != 0) {
		LatestCheckinViewController* vc = [[[LatestCheckinViewController alloc] initWithNibName:@"LatestCheckinViewController" bundle:nil] autorelease];
		vc.owner = owner;
		[self.navigationController pushViewController:vc animated:YES];		
	}
}

- (IBAction)goFollower {
    MyHomeNeighborViewController *neiViewController = [[MyHomeNeighborViewController alloc]initWithSnsId:owner.snsId nickName:owner.nickname listType:@"Y"];
	[(UINavigationController*)[ViewControllers sharedViewControllers].tabBarController.selectedViewController pushViewController:neiViewController animated:YES];
	[neiViewController release]; 
}

- (IBAction)goFollowing {
	MyHomeNeighborViewController *neiViewController = [[MyHomeNeighborViewController alloc]initWithSnsId:owner.snsId nickName:owner.nickname listType:@"M"];
	[(UINavigationController*)[ViewControllers sharedViewControllers].tabBarController.selectedViewController pushViewController:neiViewController animated:YES];
	[neiViewController release]; 
}

- (IBAction)setBtn:(UIButton*) sender {
    if (![[UserContext sharedUserContext].snsID isEqualToString:owner.snsId]) { //타인홈
        
    } else { // 마이홈
        [self requestHomeInfoDetail];
    }
}

- (IBAction)foGift {
    
}

- (IBAction)goBack
{
	[self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark ImInProtocol request 

- (void) requestHomeInfo {
    self.homeInfo = [[[HomeInfo alloc] init] autorelease];
    homeInfo.delegate = self;
    homeInfo.snsId = owner.snsId;
    
    [homeInfo requestWithoutIndicator];
}

- (void) requestHomeInfoDetail {
    self.homeInfoDetail = [[[HomeInfoDetail alloc] init] autorelease];
    homeInfoDetail.delegate = self;
    
    [homeInfoDetail.params addEntriesFromDictionary:[NSDictionary dictionaryWithObject:owner.snsId forKey:@"snsId"]];
    [homeInfoDetail request];
}


#pragma mark -
#pragma mark func 
- (void) processHomeInfo:(NSDictionary*) result {
    self.homeInfoResult = result;
    MY_LOG(@"myhome Info = %@", result);
    
    NSNumber* isOpen = [result objectForKey:@"isOpenHome"];
	
    if (![[UserContext sharedUserContext].snsID isEqualToString:owner.snsId]) { //타인홈
        if ([isOpen intValue] == 0) {
            [CommonAlert alertWithTitle:@"알림" message:@"해당홈은 비공개입니다."];
            [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(goBack) userInfo:nil repeats:NO];
            return;
        }
    }
    
    NSString *whoIs = [result objectForKey:@"isPerm"];
    
    // 서로 이웃인지 여부를 확인해서 표시한다.
    if (![whoIs isEqualToString:@"OWNER"]) { // 타인홈        
        if( [whoIs isEqualToString:@"FRIEND"] ){
            friendCodeInt = FR_TRUE;
        }else if( [whoIs isEqualToString:@"NEIGHBOR_YOU"] ){ 
            friendCodeInt = FR_ME;  // 항상 다른사람의 홈페이지으므로 의미가 반대가 된다.
        }else if( [whoIs isEqualToString:@"NEIGHBOR_ME"] ){
            friendCodeInt = FR_YOU; // 따라서, 나(그사람을)를 (내가)등록한 이웃 이라는 뜻이 됨.
        }else{
            friendCodeInt = FR_NONE;
        }
        
        if( FR_YOU == friendCodeInt || FR_NONE == friendCodeInt ) {
            [setImg setImage:[UIImage imageNamed:@"pfv2_fri_add.png"]];
            setTitle.text = @"이웃추가";
        } else {
            [setImg setImage:[UIImage imageNamed:@"pfv2_fri_set.png"]];
            setTitle.text = @"이웃설정";
        }
        
        setTitle.frame = FRI_TEXT_FRAME;
    } else {
        [setImg setImage:[UIImage imageNamed:@"pfv2_fri_myset.png"]];
        setTitle.frame = PROFILEEDIT_TEXT_FRAME;

        setTitle.text = @"프로필\n편집";
    }
    NSNumber* neighborCnt = [result objectForKey:@"neighborCnt"];
    NSNumber* poiCnt = [result objectForKey:@"poiCnt"];
    NSNumber* calleeNeighborCnt = [result objectForKey:@"calleeNeighborCnt"];
    
    followingCntLabel.text = [neighborCnt stringValue];
    postCntLabel.text = [NSString stringWithFormat:@"%d", [poiCnt intValue]];
    followerCntLabel.text = [NSString stringWithFormat:@"%d", [calleeNeighborCnt intValue]];
    
    NSString* nickname = [result objectForKey:@"nickname"];
    nickNameLabel.text = nickname;
    
    NSString* profileImage = [result objectForKey:@"profileImg"];
    MY_LOG(@"profileImage = %@", profileImage);
    
    NSRange range = [profileImage rangeOfString:@"no_prf_"];
    if (range.location != NSNotFound) { // 있으면
        [profileImg setImage:[UIImage imageNamed:@"pfv2_dummy1.png"]];
    } else { 
        range = [profileImage rangeOfString:@"thumb1"];
        if (range.location != NSNotFound) { // 있으면
            profileImage = [profileImage stringByReplacingCharactersInRange:range withString:@"thumb6"];
        } 
        [profileImg setImageWithURL:[NSURL URLWithString:profileImage]
                   placeholderImage:[UIImage imageNamed:@"pfv2_dummy1.png"]];
    }
    
    self.owner.nickname = nickname;
    self.owner.profileImgUrl = profileImage;	
}

#pragma mark -
#pragma mark profile func

- (void)profileFold{
    isProfileOpen = NO;
    [myHomeTableView reloadData];
}

- (UITableViewCell*) createProfileCell:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    if (isProfileOpen) {
        static NSString *cellIdentifier = @"myProfileOpenCell";
        cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"MyHomeProfileCell" owner:self options:nil];
            cell = [nib lastObject];
            cell.backgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pfv2_detail_bg.png"]] autorelease];
        }
    }else {
        static NSString *cellIdentifier = @"myProfileSimpleCell";
        cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] autorelease];
            
            UILabel *label = [[[UILabel alloc] initWithFrame:CGRectMake(10, 0, 250, 30.f)] autorelease];
            label.text = @"Something good - 먼가 멘붕의 스멜이 하하하하하하하하하하하하하하하하 ";
            [label setLineBreakMode:UILineBreakModeTailTruncation];
            [label setFont:[UIFont systemFontOfSize:12]];
            [cell addSubview:label];
            
        }
    }
    return cell;
}

#pragma mark-
#pragma mark notificationCenter func

- (void) profileUpdateCompleted:(NSNotification*) noti
{
    // profile이업데이트가되었으니, 다시요청하자.
    [self requestHomeInfoDetail];
}

//- (void) friendSettingChanged:(NSNotification*) noti
//{
//NSDictionary* saveResult = [noti userInfo];
//MY_LOG(@"bool: %@ snsid: %@", [saveResult objectForKey:@"isFollowing"], [saveResult objectForKey:@"snsId"]);
//
//
//if ([[saveResult objectForKey:@"isFollowing"] boolValue]) {
//friendAdded = YES;
//} else {
//friendAdded = NO;
//}
//
//NSNotificationCenter* dnc = [NSNotificationCenter defaultCenter];
//[dnc removeObserver:self name:@"FriendSetSaved" object:nil];
//}

@end
