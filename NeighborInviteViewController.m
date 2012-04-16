//
//  NeighborInviteViewController.m
//  ImIn
//
//  Created by ja young park on 11. 9. 19..
//  Copyright 2011년 __MyCompanyName__. All rights reserved.
//

#import "NeighborInviteViewController.h"
#import "SNSInvitationTableCell.h"
#import "CpNeighborList.h"
#import "OAuthWebViewController.h"
#import "NSString+URLEncoding.h"
#import "SendMsg.h"
#import "KakaoLinkCenter.h"
#import "AddLink.h"

@implementation NeighborInviteViewController

@synthesize cpNeighborList;
@synthesize cellDataList;
@synthesize isLoaded;
@synthesize sendMsg;
@synthesize addLink;
@synthesize titleString;

//- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
//    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
//    if (self) {
//        // Custom initialization.
//    }
//    return self;
//}

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
    // Do any additional setup after loading the view from its nib.
    isLoaded = NO;
    isEnd = NO;
    cellDataList = [[NSMutableArray alloc] initWithCapacity:100];
    mainTable.autoresizesSubviews = YES;
    [footerTable setSeparatorColor:RGB(181, 181, 181)];
    if ([cellDataList count] > 0) { //페이스북 리스트가 있으면
        footerView.hidden = NO; 
       // [self.tableView setTableFooterView:self.footerView]; 
    } else {
        //[self.tableView setTableFooterView:self.emptyView]; 
        footerView.hidden = YES; 
    }
    if (titleString != nil) {
        titleLabel.text = titleString;
    }

    //mainTable.frame = CGRectMake(0, 0, 320, 270);
    
    currPage = 1;
	scale = 25;
	nickNameToSearch = @"";
}

- (void)viewDidUnload
{
    [titleLabel release];
    titleLabel = nil;
    [super viewDidUnload];
    

    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void) viewWillAppear:(BOOL)animated {
	MY_LOG(@"NeighborInviteViewController new");
    
    if (![UserContext sharedUserContext].cpFacebook.isConnected) { // 연결 해제 되었는데
        if ([cellDataList count] > 0) {
            [cellDataList removeAllObjects];
            footerView.frame = CGRectMake(0, footerView.frame.origin.y, 320, 200);
            footerView.hidden = YES; 
            [mainTable.tableFooterView setFrame:footerView.frame];
            [mainTable setTableFooterView:footerView]; 
            [mainTable reloadData];
            [footerTable reloadData];
        }
    } else { // 연결되어있는데 
        if ([cellDataList count] <= 0) { // 데이타가 없으면
            isLoaded = NO;
        }
    }
    
    if (!isLoaded) {
        currPage = 1;
		[cellDataList removeAllObjects];
		[self cpNeighborListRequest];
	}
     
    [super viewWillAppear:animated];
}

- (void) viewWillDisappear:(BOOL)animated {

}

- (void) cpNeighborListRequest {
    if( [UserContext sharedUserContext].cpFacebook.isConnected ) {
        self.cpNeighborList = [[[CpNeighborList alloc] init] autorelease];
        cpNeighborList.delegate = self;
        [cpNeighborList.params addEntriesFromDictionary:[NSDictionary dictionaryWithObject:nickNameToSearch forKey:@"nickName"]];
        [cpNeighborList.params addEntriesFromDictionary:[NSDictionary dictionaryWithObject:@"52" forKey:@"cpCode"]];
        [cpNeighborList.params addEntriesFromDictionary:[NSDictionary dictionaryWithObject:@"0" forKey:@"isSnsUser"]];
        [cpNeighborList.params addEntriesFromDictionary:[NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"%d", scale] forKey:@"scale"]];
        [cpNeighborList.params addEntriesFromDictionary:[NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"%d", currPage] forKey:@"currPage"]];
        
        [cpNeighborList request];
    }   
}

#pragma mark -
#pragma mark ImInProtocol

