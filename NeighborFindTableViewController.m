//
//  NeighborFindTableViewController.m
//  ImIn
//
//  Created by ja young park on 11. 9. 7..
//  Copyright 2011년 __MyCompanyName__. All rights reserved.
//

#import "NeighborFindTableViewController.h"
#import "UIHomeViewController.h"
#import "NeighborInviteViewController.h"
#import "ViewControllers.h"
#import "CheckMyPhoneViewController.h"
#import "OAuthWebViewController.h"
#import "NSString+URLEncoding.h"
#import "SearchUser.h"
#import "NeighborRecomList.h"
#import "NeighborRecomReject.h"
#import "NeighborRegist.h"
#import "TableCoverNoticeViewController.h"
#import "BrandHomeViewController.h"
#import "BizWebViewController.h"
#import "ASIHTTPRequest.h"
#import "Reachability.h"

@implementation NeighborFindTableViewController

@synthesize innerTable;
@synthesize headerView;
@synthesize youMayKnows;
@synthesize youKnows;
@synthesize nicknameSearchList;
@synthesize nicknameKeyword;
@synthesize searchUser;
@synthesize pulldownState;
@synthesize recomBrands;

static float kOFFSET_FOR_KEYBOARD = 43.0f;

- (NSInteger) phoneCnt {
    int retCnt = 0;
    for (NSDictionary* aFriend in youKnows) {
        if ([[aFriend objectForKey:@"recomType"] isEqualToString:@"11"]) {
            retCnt++;
        }
    }
    
    return retCnt;
}

- (NSInteger) twitterCnt {
    int retCnt = 0;
    for (NSDictionary* aFriend in youKnows) {
        if ([[aFriend objectForKey:@"recomType"] isEqualToString:@"21"]) {
            retCnt++;
        }
    }
    
    return retCnt;
}


- (NSInteger) facebookCnt {
    int retCnt = 0;
    for (NSDictionary* aFriend in youKnows) {
        if ([[aFriend objectForKey:@"recomType"] isEqualToString:@"23"]) {
            retCnt++;
        }
    }
    
    return retCnt;
}

- (void) sequencialRequestWithMaxRetryCount:(NSInteger) maxRequestCnt {
    retryCnt = maxRequestCnt;
    for (int i = 0; i < retryCnt; i++) {   
        // 여러번 요청해본다. 시간을 달리해서
        [self performSelector:@selector(requestNeighborRecomList) withObject:nil afterDelay:i*2];
    }
}


#pragma mark - 요청
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
	
    NeighborRecomList* aRequest = [[NeighborRecomList alloc] init];
    aRequest.delegate = self;
    [aRequest.params addEntriesFromDictionary:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [[GeoContext sharedGeoContext].lastTmX stringValue], @"pointX", 
      [[GeoContext sharedGeoContext].lastTmY stringValue], @"pointY",
      [UserContext sharedUserContext].snsID, @"snsId",
      @"100", @"scale",
      @"1", @"lt",
      @"2", @"phoneNoType",
      phoneNumberListString, @"phoneNo", nil]];
    
    if (initRequest) { //처음 이웃추천을 들어갈때는 동글이가 나오도록 설정
        [aRequest request];
        initRequest = NO;
    } else {
        [aRequest requestWithoutIndicator];   
    }
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    MY_LOG(@"NeighborFindTableViewController viewDidLoad");
    
    initRequest = YES;
    infoView = nil;
    self.tableView.autoresizesSubviews = YES;
    [self.tableView setSeparatorColor:RGB(181, 181, 181)];
    [self.searchDisplayController.searchResultsTableView setSeparatorColor:RGB(181, 181, 181)];
    
    if ([ApplicationContext osVersion] > 3.2) {
        UIImageView *imageView = [[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"friend_friendsearch_bg_01.png"]] autorelease];
        [self.innerTable setBackgroundView:imageView];

    } else {
        self.innerTable.backgroundColor = [UIColor clearColor];
        UIImage *patternImage = [UIImage imageNamed:@"friend_friendsearch_bg_01.png"];
        [self.innerTable setBackgroundColor:[UIColor colorWithPatternImage: patternImage]];
    }
    
    self.headerView.frame = CGRectMake(0, 0, 320, 114);
    self.innerTable.frame = CGRectMake(0, 44, 320, 70);
    pulldownState = NO; // 접혀있음
    isReUserSearch = YES; // 검색 가능
        
    nicknameSearchList = [[NSMutableArray alloc] initWithCapacity:10];
	currPage = 1;
	searchResultCnt = 0;
	scale = 25;
	isEnd = NO;
    
    phoneBookConnected = [UserContext sharedUserContext].cpPhone.isConnected;
    twitterConnected = [UserContext sharedUserContext].cpTwitter.isConnected;
    facebookConnected = [UserContext sharedUserContext].cpFacebook.isConnected;
    
    indicators = [[NSMutableArray alloc] initWithCapacity:3];
}

- (BOOL) hasConnectionChanged {
    if (phoneBookConnected != [UserContext sharedUserContext].cpPhone.isConnected) {
        return YES;
    }
    
    if (twitterConnected != [UserContext sharedUserContext].cpTwitter.isConnected) {
        return YES;
    }
    
    if (facebookConnected != [UserContext sharedUserContext].cpFacebook.isConnected) {
        return YES;
    }
    
    return NO;
}

