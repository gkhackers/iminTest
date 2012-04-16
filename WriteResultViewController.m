//
//  WriteResult.m
//  ImIn
//
//  Created by choipd on 10. 5. 13..
//  Copyright 2010 edbear. All rights reserved.
//

#import "WriteResultViewController.h"
#import "ViewControllers.h"
#import "UIWebView+WebUI.h"
#import "UserContext.h"
// 통계관련
#import "NWAppUsageLogger.h"

#import "BadgeDetailView.h"
#import "BadgeAcquisitionViewController.h"
#import "NSString+URLEncoding.h"


@implementation WriteResultViewController
@synthesize resultData;
@synthesize left_jscall;
@synthesize urlString;

#pragma mark - WebAppGatewayProtocol Delegate

- (BOOL) willProcessUiDescriptionWithData:(NSDictionary*) data {    
    MY_LOG(@"willProcessUiDescriptionWithData");

    if ([data objectForKey:@"left_enable"]
        || [data objectForKey:@"title_text"]
        || [data objectForKey:@"left_jscall"]) {
        
        leftBtn.hidden = ![[data objectForKey:@"left_enable"] isEqualToString:@"y"];
        titleLabel.text = [data objectForKey:@"title_text"];
        
        self.left_jscall = [data objectForKey:@"left_jscall"];        
    }
    
    return YES;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
    }
    return self;
}

- (void) writeDone {
    GA1(@"발도장찍기완료");
    GA3(@"발도장찍기완료", nil, nil);

    NSArray* badgeList = [resultData objectForKey:@"data"];
    
//    if ([badgeList count] == 0) {
//		badgeList = [NSArray arrayWithObjects:
//					 [NSDictionary dictionaryWithObjectsAndKeys:
//					  @"45", @"badgeId", 
//					  @"Rider", @"badgeName",
//					  @"http://211.113.4.83/TOP/svc/imin/v1/img/badge/45_126x126_f_1.png", @"badgeImgUrl",
//					  @"축하해요~ Rider 뱃지짠~하셨어요~!", @"badgeGetMsg",
//					  @"도전! 한시간에 80km~130km 만큼 이동하여 발도장 찍으면 획득할 수 있어요~", @"badgeGuideMsg",
//					  @"exInfo", @"badgeDesc",
//					  @"1", @"actionType", nil], 
//					 [NSDictionary dictionaryWithObjectsAndKeys:
//					  @"46", @"badgeId", 
//					  @"훼라리", @"badgeName",
//					  @"http://211.113.4.83/TOP/svc/imin/v1/img/badge/46_126x126_f_1.png", @"badgeImgUrl",
//					  @"축하해요~ 훼라리 뱃지짠~하셨어요~!", @"badgeGetMsg",
//					  @"도전! 한시간에 80km~130km 만큼 이동하여 발도장 찍으면 획득할 수 있어요~", @"badgeGuideMsg",
//					  @"exInfo", @"badgeDesc",
//					  @"1", @"actionType", nil], nil];					 
//	}

    
	if ([badgeList count] != 0) {
		BadgeAcquisitionViewController* acquisitionVC = [[[BadgeAcquisitionViewController alloc] 
														  initWithNibName:@"BadgeAcquisitionViewController" bundle:nil] autorelease];
		acquisitionVC.badgeList = badgeList;
		
		[self.view addSubview:acquisitionVC.view];		
	}
	
	// 발도장 정보 통계 처리
	NWAppUsageLogger *logger = [NWAppUsageLogger logger];
	[logger fireUsageLog:@"FOOTSTAMP" andEventDesc:nil andCategoryId:nil];
}


- (IBAction) leftBtnClick
{
    if (left_jscall != nil) {
        [aWebView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"%@()", left_jscall]];        
    }
}

