//
//  CommonWebViewController.m
//  ImIn
//
//  Created by Myungjin Choi on 11. 4. 13..
//  Copyright 2011 KTH. All rights reserved.
//

#import "CommonWebViewController.h"
#import "UIHomeViewController.h"
#import "UserContext.h"
#import "NSString+URLEncoding.h"
#import "MyPostListById.h"
#import "PostDetailTableViewController.h"
#import "NSDataAdditions.h"
#import "UIWebView+WebUI.h"
#import "iToast.h"

@implementation CommonWebViewController
@synthesize urlString;
@synthesize titleString;
@synthesize viewType;
@synthesize retDictionary, preRetDictionary;
@synthesize postListById;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
		viewType = BOTTOM; 
        heartconTitleView.hidden = YES;
    }
    return self;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];

    wagw = [[WebAppGatewayProtocol alloc] init];
    wagw.delegate = self;
    wagw.whichVC = self;
    wagw.whichWebView = aWebView;

	aWebView.delegate = self;
	
    [ApplicationContext sharedApplicationContext].jsCallWebVC = self;

	//웹페이지에서 css등.. 변경된것이 있을수 있이니 캐쉬를 지워서 다시 받도록 함
	[[NSURLCache sharedURLCache] removeAllCachedResponses];
	    
    switch (viewType) {
        case SUBVIEW_WEB:  //랭킹뷰의 경우
            titleView.hidden = YES;
            heartconTitleView.hidden = YES;
            bottomView.hidden = YES;
            aWebView.frame = CGRectMake(0, 0, 320, 368);
            break;
        case TITLE_BOTTOM:  //타이틀+하단뷰 show
            titleView.hidden = NO;
            bottomView.hidden = NO;
            htmlTitle.text = titleString;
            aWebView.frame = CGRectMake(0, 43, 320, 379);
            break;
        case TITLE:  //타이틀만 show
            titleView.hidden = NO;
            bottomView.hidden = YES;
            htmlTitle.text = titleString;
            aWebView.frame = CGRectMake(0, 43, 320, 420);
            break;
        case BOTTOM:  //하단뷰만 show
            titleView.hidden = YES;
            bottomView.hidden = NO;
            aWebView.frame = CGRectMake(0, 0, 320, 416);
            break;
        case HEARTCON:  //하트콘의 경우
            titleView.hidden = YES;
            heartconTitleView.hidden = NO;
            bottomView.hidden = YES;
            heartconTitle.text = titleString;
            aWebView.frame = CGRectMake(0, 43, 320, 420);
            break;
        case BIZWEBVIEW: // 비스 웹뷰
            titleView.hidden = YES;
            heartconTitleView.hidden = NO;
            bottomView.hidden = YES;
            heartconTitle.text = titleString;
            aWebView.frame = CGRectMake(0, 43, 320, 420);
            break;
            
        case WRITE_POST_RESULT: // 발도장 결과 화면 웹뷰
            titleView.hidden = YES;
            heartconTitleView.hidden = YES;
            bottomView.hidden = YES;
            aWebView.frame = CGRectMake(0, 0, 320, 440);
            break;
            
        default:  //타이틀, 하단뷰 모두 보이지 않는 경우
            titleView.hidden = YES;
            bottomView.hidden = YES;
            aWebView.frame = CGRectMake(0, 0, 320, 420);
            break;
            
    }
    // commonWebView에서는 버전 정보를 추가하지 않도록 아래 내용을 주석처리함.