- (void)viewDidUnload
{
    [self setInnerTable:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    MY_LOG(@"이웃: 노티생성");

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(friendAdd:) name:@"friendAdd" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(friendReject:) name:@"friendReject" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(friendAddInSearchResult:) name:@"friendAddInSearchResult" object:nil];


    if ([self hasConnectionChanged]) {
        [self sequencialRequestWithMaxRetryCount:3];
        // 카운트 조절 
    }
    
    CGFloat searchBarHeight = 44;
    if ([self.tableView contentOffset].y < searchBarHeight && [ApplicationContext sharedApplicationContext].searchBarHidden == YES) {
        [self.tableView setContentOffset:CGPointMake(0, searchBarHeight) animated:YES];
    } else {
        [ApplicationContext sharedApplicationContext].searchBarHidden = YES;
    }

    [innerTable reloadData];
    [self.tableView reloadData];
    [self.searchDisplayController.searchResultsTableView reloadData];
    
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    MY_LOG(@"이웃: 노티삭제");
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"friendAdd" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"friendReject" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"friendAddInSearchResult" object:nil];
    

    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
    [youKnows release];
    [youMayKnows release];
    [nicknameSearchList release];
    [recomBrands release];
    [nicknameKeyword release];
    [innerTable release];
    [headerView release];
    [searchUser release];
    
    [indicators release];
    [infoView release];
    
    [super dealloc];
}



