//
//  ManageTableViewController.m
//  ImIn
//
//  Created by 태한 김 on 10. 5. 10..
//  Copyright 2010 kth. All rights reserved.
//

#import "macro.h"
#import "ManageTableViewController.h"
#import "UITabBarItem+WithImage.h"
#import "UIImageView+WebCache.h"
#import "UserContext.h"
#import "ViewControllers.h"
#import "CgiStringList.h"
#import "UILoginViewController.h"
#import "AboutViewController.h"

#import "UIPlazaViewController.h"
#import "Utils.h"
#import "SnsKeyChain.h"
#import "UINoticeCatalogController.h"
#import "UIPhoneNumEditController.h"
#import "FriendFinderSettingViewController.h"
#import "SNSConnectionViewController.h"
#import "CheckMyPhoneViewController.h"
#import "NotiSettingViewController.h"
#import "NeighborBlockViewController.h"
#import "CustomerServiceViewController.h"
#import "ProfileEditViewController.h"
#import "HomeInfoDetail.h"
#import "BizWebViewController.h"
#import "CommonWebViewController.h"
#import "NeighborInviteViewController.h"
#import "NSString+URLEncoding.h"


#define DOCSFOLDER [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]
#define PROGRESS_BAR	999


@implementation ManageTableViewController

@synthesize homeInfoDetail, homeInfoDetailResult, giftNewCnt;

#pragma mark -
#pragma mark Initialization

/**
 @brief 테이블 스타일 초기설정
 @return self
 */
- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if ((self = [super initWithStyle:style])) {
		self.view.backgroundColor = RGB(230,230,230);
		isTwitterSet = NO;

		NSNotificationCenter* dnc = [NSNotificationCenter defaultCenter];
		[dnc addObserver:self selector:@selector(profileUpdateCompleted:) name:@"profileUpdateCompleted" object:nil];
    }
    
    return self;
}

- (void) profileUpdateCompleted:(NSNotification*) noti {
	UIImageView* profileImageView = (UIImageView*) [self.view viewWithTag:PROFILE_IMAGEVIEW_TAG];
	[profileImageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",[UserContext sharedUserContext].userProfile]]
					 placeholderImage:[UIImage imageNamed:@"delay_nosum70.png"]];
}

- (void) gitfNewImageSet {
    UIImageView* newImageView = (UIImageView*) [self.view viewWithTag:GIFTNEW_IMAGEVIEW_TAG];
    if (giftNewCnt > 0) {
        newImageView.image = [UIImage imageNamed:@"myhome_top_iconnew.png"];
    } else {
        newImageView.image = nil;
    }
}

#pragma mark View lifecycle

/**
 @brief 알림 설정 알아오기
 @return void
 */
- (void) viewCheckWhenAppear{
	// 알림 설정 알아오기
	[self.tableView reloadData];
}

/*
- (void)viewDidAppear:(BOOL)animated {
 	[super viewDidAppear:animated];
}*/

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}
/*
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}
*/
/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void) setLogoutAlertDelegate:(id)vc
{
	alertDelegate = vc;
}


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 6;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    switch (section) {
        case 0: return 2;
        case 1: return 3;
        case 2: return 2;
        case 3: return 2;
        case 4: return 4;
        case 5: return 1;
        default: 
            return 0;
            break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if(5 == indexPath.section) {
		return 43.0;
	}
	else {
		return 49.0;
	}
}

