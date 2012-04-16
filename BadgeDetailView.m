//
//  BadgeDetailView.m
//  ImIn
//
//  Created by Myungjin Choi on 11. 2. 11..
//  Copyright 2011 KTH. All rights reserved.
//

#import "BadgeDetailView.h"
#import <QuartzCore/QuartzCore.h>
#import "BadgeInfo.h"
#import "NeighborInviteViewController.h"

@implementation BadgeDetailView
@synthesize badgeData, ownerList, badgeInfo;
@synthesize delegate;
@synthesize biggerBadgeIconLayer;
@synthesize owner;

#pragma mark -
#pragma mark 애니메이숑!!!
- (void) doAnimationWithLayer:(CALayer*) layer withType:(BadgeAnimationType) animationType
{
	layer.zPosition = 1.0f;	
	
	CGFloat animationDuration = 0.5;
	BOOL removedOnCompletion = YES;
	
	CABasicAnimation* rotateAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.y"];
	rotateAnimation.fromValue = [NSNumber numberWithFloat: 0.0];
	rotateAnimation.toValue = [NSNumber numberWithFloat:M_PI/2];
	rotateAnimation.duration = animationDuration/2;
	rotateAnimation.repeatCount = 2;
	rotateAnimation.autoreverses = YES;
	rotateAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
	rotateAnimation.removedOnCompletion = removedOnCompletion;
	
	CABasicAnimation* scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
	scaleAnimation.fromValue = [NSNumber numberWithFloat: 1.0f];
	scaleAnimation.toValue = [NSNumber numberWithFloat:3.0f];
	scaleAnimation.duration = animationDuration;
	scaleAnimation.repeatCount = 0;
	scaleAnimation.autoreverses = NO;
	scaleAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
	scaleAnimation.removedOnCompletion = removedOnCompletion;
	
	
	CAKeyframeAnimation *bounceAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
	bounceAnimation.removedOnCompletion = removedOnCompletion;
	
	CGMutablePathRef thePath = CGPathCreateMutable();
	
	CGFloat midX = self.frame.size.width / 2;
	CGFloat midY = 56 + 252/2;
	
	CGPathMoveToPoint(thePath, NULL, layer.position.x, layer.position.y);
	CGPathAddLineToPoint(thePath, NULL, midX, midY);
	bounceAnimation.path = thePath;
	bounceAnimation.duration = animationDuration;
	CGPathRelease(thePath);
	
	
	CAAnimationGroup *theGroup = [CAAnimationGroup animation];
	theGroup.delegate = self;
	theGroup.duration = animationDuration;
	theGroup.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
	theGroup.animations = [NSArray arrayWithObjects: rotateAnimation, bounceAnimation, scaleAnimation,  nil];
	
	
	switch (animationType) {
		case BADGE_ANIMATION_TYPE1: // 뒤집기, 무지개빛 애니메이션,
		{
			[layer addAnimation:theGroup forKey:@"moveToCenter"];
			layer.position = CGPointMake(midX, midY);
			layer.transform = CATransform3DMakeScale(3, 3, 3);

			layer.masksToBounds = YES;
			break;
		}
		case BADGE_ANIMATION_TYPE2: // 뒤집기, 무지개빛 애니메이션, 진동
			break;
		case BADGE_ANIMATION_TYPE3: // 뒤집기, 무지개빛 애니메이션, 소리
			break;
		case BADGE_ANIMATION_TYPE4: // 뒤집기, 무지개빛 애니메이션, 진동, 소리
			break;
		default:
			break;
	}
}

- (void)animationDidStart:(CAAnimation *)anim
{
	if (isFrontSide) {
		badgeRearSide.hidden = YES;
	}
}


- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag
{
	if (!isFrontSide) {
		badgeRearSide.hidden = NO;
	} 
}

- (void) awakeFromNib
{
	isFrontSide = YES;
	badgeRearSide.layer.name = @"badgeRearSide";
	difficulty.layer.name = @"difficulty";
	since.layer.name = @"since";
	totalUser.layer.name = @"totalUser";
	tipView.layer.zPosition = 100;
}