#pragma mark - Table view data source


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (!(tableView == innerTable || tableView == self.searchDisplayController.searchResultsTableView)) {
        if (section == 0) {
            if ([youKnows count] > 0) {
                return 24;
            }
        } else if (section == 1) {
            if ([youMayKnows count] > 0) {
                return 24;
            }
        } else if (section == 2) {
            if ([recomBrands count] > 0) {
                return 24;
            }
        }
    } 
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section  //2
{	
    UIView *viewToReturn = [[[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 24.0f)] autorelease];
    
    if (tableView == innerTable || tableView == self.searchDisplayController.searchResultsTableView) {
        return viewToReturn;
    } else {
        if (section == 0) {
            if ([youKnows count] > 0) { // 아는 사람
                viewToReturn = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"friend_title_news.png"]] autorelease];
            } 
        } else if (section == 1) {
            if ([youMayKnows count] > 0) { // 알수도 있는 사람
                viewToReturn = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"friend_title_know.png"]] autorelease];
            }    
        } else if (section == 2) {
            if ([recomBrands count] > 0) { //브랜드
                viewToReturn = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"friend_title_brand.png"]] autorelease];
            }     
        }
    }

	return viewToReturn;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {  //4
    if (tableView == innerTable) {
        return 48;
    } else if (tableView == self.searchDisplayController.searchResultsTableView ) {
        return 80;  
    } else {
        return 88;   
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView  //1
{
    // Return the number of sections.    
    if (tableView == innerTable || tableView == self.searchDisplayController.searchResultsTableView) {
        return 1;
    } else {
        return 3;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section  //3
{
    // Return the number of rows in the section.
    if (tableView == innerTable) {
        if (pulldownState == NO) { //접혀있으면
            return 1;
        } else {
            return 4;
        }
    } else if (tableView == self.searchDisplayController.searchResultsTableView ) {
        return [nicknameSearchList count];
    } else {
        switch (section) {
            case 0: return [youKnows count];
                break;
            case 1: return [youMayKnows count];
                break;
            case 2: return [recomBrands count];
                break;
            default: return 0;
                break;
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{    
    // Configure the cell...
    if (tableView == innerTable) {
        static NSString *CellIdentifier = @"moreSearchCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
            UIImageView *pulldownArrow = [[[UIImageView alloc] initWithFrame:CGRectMake(285, 17, 15, 15)] autorelease];
            pulldownArrow.tag = 200;
            [cell addSubview:pulldownArrow];
            
            UIImageView* snsIcon = [[[UIImageView alloc] initWithFrame:CGRectMake(11+9, 10, 27, 27)] autorelease];
            snsIcon.tag = 1000;
            [cell addSubview:snsIcon];
        }
    
        cell.textLabel.font = [UIFont fontWithName:@"Helvetica" size:16.0];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.backgroundColor = RGB(255, 255, 255);
        
        if (indexPath.row == 0) {
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.textLabel.textColor = RGB(17, 17, 17);
            
            UIImageView* pulldownArrow = (UIImageView*)[cell viewWithTag:200];
            if( pulldownState == NO ) { //접혀있음
                [pulldownArrow setImage:[UIImage imageNamed:@"friend_search_arrow_down.png"]];
            } else {
                [pulldownArrow setImage:[UIImage imageNamed:@"friend_search_arrow_up.png"]];
            }
                
            if (![UserContext sharedUserContext].cpPhone.isConnected 
                && ![UserContext sharedUserContext].cpFacebook.isConnected 
                && ![UserContext sharedUserContext].cpTwitter.isConnected ) { // 모두 연결되어있지 않으면
                cell.textLabel.text = @"아임IN에서 내 친구를 찾아보세요";
            } else {
                cell.textLabel.text = [NSString stringWithFormat:@" 총 %d 명의 친구를 찾았습니다", [self phoneCnt] + [self twitterCnt] + [self facebookCnt]];
            }
            [cell viewWithTag:1000].hidden = YES;
            
        } else {
            
            UIImageView* snsIcon = (UIImageView*)[cell viewWithTag:1000];
            snsIcon.hidden = NO;
            NSString* recomCnt;
            cell.textLabel.textColor = RGB(17, 17, 17);
            
            switch (indexPath.row) {
                case 1:
                    if (![UserContext sharedUserContext].cpPhone.isConnected) {
                        cell.backgroundColor = RGB(239, 239, 239);
                        //cell.textLabel.textColor = RGB(102, 102, 102);
                        [snsIcon setImage:[UIImage imageNamed:@"friend_icon_contacts_off.png"]]; 
                        cell.textLabel.text = @"         폰주소록에서 친구 찾기";
                    } else {
                        //cell.backgroundColor = RGB(0, 0, 0);
                        cell.accessoryType = UITableViewCellAccessoryNone;
                        cell.selectionStyle = UITableViewCellSelectionStyleNone;
                        //cell.textLabel.textColor = RGB(17, 17, 17);
                        [snsIcon setImage:[UIImage imageNamed:@"friend_icon_contacts_on.png"]]; 
                        recomCnt = [NSString stringWithFormat:@"         %d 명의 친구를 찾았습니다", [self phoneCnt]];
                        cell.textLabel.text = recomCnt;
                    }
                    break;
                case 2:
                    if (![UserContext sharedUserContext].cpFacebook.isConnected) {
                        cell.backgroundColor = RGB(239, 239, 239);
                        //cell.textLabel.textColor = RGB(102, 102, 102);
                        [snsIcon setImage:[UIImage imageNamed:@"friend_icon_facebook_off.png"]];
                        cell.textLabel.text = @"         페이스북에서 친구 찾기";
                    } else {
                        cell.accessoryType = UITableViewCellAccessoryNone;
                        cell.selectionStyle = UITableViewCellSelectionStyleNone;
                        //cell.textLabel.textColor = RGB(17, 17, 17);
                        [snsIcon setImage:[UIImage imageNamed:@"friend_icon_facebook_on.png"]];
                        recomCnt = [NSString stringWithFormat:@"         %d 명의 친구를 찾았습니다", [self facebookCnt]];
                        cell.textLabel.text = recomCnt;
                    }
                    break;
                case 3:
                    if (![UserContext sharedUserContext].cpTwitter.isConnected) {
                        cell.backgroundColor = RGB(239, 239, 239);
                        //cell.textLabel.textColor = RGB(102, 102, 102);
                        [snsIcon setImage:[UIImage imageNamed:@"friend_icon_twitter_off.png"]];
                        cell.textLabel.text = @"         트위터에서 친구 찾기";
                    } else {
                        cell.accessoryType = UITableViewCellAccessoryNone;
                        cell.selectionStyle = UITableViewCellSelectionStyleNone;
                        //cell.textLabel.textColor = RGB(17, 17, 17);
                        [snsIcon setImage:[UIImage imageNamed:@"friend_icon_twitter_on.png"]];
                        recomCnt = [NSString stringWithFormat:@"         %d 명의 친구를 찾았습니다", [self twitterCnt]];
                        cell.textLabel.text = recomCnt;
                    }
                    break;
                default:
                    break;
            } 
        }
        return cell;
    } else {
        static NSString *CellIdentifier2 = @"recomendCell"; 
        RecomendCell *cell = (RecomendCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier2];
        if (cell == nil) {
            MY_LOG(@"recomend cell create");
            cell = (RecomendCell*)[[[NSBundle mainBundle] loadNibNamed:@"RecomendCell" owner:nil options:nil] lastObject];		
        }

        if (tableView == self.searchDisplayController.searchResultsTableView) {
            cell.cellType = IMIN_CELLTYPE_NICKNAME;
            RecomendCellData* cellData = [nicknameSearchList objectAtIndex:indexPath.row];
            [cell redrawMainThreadCellWithCellData:cellData];
            cell.cellDataList = nicknameSearchList;
            cell.cellDataListIndex = indexPath.row;
        } else {
            cell.cellType = IMIN_CELLTYPE_RECOMMEND;
            RecomendCellData* cellData;

            switch (indexPath.section) {
                case 0:
                    cellData = [[[RecomendCellData alloc] initWithDictionary:[youKnows objectAtIndex:indexPath.row]] autorelease];
                    [cell redrawMainThreadCellWithCellData:cellData];
                    cell.cellDataListIndex = indexPath.row;
                    cell.cellDataList = youKnows;
                    break;
                case 1: 
                    cellData = [[[RecomendCellData alloc] initWithDictionary:[youMayKnows objectAtIndex:indexPath.row]] autorelease];
                    [cell redrawMainThreadCellWithCellData:cellData];
                    cell.cellDataListIndex = indexPath.row;
                    cell.cellDataList = youMayKnows;
                    break;
                case 2: //브랜드
                    cellData = [[[RecomendCellData alloc] initWithDictionary:[recomBrands objectAtIndex:indexPath.row]] autorelease];
                    [cell redrawMainThreadCellWithCellData:cellData];
                    cell.cellDataListIndex = indexPath.row;
                    cell.cellDataList = recomBrands;
                    break;
                default:
                    break;
            }
        }
        return cell;
    }
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [[tableView cellForRowAtIndexPath:indexPath] setSelected:FALSE animated:YES];
    
    if (tableView == innerTable) {
        switch (indexPath.row) {
            case 0:
                [self moreSearch];
                break;
            case 1:
                if (![UserContext sharedUserContext].cpPhone.isConnected ) { // 연결되어있지 않으면
                    GA3(@"이웃", @"폰주소록에서친구찾기", @"이웃찾기탭내");
                    CheckMyPhoneViewController* vc = [[[CheckMyPhoneViewController alloc] initWithNibName:@"CheckMyPhoneViewController" bundle:nil] autorelease];
                    //[(UINavigationController*)[ViewControllers sharedViewControllers].tabBarController.selectedViewController pushViewController:vc animated:YES];
                    [[ViewControllers sharedViewControllers].neighbersViewController.navigationController pushViewController:vc animated:YES];
                } else {
                    UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
                    
                    if ([cell viewWithTag:8881]) {
                        break;
                    } else {
                        [self sequencialRequestWithMaxRetryCount:1];
                        UIActivityIndicatorView* activityIndicator = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray] autorelease];
                        activityIndicator.frame = CGRectMake(280, 14, 20, 20);
                        activityIndicator.tag = 8881;
                        [activityIndicator startAnimating];
                        [indicators addObject:activityIndicator];
                        [cell addSubview:activityIndicator];
                    }
                }
                break;
            case 2:
                if (![UserContext sharedUserContext].cpFacebook.isConnected ) { // 연결되어있지 않으면
                    GA3(@"이웃", @"페이스북에서친구찾기", @"이웃찾기탭내");
                    NSString* temp = [NSString stringWithFormat:@"sitename=facebook.com&appname=%@&env=app&rturl=%@&cskey=%@&atkey=%@", [IMIN_APP_NAME URLEncodedString], [CALLBACK_URL URLEncodedString], [SNS_CONSUMER_KEY  URLEncodedString], [[UserContext sharedUserContext].token URLEncodedString]] ;
                    
                    OAuthWebViewController* webViewCtrl = [[[OAuthWebViewController alloc] init] autorelease];
                    webViewCtrl.requestInfo = [NSString stringWithFormat:@"%@?%@", OAUTH_URL, temp] ;
                    webViewCtrl.webViewTitle = @"facebook 설정";
                    webViewCtrl.authType = FB_TYPE;
                    
                    [webViewCtrl setHidesBottomBarWhenPushed:YES];
                    [[ViewControllers sharedViewControllers].neighbersViewController.navigationController pushViewController:webViewCtrl animated:YES];
                    
                    return;
                } else {
                    UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
                    
                    if ([cell viewWithTag:8882]) {
                        break;
                    } else {
                        [self sequencialRequestWithMaxRetryCount:1];
                        UIActivityIndicatorView* activityIndicator = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray] autorelease];
                        activityIndicator.frame = CGRectMake(280, 14, 20, 20);
                        activityIndicator.tag = 8882;
                        [activityIndicator startAnimating];
                        [indicators addObject:activityIndicator];
                        [cell addSubview:activityIndicator];
                    }
                }
                break;
            case 3:
                if (![UserContext sharedUserContext].cpTwitter.isConnected ) { // 연결되어있지 않으면
                    GA3(@"이웃", @"트위터에서친구찾기", @"이웃찾기탭내");
                    NSString* temp = [NSString stringWithFormat:@"sitename=twitter.com&appname=%@&env=app&rturl=%@&cskey=%@&atkey=%@", [IMIN_APP_NAME URLEncodedString], [CALLBACK_URL URLEncodedString], [SNS_CONSUMER_KEY  URLEncodedString], [[UserContext sharedUserContext].token URLEncodedString]] ;
                    
                    OAuthWebViewController* webViewCtrl = [[[OAuthWebViewController alloc] init] autorelease];
                    webViewCtrl.requestInfo = [NSString stringWithFormat:@"%@?%@", OAUTH_URL, temp] ;
                    webViewCtrl.webViewTitle = @"twitter 설정";
                    webViewCtrl.authType = TWITTER_TYPE;
                    
                    [webViewCtrl setHidesBottomBarWhenPushed:YES];
                    [[ViewControllers sharedViewControllers].neighbersViewController.navigationController pushViewController:webViewCtrl animated:YES];
                    
                    return;
                } else {
                    UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];

                    if ([cell viewWithTag:8883]) {
                        break;
                    } else {
                        [self sequencialRequestWithMaxRetryCount:1];
                        UIActivityIndicatorView* activityIndicator = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray] autorelease];
                        activityIndicator.frame = CGRectMake(280, 14, 20, 20);
                        activityIndicator.tag = 8883;
                        [activityIndicator startAnimating];
                        [indicators addObject:activityIndicator];
                        [cell addSubview:activityIndicator];
                    }
                }
                break;
            default:
                break;
        }
    } else if (tableView == self.searchDisplayController.searchResultsTableView) {
        if ([nicknameSearchList count] == 0 || [nicknameSearchList count] < indexPath.row) {
            return;
        }
        
        RecomendCellData* cellData = [nicknameSearchList objectAtIndex:indexPath.row];
        
        //해당 사용자의 홈페이지로 이동하게 한다.
        UIHomeViewController *vc = [[UIHomeViewController alloc] initWithNibName:@"UIHomeViewController" bundle:nil];
        
        MemberInfo* owner = [[[MemberInfo alloc] init] autorelease];
        owner.snsId = cellData.snsId;
        owner.nickname = cellData.nickName;
        owner.profileImgUrl = cellData.profileImgURL;	
        
        vc.owner = owner;
        
        [(UINavigationController*)[ViewControllers sharedViewControllers].tabBarController.selectedViewController pushViewController:vc animated:YES];
        [vc release];
    } else {        
        RecomendCellData* cellData;

        switch (indexPath.section) {
            case 0:
                cellData = [[[RecomendCellData alloc] initWithDictionary:[youKnows objectAtIndex:indexPath.row]] autorelease];
                break;
            case 1:
                cellData = [[[RecomendCellData alloc] initWithDictionary:[youMayKnows objectAtIndex:indexPath.row]] autorelease];
                break;
            case 2:
                cellData = [[[RecomendCellData alloc] initWithDictionary:[recomBrands objectAtIndex:indexPath.row]] autorelease];
                break;
            default:
                return;
                break;
        }
       
        if (indexPath.section == 0 || indexPath.section == 1) {
            //해당 사용자의 홈페이지로 이동하게 한다.
            UIHomeViewController *vc = [[UIHomeViewController alloc] initWithNibName:@"UIHomeViewController" bundle:nil];
            
            MemberInfo* owner = [[[MemberInfo alloc] init] autorelease];
            owner.snsId = cellData.snsId;
            owner.nickname = cellData.nickName;
            owner.profileImgUrl = cellData.profileImgURL;	
            
            vc.owner = owner;
            
            [(UINavigationController*)[ViewControllers sharedViewControllers].tabBarController.selectedViewController pushViewController:vc animated:YES];
            [vc release];   
        } else {
            BrandHomeViewController *vc = [[BrandHomeViewController alloc] initWithNibName:@"BrandHomeViewController" bundle:nil];
            MemberInfo *owner = [[[MemberInfo alloc] init] autorelease];
            owner.snsId = cellData.snsId;
            owner.nickname = cellData.nickName;
            owner.profileImgUrl = cellData.profileImgURL;
                          
            vc.owner = owner;
            
            [(UINavigationController*)[ViewControllers sharedViewControllers].tabBarController.selectedViewController pushViewController:vc animated:YES];
            [vc release];
        }
        
        GA3(@"이웃", @"발도장상세보기", @"이웃찾기탭내");
    }
}

