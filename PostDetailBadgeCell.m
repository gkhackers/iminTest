//
//  PostDetailBadgeCell.m
//  ImIn
//
//  Created by park ja young on 11. 2. 23..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PostDetailBadgeCell.h"
#import "UIImageView+WebCache.h"
#import "ViewControllers.h"
#import "UIHomeViewController.h"
#import "BadgePictureViewController.h"
#import "MainThreadCell.h"
#import "PostDelete.h"
#import "PictureViewController.h"

@implementation PostDetailBadgeCell

@synthesize postData;
@synthesize profileImg;
@synthesize badgeMsgLabel, badgeMsgTextView;
@synthesize postImg;
@synthesize descLabel;
@synthesize badgeNameLabel;
@synthesize postDelete;
@synthesize brandMark;

#define PROFILE_BRAND_IMAGE_FRAME CGRectMake(8, 22, 38, 38)
#define PROFILE_DEFAULT_IMAGE_FRAME CGRectMake(8, 12, 38, 38)

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
         //connect = nil;
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state.
}


- (void)dealloc {
	[postData release];
	[profileImg release];
	[badgeNameLabel release];
	[badgeMsgTextView release];
	[postImg release];
	[descLabel release];
	[badgeMsgTextView release];
    [postDelete release];
	
    [super dealloc];
}


- (void) redrawMainThreadCellWithCellData: (NSDictionary*) data {
	
	self.postData = data;
	//[postData updateDescription]; //todo: update어쩔까나?
	UIView* bgView = [[[UIView alloc] initWithFrame:self.frame] autorelease];
	bgView.backgroundColor = [UIColor whiteColor];
	self.backgroundView = bgView;
	
	float currentHeight = 0.0f;
	float heightPostLabelUpper = 35.0f;
	float heightDescLabelUpper = 15.0f;
	
	self.badgeMsgTextView.font = [UIFont fontWithName:@"Helvetica" size:15];
	self.badgeMsgTextView.contentInset = UIEdgeInsetsMake(-8,-8,0,0);
	
	MY_LOG(@"post = %@, decription = %@, badgeMsg = %@", [postData objectForKey:@"post"], 
		   [postData objectForKey:@"description"], 
		   [postData objectForKey:@"badgeMsg"]);
	
    if ([[postData objectForKey:@"postType"] isEqualToString:@"2"]) {
        self.badgeNameLabel.text = [postData objectForKey:@"poiName"];
    } else {
        self.badgeNameLabel.text = [postData objectForKey:@"post"];
    }
    
	//뱃지 내용에 혹시 \n 값이 있으면 정리하려고..
	NSString* search = @"\n";
	NSString* replace = @" ";
	NSRange rangeStr;
	
    NSMutableString* badgeMsg = nil;
    if ([[postData objectForKey:@"postType"] isEqualToString:@"2"]) {
        badgeMsg = [NSMutableString stringWithString: [postData objectForKey:@"post"]];
    } else {
        badgeMsg = [NSMutableString stringWithString: [postData objectForKey:@"badgeMsg"]];
    }

	rangeStr = [badgeMsg rangeOfString : search];
	
	while (rangeStr.location != NSNotFound) {
		[badgeMsg replaceCharactersInRange:rangeStr withString:replace];
		rangeStr = [badgeMsg rangeOfString : search];
	}
	
	if ([[postData objectForKey:@"post"] isEqualToString:@""]) {
		self.badgeMsgTextView.text = @"뺏지!";
	} else {
		self.badgeMsgTextView.text = badgeMsg;
	}
	
    CGSize c = CGSizeZero;
    c = CGSizeMake(self.badgeMsgTextView.contentSize.width, self.badgeMsgTextView.contentSize.height);
  
	c.height -= 16;
	self.badgeMsgTextView.contentSize = c;
	
    
    CGRect f = CGRectZero;
    f = CGRectMake(self.badgeMsgTextView.frame.origin.x, self.badgeMsgTextView.frame.origin.y, self.badgeMsgTextView.frame.size.width, self.badgeMsgTextView.frame.size.height);
 
	f.size.height = self.badgeMsgTextView.contentSize.height;
	self.badgeMsgTextView.frame = f;

	self.descLabel.text = [NSString stringWithFormat:@"%@ | 댓글 %@",
						   [Utils getDescriptionWithString:[data objectForKey:@"regDate"]], [data objectForKey:@"cmtCnt"]];
	
    if ([Utils isBrandUser:data]) { //브랜드면
        profileImg.frame = PROFILE_BRAND_IMAGE_FRAME;
        brandMark.hidden = NO;
        [brandMark setImage:[UIImage imageNamed:@"brand_mark.png"]];
    } else {
        profileImg.frame = PROFILE_DEFAULT_IMAGE_FRAME;
        brandMark.hidden = YES;
    }

	[self.profileImg setImageWithURL:[NSURL URLWithString: [data objectForKey:@"profileImg"]] 
					placeholderImage:[UIImage imageNamed:@"delay_nosum70.png"]];
	
	currentHeight += heightPostLabelUpper;
	//이미지가 있을 때
	[postImg setAlpha:1.0f];
    if ([[postData objectForKey:@"postType"] isEqualToString:@"2"]) {
        [postImg setImageWithURL:[NSURL URLWithString:[data objectForKey:@"imgUrl"]]
                placeholderImage:[UIImage imageNamed:@"delay_nophoto91.png"]];
        if (![[postData objectForKey:@"snsId"] isEqualToString:[UserContext sharedUserContext].snsID]) {
            delBtn.hidden = YES;
        } else {
            delBtn.hidden = NO;
        }
    } else {
        delBtn.hidden = YES;
        UIImage* image = [Utils getImageFromBaseUrl:[data objectForKey:@"imgUrl"] withSize:@"53x53" withType:@"f"];
        [postImg setImage:image];
    }
    
	[postImgBtn setEnabled:YES];
	[postImgBtn setFrame:postImg.frame];	

    CGSize size = CGSizeZero;
    size = CGSizeMake(self.badgeMsgTextView.frame.size.width, self.badgeMsgTextView.frame.size.height);
	
	currentHeight += size.height + heightDescLabelUpper;
	size = [Utils getWrapperSizeWithLabel:self.descLabel];
	descLabel.frame = CGRectMake(descLabel.frame.origin.x, currentHeight, size.width, 14);
    delBtn.frame = CGRectMake(descLabel.frame.origin.x + size.width + 5, currentHeight - 1.0f, 15.0f, 15.0f);
	
	//currentHeight += 10.0f;
	
	cellHeight = currentHeight;
	MY_LOG(@"height(redrawMainThreadCellWithCellData): %f", currentHeight);

}

