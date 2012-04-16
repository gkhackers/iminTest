//
//  MyHomePostCell.m
//  ImIn
//
//  Created by KYONGJIN SEO on 3/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MyHomePostCell.h"

#import "BrandHomeViewController.h"
#import "UIHomeViewController.h"
#import "BadgePictureViewController.h"
#import "PictureViewController.h"
#import "UIImageView+WebCache.h"
#import <QuartzCore/QuartzCore.h>

@implementation MyHomePostCell
@synthesize profileImg;
@synthesize nickname;
@synthesize description;
@synthesize poiName;
@synthesize post;
@synthesize lockIcon;
@synthesize postImg;
@synthesize profileButton;
@synthesize postImgButton;
@synthesize eventIcon;
@synthesize seperator;
@synthesize brandMarkImg;
@synthesize cellData = _cellData;
@synthesize snsId = _snsId;
@synthesize userType = _userType;

#define PROFILE_BRAND_IMAGE_FRAME CGRectMake(8, 22, 38, 38)
#define PROFILE_DEFAULT_IMAGE_FRAME CGRectMake(8, 12, 38, 38)
#define NICKNAME_BRAND_FRAME CGRectMake(8, 63, 61, 17)
#define NICKNAME_FRAME CGRectMake(8, 51, 61, 17)

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        brandMarkImg.hidden = YES;
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
	UIView* bgView = [[UIView alloc] initWithFrame:self.frame];
	CAGradientLayer *gradient = [CAGradientLayer layer];
	gradient.frame = bgView.bounds;
	gradient.colors = [NSArray arrayWithObjects:(id)[RGB(214, 241, 248) CGColor], (id)[RGB(178, 229, 241) CGColor], nil];
	[bgView.layer insertSublayer:gradient atIndex:0];
	self.selectedBackgroundView = bgView;
	[bgView release];
}

- (void)dealloc {
    [profileImg release];
    [nickname release];
    [description release];
    [poiName release];
    [post release];
    [lockIcon release];
    [postImg release];
    [profileButton release];
    [postImgButton release];
    [eventIcon release];
    [seperator release];
    [brandMarkImg release];
    [profileImg release];
    [nickname release];
    [description release];
    [poiName release];
    [post release];
    [lockIcon release];
    [postImg release];
    [profileButton release];
    [postImgButton release];
    [eventIcon release];
    [seperator release];
    [brandMarkImg release];
    [super dealloc];
}