#pragma mark 이웃초대 view load
- (void)neighborInvite:(UIButton *)sender {
    MY_LOG(@"이웃초대");
    
    GA3(@"이웃", @"친구초대버튼", @"이웃찾기탭내");

    
    NeighborInviteViewController *vc = [[NeighborInviteViewController alloc]initWithNibName:@"NeighborInviteViewController" bundle:nil];
	[[ViewControllers sharedViewControllers].neighbersViewController.navigationController pushViewController:vc animated:YES];
	[vc release];
	//[[ViewControllers sharedViewControllers] refreshNeighborVC];
}

#pragma mark 좀더많은 이웃찾기
- (void)moreSearch {
    
    GA3(@"이웃", @"좀더많은친구찾기", @"이웃찾기탭내");
    CGRect frame = self.tableView.tableHeaderView.frame;
    
    if ([ApplicationContext osVersion] > 3.2) {
        UIImageView *imageView = nil;
       
        if (pulldownState == NO) { //접혀있으면
            frame.size.height = frame.size.height + 144;
            pulldownState = YES;
            imageView = [[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"friend_friendsearch_bg_02.png"]] autorelease];
        } else {
            pulldownState = NO;
            frame.size.height = frame.size.height - 144;
            imageView = [[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"friend_friendsearch_bg_01.png"]] autorelease];
        }       
        
        [self.innerTable setBackgroundView:imageView];
    } else {
        self.innerTable.backgroundColor = [UIColor clearColor];
        UIImage *patternImage = nil;
        
        if (pulldownState == NO) { //접혀있으면
            frame.size.height = frame.size.height + 144;
            pulldownState = YES;
            patternImage = [UIImage imageNamed:@"friend_friendsearch_bg_02.png"];
        } else {
            pulldownState = NO;
            frame.size.height = frame.size.height - 144;
            patternImage = [UIImage imageNamed:@"friend_friendsearch_bg_01.png"];
        }       
        [self.innerTable setBackgroundColor:[UIColor colorWithPatternImage: patternImage]];
    }
    
    [self.tableView.tableHeaderView setFrame:frame];
    [self.tableView setTableHeaderView:self.headerView]; 
    
    [self.tableView reloadData];
    [self.innerTable reloadData];
}