- (void) apiDidLoadWithResult:(NSDictionary*)result whichObject:(NSObject*) theObject
{
    if ([[result objectForKey:@"func"] isEqualToString:@"cpNeighborList"]) { 
        MY_LOG(@"cpNeighborList result => %@", result);
        if ([[result objectForKey:@"result"] boolValue]) {
            NSArray* resultList = [result objectForKey:@"data"];
            
            for (NSDictionary *data in resultList) 
            {
                [cellDataList addObject:data];
            }
            
            scale = [(NSNumber*)[result objectForKey:@"scale"] intValue];
            currPage = [(NSNumber*)[result objectForKey:@"currPage"] intValue];
            totalCnt = [(NSNumber*)[result objectForKey:@"totalCnt"] intValue];
            MY_LOG(@"count = %d", [cellDataList count]);
            if ([cellDataList count] > 0) {
                footerView.frame = CGRectMake(0, footerView.frame.origin.y, 320, (66*[cellDataList count])+24);
                footerView.hidden = NO; 
            } else {
                footerView.frame = CGRectMake(0, footerView.frame.origin.y, 320, 200);
                footerView.hidden = YES; 
            }
            isLoaded = YES;

            [mainTable.tableFooterView setFrame:footerView.frame];
            [mainTable setTableFooterView:footerView]; 
            
            [mainTable reloadData];
            [footerTable reloadData];
            
        } else {
            MY_LOG(@"초대리스트 실패");
        }
	}
    if ([[result objectForKey:@"func"] isEqualToString:@"sendMsg"]) {
		if (![[result objectForKey:@"result"] boolValue] || ![[result objectForKey:@"errCode"] isEqualToString:@"0"]) {		
			MY_LOG(@"result == false");
            
			return;
		} 
        
        // 성공
        if (![[[(SendMsg *)theObject params] objectForKey:@"cpCode"] isEqualToString:@"80"]) {
            [CommonAlert alertWithTitle:@"알림" message:@"초대장 게시를 성공했어요~"];
        }
	}
    if ([[result objectForKey:@"func"] isEqualToString:@"addLink"]) {
        if ([[result objectForKey:@"result"] boolValue]) {
            NSArray* dataList = [result objectForKey:@"data"];
            NSString* shortUrl = nil;
            for (NSDictionary *data in dataList) 
            {
                shortUrl = [data objectForKey:@"shortUrl"];
            }
            NSString *message = [NSString stringWithFormat:@"%@님이 아임IN으로 초대합니다.", [UserContext sharedUserContext].nickName];
            NSString *referenceURLString = shortUrl;
            NSString *appBundleID = @"com.paran.sns";
            NSString *appVersion = @"1.8.1";
            
            if ([[KakaoLinkCenter defaultCenter] canOpenKakaoLink]) { //설치 되어있으면
                [self snsInvite:@"80" msgType:@"9" msg:@"publicInvite"];
                [[KakaoLinkCenter defaultCenter] openKakaoLinkWithURL:referenceURLString 
                                                           appVersion:appVersion
                                                          appBundleID:appBundleID
                                                              message:message];
            } else {
                [CommonAlert alertWithTitle:@"알림" message:@"카카오톡이 설치되어있지 않습니다."];
                return;
            }
        } else {
            return;
        }
    }
}

- (void) apiFailed
{
	MY_LOG(@"실패");
}

