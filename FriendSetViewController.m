//
//  FriendSetViewController.m
//  ImIn
//
//  Created by park ja young on 11. 3. 7..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FriendSetViewController.h"
#import "RecomendCellData.h"
#import "NeighborList.h"
#import "NeighborDelete.h"
#import "NeighborRegist.h"
#import "SetBlock.h"
#import "UIImageView+WebCache.h"
#import "NSString+URLEncoding.h"
#import "DenyGuestDelete.h"
#import "DenyGuestRegist.h"
#import "IsDenyGuest.h"
#import "BizWebViewController.h"
#import "ValidNeighborCoupon.h"

#import <QuartzCore/QuartzCore.h>

@implementation FriendSetViewController

@synthesize	frCode, cellDataList, cellDataListIndex;
@synthesize recomType, referCode, position;
@synthesize neighborList, neighborRegist, neighborDelete, setBlock;
@synthesize denyGuestRegist, denyGuestDelete, isDenyGuest, couponId;

- (id) initWithName:(NSString*)name friendSnsId:(NSString*)snsId friendCode:(NSInteger)code friendImage:(NSString*)profileImage 
{
	if( self = [super init] ){
		nickNameStr = name;
		snsIdStr = snsId;
		frCode = code;
		profileUrl = profileImage;
        hasNeighborCoupon = NO;
	}
	return self;
}

- (void) viewWillAppear:(BOOL)animated {

	[super viewWillAppear:animated];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	isFollowing = (frCode == FR_YOU || frCode == FR_NONE) ? NO : YES;
	
    neighborBlockSwitch.on = NO;
    friendSetSwitch.on = NO;
    notiSwitch.on = NO;
    
	preFollowing = isFollowing;
	if( isFollowing ){ // 이웃이면
		[friendSetSwitch setOn:YES animated:NO];
		notiSwitch.enabled = YES;
		notiLable.textColor = RGB(0,0,0);
		[self requestNeighborList];
	}
	else { // 이웃이 아니면
		[friendSetSwitch setOn:NO animated:NO];
		[notiSwitch setOn:NO animated:NO];
		notiSwitch.enabled = NO;
		notiLable.textColor = RGB(181,181,181);
	}	
	
   
    
	// denyGuest인지 확인
	self.isDenyGuest = [[[IsDenyGuest alloc] init] autorelease];
	isDenyGuest.delegate = self;
	[isDenyGuest.params addEntriesFromDictionary:[NSDictionary dictionaryWithObject:snsIdStr 
                                                                             forKey:@"denySnsId"]];
	[isDenyGuest request];
	
	neighborNickname.text = nickNameStr;
	
	[profileImageView setImageWithURL:[NSURL URLWithString:profileUrl]
					 placeholderImage:[UIImage imageNamed:@"delay_nosum70.png"]];
    
    // 사용하지 않은 쿠폰이 있는지 확인
    ValidNeighborCoupon* validNeighborCoupon = [[ValidNeighborCoupon alloc] init];
    validNeighborCoupon.delegate = self;
    [validNeighborCoupon.params addEntriesFromDictionary:[NSDictionary dictionaryWithObject:snsIdStr forKey:@"bizSnsId"]];
    [validNeighborCoupon requestWithAuth:YES withIndicator:NO];       

    
	
	if([[[UIDevice currentDevice] systemVersion] doubleValue] >= 4.0) {
		profileImageView.layer.shadowColor = [UIColor grayColor].CGColor;
		profileImageView.layer.shadowOffset = CGSizeMake(0, 1);
		profileImageView.layer.shadowOpacity = 1;
		profileImageView.layer.shadowRadius = 1.0;
	}
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
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)dealloc {
	
	[cellDataList release];
	[recomType release];
	[referCode release];
	[position release];
	[neighborList release];
	[neighborDelete release];
	[neighborRegist release];
	[setBlock release];
	
	[denyGuestRegist release];
	[denyGuestDelete release];
	
	[isDenyGuest release];
    [couponId release];
	
    [super dealloc];
}

#pragma mark - API handler

