//
//  SNSInvitationTableCell.m
//  ImIn
//
//  Created by choipd on 10. 8. 3..
//  Copyright 2010 edbear. All rights reserved.
//

#import "SNSInvitationTableCell.h"
#import "UIImageView+WebCache.h"
#import "UIHomeViewController.h"
#import "ViewControllers.h"
#import "const.h"
#import "HttpConnect.h"
#import "CgiStringList.h"
#import "CommonAlert.h"
#import "UserContext.h"
#import "JSON.h"
//#import "MyFriendSetController.h"
#import "FriendSetViewController.h"
#import "HomeInfo.h"

@implementation SNSInvitationTableCell

@synthesize cellDataList, cellDataListIndex, cellDataDictionary, cellType;
@synthesize homeInfo;


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        // Initialization code
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)dealloc {

	if (connect1 != nil) {
		[connect1 stop];
		[connect1 release];
		connect1 = nil;
	}
	
	[cellDataList release];
	[cellDataDictionary release];
    [homeInfo release];
    [super dealloc];
}


- (void) redrawCellWithDictionary:(NSDictionary*) cellData {
	
	self.cellDataDictionary = [NSMutableDictionary dictionaryWithDictionary:cellData];
	
	NSString* snsId = [cellData objectForKey:@"snsId"];
	
	if ([snsId isEqualToString:@""]) {
		//아임인 유저가 아님
		[cpProfileImg setImageWithURL:[NSURL URLWithString:[cellData objectForKey:@"cpProfileImg"]]
					 placeholderImage:[UIImage imageNamed:@"delay_nosum70.png"]];
		
		if ([[cellData objectForKey:@"cpCode"] isEqualToString:@"-1"]) {
			// 전화번호에서의 추천이라면
			NSString* md5 = [cellData objectForKey:@"md5phoneNo"];
			cpNickNameLarge.text = [Utils getNameWithMd5:md5];
		} else {
			cpNickNameLarge.text = [cellData objectForKey:@"cpName"];
		}


		cpIdString = [cellData objectForKey:@"cpId"]; //dm버튼을 누를 경우 사용할 데이터를 저장해놓자.
		cpCode = [cellData objectForKey:@"cpCode"];
		
		NSString* isInvite = [cellData objectForKey:@"isInvite"];
		
		if ([isInvite isEqualToString:@"0"]) {
			[sendDMBtn setImage:[UIImage imageNamed:@"btn_invite.png"] forState:UIControlStateNormal];
			sendDMBtn.enabled = [[cellData objectForKey:@"cpIsFriend"] isEqualToString:@"1"]; //맞팔 관계가 아니라면 DM보낼 수 없으므로 버튼 비활성화 시키자
		} else {
			[sendDMBtn setImage:[UIImage imageNamed:@"btn_inviting.png"] forState:UIControlStateNormal];
			sendDMBtn.enabled = NO;
		}
		
		imInUserView.hidden = YES;
		nonImInUserView.hidden = NO;
	} else {
		//서로 이웃 여부
		BOOL isFriend = [[cellData objectForKey:@"isFriend"] isEqualToString:@"1"] ? YES : NO; 
		
		if (isFriend) {
			[friendAddBtn setImage:[UIImage imageNamed:@"friend_friend_admin.png"] forState:UIControlStateNormal];
		} else {
			[friendAddBtn setImage:[UIImage imageNamed:@"friend_friend_admin.png"] forState:UIControlStateNormal];
		}


		[profileImg setImageWithURL:[NSURL URLWithString:[cellData objectForKey:@"profileImg"]]
					 placeholderImage:[UIImage imageNamed:@"delay_nosum70.png"]];

		nickName.text = [cellData objectForKey:@"nickname"];
		
		if ([[cellData objectForKey:@"cpCode"] isEqualToString:@"-1"]) {
			// 전화번호에서의 추천이라면
			NSString* md5 = [cellData objectForKey:@"md5phoneNo"];
			cpNickName.text = [NSString stringWithFormat:@"     %@", [Utils getNameWithMd5:md5]];
			cpIcon.hidden = NO;
		} else {
			cpNickName.text = [cellData objectForKey:@"cpName"];
			cpIcon.hidden = YES;
		}
		
		
		columbus.text = [NSString stringWithFormat:@"콜럼버스 %@", [cellData objectForKey:@"totalColumbusCnt"]];
		neighbor.text = [NSString stringWithFormat:@"이웃 %@명", [cellData objectForKey:@"totalNeighborCnt"]];
		
		lastPoiName.text = [cellData objectForKey:@"poiName"];
		
		//마이홈 이동을 위한 저장
		snsIdString = [cellData objectForKey:@"snsId"];
		nickNameString = [cellData objectForKey:@"nickname"];
		profileImgString = [cellData objectForKey:@"profileImg"];
		
		nonImInUserView.hidden = YES;
		imInUserView.hidden = NO;
	}	
}

- (IBAction) goSnsInvite
{
	MY_LOG(@"이웃 초대하기");
	[self request];
}