//    if ([urlString rangeOfString:@"?"].location == NSNotFound) {
//        self.urlString = [urlString stringByAppendingFormat:@"?wagw_ver=%@", [ApplicationContext sharedApplicationContext].wagwVersion];
//    } else {
//        self.urlString = [urlString stringByAppendingFormat:@"&wagw_ver=%@", [ApplicationContext sharedApplicationContext].wagwVersion];
//    }
    
    NSURL* url = [NSURL URLWithString:urlString];
    
	if (url) {
        if ([UserContext sharedUserContext].snsCookieArray != nil && [[UserContext sharedUserContext].snsCookieArray count] == 2) {
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
    
    
    CGRect webViewFrame = aWebView.frame;
    
	webViewFrame.origin.x = webViewFrame.size.width/2;
	webViewFrame.origin.y = webViewFrame.size.height/2;
    
    heartconPreBtn.hidden = YES;
    cancelBtn.hidden = NO;

}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
	[aWebView stopLoading];
	
    [super viewDidUnload];
    
    [ApplicationContext stopActivity];
	
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [retDictionary release];
    [preRetDictionary release];
	[aWebView release];		
	[urlString release];
	[titleString release];
    [wagw release];
	
    [super dealloc];
}

- (IBAction) closeVC {
	[aWebView stopLoading];
	
    [ApplicationContext sharedApplicationContext].jsCallWebVC = nil;
	[self dismissModalViewControllerAnimated:YES];
}

- (void) uiSetWithData:(NSDictionary*) data {
    heartconPreBtn.hidden = YES;
    cancelBtn.hidden = NO;
    
    NSString* retString = nil;
    
    if ((retString = [data objectForKey:@"left_enable"])) {
        if ([retString isEqualToString:@"y"]) {
            heartconPreBtn.hidden = NO;
        } else {
            heartconPreBtn.hidden = YES;
        }
    }

    if ((retString = [data objectForKey:@"title_enable"])) {
        if ([retString isEqualToString:@"y"]) {
            heartconTitle.hidden = NO;
        } else {
            heartconTitle.hidden = YES;
        }
    }
    
    if ((retString = [data objectForKey:@"title_text"])) {
        htmlTitle.text = retString;
        heartconTitle.text = retString;
        MY_LOG(@"heartconTitle.text = %@, retString = %@", heartconTitle.text, retString);
    }
    
    if ((retString = [data objectForKey:@"right_enable"])) {
        if ([retString isEqualToString:@"y"]) {
            cancelBtn.hidden = NO;
        } else {
            cancelBtn.hidden = NO; // 체크
        }
    }
}

#pragma mark - WebAppGatewayProtocol Delegate