#pragma mark - UITableViewCell Redrawing
- (void) redrawMyHomePostCellWithCellData: (NSDictionary*) myCellData {
    
    self.cellData = myCellData;
    
    float topInSet = 12.0f;
    float poiNameHeight = 20.0f;
    float poiPostInSet = 2.0f;
    float postDescInSet = 4.0f;
    float currentHeight = 0.0f;
    float postHeight = 0.0f;
    float descHeight = 0.0f;
    
    nickname.text = [myCellData objectForKey:@"nickname"];
    description.text = [MyHomePostCell getDescriptionWithDictionary:myCellData];
	_imageUrlStr = [myCellData objectForKey:@"profileImg"];
    _snsId = [myCellData objectForKey:@"snsId"];
    
    _brandType = [Utils isBrandUser:myCellData]?BRANDTYPEISBRAND:BRANDTYPEISDEFAULT;
    
    if ([[myCellData objectForKey:@"isBadge"] isEqualToString:@"1"] && [[myCellData objectForKey:@"postType"] isEqualToString:@"1"]) {
        _postType = POSTTYPEISBADGE;
    } else if ([[myCellData objectForKey:@"isBadge"] isEqualToString:@"0"] && [[myCellData objectForKey:@"postType"] isEqualToString:@"2"]) {
        _postType = POSTTYPEISHEARTCON;
    } else {
        _postType = POSTTYPEISPICTURES;
    }
    
    currentHeight = topInSet + poiNameHeight + poiPostInSet; 
    
    // 글 본문 사이즈 계산 및 적용
	CGSize postLabelSize = [MyHomePostCell requiredLabelSize:myCellData withType: (_postType == POSTTYPEISBADGE)? YES:NO];
    postLabelSize = CGSizeMake(postLabelSize.width, postLabelSize.height);
	[post setFrame:CGRectMake(70.0f, currentHeight, postLabelSize.width, postLabelSize.height)];
	postHeight = postLabelSize.height;
	
	// description 사이즈 계산
	descHeight = [Utils getWrapperSizeWithLabel:description fixedWidthMode:NO fixedHeightMode:NO].height;
    
	currentHeight += postHeight;
	if (postHeight != 0) {
		currentHeight += postDescInSet;
	}
    
    //브랜드 구분
    if (_brandType == BRANDTYPEISBRAND) {
        [brandMarkImg setImage:[UIImage imageNamed:@"brand_mark.png"]];
        profileImg.frame = PROFILE_BRAND_IMAGE_FRAME;
        brandMarkImg.hidden = NO;
        nickname.frame = NICKNAME_BRAND_FRAME;
    } else {
        profileImg.frame = PROFILE_DEFAULT_IMAGE_FRAME;
        brandMarkImg.hidden = YES;
        nickname.frame = NICKNAME_FRAME;
    }
    
    post.text = [MyHomePostCell getPostWithDictionary:myCellData];
    [profileImg setImageWithURL:[NSURL URLWithString: [myCellData objectForKey:@"profileImg"]] 
			   placeholderImage:[UIImage imageNamed:@"delay_nosum70.png"]];
    
    
    if (_postType == POSTTYPEISBADGE) { //  postType -> badge
        poiName.text = [myCellData objectForKey:@"badgeName"];
    } else {
        poiName.text = [myCellData objectForKey:@"poiName"];
    }
    
	poiName.frame = CGRectMake(poiName.frame.origin.x,
							   poiName.frame.origin.y,
							   172, poiName.frame.size.height);
	
	[poiName setTextColor:[UIColor colorWithRed:1/255.0 green:129/255.0 blue:176/255.0 alpha:1]];
    
    if (_postType == POSTTYPEISBADGE) { //  postType -> badge
        [self badgeRedrawCellWithCurrentHeight:currentHeight WithCurrentDescriptionHeight:descHeight];
    }  else { // postType -> post, heartcon
        [self postRedrawCellWithCurrentHeight:currentHeight WithCurrentDescriptionHeight:descHeight];
    }

}