- (IBAction) goHome
{
	MY_LOG(@"아임IN 홈으로 이동");
	
	UIHomeViewController *vc = [[UIHomeViewController alloc] initWithNibName:@"UIHomeViewController" bundle:nil];
	
	MemberInfo* owner = [[[MemberInfo alloc] init] autorelease];
	owner.snsId = snsIdString;
	owner.nickname = nickNameString;
	owner.profileImgUrl = profileImgString;	
	
	vc.owner = owner;
	
	[(UINavigationController*)[ViewControllers sharedViewControllers].tabBarController.selectedViewController pushViewController:vc animated:YES];
	[vc release];	
}


#pragma mark -
#pragma mark request
- (void) request
{
	UserContext* userContext = [UserContext sharedUserContext];
	
	CgiStringList* strPostData=[[CgiStringList alloc]init:@"&"];
	[strPostData setMapString:@"svcId" keyvalue:SNS_IPHONE_SVCID];
    [strPostData setMapString:@"appVer" keyvalue:[ApplicationContext appVersion]];
	[strPostData setMapString:@"device" keyvalue:SNS_DEVICE_MOBILE_APP];	
	[strPostData setMapString:@"at" keyvalue:@"1"];
	[strPostData setMapString:@"av" keyvalue:userContext.snsID];
	[strPostData setMapString:@"cpCode" keyvalue:cpCode];
	[strPostData setMapString:@"cpIdList" keyvalue:cpIdString];
	[strPostData setMapString:@"msg" keyvalue:@"invite"];
	
	if (connect1 != nil)
	{
		[connect1 stop];
		[connect1 release];
		connect1 = nil;
	}
	
	connect1 = [[HttpConnect alloc] initWithURL:PROTOCOL_CP_MSG
									   postData: [strPostData description]
									   delegate: self
								   doneSelector: @selector(onTransDone:)
								  errorSelector: @selector(onResultError:)
							   progressSelector: nil];
	[strPostData release];
}

- (void) onTransDone:(HttpConnect*)up 
{
	MY_LOG(@"=== cpMsg:\n\n %@\n\n", up.stringReply);
	SBJSON* jsonParser = [SBJSON new];
	[jsonParser setHumanReadable:YES];
	
	NSDictionary* results = (NSDictionary *)[jsonParser objectWithString:up.stringReply error:NULL];
	[jsonParser release];
	
	if (connect1 != nil)
	{
		[connect1 release];
		connect1 = nil;
	}
	
	NSNumber* resultNumber = (NSNumber*)[results objectForKey:@"result"];
	
	if ([resultNumber intValue] == 0) { //에러처리
		[CommonAlert alertWithTitle:@"에러" message:[results objectForKey:@"description"]];
		return;
	} else {
		[CommonAlert alertWithTitle:@"알림" message:@"아임IN 초대장이\n발송되었습니다."];
		[sendDMBtn setImage:[UIImage imageNamed:@"btn_inviting.png"] forState:UIControlStateNormal];
		sendDMBtn.enabled = NO;
		[self.cellDataDictionary setObject:@"1" forKey:@"isInvite"];
		
		if (self.cellDataDictionary != nil) { // replaceObjectAtIndex의 data가 nil이면 문제
			[cellDataList replaceObjectAtIndex:cellDataListIndex withObject:self.cellDataDictionary];
		}
	}

}

- (void) onResultError:(HttpConnect*)connect 
{
	MY_LOG(@"%@", connect.stringReply);
}

#pragma mark -
#pragma mark 이웃설정
- (IBAction) goNeighborSetView
{	
	// 친구 관계가 어떻게 설정되어 있는지 확인한다.
    self.homeInfo = [[[HomeInfo alloc] init] autorelease];
    homeInfo.delegate = self;
    homeInfo.snsId = snsIdString;
    [homeInfo request];
    
//	CgiStringList* strPostData=[[CgiStringList alloc]init:@"&"];
//	
//	[strPostData setMapString:@"svcId" keyvalue:SNS_IPHONE_SVCID];
//    [strPostData setMapString:@"appVer" keyvalue:[ApplicationContext appVersion]];
//	[strPostData setMapString:@"device" keyvalue:SNS_DEVICE_MOBILE_APP];
//	[strPostData setMapString:@"snsId" keyvalue:snsIdString];
//	[strPostData setMapString:@"at" keyvalue:@"1"];
//	[strPostData setMapString:@"av" keyvalue:[UserContext sharedUserContext].snsID];
//	
//	if (connect1 != nil)
//	{
//		[connect1 stop];
//		[connect1 release];
//		connect1 = nil;
//	}
//	
//	connect1 = [[HttpConnect alloc] initWithURL: PROTOCOL_MYHOME_INFO
//									  postData: [strPostData description]
//									  delegate: self
//								  doneSelector: @selector(onMyHomeInfoTransdone:)
//								 errorSelector: @selector(onHttpConnectError:)
//							  progressSelector: nil];
//	//[[OperationQueue queue] addOperation:conn];
//	//[conn release];
//	[strPostData release];
}