- (void) startOpeningAnimation {
	self.biggerBadgeIconLayer = [CALayer layer];
	biggerBadgeIconLayer.doubleSided = NO;
	biggerBadgeIconLayer.name = [NSString stringWithFormat:@"biggerBadgeIcon"];
	[biggerBadgeIconLayer setContents:(id)[[Utils getImageFromBaseUrl:[badgeData objectForKey:@"imgUrl"] 
															 withSize:@"252x252" 
															 withType:@"f"] CGImage]];
	
	[biggerBadgeIconLayer setBounds:CGRectMake(0, 0, 84, 84)];
	
	NSValue* from = (NSValue*)[badgeData objectForKey:@"startPoint"];
	CGPoint fromPosition = [from CGPointValue];

	[biggerBadgeIconLayer setPosition:CGPointMake(fromPosition.x, fromPosition.y)];
	
	[self.layer insertSublayer:biggerBadgeIconLayer above:badgeRearSide.layer];
	
	[self doAnimationWithLayer:biggerBadgeIconLayer withType:BADGE_ANIMATION_TYPE1];	
		
}

- (void) drawBasicInfo
{
	titleLabel.text = [badgeData objectForKey:@"badgeName"];
	guideTextView.text = [badgeData objectForKey:@"badgeGuideMsg"];
    
    if ([[badgeData objectForKey:@"type"] isEqualToString:@"K"]) {
        [tipButton setImage:[UIImage imageNamed:@"invite_badge.png"] forState:UIControlStateNormal];
        tipButton.frame = CGRectMake(18, 38, 55, 63);
    }
	
	if ([[badgeData objectForKey:@"badgeTipMsg"] isEqualToString:@""] == NO 
        || [[badgeData objectForKey:@"type"] isEqualToString:@"K"]) {
		[UIView beginAnimations:@"tipButtonShow" context:nil];
		tipButton.alpha = 1.0f;
		[UIView commitAnimations];
		
		tipViewTip.text = [badgeData objectForKey:@"badgeTipMsg"];
		tipViewTitle.text = [badgeData objectForKey:@"badgeName"];
	}
	
}

- (void) requestBadgeInfo
{
	NSAssert(badgeData, @"뱃지에 대한 일차정보는 호출한 VC에서 넘겨받아야 함");
	[self drawBasicInfo];
	self.badgeInfo = [[[BadgeInfo alloc] init] autorelease];
	[badgeInfo.params addEntriesFromDictionary:[NSDictionary
												 dictionaryWithObjectsAndKeys:
												 [badgeData objectForKey:@"badgeId"], @"badgeId",
												 @"4", @"scale4LastUserList",
												owner.snsId, @"snsId", nil]];
	badgeInfo.delegate = self;
	[badgeInfo requestWithoutIndicator];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code.
}		
*/
- (void) doAnimationWithLayer:(CALayer*) layer
{
	NSString* url = [badgeData objectForKey:@"badgeImgUrl"];
	if (url == nil) {
		url = [badgeData objectForKey:@"imgUrl"];
	}
	
	if (isFrontSide) {
		GA3(@"뱃지상세보기", @"뱃지뒤집기", nil);
		isFrontSide = NO;
		[layer setContents:(id)[[Utils getImageFromBaseUrl:url withSize:@"252x252" withType:@"b"] CGImage]];
	} else {
		isFrontSide = YES;
		[layer setContents:(id)[[Utils getImageFromBaseUrl:url withSize:@"252x252" withType:@"f"] CGImage]];
	}
	
	layer.zPosition = -10;
	CGFloat animationDuration = 0.4;
	BOOL removedOnCompletion = YES;
	
	CABasicAnimation* rotateAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.y"];
	rotateAnimation.fromValue = [NSNumber numberWithFloat: 0.0];
	rotateAnimation.toValue = [NSNumber numberWithFloat:M_PI];
	rotateAnimation.duration = animationDuration;
	rotateAnimation.repeatCount = 1;
	rotateAnimation.autoreverses = NO;
	rotateAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
	rotateAnimation.removedOnCompletion = removedOnCompletion;
	
	CAAnimationGroup *theGroup = [CAAnimationGroup animation];
	theGroup.delegate = self;
	theGroup.duration = animationDuration;
	theGroup.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
	theGroup.animations = [NSArray arrayWithObjects: rotateAnimation, nil];
	
	[layer addAnimation:theGroup forKey:@"flip"];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch *touch = [touches anyObject];
	CGPoint tapLocation = [touch locationInView:self];
	
	CALayer *layer = [self.layer hitTest:tapLocation];
	MY_LOG(@"Layer Name = %@", layer.name);
	
	if ([layer.name isEqualToString:@"biggerBadgeIcon"] 
		|| [layer.name isEqualToString:@"difficulty"]
		|| [layer.name isEqualToString:@"since"]
		|| [layer.name isEqualToString:@"badgeRearSide"]
		|| [layer.name isEqualToString:@"totalUser"]) {
		[self doAnimationWithLayer:biggerBadgeIconLayer];
	}
}

