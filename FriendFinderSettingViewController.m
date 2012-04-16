//
//  FriendFinderSettingViewController.h.m
//  ImIn
//
//  Created by choipd on 10. 7. 30..
//  Copyright 2010 edbear. All rights reserved.
//

#import "FriendFinderSettingViewController.h"
#import "ViewControllers.h"

#import "UserContext.h"
#import "CgiStringList.h"
#import "HttpConnect.h"
#import "JSON.h"
#import "CommonAlert.h"

#import "CpData.h"

#import "FBInvitationViewController.h"
#import "TwitterInvitationViewController.h"
#import "CheckMyPhoneViewController.h"

#import "ProfileUpdate.h"
#import "PhoneNeighborList.h"
#import "GetDelivery.h"
#import "DelDelivery.h"

#import "define.h"
#import "OAuthWebViewController.h"
#import "NSString+URLEncoding.h"

@implementation FriendFinderSettingViewController
@synthesize fbVC, twVC, profileUpdate, phoneNeighborList, getDelivery, delDelivery;


- (void) viewWillDisappear:(BOOL)animated {
	if (connect1 != nil)
	{
		[connect1 stop];
		[connect1 release];
		connect1 = nil;
	}
}


- (IBAction) popViewController {
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void) viewDidLoad
{
    UIView* aView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 70)] autorelease];
    UILabel* aLabel = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 70)] autorelease];
    aLabel.textAlignment = UITextAlignmentCenter;
    aLabel.text = @"내 주소록 혹은 다른 서비스의\n친구 목록 가져오기 합니다.";
    aLabel.numberOfLines = 2;
    aLabel.font = [UIFont systemFontOfSize:12.0f];
    aLabel.backgroundColor = [UIColor clearColor];
    aLabel.textColor = RGB(17, 17, 17);
    
    [aView addSubview:aLabel];
    myTableView.tableFooterView = aView;
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void) viewWillAppear:(BOOL)animated {
	[self getDeriveryInfo];
}

- (void)dealloc {
	[twVC release];
	[fbVC release];
	[phoneNeighborList release];
	[profileUpdate release];
    [getDelivery release];
    [delDelivery release];

    [super dealloc];
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
	NSInteger retValue = 0;
	
	switch (section) {
		case 0:
			if ([UserContext sharedUserContext].cpPhone.isConnected) {
				retValue = 2;
			} else {
				retValue = 1;
			}
			break;
			
		case 1:
			if ([UserContext sharedUserContext].cpTwitter.isConnected) {
				retValue = 2;
			} else {
				retValue = 1;
			}
			break;
			
		case 2:
			if ([UserContext sharedUserContext].cpFacebook.isConnected&& [UserContext sharedUserContext].cpFacebook.isCpNeighbor) {
				retValue = 2;
			} else {
				retValue = 1;
			}
			break;
	}
	
	return retValue;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 48.0;
}



// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier;
	
	CellIdentifier = @"Cell";
	
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		
		cell.selectionStyle = UITableViewCellSelectionStyleGray;
	}
	
	// Configure the cell...
	UserContext* uc = [UserContext sharedUserContext];
	UIImageView* snsIcon;
	switch ( indexPath.section ) {
		case 0:
			snsIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_find_call.png"]];
			[snsIcon setFrame:CGRectMake(11+9, 10, 27, 27)];
			[cell addSubview:snsIcon];
			[snsIcon release];
			
			if (uc.cpPhone.isConnected) {
				switch (indexPath.row) {
					case 0:
						cell.textLabel.text = @"       연결 해제하기";
						cell.accessoryType = UITableViewCellAccessoryNone;
						break;
					case 1:
						cell.textLabel.text = @"       폰 주소록 다시 가져오기";
						cell.accessoryType = UITableViewCellAccessoryNone;
						break;
					default:
						break;
				}
			} else {
				cell.textLabel.text = @"       폰 주소록연결하기";
				cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			}
			break;
			
		case 1:
			snsIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_find_twitter.png"]];
			[snsIcon setFrame:CGRectMake(11+9, 10, 27, 27)];
			[cell addSubview:snsIcon];
			[snsIcon release];
			
			if (uc.cpTwitter.isConnected) {
				switch (indexPath.row) {
					case 0:
						cell.textLabel.text = @"       트위터 연결 해제하기";
						cell.accessoryType = UITableViewCellAccessoryNone;
						break;
					case 1:
						cell.textLabel.text = @"       트위터 정보 다시 가져오기";
						cell.accessoryType = UITableViewCellAccessoryNone;
						break;
					default:
						break;
				}
			} else {
				cell.textLabel.text = @"       트위터 연결하기";
				cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			}
			break;

		case 2:
			snsIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_find_facebook.png"]];
			[snsIcon setFrame:CGRectMake(11+9, 10, 27, 27)];
			[cell addSubview:snsIcon];
			[snsIcon release];
		
			MY_LOG(@"uc.cpFacebook.isCpNeighbor = %d", uc.cpFacebook.isCpNeighbor);
			if (uc.cpFacebook.isConnected && uc.cpFacebook.isCpNeighbor) {
				switch (indexPath.row) {
					case 0:
						cell.textLabel.text = @"       페이스북 연결 해제하기";
						cell.accessoryType = UITableViewCellAccessoryNone;						
						break;
					case 1:
						cell.textLabel.text = @"       페이스북 정보 다시 가져오기";
						cell.accessoryType = UITableViewCellAccessoryNone;						
						break;
					default:
						break;
				}
			} else {
				cell.textLabel.text = @"       페이스북 연결하기";
				cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			}
			break;
	}
	
	return cell;
}


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	UserContext* uc = [UserContext sharedUserContext];
	switch ( indexPath.section ) {
		case 0:
		{
			switch (indexPath.row) {
				case 0: // 폰주소록 연결하기 or 연결 끊기
					if (uc.cpPhone.isConnected) {
						//끊어 주삼
						[self deletePhoneNoAndClearPhoneList];
						
					} else {
						CheckMyPhoneViewController *vc = [[[CheckMyPhoneViewController alloc]initWithNibName:@"CheckMyPhoneViewController" bundle:nil] autorelease];
						[(UINavigationController*)[ViewControllers sharedViewControllers].settingViewController pushViewController:vc animated:YES];
					}					
					break;
				case 1:	// 친구 목록 다시 가져오기
				{
					[self refreshPhoneList];
					break;
				}	
				default:
					break;
			}
			break;
		}

		case 1:
		{
			switch (indexPath.row) {
				case 0: // 트위터 연결하기 or 연결 끊기
					if (uc.cpTwitter.isConnected) {
						//끊어 주삼
						[self delDeriveryTwitter];
					} else {
						NSString* temp = [NSString stringWithFormat:@"sitename=twitter.com&appname=%@&env=app&rturl=%@&cskey=%@&atkey=%@", [IMIN_APP_NAME URLEncodedString], [CALLBACK_URL URLEncodedString], [SNS_CONSUMER_KEY  URLEncodedString], [[UserContext sharedUserContext].token URLEncodedString]] ;
                        
						OAuthWebViewController* webViewCtrl = [[[OAuthWebViewController alloc] init] autorelease];
						webViewCtrl.requestInfo = [NSString stringWithFormat:@"%@?%@", OAUTH_URL, temp] ;
						webViewCtrl.webViewTitle = @"twitter 설정";
						webViewCtrl.authType = TWITTER_TYPE;
						
						[webViewCtrl setHidesBottomBarWhenPushed:YES];
						[(UINavigationController*)[ViewControllers sharedViewControllers].settingViewController pushViewController:webViewCtrl animated:YES];
                    }					
					break;
				case 1:	// 친구 목록 다시 가져오기
				{
					self.twVC = [[[TwitterInvitationViewController alloc]
								  initWithNibName:@"TwitterInvitationViewController" bundle:nil] autorelease];
					[self.twVC refreshTwitterList];
					break;
				}	
				default:
					break;
			}
			break;
		}
			
			
		case 2:
		{
			switch (indexPath.row) {
				case 0: // fb 연결하기 or 연결 끊기
					if (uc.cpFacebook.isConnected&&uc.cpFacebook.isCpNeighbor) {
						//끊어 주삼
						[self delDeriveryFacebook];
					} else {
						NSString* temp = [NSString stringWithFormat:@"sitename=facebook.com&appname=%@&env=app&rturl=%@&cskey=%@&atkey=%@", [IMIN_APP_NAME URLEncodedString], [CALLBACK_URL URLEncodedString], [SNS_CONSUMER_KEY  URLEncodedString], [[UserContext sharedUserContext].token URLEncodedString]] ;
						
						OAuthWebViewController* webViewCtrl = [[[OAuthWebViewController alloc] init] autorelease];
						webViewCtrl.requestInfo = [NSString stringWithFormat:@"%@?%@", OAUTH_URL, temp] ;
						webViewCtrl.webViewTitle = @"facebook 설정";
						webViewCtrl.authType = FB_TYPE;
						
						[webViewCtrl setHidesBottomBarWhenPushed:YES];
						[(UINavigationController*)[ViewControllers sharedViewControllers].settingViewController pushViewController:webViewCtrl animated:YES];	
					}					
					break;
				case 1:	// 친구 목록 다시 가져오기
				{
					self.fbVC = [[[FBInvitationViewController alloc]
													   initWithNibName:@"FBInvitationViewController" bundle:nil] autorelease];
					[self.fbVC refreshFacebookList];
					break;
				}	
				default:
					break;
			}
			break;
		}
	}
	
	[self.navigationController dismissModalViewControllerAnimated:YES];
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}