- (void) postRedrawCellWithCurrentHeight:(float)currHeight WithCurrentDescriptionHeight: (float)currDescHeight { //post+소상공인(poi랑 매칭될때만)+브랜드
    float currentHeight = currHeight;
    //아직 발도장을 찍은 적이 없는 이웃의 경우는 "아직 발도장을 찍은 곳이 없어요~를 보여줄 위치 지정
    if ([[_cellData objectForKey:@"postId"] isEqualToString:@""]) {
        [poiName setTextColor:[UIColor colorWithRed:17/255.0 green:17/255.0 blue:17/255.0 alpha:1]];
        poiName.text = @"이 이웃에게 관심을..";
    }
    
    NSNumber* openState = [_cellData objectForKey:@"isOpen"];
	BOOL isOpen = NO;
	if (openState != nil) {
		isOpen = [openState intValue] == 0 ? NO : YES;
	} else {
		isOpen = YES;
	}
    
	if (!isOpen) {
		lockIcon.hidden = NO;
		[lockIcon setFrame:CGRectMake(70.0f, currentHeight, 8.0f, 10.0f )];
		[description setFrame:CGRectMake(83.0f, currentHeight, 200, currDescHeight)];		
	} else {
		lockIcon.hidden = YES;
		[description setFrame:CGRectMake(70.0f, currentHeight, 200, currDescHeight)];
	}
    
    currentHeight += currDescHeight;
    
    [self drawSeperatorLine:currentHeight];
    
    // biz 타입이냐?
    if ([[_cellData objectForKey:@"postId"] isEqualToString:[_cellData objectForKey:@"bizPostId"]]) {
        [poiName setTextColor:[UIColor colorWithRed:17/255.0 green:17/255.0 blue:17/255.0 alpha:1]];
        poiName.text = [_cellData objectForKey:@"nickname"];
    } 
    
    BOOL isEvent = [_cellData objectForKey:@"evtId"] && ![[_cellData objectForKey:@"evtId"] isEqualToString:@""];
    
    if (![[_cellData objectForKey:@"imgUrl"] isEqualToString:@""] && nil != [_cellData objectForKey:@"imgUrl"]) {
        [postImg setAlpha:1.0f];
		
        if (isEvent) { // 이벤트면
            poiName.frame = CGRectMake(poiName.frame.origin.x,
                                       poiName.frame.origin.y,
                                       180-32-3, poiName.frame.size.height);
            
            //poiName.text = @"[공식]ABC마트";
            
            eventIcon.hidden = NO; // 이벤트 표시를 해준다.
            
            CGSize size = [poiName.text sizeWithFont:poiName.font];
            
            if(size.width < (180-32-3)) {// 라벨사이즈의 넓이가 한계치보다 크면
                poiName.frame = CGRectMake(poiName.frame.origin.x,
                                           poiName.frame.origin.y,
                                           size.width, poiName.frame.size.height);
            } 
            
            CGRect frame = eventIcon.frame;
            frame.origin.x = poiName.frame.origin.x + poiName.frame.size.width + 3;
            eventIcon.frame = frame;
            
        } else {
            eventIcon.hidden = YES; // 이벤트 표시를 안해준다.
        }
        
        [postImg setImageWithURL:[NSURL URLWithString:[_cellData objectForKey:@"imgUrl"]] placeholderImage:[UIImage imageNamed:@"delay_nophoto91.png"]];
		
        
		[postImgButton setEnabled:YES];
		[postImgButton setFrame:postImg.frame];
    } else {
        if (isEvent) { // 이벤트면
			poiName.frame = CGRectMake(poiName.frame.origin.x,
									   poiName.frame.origin.y,
									   240-32-3, poiName.frame.size.height);
			
			eventIcon.hidden = NO; // 이벤트 표시를 해준다.
			
			CGSize size = [poiName.text sizeWithFont:poiName.font];
			
			if(size.width < (240-32-3)) {// 라벨사이즈의 넓이가 한계치보다 크면
				poiName.frame = CGRectMake(poiName.frame.origin.x,
										   poiName.frame.origin.y,
										   size.width, poiName.frame.size.height);
			} 
			
			CGRect frame = eventIcon.frame;
			frame.origin.x = poiName.frame.origin.x + poiName.frame.size.width + 3;
			eventIcon.frame = frame;
			
		} else {
			eventIcon.hidden = YES; // 이벤트 표시를 안해준다.
		}
		
		[postImg setAlpha:0.0f];
		[postImgButton setEnabled:NO];
    }
    
    _snsId = [_cellData objectForKey:@"snsId"];
}