- (void) apiFailed {
    
}

- (void) apiDidLoad:(NSDictionary *)result {
    NSInteger friendCodeInt;
	if( ![[result objectForKey:@"result"] boolValue]){
		return;
	}
	
	NSString *whoIs = [result objectForKey:@"isPerm"];
	
	// 서로 이웃인지 여부를 확인해서 표시한다.
	if( [whoIs isEqualToString:@"FRIEND"] ){
		friendCodeInt = FR_TRUE;
	}else if( [whoIs isEqualToString:@"NEIGHBOR_YOU"] ){  // 당신이 그를 친구로 등록했다.
		friendCodeInt = FR_ME;
	}else if( [whoIs isEqualToString:@"NEIGHBOR_ME"] ){
		friendCodeInt = FR_YOU;
	}else{
		friendCodeInt = FR_NONE;
	}
	
	FriendSetViewController *friendSetViewController = [[FriendSetViewController alloc]initWithName:nickNameString friendSnsId: snsIdString friendCode:friendCodeInt friendImage:profileImgString];
    
	NSString* referCode = @"";
	NSString* recomType = @"";
	
	switch (cellType) {
		case IMIN_CELLTYPE_INVITE_FACEBOOK:
			referCode = @"0007";
			break;
		case IMIN_CELLTYPE_INVITE_PHONEBOOK:
			referCode = @"0013";
			break;
		case IMIN_CELLTYPE_INVITE_TWITTER:
			referCode = @"0012";
			break;
		default:
			referCode = @"";
			break;
	}
	
	
	friendSetViewController.referCode = referCode;
	friendSetViewController.recomType = recomType;
	
	friendSetViewController.cellDataList = self.cellDataList;
	friendSetViewController.cellDataListIndex = self.cellDataListIndex;
	
	[friendSetViewController setHidesBottomBarWhenPushed:YES];
	[[ViewControllers sharedViewControllers].neighbersViewController.navigationController pushViewController:friendSetViewController animated:YES];
	[friendSetViewController release];
	[[ViewControllers sharedViewControllers] refreshNeighborVC];

}

//- (void) onHttpConnectError:(HttpConnect*) up
//{
//	if (connect1 != nil)
//	{
//		[connect1 release];
//		connect1 = nil;
//	}
//}
//
//- (void) onMyHomeInfoTransdone:(HttpConnect*)up
//{
//	NSInteger friendCodeInt;
//	SBJSON* jsonParser = [SBJSON new];
//	[jsonParser setHumanReadable:YES];
//	
//	NSDictionary* results = (NSDictionary *)[jsonParser objectWithString:up.stringReply error:NULL];
//	if (connect1 != nil)
//	{
//		[connect1 release];
//		connect1 = nil;
//	}
//	if( ![[results objectForKey:@"result"] boolValue]){
//		[jsonParser release];
//		return;
//	}
//	
//	NSString *whoIs = [results objectForKey:@"isPerm"];
//	
//	// 서로 이웃인지 여부를 확인해서 표시한다.
//	if( [whoIs isEqualToString:@"FRIEND"] ){
//		friendCodeInt = FR_TRUE;
//	}else if( [whoIs isEqualToString:@"NEIGHBOR_YOU"] ){  // 당신이 그를 친구로 등록했다.
//		friendCodeInt = FR_ME;
//	}else if( [whoIs isEqualToString:@"NEIGHBOR_ME"] ){
//		friendCodeInt = FR_YOU;
//	}else{
//		friendCodeInt = FR_NONE;
//	}
//	
//	[jsonParser release];
//	
//	FriendSetViewController *friendSetViewController = [[FriendSetViewController alloc]initWithName:nickNameString friendSnsId: snsIdString friendCode:friendCodeInt friendImage:profileImgString];
//
//	NSString* referCode = @"";
//	NSString* recomType = @"";
//	
//	switch (cellType) {
//		case IMIN_CELLTYPE_INVITE_FACEBOOK:
//			referCode = @"0007";
//			break;
//		case IMIN_CELLTYPE_INVITE_PHONEBOOK:
//			referCode = @"0013";
//			break;
//		case IMIN_CELLTYPE_INVITE_TWITTER:
//			referCode = @"0012";
//			break;
//		default:
//			referCode = @"";
//			break;
//	}
//	
//	
//	friendSetViewController.referCode = referCode;
//	friendSetViewController.recomType = recomType;
//	
//	friendSetViewController.cellDataList = self.cellDataList;
//	friendSetViewController.cellDataListIndex = self.cellDataListIndex;
//	
//	[friendSetViewController setHidesBottomBarWhenPushed:YES];
//	[[ViewControllers sharedViewControllers].neighbersViewController.navigationController pushViewController:friendSetViewController animated:YES];
//	[friendSetViewController release];
//	[[ViewControllers sharedViewControllers] refreshNeighborVC];
//}
//

@end