- (BOOL) willProcessUiDescriptionWithData:(NSDictionary*) data {
    MY_LOG(@"willProcessUiDescriptionWithData");
    NSString* returnSnsId = nil;
    NSString* retString = nil;
    
    NSURL* url = [data objectForKey:@"URL"];
    
	if ([[url.scheme lowercaseString] isEqualToString:@"imin"]) {        
        retString = [data objectForKey:@"schemename"];
        if ([retString isEqualToString:@"UIDescription"]) {
            self.preRetDictionary = data; //하트콘 쿠폰 저장시 UI정보 보존
            [self uiSetWithData:data];
            return NO;
        }
        
        if ([retString isEqualToString:@"saveimage"]) {
            //http://imindev.paran.com/sns/setup/exportHeartconImg.kth?snsId=100000000000&orderId=201108230000000007169192174555
            if ((retString = [data objectForKey:@"data"])) {
                //data 받아서 이미지로(format받은 값을 이용해서) 저장해야 함
                NSData* imageData = [NSData dataWithBase64EncodedString: retString];
                UIImage *imageToSave = [UIImage imageWithData:imageData];
                UIImageWriteToSavedPhotosAlbum(imageToSave, self,
                                               @selector(image:didFinishSavingWithError:contextInfo:), nil);
            }
            return NO;
        }
        
        if ([retString isEqualToString:@"writecomment"]) {
            if ((retString = [data objectForKey:@"postid"])) {
                
				self.postListById = [[[MyPostListById alloc] init] autorelease];
				postListById.delegate = self;
				//postListById.postIdList = @"2011033876847";
                postListById.postIdList = retString;
				[postListById requestWithoutIndicator]; //요청까지
            }
            return NO;
        }
        
		// TODO: 여기에 key/value 형식에 대한 구현을 하라.
		
		MY_LOG(@"SNSID = %@", returnSnsId);
		
		return YES;
	} else if ([[url.scheme lowercaseString] isEqualToString:@"ispmobile"]) {
        BOOL installedApp = [[UIApplication sharedApplication] canOpenURL:url];
        if(installedApp == YES) //이미 모바일ISP가 설치되어있는경우
        {
            [[UIApplication sharedApplication] openURL:url];      //모바일ISP App 바로 호출.
        }else { 
            UIAlertView* customAlert = [[[UIAlertView alloc] initWithTitle:nil message:@"모바일 ISP를 설치 후\n진행해 주세요~" delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil] autorelease];
            [customAlert show];
        }
        return NO;
    } else if ([[url.scheme lowercaseString] isEqualToString:@"itms-apps"] || [[url.scheme lowercaseString] isEqualToString:@"mailto"] || [[url.scheme lowercaseString] isEqualToString:@"tel"]) {
        [[ UIApplication sharedApplication ] openURL:url]; 
        return NO;
    } else {
        [self uiSetWithData:data];
		return YES;
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
        [CommonAlert alertWithTitle:@"안내" message:@"선물을 앨범에 저장하지 못했습니다."];
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
    [ApplicationContext runActivity];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [ApplicationContext stopActivity];
    
	backwardBtn.enabled = aWebView.canGoBack;
	forwardBtn.enabled = aWebView.canGoForward;
	
	if (![titleString isEqualToString:@""] || ![titleString isEqualToString:nil])
		return;
	
	htmlTitle.text = [webView stringByEvaluatingJavaScriptFromString:@"document.getElementsByTagName('title')[0].innerHTML"];
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
            iToast *msg = [[iToast alloc] initWithText:@"네트워크가 불안합니다. \n잠시 후 다시 시도해 주세요~"];
            [msg setDuration:2000];
            [msg setGravity:iToastGravityCenter];
            [msg show];
            [msg release];
        }

//        [CommonAlert alertWithTitle:@"알림" message:@"네트웍 연결을 확인해주세요."];
    }
}

- (void) jaCallWithSchemeKey:(NSString *)retValue
{
    if ([retValue isEqualToString:@"1"]) {
        [aWebView stringByEvaluatingJavaScriptFromString:@"post_submit();"];
    } else {
        [aWebView stringByEvaluatingJavaScriptFromString:@"cancel();"];
    }
}

- (IBAction) heartconPreBtnClick
{
    NSString* retString = nil;
    retString = [retDictionary objectForKey:@"left_jscall"];
    if (retString == nil) {
        retString = [preRetDictionary objectForKey:@"left_jscall"]; 
        [aWebView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"window['%@']()", retString]];
    } else if((retString = [retDictionary objectForKey:@"left_jscall"])) {
        [aWebView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"window['%@']()", retString]];
    }
}

- (void) apiDidLoad:(NSDictionary*) result {
    if ([[result objectForKey:@"func"] isEqualToString:@"myPostListById"]) {
		if ([[result objectForKey:@"data"] count] > 0) {
			MY_LOG(@"결과: %@", [[[result objectForKey:@"data"] objectAtIndex:0] objectForKey:@"post"]);
            
            NSMutableDictionary* postData = [[[NSMutableDictionary alloc] initWithDictionary:[[result objectForKey:@"data"] objectAtIndex:0]] autorelease];
            
            [[ApplicationContext sharedApplicationContext] performSelector:@selector(closeWebViewAndOpenPostWithData:) withObject:postData afterDelay:1];
			[self closeVC];
        } 
        else
        {
            [CommonAlert alertWithTitle:@"안내" message:@"선물도장을 찾을 수 없어요~"];
        }
	}
}

- (void) apiFailed {
}

@end

