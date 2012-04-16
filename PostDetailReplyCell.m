//
//  PostDetailReplyCell.m
//  ImIn
//
//  Created by choipd on 10. 4. 29..
//  Copyright 2010 edbear. All rights reserved.
//

#import "PostDetailReplyCell.h"
#import "macro.h"
#import "UIHomeViewController.h"
#import "ViewControllers.h"
#import "UserContext.h"
#import "ReplyCellData.h"
#import "UIImageView+WebCache.h"
#import "Utils.h"
#import <QuartzCore/QuartzCore.h>
#import "WriteCommentViewController.h"
#import "UIPostReportViewController.h"
#import "BrandHomeViewController.h"
#import "CmtDelete.h"

#define SWIPE_DRAG_HORIZ_MIN 40
#define SWIPE_DRAG_VERT_MAX 40
#define PROFILE_BRAND_IMAGE_FRAME CGRectMake(8, 19, 38, 38)
#define PROFILE_DEFAULT_IMAGE_FRAME CGRectMake(8, 13, 38, 38)

@implementation PostDetailReplyCell

@synthesize postData, dataToUpdate, delegate;

@synthesize comment;
@synthesize description;
@synthesize nickName;
@synthesize profileImg;
@synthesize commentImg;
@synthesize cellData;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        // Initialization code
		self.backgroundColor = RGB(239, 239, 239);
		hasShownMenu = NO;
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
//	UIView* bgView = [[UIView alloc] initWithFrame:self.frame];
//	CAGradientLayer *gradient = [CAGradientLayer layer];
//	gradient.frame = bgView.bounds;
//	gradient.colors = [NSArray arrayWithObjects:(id)[RGB(214, 241, 248) CGColor], (id)[RGB(178, 229, 241) CGColor], nil];
//	[bgView.layer insertSublayer:gradient atIndex:0];
//	self.selectedBackgroundView = bgView;
}


- (void)dealloc {
	[comment release];
	[description release];
	[nickName release];
	[profileImg release];
	[commentImg release];
	
	if (connect != nil) {
		[connect stop];
		[connect release];
		connect = nil;
	}
	
	[cellData release];
	[postData release];
	[dataToUpdate release];
    [super dealloc];
}


#pragma mark -

- (void) redrawUI {
	UIView* bgView = [[[UIView alloc] initWithFrame:self.frame] autorelease];
	bgView.backgroundColor = RGB(239, 239, 239);
	self.backgroundView = bgView;
	comment.text = cellData.comment;
	CGSize size = [Utils getWrapperSizeWithLabel:comment fixedWidthMode:YES fixedHeightMode:NO];
	comment.frame = CGRectMake(comment.frame.origin.x, 
							   comment.frame.origin.y, 
							   size.width, 
							   size.height);

	nickName.text = cellData.nickName;
	description.text = cellData.description;
        
    if ([cellData isBrandUser]) { //브랜드면
        brandMark.hidden = NO;
        profileImg.frame = PROFILE_BRAND_IMAGE_FRAME;
        [brandMark setImage:[UIImage imageNamed:@"brand_mark.png"]];
    } else {
        brandMark.hidden = YES;   
        profileImg.frame = PROFILE_DEFAULT_IMAGE_FRAME;
    }
    
	if ([cellData.cmtID isEqualToString:cellData.parentID]) {
		[profileImg setImageWithURL:[NSURL URLWithString:cellData.profileImgURL]
						placeholderImage:[UIImage imageNamed:@"delay_nosum70.png"]];				
	} else {
		profileImg.image = [UIImage imageNamed:@"rereply_icon.png"];
        brandMark.hidden = YES;
		self.selectionStyle = UITableViewCellSelectionStyleNone;
	}
}