#pragma mark -
#pragma mark getDeriveryInfo

- (IBAction) getDeriveryInfo
{
    self.getDelivery = [[[GetDelivery alloc] init] autorelease];
    getDelivery.delegate = self;
    
    [getDelivery request];
    

//    UserContext* userContext = [UserContext sharedUserContext];
//	CgiStringList* strPostData=[[CgiStringList alloc]init:@"&"];
//	[strPostData setMapString:@"svcId" keyvalue:SNS_IPHONE_SVCID];
//    [strPostData setMapString:@"appVer" keyvalue:[ApplicationContext appVersion]];
//	[strPostData setMapString:@"device" keyvalue:SNS_DEVICE_MOBILE_APP];	
//	[strPostData setMapString:@"at" keyvalue:@"1"];
//	[strPostData setMapString:@"av" keyvalue:userContext.snsID];	
//	
//	if (connect1 != nil)
//	{
//		[connect1 stop];
//		[connect1 release];
//		connect1 = nil;
//	}
//	
//	connect1 = [[HttpConnect alloc] initWithURL:PROTOCOL_GET_DELIVERY
//									   postData: [strPostData description]
//									   delegate: self
//								   doneSelector: @selector(onGetDeliveryTransDone:)    
//								  errorSelector: @selector(onGetDeliveryResultError:)  
//							   progressSelector: nil];
//	[strPostData release];
}

//- (void) onGetDeliveryTransDone:(HttpConnect*)up
//{
//	MY_LOG(@"<--\nGetDelivery %@\n-->", up.stringReply);
//	
//	SBJSON* jsonParser = [SBJSON new];
//	[jsonParser setHumanReadable:YES];
//	
//	NSDictionary* results = (NSDictionary *)[jsonParser objectWithString:up.stringReply error:NULL];
//	[jsonParser release];
//	
//	if (connect1 != nil)
//	{
//		[connect1 release];
//		connect1 = nil;
//	}
//	
//	NSNumber* resultNumber = (NSNumber*)[results objectForKey:@"result"];
//	
//	if ([resultNumber intValue] == 0) { //에러처리
//		[CommonAlert alertWithTitle:@"에러" message:[results objectForKey:@"description"]];
//		return;
//	}
//	
//	UserContext* uc = [UserContext sharedUserContext];
//	
//	[uc.cpTwitter clearData];
//	[uc.cpFacebook clearData];
//	[uc.cpMe2day clearData];
//	
//	//[strPostData setMapString:@"isCpNeighbor" keyvalue:isCpNeighbor];
//	
//	NSArray* resultList = [results objectForKey:@"data"];
//	for (NSDictionary* data in resultList) {
//		NSString* cpCode = [data objectForKey:@"cpCode"];
//				
//		if ([cpCode isEqualToString:@"51"]) { // twitter
//			uc.cpTwitter = [[[CpData alloc] initWithDictionary:data] autorelease];
//		}
//		
//		if ([cpCode isEqualToString:@"52"]) { // facebook
//			uc.cpFacebook = [[[CpData alloc] initWithDictionary:data] autorelease];
//		}
//		
//		if ([cpCode isEqualToString:@"50"]) { // me2day
//			uc.cpMe2day = [[[CpData alloc] initWithDictionary:data] autorelease];
//		}
//	}
//	
//	if (uc.cpTwitter == nil) {
//		uc.cpTwitter = [[[CpData alloc] init] autorelease];
//	}
//	
//	if (uc.cpFacebook == nil) {
//		uc.cpFacebook = [[[CpData alloc] init] autorelease];
//	}
//	
//	if (uc.cpMe2day == nil) {
//		uc.cpMe2day = [[[CpData alloc] init] autorelease];
//	}
//	
//	
//	[myTableView reloadData];
//}