// Customize the appearance of table view cells.
/**
 @brief 테이블에 값 설정
 @return UITableViewCell
 */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier;

	// 보통의 셀, 슬라이더가 있는셀, 그리고 스위치가 있는 셀. 이렇게 세 가지 형태의 셀이 있다.
    if (indexPath.section == 0 && indexPath.row ==0) {
        CellIdentifier = @"profileCell";
    } else if (indexPath.section == 1 && indexPath.row == 1) {
        CellIdentifier = @"inviteCell";
    } else if (indexPath.section == 2 && indexPath.row == 0) {
        CellIdentifier = @"presentCell";
    } else if (indexPath.section == 2 && indexPath.row == 1) {
        CellIdentifier = @"eventCell";
    } else if (indexPath.section == 5) {
        CellIdentifier = @"logout";
    } else {
        CellIdentifier = @"Cell";
    }
        
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];

		cell.selectionStyle = UITableViewCellSelectionStyleGray;
		if( 0 == indexPath.row && 0 == indexPath.section ){ //프로필 영역이면
			UIImageView* profileImageView = [[[UIImageView alloc] initWithFrame:CGRectMake(20+3, 7+2, 34, 34)] autorelease];
			profileImageView.tag = PROFILE_IMAGEVIEW_TAG;
			[cell addSubview:profileImageView];
			[profileImageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",[UserContext sharedUserContext].userProfile]]
							 placeholderImage:[UIImage imageNamed:@"delay_nosum70.png"]];
		}
        if( 0 == indexPath.row && 2 == indexPath.section ){ //선물함 영역이면
            UIImageView* gitfImageView = [[[UIImageView alloc] initWithFrame:CGRectMake(20, 10, 29, 29)] autorelease];
			gitfImageView.tag = GIFT_IMAGEVIEW_TAG;
			[cell addSubview:gitfImageView];
			gitfImageView.image = [UIImage imageNamed:@"set_gift.png"];

			UIImageView* newImageView = [[[UIImageView alloc] initWithFrame:CGRectMake(106, 14, 21, 22)] autorelease];
            newImageView.tag = GIFTNEW_IMAGEVIEW_TAG;
            [cell addSubview:newImageView];
            newImageView.image = nil;
		}
        if( 1 == indexPath.row && 2 == indexPath.section ){ //이벤트 영역이면
            UIImageView* eventImageView = [[[UIImageView alloc] initWithFrame:CGRectMake(20, 10, 29, 29)] autorelease];
			eventImageView.tag = EVENT_IMAGEVIEW_TAG;
			[cell addSubview:eventImageView];
			eventImageView.image = [UIImage imageNamed:@"set_event.png"];

//			UIImageView* newImageView = [[[UIImageView alloc] initWithFrame:CGRectMake(75, 14, 21, 22)] autorelease];
//            newImageView.tag = GIFTNEW_IMAGEVIEW_TAG;
//            [cell addSubview:newImageView];
//            newImageView.image = nil;
		}
        if (1 == indexPath.row && 1 == indexPath.section) { // 친구 초대하기 영역이면
            if ([[[UserContext sharedUserContext].setting objectForKey:@"friendRecomPromotion"] intValue] != 1) {
                UIImageView* newImageView = [[[UIImageView alloc] initWithFrame:CGRectMake(130, 14, 21, 22)] autorelease];
                newImageView.image = [UIImage imageNamed:@"myhome_top_iconnew.png"];;
                newImageView.tag = FRIENDINVITE_IMAGEVIEW_TAG;
                [cell addSubview:newImageView];
            }
        }
    } 

    switch (indexPath.section) {
        case 0:
            if (indexPath.row == 0) {
                cell.textLabel.text = @"         프로필 편집";
				cell.textLabel.textAlignment = UITextAlignmentLeft;
            } else {
                if ([[UserContext sharedUserContext].userPhoneNumber compare:@""] == NSOrderedSame || [UserContext sharedUserContext].userPhoneNumber == nil) 
					cell.textLabel.text = @"내 폰번호 확인"; // @"내번호";
				else
					cell.textLabel.text = [NSString stringWithFormat:@"내 폰번호 (%@)",[Utils addDashToPhoneNumber:[UserContext sharedUserContext].userPhoneNumber]] ;
            }
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            break;
        case 1:
            if (indexPath.row == 0) {
                cell.textLabel.text = @"글 내보내기 설정";
            } else if (indexPath.row == 1) {
                cell.textLabel.text = @"친구 초대하기";
                if ([[[UserContext sharedUserContext].setting objectForKey:@"friendRecomPromotion"] intValue] == 1) {
                    [cell viewWithTag:FRIENDINVITE_IMAGEVIEW_TAG].hidden = YES;
                } else {
                    [cell viewWithTag:FRIENDINVITE_IMAGEVIEW_TAG].hidden = NO;
                }
            } else {
                cell.textLabel.text = @"이웃 추천 설정";
            }
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            break;
        case 2:
            if (indexPath.row == 0) {
                cell.textLabel.text = @"      선물함";
            } else {
                cell.textLabel.text = @"      이벤트/쿠폰함";
            }
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            break;
        case 3:
            if (indexPath.row == 0) {
                cell.textLabel.text = @"알림 설정";
            } else {
                cell.textLabel.text = @"이웃차단관리";
            }
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            break;
        case 4:
            if (indexPath.row == 0) {
                cell.textLabel.text = @"서비스 공지/안내";
            } else if (indexPath.row == 1) {
                cell.textLabel.text = @"아임IN 서비스 정보";
            } else if (indexPath.row == 2) {
                cell.textLabel.text = @"고객센터";
            } else {
                cell.textLabel.text = @"KTH의 다른 App보기";
            }
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            break;
        case 5:
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.contentView.backgroundColor = [UIColor clearColor];
            cell.backgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"btnnew_set_logout.png"]] autorelease];
            break;
        default:
            break;
    }
    return cell;
}