- (void) downStateDraw {
    CGRect frame = self.tableView.tableHeaderView.frame;
    
    if ([ApplicationContext osVersion] > 3.2) {
        UIImageView *imageView = nil;
        
        frame.size.height = frame.size.height + 144;
        imageView = [[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"friend_friendsearch_bg_02.png"]] autorelease];
        
        [self.innerTable setBackgroundView:imageView];
    } else {
        self.innerTable.backgroundColor = [UIColor clearColor];
        UIImage *patternImage = nil;
        
        frame.size.height = frame.size.height + 144;
        patternImage = [UIImage imageNamed:@"friend_friendsearch_bg_02.png"];
        
        [self.innerTable setBackgroundColor:[UIColor colorWithPatternImage: patternImage]];
    }
    
    [self.tableView.tableHeaderView setFrame:frame];
    [self.tableView setTableHeaderView:self.headerView]; 
    [self.tableView reloadData];
    [self.innerTable reloadData];
} 

#pragma mark Notificaiton handle

- (void) friendAdd: (NSNotification*) noti
{
    // 이웃로 추가됨
    MY_LOG(@"추가 노티 받았다");
	if(([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == ReachableViaWWAN) || 
	   ([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == ReachableViaWiFi)) {
		//NSLog(@"Network connected..");
	}
	else {
		//NSLog(@"Network not connected..");
        return;
	}
    RecomendCellData *notiData = [noti object];
    NSString* snsId = notiData.snsId;
  
    if ([notiData.knownType isEqualToString:@"1"]) {
        int i = 0;
        for (NSDictionary* aFriend in youKnows) {
            if ([[aFriend objectForKey:@"snsId"] isEqualToString:snsId]) {
                [youKnows removeObject:aFriend];
                [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:i inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
                break;
            }
            i++;
        }
    } else if ([notiData.knownType isEqualToString:@"2"]) {
        int i = 0;
        for (NSDictionary* aFriend in youMayKnows) {
            if ([[aFriend objectForKey:@"snsId"] isEqualToString:snsId]) {
                [youMayKnows removeObject:aFriend];
                [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:i inSection:1]] withRowAnimation:UITableViewRowAnimationFade];
                break;
            }
            i++;
        }
    } else { //브랜드면
        int i = 0;
        for (NSDictionary* aFriend in recomBrands) {
            if ([[aFriend objectForKey:@"snsId"] isEqualToString:snsId]) {
                [recomBrands removeObject:aFriend];
                [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:i inSection:2]] withRowAnimation:UITableViewRowAnimationFade];
                break;
            }
            i++;
        }
    }

    
    [innerTable reloadData];
    
    //뱃지 카운트 하나 빼서 다시 보여줘라. 
    if ([notiData.knownType isEqualToString:@"1"]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"recomCntBadgeReload" object:nil];
    }
    
    NeighborRegist* neighborRegist= [[NeighborRegist alloc] init];
    neighborRegist.delegate = self;
    
    [neighborRegist.params addEntriesFromDictionary:[NSDictionary dictionaryWithObject:notiData.snsId forKey:@"regSnsId"]];
    [neighborRegist.params addEntriesFromDictionary:[NSDictionary dictionaryWithObject:notiData.recomType forKey:@"recomType"]];
    [neighborRegist.params addEntriesFromDictionary:[NSDictionary dictionaryWithObject:[[noti userInfo] objectForKey:@"referCode"] forKey:@"referCode"]];
    
    [neighborRegist requestWithAuth:YES withIndicator:NO];
    
}