//- (void) onGetDeliveryResultError:(HttpConnect*)up 
//{
//	MY_LOG(@"%@", up.stringReply);
//	if (connect1 != nil)
//	{
//		[connect1 release];
//		connect1 = nil;
//	}
//}


#pragma mark -
#pragma mark delDerivery


- (IBAction) delDeriveryWithCpData:(CpData*) cpData
{
    self.delDelivery = [[[DelDelivery alloc] init] autorelease];
    delDelivery.delegate = self;
    
    [delDelivery.params addEntriesFromDictionary:[NSDictionary dictionaryWithObjectsAndKeys:cpData.cpCode, @"cpCode", 
                                                  cpData.blogId, @"blogId", nil]];
    
    [delDelivery request];
    
//	UserContext* userContext = [UserContext sharedUserContext];    
//	CgiStringList* strPostData=[[CgiStringList alloc]init:@"&"];
//	[strPostData setMapString:@"svcId" keyvalue:SNS_IPHONE_SVCID];
//    [strPostData setMapString:@"appVer" keyvalue:[ApplicationContext appVersion]];
//	[strPostData setMapString:@"device" keyvalue:SNS_DEVICE_MOBILE_APP];	
//	[strPostData setMapString:@"at" keyvalue:@"1"];
//	[strPostData setMapString:@"av" keyvalue:userContext.snsID];
//	[strPostData setMapString:@"cpCode" keyvalue:cpData.cpCode];
//	[strPostData setMapString:@"blogId" keyvalue:cpData.blogId];
//	
//	
//	if (connect1 != nil)
//	{
//		[connect1 stop];
//		[connect1 release];
//		connect1 = nil;
//	}
//	
//	connect1 = [[HttpConnect alloc] initWithURL:PROTOCOL_DEL_DELIVERY
//									   postData: [strPostData description]
//									   delegate: self
//								   doneSelector: @selector(onDelDeliveryTransDone:)    
//								  errorSelector: @selector(onDelDeliveryResultError:)  
//							   progressSelector: nil];
//	[strPostData release];
}

//- (void) onDelDeliveryTransDone:(HttpConnect*)up 
//{
//	MY_LOG(@"<--\nGetDelivery %@\n-->", up.stringReply);
//	
//	SBJSON* jsonParser = [SBJSON new];
//	[jsonParser setHumanReadable:YES];
//	
//	NSDictionary* results = (NSDictionary *)[jsonParser objectWithString:up.stringReply error:NULL];
//	[jsonParser release];
//	
//	if (connect1 != nil)
//	{
//		[connect1 release];
//		connect1 = nil;
//	}
//	
//	NSNumber* resultNumber = (NSNumber*)[results objectForKey:@"result"];
//	
//	if ([resultNumber intValue] == 0) { //에러처리
//		[CommonAlert alertWithTitle:@"에러" message:[results objectForKey:@"description"]];
//		return;
//	} else {
//		
//		UserContext* uc = [UserContext sharedUserContext];
//		NSString* cpCode = [results objectForKey:@"cpCode"];
//		
//		NSHTTPCookieStorage* cookies = [NSHTTPCookieStorage sharedHTTPCookieStorage];	
//		
//		if ([cpCode isEqualToString:@"51"]) {		
//			NSArray* twitterCookies = [cookies cookiesForURL:
//									   [NSURL URLWithString:@"http://twitter.com"]];
//			for (NSHTTPCookie* cookie in twitterCookies) {
//				[cookies deleteCookie:cookie];
//			}
//			
//			[uc.cpTwitter clearData];
//		}
//		
//		if ([cpCode isEqualToString:@"52"]) {
//			NSArray* facebookCookies = [cookies cookiesForURL:
//										[NSURL URLWithString:@"http://login.facebook.com"]];
//			for (NSHTTPCookie* cookie in facebookCookies) {
//				[cookies deleteCookie:cookie];
//			}	
//			
//			[uc.cpFacebook clearData];
//		}
//		
//		[myTableView reloadData];
//	}
//	
//	
//}
//
//- (void) onDelDeliveryResultError:(HttpConnect*)up 
//{
//	MY_LOG(@"%@", up.stringReply);
//	if (connect1 != nil)
//	{
//		[connect1 release];
//		connect1 = nil;
//	}
//}