- (void)dealloc {
	[badgeData release];
	[ownerList release];
	
	if (badgeInfo != nil) {
		[badgeInfo release];
	}
	[owner release];
	
	[biggerBadgeIconLayer release];
	
    [super dealloc];
}

- (IBAction) closeBadgeVC
{
	if (delegate != nil && [delegate respondsToSelector:@selector(closeVC)]) {
        MY_LOG(@"뱃지 뷰 닫자");
		[delegate performSelector:@selector(closeVC) withObject:nil afterDelay:0.1f];
	}
    [self removeFromSuperview];
}


- (void)closeAndOpenNeighborInvite {
    [self closeBadgeVC];
    
    NeighborInviteViewController *vc = [[[NeighborInviteViewController alloc]initWithNibName:@"NeighborInviteViewController" bundle:nil] autorelease];
    
    [(UINavigationController*)[ViewControllers sharedViewControllers].tabBarController.selectedViewController pushViewController:vc animated:YES];
}

- (IBAction) showTipView {
    
    if ([[badgeData objectForKey:@"type"] isEqualToString:@"K"]) { //초대 뱃지라면
        UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:@"알림"
                                                            message:@"페이스북, 트위터,\n카카오톡의 친구들을\n참!잘왔어요 뱃지와 함께\n아임IN으로 초대해보세요~\n\n초대한 친구가\n아임IN에 가입하면\nFollow me 뱃지를\n획득할 수 있어요~"
                                                           delegate:self
                                                  cancelButtonTitle:@"초대하기"
                                                  otherButtonTitles:@"취소", nil] autorelease];
        GA3(@"뱃지상세보기", @"초대하기버튼", @"뱃지상세보기내");
        alertView.tag = 88888;
        [alertView show];
    } else {
        [UIView beginAnimations:@"show tip view" context:nil];
        tipView.alpha = 1.0f;
        [UIView commitAnimations];
    }    
}

- (IBAction) hideTipView {
	[UIView beginAnimations:@"show tip view" context:nil];
	tipView.alpha = 0.0f;
	[UIView commitAnimations];
}

- (IBAction) closeBadgeDetailView
{
    MY_LOG(@"%@", NSStringFromClass([delegate class]));
	[self removeFromSuperview];
	if (delegate != nil && [delegate respondsToSelector:@selector(closeVC)]
        && [NSStringFromClass([delegate class]) isEqualToString:@"BadgeDetailViewController"]) {
		[delegate performSelector:@selector(closeVC)];
	}
}



- (IBAction) goHome:(UIButton*) sender
{
	MY_LOG(@"sender tag: %d", sender.tag);
	GA3(@"뱃지상세보기", @"프로필사진", @"사진만");
	int ownerIdx = sender.tag - 100;
	NSAssert(ownerIdx >= 0 && ownerIdx <4, @"반드시 0과 3사이 값");
	NSDictionary* aOwner = [ownerList objectAtIndex:ownerIdx];
	MY_LOG(@"nickname = %@", [aOwner objectForKey:@"nickname"]);

	NSString* msg = [NSString stringWithFormat:@"%@님의 홈에 구경가시겠어요?", [aOwner objectForKey:@"nickname"]];
	
	UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"알림" message:msg
													delegate:self cancelButtonTitle:@"취소" otherButtonTitles:@"확인", nil] autorelease];
	alert.tag = sender.tag;
	[alert show];
}