#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UserContext* uc = [UserContext sharedUserContext];
    // Navigation logic may go here. Create and push another view controller.	
	if( 0 == indexPath.row && 0 == indexPath.section ){ //프로필 영역 클릭
        if ([uc isBrandUser]) {
            [CommonAlert alertWithTitle:@"안내" message:@"브랜드의 프로필은 아임IN Biz 사이트에서만 수정할 수 있어요~	"];
        }  else {
            self.homeInfoDetail = [[[HomeInfoDetail alloc] init] autorelease];
            homeInfoDetail.delegate = self;
            [homeInfoDetail.params addEntriesFromDictionary:[NSDictionary dictionaryWithObject:[UserContext sharedUserContext].snsID forKey:@"snsId"]];
            [homeInfoDetail request];
        }

		[[tableView cellForRowAtIndexPath:indexPath] setSelected:FALSE animated:YES];
	} else if( 1 == indexPath.row && 0 == indexPath.section ){ //내폰번호 확인 영역 클릭
        if ([uc isBrandUser]) {
            [CommonAlert alertWithTitle:@"안내" message:@"브랜드의 프로필은 아임IN Biz 사이트에서만 수정할 수 있어요~	"];
        }  else {
            if ([UserContext sharedUserContext].cpPhone.isConnected == NO) {
                CheckMyPhoneViewController* vc = [[[CheckMyPhoneViewController alloc] initWithNibName:@"CheckMyPhoneViewController" bundle:nil] autorelease];
                [(UINavigationController*)[ViewControllers sharedViewControllers].settingViewController pushViewController:vc animated:YES];
            } else {
                UIPhoneNumEditController *pec = [[UIPhoneNumEditController alloc]initWithNibName:@"UIPhoneNumEditController" bundle:nil];
                
                [pec setPnumber:[UserContext sharedUserContext].userPhoneNumber];
                [(UINavigationController*)[ViewControllers sharedViewControllers].settingViewController pushViewController:pec animated:YES];
                [pec release];
                [[tableView cellForRowAtIndexPath:indexPath] setSelected:FALSE animated:YES];			
            }
        }
	} else if( 0 == indexPath.row && 1 == indexPath.section ){ //글내보내기 영역 클릭
		SNSConnectionViewController* vc = [[SNSConnectionViewController alloc] initWithNibName:@"SNSConnectionViewController" bundle:nil];
		[(UINavigationController*)[ViewControllers sharedViewControllers].settingViewController pushViewController:vc animated:YES];
		[vc release];
	} else if( 1 == indexPath.row && 1 == indexPath.section ){ //친구초대하기 영역 클릭
        if ([[[UserContext sharedUserContext].setting objectForKey:@"friendRecomPromotion"] intValue] != 1) {
            [[UserContext sharedUserContext].setting setObject:[NSNumber numberWithInt:1] forKey:@"friendRecomPromotion"];
            [[UserContext sharedUserContext] saveSettingToFile];
        }
        
        NeighborInviteViewController *vc = [[[NeighborInviteViewController alloc]initWithNibName:@"NeighborInviteViewController" bundle:nil] autorelease];
        vc.titleString = @"친구 초대하기";
        [(UINavigationController*)[ViewControllers sharedViewControllers].tabBarController.selectedViewController pushViewController:vc animated:YES];
	} else if (2 == indexPath.row && 1 == indexPath.section ) { //이웃추천 설정 영역 클릭
		FriendFinderSettingViewController* vc = [[FriendFinderSettingViewController alloc] initWithNibName:@"FriendFinderSettingViewController" bundle:nil];
		[(UINavigationController*)[ViewControllers sharedViewControllers].settingViewController pushViewController:vc animated:YES];
		[vc release];
		[[tableView cellForRowAtIndexPath:indexPath] setSelected:FALSE animated:NO];
	} else if (0 == indexPath.row && 2 == indexPath.section) { //선물함
        GA3(@"설정", @"선물함", @"설정내");
        
        if ([[UserContext sharedUserContext].snsCookieArray count] == 2 && [UserContext sharedUserContext].snsCookieArray != nil) {
            [self goGiftHome];
        } else {
            // 쿠키가 없다면
            [self performSelector:@selector(goGiftHome) withObject:nil afterDelay:10.0f];
        }
    } else if (1 == indexPath.row && 2 == indexPath.section) { //이벤트/쿠폰함
        MY_LOG(@"이벤트/쿠폰함 클릭");
        GA3(@"설정", @"이벤트함", @"설정내");
        
        if ([UserContext sharedUserContext].snsCookieArray != nil && [[UserContext sharedUserContext].snsCookieArray count] == 2) {
            [self goEvent];
        } else {
            // 쿠키가 없다면
            [self performSelector:@selector(goEvent) withObject:nil afterDelay:10.0f];
        }
    } else if (0 == indexPath.row && 3 == indexPath.section) { //알림설정 
		NotiSettingViewController* vc = [[NotiSettingViewController alloc] initWithNibName:@"NotiSettingViewController" bundle:nil];
		[(UINavigationController*)[ViewControllers sharedViewControllers].settingViewController pushViewController:vc animated:YES];
		[vc release];
		[[tableView cellForRowAtIndexPath:indexPath] setSelected:FALSE animated:NO];
	} else if (1 == indexPath.row && 3 == indexPath.section) { //이웃차단
		NeighborBlockViewController* vc = [[NeighborBlockViewController alloc] initWithNibName:@"NeighborBlockViewController" bundle:nil];
		[(UINavigationController*)[ViewControllers sharedViewControllers].settingViewController pushViewController:vc animated:YES];
		[vc release];
		[[tableView cellForRowAtIndexPath:indexPath] setSelected:FALSE animated:NO];
	} else if( 0 == indexPath.row && 4 == indexPath.section ){ //서비스 공지 /안내
		GA3(@"설정", @"서비스공지", @"설정내");
		UINoticeCatalogController *nc = [[UINoticeCatalogController alloc]init];
		
		[(UINavigationController*)[ViewControllers sharedViewControllers].settingViewController pushViewController:nc animated:YES];
		[nc release];
		[[tableView cellForRowAtIndexPath:indexPath] setSelected:FALSE animated:YES];
	} else if( 1 == indexPath.row && 4 == indexPath.section ){ //아임인 서비스정보
		AboutViewController *vc = [[AboutViewController alloc]initWithNibName:@"AboutViewController" bundle:nil];
		[vc setHidesBottomBarWhenPushed:YES];
		[(UINavigationController*)[ViewControllers sharedViewControllers].settingViewController pushViewController:vc animated:YES];
		[vc release];
		[[tableView cellForRowAtIndexPath:indexPath] setSelected:FALSE animated:YES];
	}
	else if( 2 ==  indexPath.row && 4 == indexPath.section ){ // 도움말
		GA3(@"설정", @"도움말", @"설정내");
		CustomerServiceViewController* csvc = [[CustomerServiceViewController alloc] initWithNibName:@"CustomerServiceViewController" bundle:nil];
		[csvc setHidesBottomBarWhenPushed:YES];
		[(UINavigationController*)[ViewControllers sharedViewControllers].settingViewController pushViewController:csvc animated:YES];
		[csvc release];
		[[tableView cellForRowAtIndexPath:indexPath] setSelected:FALSE animated:NO];
	} else if (3 == indexPath.row && 4 == indexPath.section) { //다른 어플보기
		alertView = [[UIAlertView alloc]initWithTitle:@"알림"
											  message:@"아임IN을 닫고 선택하신 페이지를 보시겠어요?"
											 delegate:self
									cancelButtonTitle:@"취소"
									otherButtonTitles:@"확인",nil];
		[alertView setTag:PARAN_APP_TAG];
		[alertView show];		
	} else if( 5 == indexPath.section ){ //로그아웃 영역 클릭
		alertView = [[UIAlertView alloc]initWithTitle:@"알림"
                                              message:@"로그아웃 하실 경우 이후 아임IN 실행 시 아이디, 패스워드를 다시 입력하고 로그인 하셔야 합니다."
                                             delegate:self
                                    cancelButtonTitle:@"취소"
                                    otherButtonTitles:@"로그아웃",nil];
		[alertView setTag:LOGOUT_TAG];
		[alertView show];
		[[tableView cellForRowAtIndexPath:indexPath] setSelected:FALSE animated:NO];
	} 
    
    [[tableView cellForRowAtIndexPath:indexPath] setSelected:FALSE animated:NO];
}

