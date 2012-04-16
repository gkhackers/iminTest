//
//  WebAppGatewayProtocol.m
//  ImIn
//
//  Created by Myungjin Choi on 11. 10. 5..
//  Copyright 2011년 KTH. All rights reserved.
//

#import "WebAppGatewayProtocol.h"
#import "NSString+URLEncoding.h"
#import "UIHomeViewController.h"
#import "ProfileViewController.h"
#import "PostListById.h"
#import "LatestCheckinViewController.h"
#import "PostDetailTableViewController.h"
#import "POIDetailViewController.h"
#import "MyHomeNeighborViewController.h"
#import "BrandHomeViewController.h"
#import "CommonWebViewController.h"
#import "PoiInfo.h"
#import "HomeInfo.h"
#import "ViewControllers.h"
#import "PoiInfoDetail.h"
#import "PoiInfoViewController.h"

#define PUSH_INTERVAL 0.1f
#define CLOSE_INTERVAL 0.2f

@implementation WebAppGatewayProtocol

@synthesize delegate, whichVC, whichWebView;

// TODO: UI관련 공통 처리 모듈을 여기에 놓자
- (BOOL) processUiDescriptionWithData:(NSDictionary*) data
{
    return YES;
}

- (void) goProfileWithData:(NSDictionary*) result
{
    NSString *whoIs = [result objectForKey:@"isPerm"];
    NSInteger friendCodeInt = FR_NONE;
    
    // 서로 이웃인지 여부를 확인해서 표시한다.
    if (![whoIs isEqualToString:@"OWNER"]) {
        
        if( [whoIs isEqualToString:@"FRIEND"] ){
            friendCodeInt = FR_TRUE;
        }else if( [whoIs isEqualToString:@"NEIGHBOR_YOU"] ){ 
            friendCodeInt = FR_ME;  // 항상 다른사람의 홈페이지으므로 의미가 반대가 된다.
        }else if( [whoIs isEqualToString:@"NEIGHBOR_ME"] ){
            friendCodeInt = FR_YOU; // 따라서, 나(그사람을)를 (내가)등록한 이웃 이라는 뜻이 됨.
        }else{
            friendCodeInt = FR_NONE;
        }
    }
    
	ProfileViewController* vc = [[[ProfileViewController alloc] initWithNibName:@"ProfileViewController" bundle:nil] autorelease];
	
    MemberInfo* owner = [[[MemberInfo alloc] init] autorelease];
    owner.snsId = [result objectForKey:@"snsId"];
    owner.profileImgUrl = [result objectForKey:@"profileImg"];
    owner.nickname = [result objectForKey:@"nickname"];

	vc.owner = owner;
	vc.friendCodeInt = friendCodeInt;
	vc.homeInfoResult = result;
    
	[[ApplicationContext sharedApplicationContext] performSelector:@selector(pushVC:) withObject:vc afterDelay:PUSH_INTERVAL];
}

- (void) goPostWithData:(NSDictionary*) result 
{
    NSMutableDictionary* postData = [[[NSMutableDictionary alloc] initWithDictionary:[[result objectForKey:@"data"] objectAtIndex:0]] autorelease];
    
    
    PostDetailTableViewController* vc = [[[PostDetailTableViewController alloc] 
                                         initWithNibName:@"PostDetailTableViewController" 
                                         bundle:nil] autorelease];
    vc.postData = postData;
    [[ApplicationContext sharedApplicationContext] performSelector:@selector(pushVC:) withObject:vc afterDelay:PUSH_INTERVAL];
}

- (void) goPostListWithData:(NSDictionary*) result
{
    LatestCheckinViewController* vc = [[[LatestCheckinViewController alloc] initWithNibName:@"LatestCheckinViewController" bundle:nil] autorelease];
    MemberInfo* owner = [[[MemberInfo alloc] init] autorelease];
    owner.snsId = [result objectForKey:@"snsId"];
    owner.nickname = [result objectForKey:@"nickname"];

    vc.owner = owner;
    
    [[ApplicationContext sharedApplicationContext] performSelector:@selector(pushVC:) withObject:vc afterDelay:PUSH_INTERVAL];
}

- (void) goPoiWithData:(NSDictionary*) result
{
    MY_LOG(@"결과: %@", [result objectForKey:@"poiName"]);
    POIDetailViewController *vc = [[[POIDetailViewController alloc] initWithNibName:@"POIDetailViewController" bundle:nil] autorelease];
    vc.poiData = result;
    [[ApplicationContext sharedApplicationContext] performSelector:@selector(pushVC:) withObject:vc afterDelay:PUSH_INTERVAL];
}