- (void)requestNeighborList { 
	
	self.neighborList = [[[NeighborList alloc] init] autorelease];
	neighborList.delegate = self;
	
	[neighborList.params addEntriesFromDictionary:[NSDictionary dictionaryWithObject:[UserContext sharedUserContext].snsID forKey:@"snsId"]];
	[neighborList.params addEntriesFromDictionary:[NSDictionary dictionaryWithObject:@"10" forKey:@"scale"]];
	[neighborList.params addEntriesFromDictionary:[NSDictionary dictionaryWithObject:snsIdStr forKey:@"neighborSnsIdList"]];
	[neighborList.params addEntriesFromDictionary:[NSDictionary dictionaryWithObject:@"M" forKey:@"listType"]];

	[neighborList requestWithAuth:YES withIndicator:NO];
}

- (void) requestSetBlock {
	self.setBlock= [[[SetBlock alloc] init] autorelease];
	setBlock.delegate = self;
	
	[setBlock.params addEntriesFromDictionary:[NSDictionary dictionaryWithObject:[UserContext sharedUserContext].snsID forKey:@"snsId"]];
	[setBlock.params addEntriesFromDictionary:[NSDictionary dictionaryWithObject:snsIdStr forKey:@"blockSnsId"]];
	
	if (!isNoti) {
		[setBlock.params addEntriesFromDictionary:[NSDictionary dictionaryWithObject:@"1" forKey:@"isBlockFeed"]];
	}
	else {
		[setBlock.params addEntriesFromDictionary:[NSDictionary dictionaryWithObject:@"0" forKey:@"isBlockFeed"]];
	}
    
	[setBlock requestWithAuth:YES withIndicator:NO];
}

#pragma mark - response handler

- (void) apiFailedWhichObject:(NSObject *)theObject {
	if ([NSStringFromClass([theObject class]) isEqualToString:@"ValidNeighborCoupon"]) {
        MY_LOG(@"에러 발생");
        [theObject release];
        [self popViewController];
    }
}

- (void) apiDidLoadWithResult:(NSDictionary *)result whichObject:(NSObject *)theObject {
	
    // 이웃 목록
	if ([[result objectForKey:@"func"] isEqualToString:@"neighborList"]) {
		
		if (![[result objectForKey:@"result"] boolValue]) {			
			return;
		}
				
		NSArray* data = [result objectForKey:@"data"];
		
		for (NSDictionary *personData in data) {
			if( [[personData objectForKey:@"isBlockFeed"] isEqualToString:@"0"])
			{
				isNoti = YES;
				[notiSwitch setOn:YES animated:NO];
			}
			else
			{
				isNoti = NO;
				[notiSwitch setOn:NO animated:NO];
			}
			notiLable.textColor = RGB(0,0,0);
			notiSwitch.enabled = YES;
		}
	}
    
    // 쿠폰이 있는지 확인
    if ([[result objectForKey:@"func"] isEqualToString:@"validNeighborCoupon"]) {
        
        hasNeighborCoupon = [[result objectForKey:@"hasCoupon"] boolValue];
        self.couponId = [result objectForKey:@"couponId"];
        
        [theObject release];
    }
	
    // 정보 차단
	if ([[result objectForKey:@"func"] isEqualToString:@"setBlock"]) {
		if (![[result objectForKey:@"result"] boolValue]) {			
			return;
		}
		[self popViewController];
	}
	
    // 이웃 해제
	if ([[result objectForKey:@"func"] isEqualToString:@"neighborDelete"]) {
		if (![[result objectForKey:@"result"] boolValue]) {			
			return;
		}
		[self popViewController];
	}
	
    // 이웃 추가
	if ([[result objectForKey:@"func"] isEqualToString:@"neighborRegist"]) {
		if (![[result objectForKey:@"result"] boolValue] || ![[result objectForKey:@"errCode"] isEqualToString:@"0"]) {		
			MY_LOG(@"result == false");
			[friendSetSwitch setOn:NO animated:YES];
			isFollowing = FALSE;

			return;
		}
        // 이웃 추가 성공
        [[UserContext sharedUserContext] recordKissMetricsWithEvent:@"Added Friend" withInfo:nil];
         
        //이웃 이벤트 시 쿠폰 획득 정보
		if ( ! [[result objectForKey:@"wvUrl"] isEqualToString:@""] ) {
            [self getEventCoupon:[result objectForKey:@"wvUrl"]];
        }
		[self requestSetBlock];
	}
	
    // 이웃 차단
	if ([[result objectForKey:@"func"] isEqualToString:@"denyGuestRegist"]) {
		if (![[result objectForKey:@"result"] boolValue]) {			
			return;
		}
		[self popViewController];
	}

    // 이웃 차단 해제
	if ([[result objectForKey:@"func"] isEqualToString:@"denyGuestDelete"]) {
		if (![[result objectForKey:@"result"] boolValue]) {			
			return;
		}
		
		// 차단을 풀었다면
		if (isFollowing) {
			[self beFriend];
		} else {
			[self popViewController];			
		}
	}
	
    // 차단 여부
	if ([[result objectForKey:@"func"] isEqualToString:@"isDenyGuest"]) {
		if ([[result objectForKey:@"isDenyGuest"] intValue] == 0) {
			[neighborBlockSwitch setOn:NO animated:NO];
			
			isDenyGuestValue = NO;
		} else {
			[neighborBlockSwitch setOn:YES animated:NO];
			neighborAddLable.textColor = RGB(181,181,181);
			friendSetSwitch.enabled = NO;
			
			notiLable.textColor = RGB(181,181,181);
			notiSwitch.enabled = NO;
			
			isDenyGuestValue = YES;
		}
	}
}