- (void) alertView:(UIAlertView *)alert clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // 로그아웃 창이 뜬 후 선택 처리.
    if (LOGOUT_TAG == alert.tag && buttonIndex == 1) // "로그아웃" 버튼
    {
        [alert release];
        [[UserContext sharedUserContext] logoutProcess];
        return;
        
    }
	
	if (PARAN_APP_TAG == alert.tag) {
		if (buttonIndex == 1) {
			[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://m.paran.com/mini/apps/appsList.jsp"]];
		}
	}

	[alert release];
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"profileUpdateCompleted" object:nil];
}


- (void)dealloc {
	
	[homeInfoDetail release];

    [super dealloc];
}

- (void) apiFailed 
{
//   [CommonAlert alertWithTitle:@"알림" message:@"네트웍 연결을 확인해주세요."];
}

- (void) apiDidLoad:(NSDictionary *)result
{
	if ([[result objectForKey:@"func"] isEqualToString:@"homeInfoDetail"]) {
		
		self.homeInfoDetailResult = result;
		
		ProfileEditViewController* vc = [[[ProfileEditViewController alloc] initWithNibName:@"ProfileEditViewController" bundle:nil] autorelease];
		vc.homeInfoDetailResult = homeInfoDetailResult;
		
		[(UINavigationController*)[ViewControllers sharedViewControllers].settingViewController pushViewController:vc animated:YES];
	}
}