- (float) getHeight {
	return cellHeight;
}

- (void) refreshDescLabel {
	// TODO: description에 어떻게?
	// [postData updateDescription];
	NSString* desc = [MainThreadCell getDescriptionWithDictionary:postData];
	NSRange descRange = [desc rangeOfString:@"|"];
    if (descRange.location != NSNotFound) {
        self.descLabel.text = [desc substringFromIndex:descRange.location+1]; 
    }
}

#pragma mark -
#pragma mark IBAction 구현
- (IBAction) profileClicked:(id)sender{
	MY_LOG(@"profileClicked");
		
	UIHomeViewController *vc = [[UIHomeViewController alloc] initWithNibName:@"UIHomeViewController" bundle:nil];
	
	MemberInfo* owner = [[[MemberInfo alloc] init] autorelease];
	owner.snsId = [postData objectForKey:@"snsId"];
	owner.nickname = [postData objectForKey:@"nickName"];
	owner.profileImgUrl = [postData objectForKey:@"profileImg"];	
	
	vc.owner = owner;
	
	[(UINavigationController*)[ViewControllers sharedViewControllers].tabBarController.selectedViewController pushViewController:vc animated:YES];
	[vc release];
}

- (IBAction) postImgClicked:(id)sender {
    MY_LOG(@"postImgClicked");
    BadgePictureViewController* pictureView = [[BadgePictureViewController alloc] initWithNibName:@"BadgePictureViewController" bundle:nil];
    pictureView.postType = [postData objectForKey:@"postType"];
    [pictureView setPictureUrl:[postData objectForKey:@"imgUrl"]];
    [pictureView setHidesBottomBarWhenPushed:YES];
    [(UINavigationController*)[ViewControllers sharedViewControllers].tabBarController.selectedViewController pushViewController:pictureView animated:NO];
    [pictureView release];
}

- (IBAction) deletePost:(id)sender {
    UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"알림" 
                                                     message:@"마이홈에서 받은 선물 내용을 삭제하셔도 '설정' > 선물함의 받은 목록에서 확인 가능합니다. 단, 댓글이 있을 경우 함께 삭제 됩니다." 
                                                    delegate:self cancelButtonTitle:@"취소" otherButtonTitles:@"삭제", nil] autorelease];
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
			MY_LOG(@"지운다.");
            self.postDelete = [[[PostDelete alloc] init] autorelease];
            postDelete.delegate = self;
            [postDelete.params addEntriesFromDictionary:[NSDictionary dictionaryWithObject:[postData objectForKey:@"postId"] forKey:@"postId"]];	
  
            [postDelete request];
		}
		return;
	}	
    if (alertView.tag == 200)
	{
		[(UINavigationController*)[ViewControllers sharedViewControllers].tabBarController.selectedViewController popViewControllerAnimated:YES];
	}
}

- (void) apiDidLoad:(NSDictionary *)result {
    if ([[result objectForKey:@"func"] isEqualToString:@"postDelete"]) {
        if (![[result objectForKey:@"result"] boolValue]) {			
			return;
		}
        [[NSNotificationCenter defaultCenter] postNotificationName:@"postDeleted" object:nil];
		UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"알림" message:@"해당 하트콘이 삭제되었습니다."
                                                        delegate:self cancelButtonTitle:@"닫기" otherButtonTitles:nil, nil] autorelease];
		alert.tag = 200;
		[alert show];
    }
}

- (void) apiFailed {
    
}

@end