#pragma mark - methods list
- (void) neighborSetCancel {
	
	if (cellDataList != nil) {
		id cellDataObject = [cellDataList objectAtIndex:cellDataListIndex];
		// 셀의 데이터가 추천 이웃목록 데이터라면 분기해서 처리해준다.
		if ([cellDataObject isKindOfClass:[RecomendCellData class]]) {
			RecomendCellData* data = (RecomendCellData*)cellDataObject;
			if ([referCode isEqualToString:@"0006"]) {
				data.isFriend = isFollowing ? @"0" : @"2";
				[cellDataList replaceObjectAtIndex:cellDataListIndex withObject:data];
			} else {
				data.isFriend = isFollowing ? @"0" : @"2";
				data.needToDelete = isFollowing;
				[cellDataList removeObjectAtIndex:cellDataListIndex];				
			}
		} else if ([cellDataObject isKindOfClass:[NSDictionary class]]) {
			NSMutableDictionary* data = [NSMutableDictionary dictionaryWithDictionary:(NSDictionary*)cellDataObject];
			NSString* isFriend = isFollowing ? @"0" : @"2";
			[data setObject:isFriend forKey:@"isFriend"];
			MY_LOG(@"confirm: %d", cellDataListIndex);
			
			if (data != nil) { // replaceObjectAtIndex의 data가 nil이면 문제
				[cellDataList replaceObjectAtIndex:cellDataListIndex withObject:data];							
			}
		}
	}
	
	NSDictionary* friendSetting = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithBool:preFollowing], snsIdStr, nil]
															  forKeys:[NSArray arrayWithObjects:@"isFollowing", @"snsId", nil]];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"FriendSetSaved" object:self userInfo:friendSetting];

	
	[self.navigationController popViewControllerAnimated:YES];
}


- (void) popViewController {
	
	if (cellDataList != nil) {
		id cellDataObject = [cellDataList objectAtIndex:cellDataListIndex];
		// 셀의 데이터가 추천 이웃목록 데이터라면 분기해서 처리해준다.
		if ([cellDataObject isKindOfClass:[RecomendCellData class]]) {
			RecomendCellData* data = (RecomendCellData*)cellDataObject;
			if ([referCode isEqualToString:@"0006"]) {
				data.isFriend = isFollowing ? @"0" : @"2";
				[cellDataList replaceObjectAtIndex:cellDataListIndex withObject:data];
			} else {
				data.isFriend = isFollowing ? @"0" : @"2";
				data.needToDelete = isFollowing;
				[cellDataList removeObjectAtIndex:cellDataListIndex];				
			}
		} else if ([cellDataObject isKindOfClass:[NSDictionary class]]) {
			NSMutableDictionary* data = [NSMutableDictionary dictionaryWithDictionary:(NSDictionary*)cellDataObject];
			NSString* isFriend = isFollowing ? @"0" : @"2";
			[data setObject:isFriend forKey:@"isFriend"];
			MY_LOG(@"confirm: %d", cellDataListIndex);
			
			if (data != nil) { // replaceObjectAtIndex의 data가 nil이면 문제
				[cellDataList replaceObjectAtIndex:cellDataListIndex withObject:data];							
			}
		}
	}
	
	NSDictionary* friendSetting = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithBool:isFollowing], snsIdStr, nil]
															  forKeys:[NSArray arrayWithObjects:@"isFollowing", @"snsId", nil]];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"FriendSetSaved" object:self userInfo:friendSetting];
    
	
	[self.navigationController popViewControllerAnimated:YES];
}

