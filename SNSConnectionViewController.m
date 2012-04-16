//
//  SNSConnectionViewController.m
//  ImIn
//
//  Created by choipd on 10. 7. 30..
//  Copyright 2010 edbear. All rights reserved.
//

#import "SNSConnectionViewController.h"
#import "Me2dayViewController.h"
#import "ViewControllers.h"

#import "UserContext.h"
#import "CgiStringList.h"
#import "HttpConnect.h"
#import "JSON.h"
#import "CommonAlert.h"

#import "CpData.h"

#import "FBInvitationViewController.h"
#import "TwitterInvitationViewController.h"
#import "OAuthWebViewController.h"
#import "NSString+URLEncoding.h"
#import "GetDelivery.h"
#import "DelDelivery.h"


@implementation SNSConnectionViewController

@synthesize getDelivery, delDelivery;

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

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

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void) viewWillAppear:(BOOL)animated {
	[self getDeriveryInfo];
}
- (void)dealloc {
    [getDelivery release];
    [delDelivery release];
    
    [super dealloc];
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 3;
}

//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
//
//	NSString* retString = @"";
//	switch (section) {
//		case 0:
//			retString = @"twitter 설정";
//			break;
//		case 1:
//			retString = @"facebook 설정";
//			break;
//		default:
//			break;
//	}
//	
//	return retString;
//}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
	NSInteger retValue = 0;
	switch (section) {
		case 0:
			
			if ([UserContext sharedUserContext].cpTwitter.isConnected) {
				retValue = 1;
			} else {
				retValue = 1;
			}

			break;

		case 1:

			if ([UserContext sharedUserContext].cpFacebook.isConnected) {
				retValue = 1;
			} else {
				retValue = 1;
			}
			
			break;
		case 2:
			if ([UserContext sharedUserContext].cpMe2day.isConnected) {
				retValue = 1;
			}
			else {
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
	
	UISwitch* twitterSwitch = (UISwitch*)[cell viewWithTag:51];
	if (twitterSwitch != nil) {
		[twitterSwitch removeFromSuperview];
	}
	UISwitch* facebookSwitch = (UISwitch*)[cell viewWithTag:52];
	if (facebookSwitch) {
		[facebookSwitch removeFromSuperview];
	}
	UISwitch* me2daySwitch = (UISwitch*)[cell viewWithTag:50];
	if (me2daySwitch) {
		[me2daySwitch removeFromSuperview];
	}
	
	
	// Configure the cell...
	UserContext* uc = [UserContext sharedUserContext];
	switch ( indexPath.section ) {
		case 0:
		{
			UIImageView* snsIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_find_twitter.png"]];
			[snsIcon setFrame:CGRectMake(11+9, 10, 27, 27)];
			[cell addSubview:snsIcon];
			[snsIcon release];

			if (uc.cpTwitter.isConnected) {
				switch (indexPath.row) {
					case 0:
						cell.textLabel.text = [NSString stringWithFormat:@"       @%@ 연결 해제하기", uc.cpTwitter.blogId];
						cell.accessoryType = UITableViewCellAccessoryNone;
						break;
					default:
						break;
				}
			} else {
				cell.textLabel.text = @"       연결하기";
				cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			}
			break;
		}
		case 1: 
		{
			UIImageView* snsIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_find_facebook.png"]];
			[snsIcon setFrame:CGRectMake(11+9, 10, 27, 27)];
			[cell addSubview:snsIcon];
			[snsIcon release];
			
			if (uc.cpFacebook.isConnected) {
				switch (indexPath.row) {
					case 0:
						cell.textLabel.text = [NSString stringWithFormat:@"       %@ 연결 해제하기", uc.cpFacebook.userName];
						cell.accessoryType = UITableViewCellAccessoryNone;						
						break;
					default:
						break;
				}
			} else {
				cell.textLabel.text = @"       연결하기";
				cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			}
			break;
		}
		case 2:
		{
			UIImageView* snsIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_find_me2.png"]];
			[snsIcon setFrame:CGRectMake(11+9, 10, 27, 27)];
			[cell addSubview:snsIcon];
			[snsIcon release];
			
			if (uc.cpMe2day.isConnected) 
			{
				switch (indexPath.row) 
				{
					case 0:
						cell.textLabel.text = [NSString stringWithFormat:@"       %@ 연결 해제하기", uc.cpMe2day.blogId];
						cell.accessoryType = UITableViewCellAccessoryNone;
						break;
					default:
						break;
				}
			} 
			else 
			{
				cell.textLabel.text = @"       연결하기";
				cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			}
			break;
		}
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
				case 0: // 트위터 연결하기 or 연결 끊기
					if (uc.cpTwitter.isConnected) {
						//끊어 주삼
						[self delDeriveryTwitter];
					} else {
						NSString* temp = [NSString stringWithFormat:@"sitename=twitter.com&appname=%@&env=app&rturl=%@&cskey=%@&atkey=%@", [IMIN_APP_NAME URLEncodedString], [CALLBACK_URL URLEncodedString], [SNS_CONSUMER_KEY  URLEncodedString], [[UserContext sharedUserContext].token URLEncodedString]] ;
					
						OAuthWebViewController* webViewCtrl = [[[OAuthWebViewController alloc] init] autorelease];
                        MY_LOG(@"URL: %@", [NSString stringWithFormat:@"%@?%@", OAUTH_URL, temp]);
						webViewCtrl.requestInfo = [NSString stringWithFormat:@"%@?%@", OAUTH_URL, temp] ;
						webViewCtrl.webViewTitle = @"twitter 설정";
						webViewCtrl.authType = TWITTER_TYPE;
						
						[webViewCtrl setHidesBottomBarWhenPushed:YES];
						[(UINavigationController*)[ViewControllers sharedViewControllers].settingViewController pushViewController:webViewCtrl animated:YES];
									
					}					
					break;
				case 1:	// 트위터 글 보내기 사용 설정
					// TODO: setDelivery 구현 
					break;
				case 2: // 친구 목록 가져오기
				{
					TwitterInvitationViewController* vc = [[[TwitterInvitationViewController alloc]
													   initWithNibName:@"TwitterInvitationViewController" bundle:nil] autorelease];
					[vc refreshTwitterList];
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
				case 0: // fb 연결하기 or 연결 끊기
					if (uc.cpFacebook.isConnected) {
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
				case 1:	// 페이스북 글 보내기 사용 설정
					// TODO: setDelivery 구현
//					
//					break;
//				case 2: // 친구 목록 가져오기
				{
					FBInvitationViewController* vc = [[[FBInvitationViewController alloc]
													   initWithNibName:@"FBInvitationViewController" bundle:nil] autorelease];
					[vc refreshFacebookList];
					break;
				}	
				default:
					break;
			}
			break;
		}
			
		case 2:  // 미투데이 연결하기
		{
			switch (indexPath.row) {
				case 0: // me2Day 연결하기 or 연결 끊기
				{
					if (uc.cpMe2day.isConnected) 
					{
						//끊어 주삼
						[self delDeriveryMe2day];
					} else {
						Me2dayViewController* vc = [[Me2dayViewController alloc] initWithNibName:@"Me2dayViewController" bundle:nil];
						[(UINavigationController*)[ViewControllers sharedViewControllers].settingViewController pushViewController:vc animated:YES];
						[vc release];			
					}					
					break;
				}
				case 1:	// me2Day 글 보내기 사용 설정
				{
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
    
//	UserContext* userContext = [UserContext sharedUserContext];
//	
//    
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
//	[myTableView reloadData];
//}
//
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
#pragma mark delDeriveryWithCpData


- (IBAction) delDeriveryWithCpData:(CpData*) cpData
{
    self.delDelivery = [[[DelDelivery alloc] init] autorelease];
    delDelivery.delegate = self;
    
    [delDelivery.params addEntriesFromDictionary:[NSDictionary dictionaryWithObjectsAndKeys:cpData.cpCode, @"cpCode", 
                                                  cpData.blogId, @"blogId", nil]];
    
    [delDelivery request];
    
    
//	UserContext* userContext = [UserContext sharedUserContext];
//	
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
//		if ([cpCode isEqualToString:@"50"]) {
//			[uc.cpMe2day clearData];
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

- (void) apiFailed {
	MY_LOG(@"API 에러");
}

- (void) apiDidLoad:(NSDictionary *)result {
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
            
            if ([cpCode isEqualToString:@"50"]) {
                [uc.cpMe2day clearData];
            }
            
            [myTableView reloadData];
        }
    }
}

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

- (IBAction) delDeriveryMe2day
{
	UserContext* uc = [UserContext sharedUserContext];
	if (uc.cpMe2day.isConnected) {
		UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"알림" message:@"me2day 연결을 해제하시겠어요?" 
														delegate:self cancelButtonTitle:@"취소" otherButtonTitles:@"설정해제", nil] autorelease];
		alert.tag = 102;
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
		}
		return;
	}
	
	if (alertView.tag == 102)
	{
		if(buttonIndex == 1)
		{
			MY_LOG(@"me2day 연결해제 시킨다.");
			UserContext* uc = [UserContext sharedUserContext];
			if (uc.cpMe2day.isConnected) 
			{
				[self delDeriveryWithCpData:uc.cpMe2day];
			}
		}
		return;
	}
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	MY_LOG(@"connectionDidFinishLoading");
}
@end
