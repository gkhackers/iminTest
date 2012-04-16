//
//  FriendFinderViewController.m
//  ImIn
//
//  Created by Myungjin Choi on 11. 9. 20..
//  Copyright 2011년 KTH. All rights reserved.
//

#import "FriendFinderViewController.h"
#import "NeighborRecomList.h"
#import "RecomendCell.h"
#import "RecomendCellData.h"
#import "CheckMyPhoneViewController.h"
#import "OAuthWebViewController.h"
#import "NSString+URLEncoding.h"
#import "UIHomeViewController.h"
#import "NeighborRegist.h"

const int YOU_KNOW = 1;
const int YOU_MAY_KNOW = 2;

@implementation FriendFinderViewController

@synthesize neighborRecomList, youKnows, youMayKnows;
@synthesize friendType;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        friendType = YOU_KNOW;
        retryCnt = 3;
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void) requestNeighborRecomList 
{
    
    NSDictionary* phoneBook = [[UserContext sharedUserContext] getPhoneBook];
	
	NSString* phoneNumberListString = @"";
    
    if ([UserContext sharedUserContext].cpPhone.isConnected) {
        for (NSString* key in phoneBook) {
            phoneNumberListString = [phoneNumberListString stringByAppendingString:key];
            phoneNumberListString = [phoneNumberListString stringByAppendingString:@"|"];	
        }        
    }
	
    self.neighborRecomList = [[[NeighborRecomList alloc] init] autorelease];
    neighborRecomList.delegate = self;
    [neighborRecomList.params addEntriesFromDictionary:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [[GeoContext sharedGeoContext].lastTmX stringValue], @"pointX", 
      [[GeoContext sharedGeoContext].lastTmY stringValue], @"pointY",
      [UserContext sharedUserContext].snsID, @"snsId",
      @"100", @"scale",
      @"1", @"lt",
      @"2", @"phoneNoType",
      phoneNumberListString, @"phoneNo", nil]];
    
    [neighborRecomList request];
}