- (void) confirm {
	if (neighborBlockSwitch.on != isDenyGuestValue) { //이웃차단의 스위치 설정이 차단 플래그(처음 viewWillappear 에서 체크하기 위해 가져온값) 값과 일치 하는지..판단여부
		
		isDenyGuestValue = neighborBlockSwitch.on;
		
		if (neighborBlockSwitch.on) { // 이웃 차단이면
            
            if (hasNeighborCoupon) {
                //확인 팝업
                UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"알림" message:@"이러면 이웃 이벤트로 받은 쿠폰을 사용할 수 없어요. 이대로 설정하시겠어요?"
                                                                delegate:self cancelButtonTitle:@"취소" otherButtonTitles:@"확인", nil] autorelease];
                alert.tag = 100;
                [alert show];
                return;
            } else {
                // 차단하라
                self.denyGuestRegist = [[[DenyGuestRegist alloc] init] autorelease];
                denyGuestRegist.delegate = self;
                [denyGuestRegist.params addEntriesFromDictionary:[NSDictionary dictionaryWithObject:snsIdStr forKey:@"regDenySnsId"]];
                [denyGuestRegist request];
                return;
            }
            
		} else { // 이웃 차단 해제면
			if (!friendSetSwitch.on) {
				self.denyGuestDelete = [[[DenyGuestDelete alloc] init] autorelease];
				denyGuestDelete.delegate = self;
				[denyGuestDelete.params addEntriesFromDictionary:[NSDictionary dictionaryWithObject:snsIdStr forKey:@"delDenySnsId"]];
				[denyGuestDelete request];
				return;
			}
		}
	}
	
	if (friendSetSwitch.on) { // 이웃설정이 yes면
		isFollowing = TRUE;
		isNoti = (notiSwitch.on) ? TRUE : FALSE ; // 노티 설정이 yes면
	}
	else {
		isFollowing = FALSE;
		isNoti = FALSE;
	}
	
	if (preFollowing == isFollowing) { // 이전 설정과 동일하면 ( 여기서 preFollowing은 viewWillappear에서 보여주기 위해 처음에 가져온 값 )
		if (isFollowing) {
			[self requestSetBlock];			
		} else {
			[self.navigationController popViewControllerAnimated:YES];
		}
	} 
    else {
        if (!isFollowing) {
            
            if (hasNeighborCoupon) {
                //확인 팝업
                UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"알림" message:@"이러면 이웃 이벤트로 받은 쿠폰을 사용할 수 없어요. 이대로 설정하시겠어요?"
                                                                delegate:self cancelButtonTitle:@"취소" otherButtonTitles:@"확인", nil] autorelease];
                alert.tag = 101;    
                [alert show];
            } else {
                // 이웃 끊어라
                notiLable.textColor = RGB(181,181,181);
                notiSwitch.enabled = NO;
                [self beFriend];
            }
        } 
        else {
            [self beFriend];
        }
    }
}