- (void) friendReject: (NSNotification*) noti //브랜드는 리젝이없다.
{

    MY_LOG(@"리젝 노티 받았다");
	
    RecomendCellData *notiData = [noti object];
    NSString* snsId = notiData.snsId;
    
    if ([notiData.knownType isEqualToString:@"1"]) {
        int i = 0;
        for (NSDictionary* aFriend in youKnows) {
            if ([[aFriend objectForKey:@"snsId"] isEqualToString:snsId]) {
                [youKnows removeObject:aFriend];
                [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:i inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
                break;
            }
            i++;
        }
    } else {
        int i = 0;
        for (NSDictionary* aFriend in youMayKnows) {
            if ([[aFriend objectForKey:@"snsId"] isEqualToString:snsId]) {
                [youMayKnows removeObject:aFriend];
                [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:i inSection:1]] withRowAnimation:UITableViewRowAnimationFade];
                break;
            }
            i++;
        }
    }

    [innerTable reloadData];
    
    //뱃지 카운트 하나 빼서 다시 보여줘라. 
    if ([notiData.knownType isEqualToString:@"1"]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"recomCntBadgeReload" object:nil];
    }

    // 친구가 빼짐
    NeighborRecomReject* neighborRecomReject = [[NeighborRecomReject alloc] init];
	neighborRecomReject.delegate = self;
	[neighborRecomReject.params addEntriesFromDictionary:[NSDictionary dictionaryWithObject:notiData.snsId forKey:@"rejectSnsId"]];
    [neighborRecomReject.params addEntriesFromDictionary:[NSDictionary dictionaryWithObject:notiData.recomType forKey:@"recomType"]];
    
	[neighborRecomReject request];

}

- (void) friendAddInSearchResult: (NSNotification*) noti // 검색결과엔 브랜드는 없다.
{
	RecomendCellData *notiData = [noti object];
    NSDictionary *dic = [noti userInfo];

    NSInteger index = [[dic objectForKey:@"index"] intValue];
	
    notiData.isFriend = @"1"; 
    [nicknameSearchList replaceObjectAtIndex:index withObject:notiData];
    
    [self.searchDisplayController.searchResultsTableView reloadData];
        
    NeighborRegist* neighborRegist= [[NeighborRegist alloc] init];
    neighborRegist.delegate = self;
    
    [neighborRegist.params addEntriesFromDictionary:[NSDictionary dictionaryWithObject:notiData.snsId forKey:@"regSnsId"]];
    
    if (notiData.recomType != nil) {
        [neighborRegist.params addEntriesFromDictionary:[NSDictionary dictionaryWithObject:notiData.recomType forKey:@"recomType"]];        
    }
    
    NSString* referCode = [[noti userInfo] objectForKey:@"referCode"];
    if (referCode != nil) {
        [neighborRegist.params addEntriesFromDictionary:[NSDictionary dictionaryWithObject:referCode forKey:@"referCode"]];        
    }
    
    [neighborRegist requestWithAuth:YES withIndicator:NO];
}