- (void) goPoiInfoDetailWithData:(NSDictionary*) result
{
    PoiInfoViewController* vc = [[[PoiInfoViewController alloc] initWithNibName:@"PoiInfoViewController" bundle:nil] autorelease];
    vc.poiKey = [result objectForKey:@"poiKey"];
    vc.poiInfoResult = result;

    [[ApplicationContext sharedApplicationContext] performSelector:@selector(pushVC:) withObject:vc afterDelay:PUSH_INTERVAL];
}

- (void) goNeighborListWithData:(NSDictionary*) result 
{
    MyHomeNeighborViewController *vc = 
    [[[MyHomeNeighborViewController alloc] initWithSnsId:[result objectForKey:@"snsId"] 
                                                nickName:[result objectForKey:@"nickname"]
                                                listType:[result objectForKey:@"listType"]] autorelease];
    
	[[ApplicationContext sharedApplicationContext] performSelector:@selector(pushVC:) withObject:vc afterDelay:PUSH_INTERVAL];
}

- (void) goBrandHomeWithData:(NSDictionary*) result
{
    
}



// TODO: 앱내 호출 관련, 공통 처리 모듈을 여기 놓자
- (BOOL) processAppRequestWithData:(NSDictionary*) data
{
    // 이전 랭킹 뷰 호환용
    NSString* returnSnsId = [data objectForKey:@"goHome"];
    if (returnSnsId != nil) {
        UIHomeViewController *vc = [[[UIHomeViewController alloc] initWithNibName:@"UIHomeViewController" bundle:nil] autorelease];
        
        MemberInfo* owner = [[[MemberInfo alloc] init] autorelease];
        owner.snsId = returnSnsId;
        vc.owner = owner;
        
        [[ApplicationContext sharedApplicationContext] performSelector:@selector(pushVC:) withObject:vc afterDelay:PUSH_INTERVAL];
        return NO;
    }
    
    
    NSString* command = [data objectForKey:@"schemename"];
    
    if ([command isEqualToString:@"saveimage"]) {
        return NO;
    }
    
    if ([command isEqualToString:@"myHome"]) {
        UIHomeViewController *vc = [[[UIHomeViewController alloc] initWithNibName:@"UIHomeViewController" bundle:nil] autorelease];
        
        MemberInfo* owner = [[[MemberInfo alloc] init] autorelease];
        owner.snsId = [data objectForKey:@"snsId"];
        vc.owner = owner;
        
        [[ApplicationContext sharedApplicationContext] performSelector:@selector(pushVC:) withObject:vc afterDelay:PUSH_INTERVAL];
        
        [self performSelector:@selector(closeVC) withObject:nil afterDelay:CLOSE_INTERVAL];
        
        return NO;
    }
    
    if ([command isEqualToString:@"profile"]) {
        HomeInfo* homeInfo = [[HomeInfo alloc] init];
        homeInfo.snsId = [data objectForKey:@"snsId"];
        homeInfo.delegate = self;
        [homeInfo requestWithoutIndicator];

        return NO;
    }
    
    if ([command isEqualToString:@"post"]) {
        
        PostListById* postListById = [[PostListById alloc] init];
        postListById.delegate = self;
        [postListById.params addEntriesFromDictionary:[NSDictionary dictionaryWithObject:[data objectForKey:@"postId"] forKey:@"postId"]];
        [postListById request];
        
        return NO;
    }
    
    if ([command isEqualToString:@"postList"]) {
        [self goPostListWithData:data];
        [self performSelector:@selector(closeVC) withObject:nil afterDelay:CLOSE_INTERVAL];
        return NO;
    }
    
    if ([command isEqualToString:@"poi"]) {
        PoiInfo* poiInfo = [[PoiInfo alloc] init];
        poiInfo.delegate = self;
        poiInfo.poiKey = [data objectForKey:@"poiKey"];
        [poiInfo requestWithoutIndicator];
        
        return NO;
    }

    if ([command isEqualToString:@"poiInfoDetail"]) {
        PoiInfoDetail* poiInfoDetail = [[PoiInfoDetail alloc] init];
        poiInfoDetail.delegate = self;
        [poiInfoDetail.params addEntriesFromDictionary:[NSDictionary dictionaryWithObject:[data objectForKey:@"poiKey"] forKey:@"poiKey"]];
        [poiInfoDetail requestWithoutIndicator];
        
        return NO;
    }

    if ([command isEqualToString:@"comment"]) {
        PostListById* postListById = [[PostListById alloc] init];
        postListById.delegate = self;
        [postListById.params addEntriesFromDictionary:[NSDictionary dictionaryWithObject:[data objectForKey:@"postId"] forKey:@"postId"]];
        [postListById request];
        
        return NO;
    }
    
    if ([command isEqualToString:@"closeWebView"]) {
        [self performSelector:@selector(closeVC) withObject:nil afterDelay:CLOSE_INTERVAL];
        return NO;
    }
    
    if ([command isEqualToString:@"activityIndicator"]) {
        if ([[data objectForKey:@"status"] isEqualToString:@"appear"]) {
            [ApplicationContext runActivity];
        } else if ([[data objectForKey:@"status"] isEqualToString:@"disappear"]) {
            [ApplicationContext stopActivity];
        }
        return NO;
    }
    
    
    if ([command isEqualToString:@"neighborList"]) {
        [self goNeighborListWithData:data];
        [self performSelector:@selector(closeVC) withObject:nil afterDelay:CLOSE_INTERVAL];
        
        return NO;
    }
    
    if ([command isEqualToString:@"brandHome"]) {
        BrandHomeViewController *vc = [[[BrandHomeViewController alloc] initWithNibName:@"BrandHomeViewController" bundle:nil] autorelease];
        
        MemberInfo* owner = [[[MemberInfo alloc] init] autorelease];
        owner.snsId = [data objectForKey:@"snsId"];
        vc.owner = owner;
        [[ApplicationContext sharedApplicationContext] performSelector:@selector(pushVC:) withObject:vc afterDelay:PUSH_INTERVAL];
        
        [self performSelector:@selector(closeVC) withObject:nil afterDelay:CLOSE_INTERVAL];
        return NO;
    }
    
    if ([command isEqualToString:@"outlink"]) {
        CommonWebViewController* vc = [[[CommonWebViewController alloc] initWithNibName:@"CommonWebViewController" bundle:nil] autorelease];
        vc.urlString = [data objectForKey:@"url"];
        vc.viewType = BOTTOM;
        
        [whichVC presentModalViewController:vc animated:YES];
        return NO;
    }
    
    if ([command isEqualToString:@"selectTab"]) {
        int tabIndex = [[data objectForKey:@"tabId"] intValue];
        [[ApplicationContext sharedApplicationContext] selectTabWithIndex:tabIndex];
        
        [self performSelector:@selector(closeVC) withObject:nil afterDelay:CLOSE_INTERVAL];
        return NO;
    }
    
    
    NSURL* url = [data objectForKey:@"URL"];
    if ([[url.scheme lowercaseString] isEqualToString:@"itms-apps"]
//        || [[url.scheme lowercaseString] isEqualToString:@"tel"] // 전화는 바로 걸리면 결례라서 뺀다
        ) {
        
        [[ UIApplication sharedApplication ] openURL:url];
        return NO;
    }
    
    if ([[url.scheme lowercaseString] isEqualToString:@"mailto"]) {
        MFMailComposeViewController *mailVC = [[MFMailComposeViewController alloc] init];
        mailVC.mailComposeDelegate = self;
        NSString* urlString = [url relativeString];
        NSString* email = [urlString stringByReplacingOccurrencesOfString:@"mailto:" withString:@""];
        [mailVC setToRecipients:[NSArray arrayWithObject:email]];
        [whichVC presentModalViewController:mailVC animated:YES];
        [mailVC release];
                
        return NO;
    }
    
    return YES;
}