- (IBAction) popViewController {
    GA3(@"친구초대", @"이전버튼", @"이웃초대내");
	[self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Table view data source
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (!(tableView == mainTable)) {
        if ([cellDataList count] > 0) {
            return 24;
        }
    } 
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section  //2
{
    if (tableView == mainTable) {
        return [[[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 24.0f)] autorelease];
    } else {
        return [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"friend_title_facebookinvite.png"]] autorelease];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {  //4
    if (tableView == mainTable) {
        return 47;
    } else {
        return 66;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView  //1
{
    if (tableView == mainTable) {
        return 3;
    } else {
        return 1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section  //3
{
    if (tableView == mainTable) {
        return 1;
    } else {
        return [cellDataList count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    static NSString *CellIdentifier = @"Cell";
//
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
//    if (cell == nil) {
//        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
//    }
//    return cell;
    
    
    static NSString *CellIdentifier;
    if (tableView == mainTable) {
        CellIdentifier = @"InviteCell";
    } else {
        CellIdentifier = @"FacebookCell";   
    }
    
    // Configure the cell...
    if (tableView == mainTable) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        }
        
        cell.textLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:16.0];
        cell.textLabel.textColor = RGB(17, 17, 17);
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        cell.accessoryType = UITableViewCellAccessoryNone;
        
        UIImageView* snsIcon = nil;
        switch (indexPath.section) {
            case 0:
                snsIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"friend_icon_kakao_on.png"]];
                cell.textLabel.text = @"         카카오톡으로 직접 초대하기";
                break;
            case 1:
                snsIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"friend_icon_facebook_on.png"]];
                cell.textLabel.text = @"         내 담벼락에 초대장 남기기";
                break;
            case 2:
                snsIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"friend_icon_twitter_on.png"]];
                cell.textLabel.text = @"         초대장 트윗하기";
                break;
            default:
                break;
        }
        [snsIcon setFrame:CGRectMake(11+9, 10, 27, 27)];
        [cell addSubview:snsIcon];
        [snsIcon release];
        return cell;
    } 
    else { // 리스트 테이블
        SNSInvitationTableCell *cell = (SNSInvitationTableCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            NSArray* nibObjects = [[NSBundle mainBundle] loadNibNamed:@"SNSInvitationTableCell" owner:nil options:nil];	
            
            for (id currentObject in nibObjects) {
                if([currentObject isKindOfClass:[SNSInvitationTableCell class]]) {
                    cell = (SNSInvitationTableCell*) currentObject;
                    cell.cellType = IMIN_CELLTYPE_INVITE_FACEBOOK;
                }
            }
        }
        
        if ([cellDataList count] > indexPath.row) { // cellDataList를 미쳐 가져오기 전에 테이블 뷰를 그려줘야 하는 문제를 방지하기 위해 삽입한 조건
            cell.cellDataList = cellDataList;
			cell.cellDataListIndex = indexPath.row;
			NSDictionary* cellData = [cellDataList objectAtIndex:indexPath.row];
			[cell redrawCellWithDictionary:cellData];
		}

        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [[tableView cellForRowAtIndexPath:indexPath] setSelected:FALSE animated:YES];
    
    if (tableView == mainTable) {
        switch (indexPath.section) {
            case 0:
                GA3(@"친구초대", @"카카오톡으로초대", @"이웃초대내");
                [self kakaotokInvite];
                break;
            case 1:
                if ([UserContext sharedUserContext].cpFacebook.isConnected) {
                    GA3(@"친구초대", @"페이스북으로초대", @"이웃초대내");
                    [self snsInvite:@"52" msgType:@"3" msg:@"publicInvite"];
                } else {
                    NSString* temp = [NSString stringWithFormat:@"sitename=facebook.com&appname=%@&env=app&rturl=%@&cskey=%@&atkey=%@", [IMIN_APP_NAME URLEncodedString], [CALLBACK_URL URLEncodedString], [SNS_CONSUMER_KEY  URLEncodedString], [[UserContext sharedUserContext].token URLEncodedString]] ;
                    
                    OAuthWebViewController* webViewCtrl = [[[OAuthWebViewController alloc] init] autorelease];
                    webViewCtrl.requestInfo = [NSString stringWithFormat:@"%@?%@", OAUTH_URL, temp] ;
                    webViewCtrl.webViewTitle = @"facebook 설정";
                    webViewCtrl.authType = FB_TYPE;
                    
                    [webViewCtrl setHidesBottomBarWhenPushed:YES];
                    [(UINavigationController*)[ViewControllers sharedViewControllers].tabBarController.selectedViewController pushViewController:webViewCtrl animated:YES];
                    
                    return;
                }
                break;
            case 2:
                if ([UserContext sharedUserContext].cpTwitter.isConnected) {
                    GA3(@"친구초대", @"트위터로초대", @"이웃초대내");
                    [self snsInvite:@"51" msgType:@"3" msg:@"publicInvite"];
                } else {
                    NSString* temp = [NSString stringWithFormat:@"sitename=twitter.com&appname=%@&env=app&rturl=%@&cskey=%@&atkey=%@", [IMIN_APP_NAME URLEncodedString], [CALLBACK_URL URLEncodedString], [SNS_CONSUMER_KEY  URLEncodedString], [[UserContext sharedUserContext].token URLEncodedString]] ;
                    
                    OAuthWebViewController* webViewCtrl = [[[OAuthWebViewController alloc] init] autorelease];
                    webViewCtrl.requestInfo = [NSString stringWithFormat:@"%@?%@", OAUTH_URL, temp] ;
                    webViewCtrl.webViewTitle = @"twitter 설정";
                    webViewCtrl.authType = TWITTER_TYPE;
                    
                    [webViewCtrl setHidesBottomBarWhenPushed:YES];
                    [(UINavigationController*)[ViewControllers sharedViewControllers].tabBarController.selectedViewController pushViewController:webViewCtrl animated:YES];
                    
                    return;
                }
                break;
            default:
                break;
        }
    } 
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)kakaotokInvite {
    //설치여부확인하고
    //실행해서 선택한곳에 메세지 날리기 (비틀리유알엘처리후)
    NSString *url = [NSString stringWithFormat:@"http://www.im-in.com/%@", [UserContext sharedUserContext].nickName];

    self.addLink = [[[AddLink alloc] init] autorelease];
    addLink.delegate = self;
    [addLink.params addEntriesFromDictionary:[NSDictionary dictionaryWithObject:url forKey:@"link"]];

    [addLink request];    
}

- (void)snsInvite:(NSString*)cpCode msgType:(NSString*)msgType msg:(NSString*)msg {
    //초대메세지 날리기
    //www.im-in.com/snsID
    
    self.sendMsg = [[[SendMsg alloc] init] autorelease];
    sendMsg.delegate = self;
    [sendMsg.params addEntriesFromDictionary:[NSDictionary dictionaryWithObject:msgType forKey:@"msgType"]];
    [sendMsg.params addEntriesFromDictionary:[NSDictionary dictionaryWithObject:cpCode forKey:@"cpCode"]];
    [sendMsg.params addEntriesFromDictionary:[NSDictionary dictionaryWithObject:msg forKey:@"msg"]];
    
    [sendMsg request];
}

- (void) doRequestMore 
{
	int lastPage = totalCnt / scale + 1;
	if (currPage >= lastPage) {
		//[CommonAlert alertWithTitle:@"안내" message:@"마지막 페이지입니다."];
		return;
	}
	currPage++;
	[self cpNeighborListRequest];
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

- (void)dealloc {
    [cellDataList release];
    [sendMsg release];
    [cpNeighborList release];
    [addLink release];
    [titleLabel release];
    [titleString release];
    
    [super dealloc];
}
@end