#pragma mark -
#pragma mark UISearchDisplayController Delegate Methods

- (void) searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller {
	//[self setViewMovedUp:YES];
}

- (void) searchDisplayControllerDidBeginSearch:(UISearchDisplayController *)controller {
	
}

- (void) searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller {
//	if (self.view.frame.origin.y < 0)
//    {
//        [self setViewMovedUp:NO];
//		[searchBar resignFirstResponder];
//    }
}

- (void) searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller {
	[controller.searchResultsTableView setSeparatorColor:RGB(181, 181, 181)];
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    [controller.searchResultsTableView setRowHeight:2000];
    
	return NO;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)aSearchBar
{
	MY_LOG(@"cancel");
	[nicknameSearchList removeAllObjects];
    [self.searchDisplayController.searchResultsTableView reloadData];
	
	aSearchBar.text = @"";
	[aSearchBar becomeFirstResponder];
    [self.tableView setContentOffset:CGPointMake(0, 0) animated:YES];
    // by mandolin(2012.03.20) : return 하기전에 재검색 가능하도록 설정
    isReUserSearch = YES;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)aSearchBar {
	MY_LOG(@"searchBar search button clicked!");
    
	currPage = 1;
	searchResultCnt = 0;
	scale = 25;
	
    if ([nicknameKeyword isEqualToString:aSearchBar.text]) { //검색어가 같은데
        if (isReUserSearch == NO) { //재검색도 안되게 설정되어 있으면
            return;
        }
    }

    isReUserSearch = NO; //재 검색 안되게
    
	self.nicknameKeyword = aSearchBar.text;
	
	[self doUserSearch];
	
	[self.tableView setContentOffset:CGPointMake(0, 0) animated:YES];
    
}

#pragma mark 닉네임검색 & iminprotocol
- (void) doUserSearch
{
	if (nicknameKeyword.length < 1 || nicknameKeyword.length > 256 ) {
		[CommonAlert alertWithTitle:@"안내" message:@"닉네임 검색은 최소 1글자 이상 입력하셔야 해요."];
		return;
	}
	
    self.searchUser = [[[SearchUser alloc] init] autorelease];
    searchUser.delegate = self;
    
    [searchUser.params addEntriesFromDictionary:[NSDictionary dictionaryWithObject:[UserContext sharedUserContext].snsID forKey:@"snsId"]];
    [searchUser.params addEntriesFromDictionary:[NSDictionary dictionaryWithObject:@"25" forKey:@"scale"]];
    [searchUser.params addEntriesFromDictionary:[NSDictionary dictionaryWithObject:nicknameKeyword forKey:@"nickname"]];
    [searchUser.params addEntriesFromDictionary:[NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"%d", currPage] forKey:@"currPage"]];
    
    [searchUser request];
}


#pragma mark -
#pragma mark API 결과

- (void)apiFailedWhichObject:(NSObject *)theObject {
    if ([NSStringFromClass([theObject class]) isEqualToString:@"NeighborRecomList"]) {
        [theObject release];        
    }
    
    if ([NSStringFromClass([theObject class]) isEqualToString:@"NeighborRegist"]) {
        [theObject release];
	}
    
    if ([NSStringFromClass([theObject class]) isEqualToString:@"NeighborReject"]) {
        [theObject release];
    }
}

#pragma mark -
#pragma mark ImInProtocol