- (void) beFriend {
	MY_LOG(@"recomType = %@, referCode = %@, position = %@", recomType, referCode, position);
    
	if( !isFollowing ){
		self.neighborDelete= [[[NeighborDelete alloc] init] autorelease];
		neighborDelete.delegate = self;
        
		[neighborDelete.params addEntriesFromDictionary:[NSDictionary dictionaryWithObject:snsIdStr forKey:@"delNeiSnsId"]];
        [neighborDelete.params addEntriesFromDictionary:[NSDictionary dictionaryWithObject:couponId forKey:@"couponId"]];
		
		[neighborDelete requestWithAuth:YES withIndicator:NO];
	}
	else {	
		self.neighborRegist= [[[NeighborRegist alloc] init] autorelease];
		neighborRegist.delegate = self;

		[neighborRegist.params addEntriesFromDictionary:[NSDictionary dictionaryWithObject:snsIdStr forKey:@"regSnsId"]];
		if (recomType != nil) {
			[neighborRegist.params addEntriesFromDictionary:[NSDictionary dictionaryWithObject:recomType forKey:@"recomType"]];
		}
		if (referCode != nil) {
			[neighborRegist.params addEntriesFromDictionary:[NSDictionary dictionaryWithObject:referCode forKey:@"referCode"]];
		}
		if (position != nil) {
			[neighborRegist.params addEntriesFromDictionary:[NSDictionary dictionaryWithObject:position forKey:@"position"]];
		}
        
		[neighborRegist requestWithAuth:YES withIndicator:NO];
	}
}

// delete??
- (void)getEventCoupon:(NSString *)eventUrl {     // 이웃 이벤트 쿠폰 가져오기

    BizWebViewController *vc = [[[BizWebViewController alloc] initWithNibName:@"BizWebViewController" 
                                                                       bundle:nil] autorelease];
    vc.urlString = [eventUrl stringByAppendingFormat:@"&title_text=%@&right_enable=y&pointX=%@&pointY=%@", 
                    [@"이벤트" URLEncodedString], 
                    [GeoContext sharedGeoContext].lastTmX, 
                    [GeoContext sharedGeoContext].lastTmY];
    
    [(UINavigationController*)[ViewControllers sharedViewControllers].tabBarController.selectedViewController presentModalViewController:vc animated:YES];
}

- (IBAction)toggleFriendSetSW {
	if (friendSetSwitch.on) {
        // 이웃 끊기 스위치 조작
		notiLable.textColor = RGB(0,0,0);
		notiSwitch.enabled = YES;
	}
	else {
		notiLable.textColor = RGB(181,181,181);
		notiSwitch.enabled = NO;
	}
}

- (IBAction)toggleFriendBlockSet {
	if (neighborBlockSwitch.on) {	// 차단
		
		neighborAddLable.textColor = RGB(181,181,181);
		friendSetSwitch.on = NO;
		friendSetSwitch.enabled = NO;
		
		notiLable.textColor = RGB(181,181,181);
		notiSwitch.on = NO;
		notiSwitch.enabled = NO;
		
		isFollowing = NO;
		isNoti = NO;		
	}
	else {		// 차단 해지
		friendSetSwitch.enabled = YES;
        notiLable.textColor = RGB(0, 0, 0);
        neighborAddLable.textColor = RGB(0, 0, 0);
		if (friendSetSwitch.on) {
			friendSetSwitch.on = preFollowing;
			notiSwitch.enabled = YES;
		}
		else {
			notiSwitch.on = preNoti;
			notiSwitch.enabled = NO;
		}			
	}
}

#pragma mark - UIAlertView delegate
// 이웃 취소할 때 이웃 이벤트 쿠폰 사용 불가능 알림
- (void)alertView:(UIAlertView*)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 100) {
        if (buttonIndex == 1) {
            // 차단 해도 좋아
            self.denyGuestRegist = [[[DenyGuestRegist alloc] init] autorelease];
			denyGuestRegist.delegate = self;
			[denyGuestRegist.params addEntriesFromDictionary:[NSDictionary dictionaryWithObject:snsIdStr forKey:@"regDenySnsId"]];
            [denyGuestRegist.params addEntriesFromDictionary:[NSDictionary dictionaryWithObject:couponId forKey:@"couponId"]];
			[denyGuestRegist request];		
        } else {
            neighborBlockSwitch.on = NO;
            [self popViewController];
        }
    } else if (alertView.tag == 101) {
        if (buttonIndex == 1) {
            // 이웃 끊어도 좋아
            notiLable.textColor = RGB(181,181,181);
            notiSwitch.enabled = NO;
            [self beFriend];
        } else {
            friendSetSwitch.on = YES;
            [self popViewController];
        }
    }
}

@end