- (IBAction) goProfile {
	MY_LOG(@"프로필 사진 클릭");
    MemberInfo* owner = [[[MemberInfo alloc] init] autorelease];
    owner.snsId = cellData.snsID;
    owner.nickname = nickName.text;
    owner.profileImgUrl = cellData.profileImgURL;	

    
    if ([cellData isBrandUser]) { //브랜드면
        BrandHomeViewController* vc = [[[BrandHomeViewController alloc] initWithNibName:@"BrandHomeViewController" bundle:nil] autorelease];
        vc.owner = owner;
        [(UINavigationController*)[ViewControllers sharedViewControllers].tabBarController.selectedViewController pushViewController:vc animated:YES];  
    } else {
        UIHomeViewController *vc = [[[UIHomeViewController alloc] initWithNibName:@"UIHomeViewController" bundle:nil] autorelease];
        vc.owner = owner;
        [(UINavigationController*)[ViewControllers sharedViewControllers].tabBarController.selectedViewController pushViewController:vc animated:YES];
    }
}


- (void) viewContextMenu:(BOOL)willShow
{
	hasParent = ![cellData.parentID isEqualToString:cellData.cmtID];
	isMine = [cellData.snsID isEqualToString:[UserContext sharedUserContext].snsID];
	[contextMenuView setFrame:CGRectMake(0, 0, 320, self.frame.size.height)];
	[contextMenuBg setFrame:CGRectMake(0, 0, 320, self.frame.size.height)];

	if (willShow)
	{
		[contextMenuBg setAlpha:0.0f];
		
		if (!hasParent) {
			replyButton.hidden = YES;

			replyButton.center = CGPointMake(replyButton.center.x, ceilf(self.frame.size.height/2));
			delButton.center = CGPointMake(delButton.center.x, ceilf(self.frame.size.height/2));
			reportButton.center = CGPointMake(reportButton.center.x, ceilf(self.frame.size.height/2));

		} else { 
			delButton.center = CGPointMake(320/2, ceilf(self.frame.size.height/2));
			reportButton.center = CGPointMake(320/2, ceilf(self.frame.size.height/2));
		}

		
		if (isMine) {
			delButton.hidden = YES;
		} else { 
			reportButton.hidden = YES;
		}

		
		[UIView beginAnimations:@"showExplainView" context:nil];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
		[UIView setAnimationDuration:0.2];
		[contextMenuBg setAlpha:1.0f];
		contextMenuView.userInteractionEnabled = YES;

		if (!hasParent) { 
			replyButton.hidden = NO; 
		}

		if (isMine) {
			delButton.hidden = NO;
		} else {
			reportButton.hidden = NO;
		}
		
		
		[UIView commitAnimations];
	} else
	{
		[contextMenuBg setAlpha:1.0f];
		
		if (!hasParent) {
			replyButton.hidden = NO;
		}
		
		if (isMine) {
			delButton.hidden = NO;
		} else {
			reportButton.hidden = NO;
		}
		
		[UIView beginAnimations:@"hideExplainView" context:nil];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
		[UIView setAnimationDuration:0.2];
		[contextMenuBg setAlpha:0.0f];
		contextMenuView.userInteractionEnabled = NO;

		if (!hasParent) {
			replyButton.hidden = YES;
		}
		
		if (isMine) {
			delButton.hidden = YES;
		} else {
			reportButton.hidden = YES;
		}

		
		[UIView commitAnimations];
	}
}


- (void) showContextMenu:(BOOL)animated {
	if (!hasShownMenu) {
		MY_LOG(@"메뉴 보여주기");
		[self viewContextMenu:YES];
		hasShownMenu = YES;	
	}
}

- (void) disappearConextMenu:(BOOL)animated {
	if (hasShownMenu) {
		MY_LOG(@"메뉴 없애기");
		[self viewContextMenu:NO];
		hasShownMenu = NO;
	}
}

- (void) toggleContextMenu:(BOOL)animated {
	if (!hasShownMenu) {
		[self showContextMenu:animated];
	} else {
		[self disappearConextMenu:animated];
	}
}