- (IBAction) delDeriveryTwitter
{
	UserContext* uc = [UserContext sharedUserContext];
	if (uc.cpTwitter.isConnected) {
		UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"알림" message:@"twitter 연결을 해제하시겠어요?"
													   delegate:self cancelButtonTitle:@"취소" otherButtonTitles:@"설정해제", nil] autorelease];
		alert.tag = 100;
		[alert show];
	}
}

- (IBAction) delDeriveryFacebook
{
	UserContext* uc = [UserContext sharedUserContext];
	if (uc.cpFacebook.isConnected) {
		UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"알림" message:@"facebook 연결을 해제하시겠어요?"
													   delegate:self cancelButtonTitle:@"취소" otherButtonTitles:@"설정해제", nil] autorelease];
		alert.tag = 101;
		[alert show];
	}
}



- (void)alertView:(UIAlertView*)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (alertView.tag == 100)
	{
		if (buttonIndex == 1)
		{
			MY_LOG(@"트위터 연결해제 시킨다.");
			UserContext* uc = [UserContext sharedUserContext];
			if (uc.cpTwitter.isConnected) {
				[self delDeriveryWithCpData:uc.cpTwitter];
			}
		}
		return;
	}
	
	
	if (alertView.tag == 101)
	{
		if (buttonIndex == 1)
		{
			MY_LOG(@"페북 연결해제 시킨다.");
			UserContext* uc = [UserContext sharedUserContext];
			if (uc.cpFacebook.isConnected) {
				[self delDeriveryWithCpData:uc.cpFacebook];
			}
			//			NSString* logoutURL = @"http://www.facebook.com/logout.php";
			//			[NSURLConnection connectionWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:logoutURL]] delegate:self ];
		}
		return;
	}
	
	if (alertView.tag == 102) {
		if (buttonIndex == 1) {
			MY_LOG(@"폰인증 해제한다.");
			self.profileUpdate = [[[ProfileUpdate alloc] init] autorelease];
			profileUpdate.delegate = self;
			
			[profileUpdate.params addEntriesFromDictionary:[NSDictionary dictionaryWithObjectsAndKeys:@"-1", @"phoneNo",
                                                            [UserContext sharedUserContext].userProfile, @"profileImg",nil]];
			[profileUpdate request];
		}
	}
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	MY_LOG(@"connectionDidFinishLoading");
}

#pragma mark -
#pragma mark 폰번호 갱신 관련

- (void) deletePhoneNoAndClearPhoneList
{
	UserContext* uc = [UserContext sharedUserContext];
	if (uc.cpPhone.isConnected) {
		UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"알림" message:@"폰 인증을 해제하시겠어요?"
														delegate:self cancelButtonTitle:@"취소" otherButtonTitles:@"설정해제", nil] autorelease];
		alert.tag = 102;
		[alert show];
	}
}


- (void) refreshPhoneList
{
	[CommonAlert alertWithTitle:@"안내" message:@"폰 주소록 가져오기를 완료했습니다."];
//	self.phoneNeighborList = [[[PhoneNeighborList alloc] init] autorelease];
//	self.phoneNeighborList.delegate = self;
//	
//	NSDictionary* phoneBook = [[UserContext sharedUserContext] getPhoneBook];
//	
//	NSString* phoneNumberListString = @"";
//	
//	for (NSString* key in phoneBook) {
//		phoneNumberListString = [phoneNumberListString stringByAppendingString:key];
//		phoneNumberListString = [phoneNumberListString stringByAppendingString:@"|"];	
//	}
//	
//	self.phoneNeighborList.phoneNo = phoneNumberListString;
//	
//	[self.phoneNeighborList request];
}