#pragma mark Notificaiton handle
- (void) recomListChanged: (NSNotification*) noti
{
    MY_LOG(@"friendAdd 노티 받았다");
	
    RecomendCellData *notiData = [noti object];
    NSString* snsId = notiData.snsId;
    
    if ([notiData.knownType isEqualToString:@"1"]) {
        int i = 0;
        for (NSDictionary* aFriend in youKnows) {
            if ([[aFriend objectForKey:@"snsId"] isEqualToString:snsId]) {
                [youKnows removeObject:aFriend];
                [mainTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:i inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
                break;
            }
            i++;
        }
    } else {
        int i = 0;
        for (NSDictionary* aFriend in youMayKnows) {
            if ([[aFriend objectForKey:@"snsId"] isEqualToString:snsId]) {
                [youMayKnows removeObject:aFriend];
                
                [mainTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:i inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
                
                break;
            }
            i++;
        }
    }
            
    NeighborRegist* neighborRegist= [[NeighborRegist alloc] init ];
    neighborRegist.delegate = self;
        
    [neighborRegist.params addEntriesFromDictionary:[NSDictionary dictionaryWithObject:notiData.snsId forKey:@"regSnsId"]];
    
    if (notiData.recomType != nil) {
        [neighborRegist.params addEntriesFromDictionary:[NSDictionary dictionaryWithObject:notiData.recomType forKey:@"recomType"]];        
    }
    
    if ([[noti userInfo] objectForKey:@"referCode"] != nil) {
        [neighborRegist.params addEntriesFromDictionary:[NSDictionary dictionaryWithObject:[[noti userInfo] objectForKey:@"referCode"] forKey:@"referCode"]];
    }
    
    [neighborRegist requestWithAuth:YES withIndicator:NO];
}


#pragma mark - View lifecycle

- (void) viewWillAppear:(BOOL)animated
{
    MY_LOG(@"노티 등록");
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(recomListChanged:) name:@"friendAdd" object:nil];

    if(friendType == YOU_KNOW) {
        mainTableView.backgroundColor = RGB(239, 239, 239);
        nextBtn.enabled = NO;
        retryCnt = 3;
        for (int i = 0; i < retryCnt; i++) {   
            // 여러번 요청해본다. 시간을 달리해서
            [self performSelector:@selector(requestNeighborRecomList) withObject:nil afterDelay:i*2];
        }
    } else {
        [mainTableView setTableHeaderView:nil];
        [mainTableView setTableFooterView:nil];
        [self reloadVC];
    }
}

- (void) viewWillDisappear:(BOOL)animated
{
    MY_LOG(@"노티 삭제");
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"friendAdd" object:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    GA1(@"아는사람찾기페이지");
    
    [self.navigationController setNavigationBarHidden:YES animated:NO];
        
    [mainTableView setSeparatorColor:RGB(181, 181, 181)];
    
    if(friendType == YOU_KNOW) {
        [self requestNeighborRecomList];
    } else {
        titleLabel.text = @"이런 이웃 어때요?";
        [mainTableView setTableFooterView:nil];
    }
}

- (void)viewDidUnload
{
    [mainTableView release];
    mainTableView = nil;
    [bottomTableView release];
    bottomTableView = nil;
    [recomSectionHeaderTitle release];
    recomSectionHeaderTitle = nil;
    [recomSectionHeader release];
    recomSectionHeader = nil;
    [youMayKnows release];
    youMayKnows = nil;
    [youKnows release];
    youKnows = nil;
    [secondSectionHeaderView release];
    secondSectionHeaderView = nil;
    [nextBtn release];
    nextBtn = nil;
    [titleLabel release];
    titleLabel = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
    [mainTableView release];
    [bottomTableView release];
    [recomSectionHeaderTitle release];
    [recomSectionHeader release];
    [youKnows release];
    [youMayKnows release];
    [secondSectionHeaderView release];
    [nextBtn release];
    [titleLabel release];
    [super dealloc];
}

- (IBAction)popVC:(id)sender {
    
    if (friendType == YOU_KNOW) {
        GA3(@"아는사람찾기", @"다음", @"알수도있는사람");
        if ([youMayKnows count] == 0) {
            [self dismissModalViewControllerAnimated:YES];
        }
        
        FriendFinderViewController* vc = [[[FriendFinderViewController alloc] initWithNibName:@"FriendFinderViewController" bundle:nil] autorelease];
        
        vc.friendType = YOU_MAY_KNOW;
        vc.youMayKnows = youMayKnows;
        [self.navigationController pushViewController:vc animated:YES];
        
        [[UserContext sharedUserContext].setting setObject:[NSNumber numberWithInt:1] forKey:@"hasDoneFriendFinder"];
        [[UserContext sharedUserContext] saveSettingToFile];
    } else {
        GA3(@"아는사람찾기", @"다음", @"아는사람");
        [self dismissModalViewControllerAnimated:YES];
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger retValue = 0;
    if (tableView == mainTableView) {
        if (friendType == YOU_KNOW) {
            retValue = [youKnows count];
        } else {
            retValue = [youMayKnows count];
        }
    }
    
    if (tableView == bottomTableView && friendType == YOU_KNOW) {
        retValue = 3;
    }
    return retValue;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == mainTableView) {
        return 92.0f - 14.0f;
    } else {
        return 48.0f;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (tableView == mainTableView) {
        
        if ( (friendType == YOU_KNOW && section == 0 && [youKnows count] > 0) 
            || (friendType == YOU_MAY_KNOW && section == 0) ) {
            return 24.0f;
        } else {
            return 0;
        }
    } else {
        return 62.0f;
    }
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (friendType == YOU_KNOW) {
        if (tableView == mainTableView && section == 0 && [youKnows count] > 0) {
            return recomSectionHeader;
        }         
    } else {
        if (tableView == mainTableView && section == 0) {
            return recomSectionHeader;
        }                 
    }
    
    if (tableView == bottomTableView) {
        return secondSectionHeaderView;
    }
    
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == mainTableView) {
        static NSString *cellIdentifier = @"recomendCell";
        
        RecomendCell *cell = (RecomendCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            cell = (RecomendCell*)[[[NSBundle mainBundle] loadNibNamed:@"RecomendCell" owner:nil options:nil] lastObject];
            cell.cellType = IMIN_CELLTYPE_WELCOME_RECOMMEND;
        }
        
        RecomendCellData* aData = nil;
        if (friendType == YOU_KNOW) {
            aData = [[[RecomendCellData alloc] 
                                        initWithDictionary:[youKnows objectAtIndex:indexPath.row]] autorelease];            
        } else {
            aData = [[[RecomendCellData alloc] 
                                        initWithDictionary:[youMayKnows objectAtIndex:indexPath.row]] autorelease];
        }
        [cell redrawMainThreadCellWithCellData:aData];
        
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        return cell;
    } 
    
    if (tableView == bottomTableView) {
        static NSString *cellIdentifier = @"Connect";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] autorelease];
        }
        
        [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
        UIImageView* snsIcon = nil;
        switch (indexPath.row) {
            case 0:
                if (![UserContext sharedUserContext].cpPhone.isConnected) {
                    snsIcon = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"friend_icon_contacts_off.png"]] autorelease]; 
                    cell.textLabel.text = @"         휴대폰 인증하기";
                    cell.accessoryType =UITableViewCellAccessoryDisclosureIndicator;
                } else {
                    snsIcon = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"friend_icon_contacts_on.png"]] autorelease]; 
                    cell.textLabel.text = @"         휴대폰 인증되었습니다.";
                    cell.accessoryType =UITableViewCellAccessoryNone;
                    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
                }
                break;
            case 1:
                if (![UserContext sharedUserContext].cpFacebook.isConnected) {
                    snsIcon = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"friend_icon_facebook_off.png"]] autorelease];
                    cell.textLabel.text = @"         페이스북에서 친구찾기";
                    cell.accessoryType =UITableViewCellAccessoryDisclosureIndicator;
                } else {
                    snsIcon = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"friend_icon_facebook_on.png"]] autorelease];
                    cell.textLabel.text = @"         페이스북이 연결되었습니다.";
                    cell.accessoryType =UITableViewCellAccessoryNone;
                    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
                }
                break;
            case 2:
                if (![UserContext sharedUserContext].cpTwitter.isConnected) {
                    snsIcon = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"friend_icon_twitter_off.png"]] autorelease];
                    cell.textLabel.text = @"         트위터에서 친구찾기";
                    cell.accessoryType =UITableViewCellAccessoryDisclosureIndicator;
                } else {
                    snsIcon = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"friend_icon_twitter_on.png"]] autorelease];
                    cell.textLabel.text = @"         트위터가 연결되었습니다.";
                    cell.accessoryType =UITableViewCellAccessoryNone;
                    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
                }
                break;
            default:
                break;
        } 
        
        [snsIcon setFrame:CGRectMake(11+9, 10, 27, 27)];
        [cell addSubview:snsIcon];
        return cell;
    }
    return nil;
}
#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    if (tableView == mainTableView) {
//        NSDictionary* aData = [youKnows objectAtIndex:indexPath.row];
//        
//        //해당 사용자의 홈페이지로 이동하게 한다.
//        
//        UIHomeViewController *vc = [[[UIHomeViewController alloc] initWithNibName:@"UIHomeViewController" bundle:nil] autorelease];
//        
//        MemberInfo* owner = [[[MemberInfo alloc] init] autorelease];
//        owner.snsId = [aData objectForKey:@"snsId"];
//        owner.nickname = [aData objectForKey:@"nickname"];
//        owner.profileImgUrl = [aData objectForKey:@"profileImg"];	
//        
//        vc.owner = owner;
//        
////        GA3(@"이웃", @"발도장상세보기", @"이웃추천");
//        [self.navigationController pushViewController:vc animated:YES];
//    }
    
    if (tableView == bottomTableView) {
        switch (indexPath.row) {
            case 0:
                if (![UserContext sharedUserContext].cpPhone.isConnected ) { // 연결되어있지 않으면
                    GA3(@"아는사람찾기", @"폰주소록에서친구찾기", @"아는사람찾기내");
                    CheckMyPhoneViewController* vc = [[[CheckMyPhoneViewController alloc] initWithNibName:@"CheckMyPhoneViewController" bundle:nil] autorelease];
                    //[(UINavigationController*)[ViewControllers sharedViewControllers].tabBarController.selectedViewController pushViewController:vc animated:YES];
                    [self.navigationController pushViewController:vc animated:YES];
                }
                break;
            case 1:
                if (![UserContext sharedUserContext].cpFacebook.isConnected ) { // 연결되어있지 않으면
                    GA3(@"아는사람찾기", @"페이스북에서친구찾기", @"아는사람찾기내");

                    NSString* temp = [NSString stringWithFormat:@"sitename=facebook.com&appname=%@&env=app&rturl=%@&cskey=%@&atkey=%@", [IMIN_APP_NAME URLEncodedString], [CALLBACK_URL URLEncodedString], [SNS_CONSUMER_KEY  URLEncodedString], [[UserContext sharedUserContext].token URLEncodedString]] ;
                    
                    OAuthWebViewController* webViewCtrl = [[[OAuthWebViewController alloc] init] autorelease];
                    webViewCtrl.requestInfo = [NSString stringWithFormat:@"%@?%@", OAUTH_URL, temp] ;
                    webViewCtrl.webViewTitle = @"facebook 설정";
                    webViewCtrl.authType = FB_TYPE;
                    
                    [webViewCtrl setHidesBottomBarWhenPushed:YES];
                    [self.navigationController pushViewController:webViewCtrl animated:YES];
                    
                    return;
                }
                break;
            case 2:
                if (![UserContext sharedUserContext].cpTwitter.isConnected ) { // 연결되어있지 않으면
                    GA3(@"아는사람찾기", @"트위터에서친구찾기", @"아는사람찾기내");
                    
                    NSString* temp = [NSString stringWithFormat:@"sitename=twitter.com&appname=%@&env=app&rturl=%@&cskey=%@&atkey=%@", [IMIN_APP_NAME URLEncodedString], [CALLBACK_URL URLEncodedString], [SNS_CONSUMER_KEY  URLEncodedString], [[UserContext sharedUserContext].token URLEncodedString]] ;
                    
                    OAuthWebViewController* webViewCtrl = [[[OAuthWebViewController alloc] init] autorelease];
                    webViewCtrl.requestInfo = [NSString stringWithFormat:@"%@?%@", OAUTH_URL, temp] ;
                    webViewCtrl.webViewTitle = @"twitter 설정";
                    webViewCtrl.authType = TWITTER_TYPE;
                    
                    [webViewCtrl setHidesBottomBarWhenPushed:YES];
                    [self.navigationController pushViewController:webViewCtrl animated:YES];
                    
                    return;
                }
                break;
            default:
                break;
        }
    }
}