- (IBAction) deleteReply:(id) sender
{
	UIAlertView *alert;
	if (hasParent) {
		alert = [[[UIAlertView alloc] initWithTitle:@"알림" message:@"대댓글을 삭제하시겠어요?"
														delegate:self cancelButtonTitle:@"취소" otherButtonTitles:@"확인", nil] autorelease];
	}
	else {
		alert = [[[UIAlertView alloc] initWithTitle:@"알림" message:@"댓글을 삭제하시겠어요? 대댓글이 있을 경우 함께 삭제됩니다."
														delegate:self cancelButtonTitle:@"취소" otherButtonTitles:@"확인", nil] autorelease];
	}

	alert.tag = 100;
	[alert show];
}

- (void)alertView:(UIAlertView*)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (alertView.tag == 100)
	{
		if (buttonIndex == 1)
		{
			// 확인일때  일듯, 0이면 취소일대..
			[self disappearConextMenu:YES];
			MY_LOG(@"삭제하자");
			
			[self requestDelComment];
		}
		return;
	}	
}

- (IBAction) writeReply:(id) sender
{
	[self disappearConextMenu:YES];
	MY_LOG(@"댓글쓰자");

	WriteCommentViewController* vc = [[WriteCommentViewController alloc] initWithNibName:@"WriteCommentViewController" bundle:nil];
	vc.poiData = postData;
	vc.parentId = cellData.cmtID;
	vc.replyCellData = self.dataToUpdate;

	UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:vc];
	[vc release];
	[navController setNavigationBarHidden:YES] ;
	[[ViewControllers sharedViewControllers].tabBarController.selectedViewController presentModalViewController:navController animated:YES];
	[navController release];


}

- (IBAction) reportReply:(id) sender
{
	[self disappearConextMenu:YES];
	MY_LOG(@"신고하자");
	[self goReportComment];
}

#pragma mark -
#pragma mark 삭제하기

- (void) requestDelComment
{
    CmtDelete* cmtDelete = [[CmtDelete alloc] init];

    cmtDelete.delegate = self.delegate;
    [cmtDelete.params addEntriesFromDictionary:[NSDictionary dictionaryWithObject:cellData.cmtID forKey:@"cmtId"]];
    [cmtDelete request];
    

//	UserContext* userContext = [UserContext sharedUserContext];
//	
//	CgiStringList* strPostData=[[CgiStringList alloc]init:@"&"];
//	[strPostData setMapString:@"svcId" keyvalue:SNS_IPHONE_SVCID];
//    [strPostData setMapString:@"appVer" keyvalue:[ApplicationContext appVersion]];
//	[strPostData setMapString:@"device" keyvalue:SNS_DEVICE_MOBILE_APP];
//	[strPostData setMapString:@"at" keyvalue:@"1"];
//	[strPostData setMapString:@"av" keyvalue:userContext.snsID];
//	
//	[strPostData setMapString:@"cmtId" keyvalue:cellData.cmtID];
//	
//	if (connect != nil)
//	{
//		[connect stop];
//		[connect release];
//		connect = nil;
//	}
//	
//	connect = [[HttpConnect alloc] initWithURL:PROTOCOL_CMT_DELETE
//									  postData: [strPostData description]
//									  delegate: self.delegate
//								  doneSelector: @selector(onDelCommentTransDone:)    
//								 errorSelector: @selector(onResultError:)  
//							  progressSelector: nil];
//	[strPostData release];
}

#pragma mark -
#pragma mark 신고하기
- (void) goReportComment
{
	UIPostReportViewController* vc = [[UIPostReportViewController alloc] init];
	[vc setHidesBottomBarWhenPushed:YES];
	[vc setCmtId:cellData.cmtID];
	[vc setPostId:cellData.postID];
	[(UINavigationController*)[ViewControllers sharedViewControllers].tabBarController.selectedViewController pushViewController:vc animated:YES];
	[vc release];
}

@end