- (void) heartconRedrawCellWithCurrentHeight:(float)currHeight WithCurrentDescriptionHeight: (float)currDescHeight { 
    float currentHeight = currHeight;
    
    if ([[_cellData objectForKey:@"postId"] isEqualToString:@""]) {
        [poiName setTextColor:[UIColor colorWithRed:17/255.0 green:17/255.0 blue:17/255.0 alpha:1]];
        poiName.text = @"이 이웃에게 관심을..";
    }
    
    NSNumber* openState = [_cellData objectForKey:@"isOpen"];
	BOOL isOpen = NO;
	if (openState != nil) {
		isOpen = [openState intValue] == 0 ? NO : YES;
	} else {
		isOpen = YES;
	}
    
	if (!isOpen) {
		lockIcon.hidden = NO;
		[lockIcon setFrame:CGRectMake(70.0f, currentHeight, 8.0f, 10.0f )];
		[description setFrame:CGRectMake(83.0f, currentHeight, 200, currDescHeight)];		
	} else {
		lockIcon.hidden = YES;
		[description setFrame:CGRectMake(70.0f, currentHeight, 200, currDescHeight)];
	}
    
    currentHeight += currDescHeight;
    
    [self drawSeperatorLine:currentHeight];
    
    // biz 타입이냐?
    if ([[_cellData objectForKey:@"postId"] isEqualToString:[_cellData objectForKey:@"bizPostId"]]) {
        [poiName setTextColor:[UIColor colorWithRed:17/255.0 green:17/255.0 blue:17/255.0 alpha:1]];
        poiName.text = [_cellData objectForKey:@"nickname"];
    } 
    
    BOOL isEvent = [_cellData objectForKey:@"evtId"] && ![[_cellData objectForKey:@"evtId"] isEqualToString:@""];
    
    if (![[_cellData objectForKey:@"imgUrl"] isEqualToString:@""] && nil != [_cellData objectForKey:@"imgUrl"]) {
        [postImg setAlpha:1.0f];
		
        if (isEvent) { // 이벤트면
            poiName.frame = CGRectMake(poiName.frame.origin.x,
                                       poiName.frame.origin.y,
                                       180-32-3, poiName.frame.size.height);
            
            //poiName.text = @"[공식]ABC마트";
            
            eventIcon.hidden = NO; // 이벤트 표시를 해준다.
            
            CGSize size = [poiName.text sizeWithFont:poiName.font];
            
            if(size.width < (180-32-3)) {// 라벨사이즈의 넓이가 한계치보다 크면
                poiName.frame = CGRectMake(poiName.frame.origin.x,
                                           poiName.frame.origin.y,
                                           size.width, poiName.frame.size.height);
            } 
            
            CGRect frame = eventIcon.frame;
            frame.origin.x = poiName.frame.origin.x + poiName.frame.size.width + 3;
            eventIcon.frame = frame;
            
        } else {
            eventIcon.hidden = YES; // 이벤트 표시를 안해준다.
        }
        
        [postImg setImageWithURL:[NSURL URLWithString:[_cellData objectForKey:@"imgUrl"]] placeholderImage:[UIImage imageNamed:@"delay_nophoto91.png"]];
		
        
		[postImgButton setEnabled:YES];
		[postImgButton setFrame:postImg.frame];
    } else {
        if (isEvent) { // 이벤트면
			poiName.frame = CGRectMake(poiName.frame.origin.x,
									   poiName.frame.origin.y,
									   240-32-3, poiName.frame.size.height);
			
			eventIcon.hidden = NO; // 이벤트 표시를 해준다.
			
			CGSize size = [poiName.text sizeWithFont:poiName.font];
			
			if(size.width < (240-32-3)) {// 라벨사이즈의 넓이가 한계치보다 크면
				poiName.frame = CGRectMake(poiName.frame.origin.x,
										   poiName.frame.origin.y,
										   size.width, poiName.frame.size.height);
			} 
			
			CGRect frame = eventIcon.frame;
			frame.origin.x = poiName.frame.origin.x + poiName.frame.size.width + 3;
			eventIcon.frame = frame;
			
		} else {
			eventIcon.hidden = YES; // 이벤트 표시를 안해준다.
		}
		
		[postImg setAlpha:0.0f];
		[postImgButton setEnabled:NO];
    }
    
    _snsId = [_cellData objectForKey:@"snsId"];
    lockIcon.hidden = YES;
    [description setFrame:CGRectMake(70.0f, currentHeight, 200, currDescHeight)];
    currentHeight += currDescHeight;
    [self drawSeperatorLine:currentHeight];
    
   
        description.text = [NSString stringWithFormat:@"%@ | 댓글 %@",[Utils getDescriptionWithString:[_cellData objectForKey:@"regDate"]], [_cellData objectForKey:@"cmtCnt"]];
        post.text = [MyHomePostCell getPostWithDictionary:_cellData];
        [poiName setTextColor:[UIColor colorWithRed:17/255.0 green:17/255.0 blue:17/255.0 alpha:1]];
        
        [postImg setImageWithURL:[NSURL URLWithString:[_cellData objectForKey:@"imgUrl"]]
                placeholderImage:[UIImage imageNamed:@"delay_nophoto91.png"]];
    
    [postImgButton setEnabled:YES];
    [postImgButton setFrame:postImg.frame];

}