- (void)viewDidLoad {
	[super viewDidLoad];
    wagw = [[WebAppGatewayProtocol alloc] init];
    wagw.delegate = self;
    wagw.whichVC = self;
    wagw.whichWebView = aWebView;
    
    aWebView.delegate = self;
    
    realtimeBadge = [[RealtimeBadge alloc] init];
    realtimeBadge.delegate = self;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadList" object:nil userInfo:nil];
    
    NSArray* badgeList = [resultData objectForKey:@"data"];
//	if ([badgeList count] == 0) {
//		badgeList = [NSArray arrayWithObjects:
//					 [NSDictionary dictionaryWithObjectsAndKeys:
//					  @"45", @"badgeId", 
//					  @"Rider", @"badgeName",
//					  @"http://211.113.4.83/TOP/svc/imin/v1/img/badge/45_126x126_f_1.png", @"badgeImgUrl",
//					  @"축하해요~ Rider 뱃지짠~하셨어요~!", @"badgeGetMsg",
//					  @"도전! 한시간에 80km~130km 만큼 이동하여 발도장 찍으면 획득할 수 있어요~", @"badgeGuideMsg",
//					  @"exInfo", @"badgeDesc",
//					  @"1", @"actionType", nil], 
//					 [NSDictionary dictionaryWithObjectsAndKeys:
//					  @"46", @"badgeId", 
//					  @"훼라리", @"badgeName",
//					  @"http://211.113.4.83/TOP/svc/imin/v1/img/badge/46_126x126_f_1.png", @"badgeImgUrl",
//					  @"축하해요~ 훼라리 뱃지짠~하셨어요~!", @"badgeGetMsg",
//					  @"도전! 한시간에 80km~130km 만큼 이동하여 발도장 찍으면 획득할 수 있어요~", @"badgeGuideMsg",
//					  @"exInfo", @"badgeDesc",
//					  @"1", @"actionType", nil], nil];					 
//	}
	if ([badgeList count] > 0) {
		[realtimeBadge downloadImageWithArray:badgeList];		
	} else {
		[self writeDone];
	}
	
    [[NSURLCache sharedURLCache] removeAllCachedResponses];

    self.urlString = [NSString stringWithFormat:@"%@&title_text=%@", 
                                    [resultData objectForKey:@"wvUrl"],
                                    [@"발도장 찍기 결과" URLEncodedString]];
    
    if ([urlString rangeOfString:@"?"].location == NSNotFound) {
        self.urlString = [urlString stringByAppendingFormat:@"?wagw_ver=%@", [ApplicationContext sharedApplicationContext].wagwVersion];
    } else {
        self.urlString = [urlString stringByAppendingFormat:@"&wagw_ver=%@", [ApplicationContext sharedApplicationContext].wagwVersion];
    }
    
    NSURL* url = [NSURL URLWithString:urlString];

    if (url) {
        UserContext* uc = [UserContext sharedUserContext];
        NSMutableArray* aMutableArray = uc.snsCookieArray;
        
        if (aMutableArray != nil && [aMutableArray count] == 2) {
            NSString *cookieDomain = nil;
#ifdef APP_STORE_FINAL
            cookieDomain = @"http://im-in.paran.com";
#else
            cookieDomain = @"http://imindev.paran.com";
#endif
            
            //clearCookie
            NSHTTPCookieStorage* cookies = [NSHTTPCookieStorage sharedHTTPCookieStorage];
            NSArray* heartconCookies = [cookies cookiesForURL:
                                        [NSURL URLWithString:cookieDomain]];
            for (NSHTTPCookie* cookie in heartconCookies) {
                [cookies deleteCookie:cookie];
            }	
            
            for (int i=0; i<[[UserContext sharedUserContext].snsCookieArray count]; i++) {
                NSHTTPCookie *cookie = [[NSHTTPCookie alloc] initWithProperties:[[UserContext sharedUserContext].snsCookieArray objectAtIndex:i]];
                [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
                [cookie release];
            }
        }
        
        [aWebView loadRequest:[NSURLRequest requestWithURL:url]];
    }
    
    aWebView.autoresizesSubviews = YES; 
    aWebView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);    
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
    [[UserContext sharedUserContext] recordKissMetricsWithEvent:@"Check-in Result Page" withInfo:nil];
}

- (void) viewWillDisappear:(BOOL)animated {
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
    [ApplicationContext stopActivity];
}


- (void)dealloc {
    
    if (resultData != nil) {
        [resultData release];
    }
    
    if (wagw != nil) {
        [wagw release];
    }
    
    if (left_jscall != nil) {
        [left_jscall release];
    }
    if (urlString != nil) {
        [urlString release];
    }
    
    if (aWebView != nil) {
        [aWebView setDelegate:nil];
		[aWebView stopLoading];
		[aWebView release];		
	}

    [super dealloc];
}

- (IBAction) closeVC
{
    GA3(@"발도장찍기결과화면", @"닫기버튼", @"발도장찍기결과화면내");
    
    [ApplicationContext stopActivity];
    
    if (aWebView != nil) {
        [aWebView setDelegate:nil];
		[aWebView stopLoading];
		[aWebView release];		
	}
    
	[ApplicationContext sharedApplicationContext].shouldRotate = NO;
    if ([ApplicationContext osVersion] < 3.3) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"moveToTop" object:nil];
    }
  	[self dismissModalViewControllerAnimated:YES];    
}


#pragma mark -
#pragma mark webview delegate 
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType;
{
	NSURL *url = request.URL;
    MY_LOG(@"[wagw processWithUrl:url] = %d", [wagw processWithUrl:url]);
    return [wagw processWithUrl:url];
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [ApplicationContext runActivity];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [ApplicationContext stopActivity];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [ApplicationContext stopActivity];
    
    if (error.code == NSURLErrorTimedOut) {
        NSString *html = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"postError" ofType:@"html"] encoding:NSUTF8StringEncoding error:nil];
        
        NSString *imagePath = [[NSBundle mainBundle] resourcePath];
        imagePath = [imagePath stringByReplacingOccurrencesOfString:@"/" withString:@"//"];
        imagePath = [imagePath stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
        
        [aWebView loadHTMLString:html baseURL:[NSURL URLWithString:[NSString stringWithFormat:@"file:/%@//", imagePath]]];
    } 
}

#pragma mark - 실시간 뱃지
- (void) badgeDownloadCompleted
{
    [self writeDone];
}

@end