- (void) goGiftHome
{
    if ([UserContext sharedUserContext].snsCookieArray == nil || [[UserContext sharedUserContext].snsCookieArray count] < 2) {
        [[UserContext sharedUserContext] requestSnsCookie];
        [CommonAlert alertWithTitle:@"안내" message:@"인증정보를 받아오고 있어요 잠시후 다시 시도해주세요~!"];
        return;
    }
    
    CommonWebViewController* vc = [[[CommonWebViewController alloc] initWithNibName:@"CommonWebViewController" bundle:nil] autorelease];
    
    vc.urlString = [NSString stringWithFormat:@"%@?targetUrl=heartconGiftHome.kth&snsId=%@&device=%@&osVer=%@", 
                    HEARTCON_GIFT,
                    [UserContext sharedUserContext].snsID,
                    [ApplicationContext deviceId],
                    [[UIDevice currentDevice] systemVersion]];
    
    vc.viewType = HEARTCON;
    vc.titleString = @"선물함";
    [(UINavigationController*)[ViewControllers sharedViewControllers].tabBarController.selectedViewController 
     presentModalViewController:vc animated:YES];
}

- (void) goEvent
{
    if ([UserContext sharedUserContext].snsCookieArray == nil || [[UserContext sharedUserContext].snsCookieArray count] < 2) {
        [[UserContext sharedUserContext] requestSnsCookie];
        [CommonAlert alertWithTitle:@"안내" message:@"인증정보를 받아오고 있어요 잠시후 다시 시도해주세요~!"];
        return;
    }
    
    BizWebViewController* vc = [[[BizWebViewController alloc] initWithNibName:@"BizWebViewController" bundle:nil] autorelease];
    
    vc.urlString = [EVENT_BOX_URL stringByAppendingFormat:@"&title_text=%@&right_enable=y&pointX=%@&pointY=%@", [@"이벤트/쿠폰함" URLEncodedString], [GeoContext sharedGeoContext].lastTmX, [GeoContext sharedGeoContext].lastTmY];
    [(UINavigationController*)[ViewControllers sharedViewControllers].tabBarController.selectedViewController 
     presentModalViewController:vc animated:YES];
}


@end