- (void) apiFailed {
	MY_LOG(@"API 에러");
}

- (void) apiDidLoad:(NSDictionary *)result {
	
//	// phoneNeighborList API
//	if ([[result objectForKey:@"func"] isEqualToString:@"phoneNeighborList"]) {
//		if ([[result objectForKey:@"result"] boolValue]) {
//			[CommonAlert alertWithTitle:@"안내" message:@"폰 주소록 동기화에 성공했습니다."];
//		} // 에러인 경우는 이미 경고창을 띄웠기 때문에 띄워주지 않음.
//	}
	
	if ([[result objectForKey:@"func"] isEqualToString:@"profileUpdate"]) {
		if ([[result objectForKey:@"result"] boolValue]) {
			[CommonAlert alertWithTitle:@"안내" message:@"폰 인증을 해제했습니다."];
			UserContext* uc = [UserContext sharedUserContext];
			[uc.cpPhone clearData];
			[myTableView reloadData];
		} // 에러인 경우는 이미 경고창을 띄웠기 때문에 띄워주지 않음
	}
 
    if ([[result objectForKey:@"func"] isEqualToString:@"getDelivery"]) {
        NSNumber* resultNumber = (NSNumber*)[result objectForKey:@"result"];
        
        if ([resultNumber intValue] == 0) { //에러처리
            [CommonAlert alertWithTitle:@"에러" message:[result objectForKey:@"description"]];
            return;
        }
        
        UserContext* uc = [UserContext sharedUserContext];
        
        [uc.cpTwitter clearData];
        [uc.cpFacebook clearData];
        [uc.cpMe2day clearData];
        
        //[strPostData setMapString:@"isCpNeighbor" keyvalue:isCpNeighbor];
        
        NSArray* resultList = [result objectForKey:@"data"];
        for (NSDictionary* data in resultList) {
            NSString* cpCode = [data objectForKey:@"cpCode"];
            
            if ([cpCode isEqualToString:@"51"]) { // twitter
                uc.cpTwitter = [[[CpData alloc] initWithDictionary:data] autorelease];
            }
            
            if ([cpCode isEqualToString:@"52"]) { // facebook
                uc.cpFacebook = [[[CpData alloc] initWithDictionary:data] autorelease];
            }
            
            if ([cpCode isEqualToString:@"50"]) { // me2day
                uc.cpMe2day = [[[CpData alloc] initWithDictionary:data] autorelease];
            }
        }
        
        if (uc.cpTwitter == nil) {
            uc.cpTwitter = [[[CpData alloc] init] autorelease];
        }
        
        if (uc.cpFacebook == nil) {
            uc.cpFacebook = [[[CpData alloc] init] autorelease];
        }
        
        if (uc.cpMe2day == nil) {
            uc.cpMe2day = [[[CpData alloc] init] autorelease];
        }
        
        
        [myTableView reloadData];
    }
    
    if ([[result objectForKey:@"func"] isEqualToString:@"delDelivery"]) {
        NSNumber* resultNumber = (NSNumber*)[result objectForKey:@"result"];
        
        if ([resultNumber intValue] == 0) { //에러처리
            [CommonAlert alertWithTitle:@"에러" message:[result objectForKey:@"description"]];
            return;
        } else {
            
            UserContext* uc = [UserContext sharedUserContext];
            NSString* cpCode = [result objectForKey:@"cpCode"];
            
            NSHTTPCookieStorage* cookies = [NSHTTPCookieStorage sharedHTTPCookieStorage];	
            
            if ([cpCode isEqualToString:@"51"]) {		
                NSArray* twitterCookies = [cookies cookiesForURL:
                                           [NSURL URLWithString:@"http://twitter.com"]];
                for (NSHTTPCookie* cookie in twitterCookies) {
                    [cookies deleteCookie:cookie];
                }
                
                [uc.cpTwitter clearData];
            }
            
            if ([cpCode isEqualToString:@"52"]) {
                NSArray* facebookCookies = [cookies cookiesForURL:
                                            [NSURL URLWithString:@"http://login.facebook.com"]];
                for (NSHTTPCookie* cookie in facebookCookies) {
                    [cookies deleteCookie:cookie];
                }	
                
                [uc.cpFacebook clearData];
            }
            
            [myTableView reloadData];
        }
    }
}



@end