- (void) badgeRedrawCellWithCurrentHeight:(float)currHeight WithCurrentDescriptionHeight: (float)currDescHeight {
    float currentHeight = currHeight;
    
	NSString* badgeMsgTemp = [_cellData objectForKey:@"badgeMsg"];
    
    lockIcon.hidden = YES;
    [description setFrame:CGRectMake(70.0f, currentHeight, 200, currDescHeight)];
    currentHeight += currDescHeight;
    [self drawSeperatorLine:currentHeight];
    
    if (_postType == POSTTYPEISBADGE) { //그려야 할 포스트가 뱃지면
        description.text = [NSString stringWithFormat:@"%@ | 댓글 %@",[Utils getDescriptionWithString:[_cellData objectForKey:@"regDate"]], [_cellData objectForKey:@"cmtCnt"]];
        
        [poiName setTextColor:[UIColor colorWithRed:17/255.0 green:17/255.0 blue:17/255.0 alpha:1]];
        post.text = badgeMsgTemp;
        
        [postImg setAlpha:1.0f];
        UIImage* image = [Utils getImageFromBaseUrl:[_cellData objectForKey:@"imgUrl"] withSize:@"53x53" withType:@"f"];
        [postImg setImage:image];        
    } else if (_postType == POSTTYPEISHEARTCON) { //하트콘이면
        description.text = [NSString stringWithFormat:@"%@ | 댓글 %@",[Utils getDescriptionWithString:[_cellData objectForKey:@"regDate"]], [_cellData objectForKey:@"cmtCnt"]];
        post.text = [MyHomePostCell getPostWithDictionary:_cellData];
        [poiName setTextColor:[UIColor colorWithRed:17/255.0 green:17/255.0 blue:17/255.0 alpha:1]];
        
        [postImg setImageWithURL:[NSURL URLWithString:[_cellData objectForKey:@"imgUrl"]]
                placeholderImage:[UIImage imageNamed:@"delay_nophoto91.png"]];
    }
    
    [postImgButton setEnabled:YES];
    [postImgButton setFrame:postImg.frame];

}

- (void) drawSeperatorLine: (float) currPosition {
    float imageBottom;
    
    if (_brandType == BRANDTYPEISBRAND) { //브랜드면
        imageBottom = 75.0f;
    } else {
        imageBottom = 63.0f;
    }
    
    currPosition = (currPosition > imageBottom) ? currPosition : imageBottom;
    float bottomInSet = 10.0f;
    
    currPosition += bottomInSet;
    
    seperator.frame = CGRectMake(0, currPosition-1, seperator.frame.size.width, seperator.frame.size.height);
}

#pragma mark - UIButton Selector
- (IBAction) profileClicked:(id)sender {
    MY_LOG(@"프로필 사진 클릭 %@, %@", sender, _snsId);

    if ([_snsId isEqualToString:@""] || _snsId == nil) { //발도장이 삭제된 것일 경우 체크
        [CommonAlert alertWithTitle:@"안내" message:@"해당 사용자의 프로필을 보실수 없어요~"];
        return;
    }
    
    if (_userType == USERTYPEISMINE) {
        if (_brandType == BRANDTYPEISBRAND) {
            GA3(@"마이홈", @"브랜드프로필사진", @"마이홈내");
        } else {
            GA3(@"마이홈", @"프로필사진", @"마이홈내");
        }
    } else {
        if (_brandType == BRANDTYPEISBRAND) {
            GA3(@"타인홈", @"브랜드프로필사진", @"타인홈내");
        } else {
            GA3(@"타인홈", @"프로필사진", @"타인홈내");
        }
    } 
    
    MemberInfo* owner = [[[MemberInfo alloc] init] autorelease];
    owner.snsId = _snsId;
    owner.nickname = nickname.text;
    owner.profileImgUrl = _imageUrlStr;	
    
    if (_brandType == BRANDTYPEISBRAND) { //브랜드면
        BrandHomeViewController* vc = [[[BrandHomeViewController alloc] initWithNibName:@"BrandHomeViewController" bundle:nil] autorelease];
        vc.owner = owner;
        [(UINavigationController*)[ViewControllers sharedViewControllers].tabBarController.selectedViewController pushViewController:vc animated:YES];        
        
    } else {
        UIHomeViewController *vc = [[[UIHomeViewController alloc] initWithNibName:@"UIHomeViewController" bundle:nil] autorelease];
        vc.owner = owner;
        [(UINavigationController*)[ViewControllers sharedViewControllers].tabBarController.selectedViewController pushViewController:vc animated:YES];        
    }

}