- (void) apiDidLoadWithResult:(NSDictionary *)result whichObject:(NSObject *)theObject
{
    if ([[result objectForKey:@"func"] isEqualToString:@"neighborRecomList"]) {
        
        NSArray* aList = [result objectForKey:@"data"];
        
        if ([Utils isValidNeighborRecomWithArray:aList] || --retryCnt == 0) {
            // 합당한 응답이라 판단되면 나머지 요청을 취소하자
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(requestNeighborRecomList) object:nil];
            
            self.youKnows = [[[NSMutableArray alloc] initWithCapacity:50] autorelease];
            self.youMayKnows = [[[NSMutableArray alloc] initWithCapacity:25] autorelease];
            self.recomBrands = [[[NSMutableArray alloc] initWithCapacity:25] autorelease];
            
            
            for (NSDictionary* aFriend in aList) {
                int knownType = [[aFriend objectForKey:@"knownType"] intValue];
                if (knownType == 1) {
                    [youKnows addObject:aFriend];
                }
                
                if (knownType == 2) {
                    [youMayKnows addObject:aFriend];
                }
                
                if (knownType == 3) {
                    [recomBrands addObject:aFriend];
                }
            }
            
            int cnt = [indicators count];
            for (int i = 0; i < cnt; i++) {
                UIActivityIndicatorView* aView = [indicators objectAtIndex:i];
                [aView stopAnimating];
                [aView removeFromSuperview];
            }
            [indicators removeAllObjects];
                        
            [self.tableView reloadData];
            [self.innerTable reloadData];
            
        } else {
            MY_LOG(@"이 리스트는 아닌거 같아~!");
        }
        
        [theObject release];
    }

    if ([[result objectForKey:@"func"] isEqualToString:@"neighborRegist"]) {
        if (![[result objectForKey:@"result"] boolValue] || ![[result objectForKey:@"errCode"] isEqualToString:@"0"]) {		
            MY_LOG(@"result == false");
            // by mandolin(2012.03.20) : return 하기전에 재검색 가능하도록 설정
            isReUserSearch = YES; 
            return;
        }
        
        [[UserContext sharedUserContext] recordKissMetricsWithEvent:@"Added Friend" withInfo:nil];
        
        //이웃 이벤트 시 쿠폰 획득 정보
        if ( ! [[result objectForKey:@"wvUrl"] isEqualToString:@""] ) {
            [self getEventCoupon:[result objectForKey:@"wvUrl"]];
        }
        [theObject release];
    }
    
    if ([[result objectForKey:@"func"] isEqualToString:@"neighborReject"]) {
        MY_LOG(@"이웃 제거");
        [theObject release];
    }
    
    if ([[result objectForKey:@"func"] isEqualToString:@"searchUser"]) {
        NSIndexPath* previousLastIndexPath = nil;
        if (currPage != 1) {
            // 기존의 리스트의 마지막을 기억하자
            previousLastIndexPath = [NSIndexPath indexPathForRow:[nicknameSearchList count] inSection:0];		
        }
        
        searchResultCnt = [[result objectForKey:@"totalCnt"] integerValue];
        if (currPage == 1) {
            [nicknameSearchList removeAllObjects];
        }
        
        [self.searchDisplayController.searchResultsTableView reloadData];
        
        if (searchResultCnt == 0) {
            // by mandolin(2012.03.20) : infoView.view가 seachbar의 cancel호출시에 reload되면서 미아가 되는 것으로 보임
            //                           아예 infoview를 제거후에 새로 생성하는 것으로 로직 변경
            if (infoView != nil)
            {
                [infoView.view removeFromSuperview];
                [infoView release];
                infoView = nil;
            }
            /// end
            if (infoView == nil) {
                infoView = [[TableCoverNoticeViewController alloc]initWithNibName:@"TableCoverNoticeViewController" bundle:nil];	
                CGRect frame = self.searchDisplayController.searchResultsTableView.frame;
                frame.origin = CGPointMake(0, 0);
                infoView.view.frame = frame;
                
                infoView.line1.text = @"못 찾겠어요~ 다시 검색해 주세요~";
                
                [self.searchDisplayController.searchResultsTableView addSubview:infoView.view];	
            } else {
                infoView.view.hidden = NO;
            }
            [self.searchDisplayController.searchResultsTableView bringSubviewToFront:infoView.view];
            // by mandolin(2012.03.20) : return 하기전에 재검색 가능하도록 설정
            isReUserSearch = YES;
            return;
        } 	
        
        if(infoView != nil) {
            infoView.view.hidden = YES;
        }
        
        
        if ([[result objectForKey:@"result"] boolValue]) {
            NSArray* resultList = [result objectForKey:@"data"];
            for (NSDictionary *poiData in resultList) {
                RecomendCellData* cellData = [[RecomendCellData alloc] initWithDictionary:poiData];
                [nicknameSearchList addObject:cellData];
                [cellData release];
            }
        }
        [self.searchDisplayController.searchResultsTableView reloadData];
        
        if (previousLastIndexPath != nil) {
            [self.searchDisplayController.searchResultsTableView scrollToRowAtIndexPath:previousLastIndexPath 
                                                                       atScrollPosition:UITableViewScrollPositionMiddle 
                                                                               animated:YES];	
        }
        isReUserSearch = YES;
    }
}

- (void)getEventCoupon:(NSString *)eventUrl {     // 이웃 이벤트 쿠폰 가져오기
    
    BizWebViewController *vc = [[[BizWebViewController alloc] initWithNibName:@"BizWebViewController" 
                                                                       bundle:nil] autorelease];
    vc.urlString = [eventUrl stringByAppendingFormat:@"&title_text=%@&right_enable=y&pointX=%@&pointY=%@", 
                    [@"이벤트" URLEncodedString], 
                    [GeoContext sharedGeoContext].lastTmX, 
                    [GeoContext sharedGeoContext].lastTmY];
    
    [(UINavigationController*)[ViewControllers sharedViewControllers].tabBarController.selectedViewController presentModalViewController:vc animated:YES];
}

#pragma mark -
#pragma mark UIScrollView delegate

- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView {

}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {

    if (isEnd) {
        [self doRequestMore];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.contentOffset.y + 378 > scrollView.contentSize.height) {
        isEnd = YES;
    } else {
        isEnd = NO;
    }	
}

#pragma mark -
#pragma mark 키보드 처리

- (void)setViewMovedUp:(BOOL)movedUp
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    
    CGRect rect = self.view.frame;
    if (movedUp)
    {
        rect.origin.y -= kOFFSET_FOR_KEYBOARD;
        rect.size.height += kOFFSET_FOR_KEYBOARD;
		[headerView setFrame:CGRectMake(0.0f, 0.0f+kOFFSET_FOR_KEYBOARD, 320, 43)];
    }
    else
    {
        rect.origin.y += kOFFSET_FOR_KEYBOARD;
        rect.size.height -= kOFFSET_FOR_KEYBOARD;
		[headerView setFrame:CGRectMake(0.0f, 0.0f, 320, 43)];
    }
    self.view.frame = rect;
    
    [UIView commitAnimations];
}

- (void) doRequestMore
{
	if (searchResultCnt > scale * currPage) {
		currPage++;
		[self doUserSearch];
	}
}

- (void) removeSearchKeyboard
{
    [self.searchDisplayController setActive:NO animated:YES];
}
@end