- (void)alertView:(UIAlertView*)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (alertView.tag != 88888 && buttonIndex == 1)
	{
		MY_LOG(@"sender tag: %d", alertView.tag);
		GA3(@"뱃지상세보기", @"프로필사진", @"확인클릭");
		int ownerIdx = alertView.tag - 100;
		NSAssert(ownerIdx >= 0 && ownerIdx <4, @"반드시 0과 3사이 값");
		NSDictionary* aOwner = [ownerList objectAtIndex:ownerIdx];
		MY_LOG(@"nickname = %@", [aOwner objectForKey:@"nickname"]);
		
		[[NSNotificationCenter defaultCenter] postNotificationName:@"closeAndGoHome" object:nil userInfo:aOwner];
		
		[self removeFromSuperview];
		if (delegate != nil && [delegate respondsToSelector:@selector(closeVC)]) {
			[delegate performSelector:@selector(closeVC)];
		}
	}
    
    if (alertView.tag == 88888 && buttonIndex == 0) {
        GA3(@"뱃지상세보기", @"초대하기버튼", @"뱃지상세보기내_초대하기버튼태핑");
        [self closeAndOpenNeighborInvite];
    }
}

- (void) apiFailed {
	
}

- (void) apiDidLoad:(NSDictionary *)result {

	if ([[result objectForKey:@"func"] isEqualToString:@"badgeInfo"]) {
		
		if ([[result objectForKey:@"historyMsg"] isEqualToString:@""] == NO) {
			if ([owner.snsId isEqualToString:[UserContext sharedUserContext].snsID]) {
				guideTextView.text = [[guideTextView.text stringByAppendingString:@"\n\n"] 
									  stringByAppendingString:[result objectForKey:@"historyMsg"]];		
			}
		}
		NSAssert([[result objectForKey:@"difficulty"] intValue] < 6, @"level이 5이하");
		NSAssert([result objectForKey:@"regDate"], @"regDate 와야함");
		
		int difficultyValue = [[result objectForKey:@"difficulty"] intValue];

		NSString* regDate = [result objectForKey:@"regDate"];
		if ([regDate isEqualToString:@""]) {
			since.hidden = YES;
		} else {
			NSString* getDate = [Utils getSimpleDateWithString:[result objectForKey:@"regDate"]];
			since.text = getDate;			
		}
		NSString* userCnt = [NSString stringWithFormat:@"총 %d 명", [[result objectForKey:@"userCnt"] intValue]];
		totalUser.text = userCnt;
		
		NSString* difficultyString = @"";
		for (int i=0; i < difficultyValue; i++) {
			difficultyString = [difficultyString stringByAppendingString:@"★"];
		}
		difficulty.text = difficultyString;

		NSAssert([result objectForKey:@"userCnt"], @"userCnt가 nil이면 안됨");

		if ([[result objectForKey:@"userCnt"] intValue] > 0) {
			badgeOwnerListView.hidden = NO;
			
			self.ownerList = [result objectForKey:@"data"];
			int imgTag = 200;
			for (NSDictionary* aOwner in ownerList) {
				UIButton* aButton = (UIButton*)[badgeOwnerListView viewWithTag:imgTag-100];
				aButton.enabled = YES;
				MY_LOG(@"%@ %@", [aOwner objectForKey:@"nickname"], [aOwner objectForKey:@"profileImg"]);
				NSString* urlString = [aOwner objectForKey:@"profileImg"];
				UIImageView* aImageView = (UIImageView*)[badgeOwnerListView viewWithTag:imgTag++];
				
				[aImageView setImageWithURL:[NSURL URLWithString:urlString] placeholderImage:[UIImage imageNamed:@"delay_nosum70.png"]];
			}
		}
	}
	
}


@end