- (IBAction)postImageClicked:(id)sender {
	MY_LOG(@"포스트 사진 클릭");
	
	if (_postType == POSTTYPEISBADGE || _postType == POSTTYPEISHEARTCON) {
		if (_userType == USERTYPEISMINE) { // 마이홈
			GA3(@"마이홈", @"뱃지이미지", @"마이홈내"); 
		} else {
			GA3(@"타인홈", @"뱃지이미지", @"타인홈내"); 
		}
		BadgePictureViewController* pictureView = [[BadgePictureViewController alloc] initWithNibName:@"BadgePictureViewController" bundle:nil];
        pictureView.postType = [_cellData objectForKey:@"postType"];
		[pictureView setPictureUrl:[_cellData objectForKey:@"imgUrl"]];
		[pictureView setHidesBottomBarWhenPushed:YES];
		[(UINavigationController*)[ViewControllers sharedViewControllers].tabBarController.selectedViewController pushViewController:pictureView animated:NO];
		[pictureView release];	
	}
	else {
		//광장, POI, 마이홈, 타인홈의 유저생성사진        
		if  (_userType == USERTYPEISMINE) {
			GA3(@"마이홈", @"유저생성사진", @"마이홈내");
		} else if (_userType == USERTYPEISOTHER) {
			GA3(@"타인홈", @"유저생성사진", @"타인홈내");
		} 
        
		PictureViewController* zoomingViewController = [[PictureViewController alloc] initWithNibName:@"PictureViewController" bundle:nil];
		[zoomingViewController setPictureURL:[_cellData objectForKey:@"imgUrl"]];
		[zoomingViewController setHidesBottomBarWhenPushed:YES];
		[(UINavigationController*)[ViewControllers sharedViewControllers].tabBarController.selectedViewController pushViewController:zoomingViewController animated:NO];
		[zoomingViewController release];		
	}
}

+ (NSString*) getDescriptionWithDictionary:(NSDictionary*) data
{
	NSString* timeDesc = [Utils getDescriptionWithString:[data objectForKey:@"regDate"]];
	NSString* retDescription = nil;
	
	if ([[data objectForKey:@"postId"] isEqualToString:@""]) {
		retDescription = @"아직 발도장을 찍은 곳이 없어요~";
	} else {
		if (![[data objectForKey:@"deviceName"] isEqualToString:@""]) {
			retDescription = [NSString stringWithFormat:@"%@%, %@", timeDesc, [data objectForKey:@"deviceName"]];
		} else {
			retDescription = [NSString stringWithString:timeDesc];
		}
		
		if( [data objectForKey:@"cmtCnt"]  )
		{
			retDescription = [retDescription stringByAppendingFormat:@" | 댓글 %@", [data objectForKey:@"cmtCnt"]];	
		}
        
        if ([[data objectForKey:@"scrapCnt"] intValue] > 0) {
            retDescription = [retDescription stringByAppendingFormat:@" | 기억 %@", [data objectForKey:@"scrapCnt"]];
        }
	}
	
	return retDescription;
	
}

+ (CGSize) requiredLabelSize:(NSDictionary*) cellData withType:(BOOL) isBadge
{	
	float desiredWidth = 174.0f;
    
	CGSize boundingSize = CGSizeMake(desiredWidth, CGFLOAT_MAX);
    
	CGSize requiredSize;
    
	if (isBadge) {
		requiredSize = [[cellData objectForKey:@"badgeMsg"] sizeWithFont:[UIFont fontWithName:@"Helvetica" size:14.0f] 
                                                       constrainedToSize:boundingSize
                                                           lineBreakMode:UILineBreakModeWordWrap];
		
	} else { // 이 경우는 하트콘과 일반 포스트가 동일한 값을 이용한다.
		NSString* aPost = [MyHomePostCell removeCRLFWithString:[cellData objectForKey:@"post"]];
		
		requiredSize = [aPost sizeWithFont:[UIFont fontWithName:@"Helvetica" size:14.0f] 
                         constrainedToSize:boundingSize
                             lineBreakMode:UILineBreakModeWordWrap];
	}
    
	//requiredSize.height = 50;
	//requiredSize.width = 190;
	return requiredSize;
}

+ (NSString*) removeCRLFWithString:(NSString*) srcString 
{
	return [[srcString stringByReplacingOccurrencesOfString:@"\n" withString:@" "] 
			stringByReplacingOccurrencesOfString:@"\r" withString:@""];
}

+ (NSString*) getPostWithDictionary:(NSDictionary*) data
{
	NSString* retValue = nil;
	if ([[data objectForKey:@"isBlind"] isEqualToString:@"1"]) {
		retValue = @"이 게시물은 신고되어 내용을 볼 수 없습니다.";
	} else {
		retValue = [data objectForKey:@"post"];
		retValue = [MyHomePostCell removeCRLFWithString:retValue];
	}
	return retValue;
}

@end