- (BOOL) processWithUrl:(NSURL*) url
{
    MY_LOG(@"processWithUrl");
    BOOL willContinue = NO;
    NSDictionary* data = [self parseWithUrl:url];
    
    if (self.delegate == nil) {
        return YES;
    }
    
    if (data == nil) {
        return YES;
    }
    
    if ([self.delegate respondsToSelector:@selector(willProcessUiDescriptionWithData:)]) {
        willContinue = [self.delegate willProcessUiDescriptionWithData:data];
    }
    
    if (willContinue == NO) {
        return NO;
    }
    
    willContinue = [self processUiDescriptionWithData:data];

    if (willContinue == NO) {
        return NO;
    }
    
    if ([self.delegate respondsToSelector:@selector(didProcessUiDescriptionWithData:)]) {
        willContinue = [self.delegate didProcessUiDescriptionWithData:data];
    }
    
    if (willContinue == NO) {
        return NO;
    }
    
    if ([self.delegate respondsToSelector:@selector(willProcessAppRequestWithData:)]) {
        willContinue = [self.delegate willProcessAppRequestWithData:data];
    }
    
    if (willContinue == NO) {
        return NO;
    }
    
    willContinue = [self processAppRequestWithData:data];
    
    if (willContinue == NO) {
        return NO;
    }
    
    if ([self.delegate respondsToSelector:@selector(didProcessAppRequestWithData:)]) {
        willContinue = [self.delegate didProcessAppRequestWithData:data];
    }
    
    if (willContinue == NO) {
        return NO;
    }
    
    return YES;
}

