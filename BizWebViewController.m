//
//  BizWebViewController.m
//  ImIn
//
//  Created by Myungjin Choi on 11. 10. 11..
//  Copyright 2011년 KTH. All rights reserved.
//

#import "BizWebViewController.h"
#import "UserContext.h"
#import "NSString+URLEncoding.h"
#import "NSDataAdditions.h"
#import "UIWebView+WebUI.h"
#import "iToast.h"

@implementation BizWebViewController
@synthesize titleString, urlString;
@synthesize right_jscall, left_jscall;
@synthesize curPosition;                            //curPosition 22 : 이벤트 보기 23 : 진행중인 이벤트

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
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
    
    wagw = [[WebAppGatewayProtocol alloc] init];
    wagw.delegate = self;
    wagw.whichVC = self;
    wagw.whichWebView = aWebView;
    
    left_jscall = nil;
    right_jscall = nil;

    aWebView.delegate = self;
    
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    
    if ([urlString rangeOfString:@"?"].location == NSNotFound) {
        self.urlString = [urlString stringByAppendingFormat:@"?wagw_ver=%@", [ApplicationContext sharedApplicationContext].wagwVersion];
    } else {
        self.urlString = [urlString stringByAppendingFormat:@"&wagw_ver=%@", [ApplicationContext sharedApplicationContext].wagwVersion];
    }
                                                                              
    NSURL* url = [NSURL URLWithString:urlString];
    
    if (url) {
        if ([UserContext sharedUserContext].snsCookie != nil) {
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
    
    

- (void)viewDidUnload
{
    [super viewDidUnload];
    [ApplicationContext stopActivity];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (IBAction) closeVC {
	[aWebView stopLoading];
	[self dismissModalViewControllerAnimated:YES];
}

- (IBAction) leftBtnClick
{
    if (left_jscall != nil) {
        [aWebView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"%@()", left_jscall]];        
    }
}

- (IBAction) rightBtnClick
{
    if (right_jscall != nil) {
        [aWebView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"%@()", right_jscall]];        
    }
}

-(void) dealloc 
{
    [titleString release];
    [urlString release];
    [left_jscall release];
    [right_jscall release];
    [super dealloc];
}

#pragma mark - WebAppGatewayProtocol Delegate

- (BOOL) willProcessUiDescriptionWithData:(NSDictionary*) data {
    
    
    MY_LOG(@"willProcessUiDescriptionWithData");
    
    if ([data objectForKey:@"left_enable"]
        || [data objectForKey:@"title_text"]
        || [data objectForKey:@"left_jscall"]
        || [data objectForKey:@"right_enable"]
        || [data objectForKey:@"right_jscall"]
        ) {
        
        leftBtn.hidden = ![[data objectForKey:@"left_enable"] isEqualToString:@"y"];
        rightBtn.hidden = ![[data objectForKey:@"right_enable"] isEqualToString:@"y"];
        titleLabel.text = [data objectForKey:@"title_text"];
        
        self.left_jscall = [data objectForKey:@"left_jscall"];
        self.right_jscall = [data objectForKey:@"right_jscall"];
    }
    
    
    return YES;
}

- (BOOL) didProcessUiDescriptionWithData:(NSDictionary*) data {
    MY_LOG(@"didProcessUiDescriptionWithData");
    return YES;
}

- (BOOL) willProcessAppRequestWithData:(NSDictionary*) data {
    MY_LOG(@"willProcessAppRequestWithData");
    return YES;
}

- (BOOL) didProcessAppRequestWithData:(NSDictionary*) data {
    MY_LOG(@"didProcessAppRequestWithData");
    
    NSURL* url = [data objectForKey:@"URL"];

    if ([[url.scheme lowercaseString] isEqualToString:@"imin"]) {        
        return NO;
    }
    
    return YES;
}

#pragma mark -
#pragma mark webview delegate 
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType;
{
	NSURL *url = request.URL;
    return [wagw processWithUrl:url];
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error 
  contextInfo:(void *)contextInfo
{
    // Was there an error?
    if (error != NULL)
    {
        // Show error message...
        [CommonAlert alertWithTitle:@"안내" message:@"선물을 앨범 저장하지 못했습니다."];
    }
    else  // No errors
    {
        // Show message image successfully saved
        [CommonAlert alertWithTitle:@"안내" message:@"선물을 앨범에 저장했어요"];
        MY_LOG(@"사진 저장됨");
    }
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    if ([titleLabel.text isEqualToString:@"이벤트 매장"]) {
        GA1(@"이벤트매장");
    }
    
    if ([curPosition isEqualToString:@"22"]) {
        GA1(@"이벤트보기");
        
    }
    else if ([curPosition isEqualToString:@"23"]) {
        GA1(@"진행중인이벤트");
    }
    
    [ApplicationContext runActivity];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
	[ApplicationContext stopActivity];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [ApplicationContext stopActivity];
    if (error.code == NSURLErrorCancelled) {
        return;
    } else {
        //itoast
        UIWindow *window = [[[UIApplication sharedApplication] windows] objectAtIndex:0];
        UIView *v = (UIView *)[window viewWithTag:TAG_iTOAST];
        if (!v) {
            iToast *msg = [[iToast alloc] initWithText:[error localizedDescription]];
            [msg setDuration:2000];
            [msg setGravity:iToastGravityCenter];
            [msg show];
            [msg release];
        }

//        [CommonAlert alertWithTitle:@"알림" message:[error localizedDescription]];
    }
}

@end