#pragma mark - ImInProtocolDelegate
- (void) apiDidLoadWithResult:(NSDictionary *)result whichObject:(NSObject *)theObject
{
    if ([[result objectForKey:@"func"] isEqualToString:@"neighborRecomList"]) {

        NSArray* aList = [result objectForKey:@"data"];

        if ([Utils isValidNeighborRecomWithArray:aList] || --retryCnt == 0) {
            
            nextBtn.enabled = YES;
            mainTableView.backgroundColor = [UIColor whiteColor];
            // 합당한 응답이라 판단되면 나머지 요청을 취소하자
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(requestNeighborRecomList) object:nil];
            
            self.youKnows = [[[NSMutableArray alloc] initWithCapacity:50] autorelease];
            self.youMayKnows = [[[NSMutableArray alloc] initWithCapacity:25] autorelease];
            
            
            for (NSDictionary* aFriend in aList) {
                int knownType = [[aFriend objectForKey:@"knownType"] intValue];
                if (knownType == 1) {
                    [youKnows addObject:aFriend];
                }
                
                if (knownType == 2) {
                    [youMayKnows addObject:aFriend];
                }
            }
            [self reloadVC];
            
        } else {
            MY_LOG(@"이 리스트는 아닌거 같아~!");
        }
    }
    if ([[result objectForKey:@"func"] isEqualToString:@"neighborRegist"]) {
        // 이웃 추가 성공
        [[UserContext sharedUserContext] recordKissMetricsWithEvent:@"Added Friend" withInfo:nil];
        [theObject release];
    }
}

- (void) apiFailedWhichObject:(NSObject *)theObject
{
    if ([NSStringFromClass([theObject class]) isEqualToString:@"NeighborRegist"]) {
        [theObject release];
    }
    
    if ([NSStringFromClass([theObject class]) isEqualToString:@"NeighborRecomList"]) {
        nextBtn.enabled = YES;
    }
    
    MY_LOG(@"api failed!");
}

-(void) reloadVC
{
    NSString* title = nil;
    if (friendType == YOU_KNOW) {
        title = [NSString stringWithFormat:@"%d명의 친구가 아임IN을 사용하고 있어요.", [youKnows count]];  
    } else {
        title = @"알 수도 있는 사람";
    }
    [recomSectionHeaderTitle setText:title];
    [mainTableView reloadData];
    [bottomTableView reloadData];
}

@end