- (NSDictionary* ) parseWithUrl:(NSURL*) url
{    
    MY_LOG(@"parseWithUrl");
	NSString* urlBody = [[[url absoluteString] componentsSeparatedByString:@"//"] lastObject];
    
    NSMutableDictionary *mutableDictionary = [[[NSMutableDictionary alloc] init] autorelease];
    
    NSString* key = nil;
    NSString* value = nil;
    NSArray* keyValues = nil;
    
    [mutableDictionary setObject:url forKey:@"URL"];
    
    if (urlBody == nil) {
        [mutableDictionary setObject:@"error" forKey:@"schemename"]; //스키마이름 저장
        return mutableDictionary;
    }
    
    NSArray* parts = [urlBody componentsSeparatedByString:@"?"];
    if ([parts count] == 1) {
        [mutableDictionary setObject:[parts objectAtIndex:0] forKey:@"schemename"];
        keyValues = [[parts objectAtIndex:0] componentsSeparatedByString:@"/"];
    } else if ([parts count] == 2) {
        [mutableDictionary setObject:[parts objectAtIndex:0] forKey:@"schemename"];
        keyValues = [[parts objectAtIndex:1] componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"=&"]];
    }

    for (int i=0; i < [keyValues count]; i++) {
        if (i % 2 == 0) {
            // key
            key = [keyValues objectAtIndex:i];
        } else {
            // value
            value = [[keyValues objectAtIndex:i] URLDecodedString];
            [mutableDictionary setObject:value forKey:key];
        }
    }
    
    MY_LOG(@"mutableDictionary = %@", mutableDictionary);
	return mutableDictionary;
}

- (void) dealloc
{
    [whichWebView release];
    [whichVC release];
    [super dealloc];
}


#pragma mark - 아임IN 프로토콜
- (void) apiFailedWhichObject:(NSObject *)theObject {
    [theObject release];
}

- (void) closeVC {
    if ([self.delegate respondsToSelector:@selector(closeVC)]) {
        [self.delegate closeVC];
    }
}

- (void) apiDidLoadWithResult:(NSDictionary *)result whichObject:(NSObject *)theObject {
    
    if ([[result objectForKey:@"func"] isEqualToString:@"homeInfo"]) {
        [self goProfileWithData:result];
        [self performSelector:@selector(closeVC) withObject:nil afterDelay:CLOSE_INTERVAL];
    }
    
    
    if ([[result objectForKey:@"func"] isEqualToString:@"postListById"]) {
        [self goPostWithData:result];
        [self performSelector:@selector(closeVC) withObject:nil afterDelay:CLOSE_INTERVAL];
    }
    
    
    if ([[result objectForKey:@"func"] isEqualToString:@"poiInfo"]) {
        [self goPoiWithData:result];
        [self performSelector:@selector(closeVC) withObject:nil afterDelay:CLOSE_INTERVAL];
	}
    
    if ([[result objectForKey:@"func"] isEqualToString:@"poiInfoDetail"]) {
        [self goPoiInfoDetailWithData:result];
        [self performSelector:@selector(closeVC) withObject:nil afterDelay:CLOSE_INTERVAL];
    }
        
    [theObject release];
}

#pragma mark - MFMailComposeViewController delegate
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error 
{   
    MY_LOG(@"%@", error);
    
    switch (result) {
        case MFMailComposeResultFailed:
            [CommonAlert alertWithTitle:@"알림" message:@"메일 전송에 실패했습니다."];
            break;
            
        case MFMailComposeResultSent:
            [CommonAlert alertWithTitle:@"알림" message:@"메일 전송에 성공했습니다."];
            break;
            
        case MFMailComposeResultSaved:
            [CommonAlert alertWithTitle:@"알림" message:@"임시 메일함에 저장됐습니다."];
            break;
        
        case MFMailComposeResultCancelled:
            [CommonAlert alertWithTitle:@"알림" message:@"메일 전송을 취소했습니다."];
            break;
            
        default:
            break;
    }
    [whichVC dismissModalViewControllerAnimated:YES];
}

@end
