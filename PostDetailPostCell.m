//
//  PostDetailPostCell.m
//  ImIn
//
//  Created by choipd on 10. 4. 28..
//  Copyright 2010 edbear. All rights reserved.
//
#import <AudioToolbox/AudioServices.h>
#import <AudioToolbox/AudioServices.h>
#import "PostDetailPostCell.h"
#import "UIImageView+WebCache.h"
#import "ViewControllers.h"
#import "PostDetailReplyCell.h"
#import "POIDetailViewController.h"
#import "PictureViewController.h"
#import "Utils.h"
#import "UserContext.h"
#import "HttpConnect.h"

#import "CgiStringList.h"
#import "JSON.h"
#import "CommonAlert.h"
#import "const.h"
#import "UIPlazaViewController.h"
#import "UIHomeViewController.h"
#import "UIPostReportViewController.h"
#import "BrandHomeViewController.h"
#import "MainThreadCell.h"
#import "LikersListViewController.h"

#import "ScrapDelete.h"
#import "ScrapInsert.h"

#import "TScrap.h"


@implementation PostDetailPostCell

@synthesize postData;
@synthesize scrapDelete, scrapInsert;

#define PROFILE_BRAND_IMAGE_FRAME CGRectMake(8, 22, 38, 38)
#define PROFILE_DEFAULT_IMAGE_FRAME CGRectMake(8, 12, 38, 38)

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        connect = nil;
    }
    return self;
}

- (void) redrawMainThreadCellWithCellData: (NSMutableDictionary*) data {
	
	self.postData = data;
	UIView* bgView = [[[UIView alloc] initWithFrame:self.frame] autorelease];
	bgView.backgroundColor = [UIColor whiteColor];
	self.backgroundView = bgView;
	
	// 높이 정보 초기값
    float currentHeight = 0.0f;
	const float heightPostLabelUpper = 10.0f;
	const float heightDescLabelUpper = 7.0f;
    const float heightExtBtnAreaUpper = 12.0f;
	const float heightFooterViewUpper = 15.0f;
	const float heightFooterView = 40.0f;
    
    // 이미지 없을 때 너비 상수
    const float widthPostTextView = 195.0f + 60.0f;
	
	postTextView.font = [UIFont fontWithName:@"Helvetica" size:16];
	postTextView.contentInset = UIEdgeInsetsMake(-8,-8,0,0);

	// 이미지가 없으면 너비를 60 늘린다.
	if ([[postData objectForKey:@"imgUrl"] isEqualToString:@""]) {
		CGRect f = CGRectZero;
        f = CGRectMake(postTextView.frame.origin.x, postTextView.frame.origin.y, postTextView.frame.size.width, postTextView.frame.size.height);
		f.size.width = widthPostTextView;
		postTextView.frame = f;
	}

	if ([[postData objectForKey:@"post"] isEqualToString:@""]) {
		postTextView.text = @"발도장 쿡!";
	} else {
		postTextView.text = [postData objectForKey:@"post"];
	}
	
	// 스크롤없이 다 보이게 하기 위해서 프레임크기를 contentSize의 높이값과 동일하게 수정함
	CGSize c = CGSizeZero;
    c = CGSizeMake(postTextView.contentSize.width, postTextView.contentSize.height);
	c.height -= 16;
	postTextView.contentSize = c;
	
	CGRect f = CGRectZero;
    f = CGRectMake(postTextView.frame.origin.x, postTextView.frame.origin.y, postTextView.frame.size.width, postTextView.frame.size.height);
	f.size.height = postTextView.contentSize.height;
	postTextView.frame = f;
	
	descLabel.text = [MainThreadCell getDescriptionWithDictionary:postData];
	
	poiNameLabel.text = [postData objectForKey:@"poiName"];
	
	///////////////////////
	BOOL isEvent = 	[postData objectForKey:@"evtId"] && ![[postData objectForKey:@"evtId"] isEqualToString:@""];
	if (isEvent) { // 이벤트면
		poiNameLabel.frame = CGRectMake(poiNameLabel.frame.origin.x,
										poiNameLabel.frame.origin.y,
										222-32-5, poiNameLabel.frame.size.height); //222 는  xib에 지정된 descLabel 의 넓이, 32는 이벤트아이콘의 가로 사이즈, 5는 텀?
		
		eventIcon.hidden = NO; // 이벤트 표시를 해준다.
		
		CGSize size = [poiNameLabel.text sizeWithFont:poiNameLabel.font];
		
		if(size.width < (222-32-5)) {// 라벨사이즈의 넓이가 한계치보다 크면
			poiNameLabel.frame = CGRectMake(poiNameLabel.frame.origin.x,
											poiNameLabel.frame.origin.y,
											size.width, poiNameLabel.frame.size.height);
		} 
		
		CGRect frame = CGRectZero;
        frame = CGRectMake(eventIcon.frame.origin.x, eventIcon.frame.origin.y, eventIcon.frame.size.width, eventIcon.frame.size.height);
		frame.origin.x = poiNameLabel.frame.origin.x + poiNameLabel.frame.size.width + 3;
		eventIcon.frame = frame;
		
	}
	else {
		eventIcon.hidden = YES; // 이벤트 표시를 가려준다.
	}
	///////////////////////    
    if ([Utils isBrandUser:data]) { //브랜드면
        profileImg.frame = PROFILE_BRAND_IMAGE_FRAME;
        brandMark.hidden = NO;
        [brandMark setImage:[UIImage imageNamed:@"brand_mark.png"]];
    } else {
        profileImg.frame = PROFILE_DEFAULT_IMAGE_FRAME;
        brandMark.hidden = YES;
    }

	[profileImg setImageWithURL:[NSURL URLWithString: [data objectForKey:@"profileImg"]] 
					placeholderImage:[UIImage imageNamed:@"delay_nosum70.png"]];
	float heightDescLabel = 13;

	// 글윗쪽 여백
	currentHeight += heightPostLabelUpper;
	MY_LOG(@"currentHeight:%f", currentHeight);

	// 삭제 버튼은 본인 글에만 보여야
	if (![[data objectForKey:@"snsId"] isEqualToString:[UserContext sharedUserContext].snsID]) {
		delBtn.hidden = YES;
		reportBtn.hidden = NO;
	} else {
		reportBtn.hidden = YES;
		delBtn.hidden = NO;
	}

	if ( nil != [data objectForKey:@"imgUrl"] && ![[data objectForKey:@"imgUrl"] isEqualToString:@""]) { 
		//이미지가 있을 때
		[postImg setAlpha:1.0f];
		[postImg setImageWithURL:[NSURL URLWithString:[data objectForKey:@"imgUrl"]]
				placeholderImage:[UIImage imageNamed:@"delay_nophoto91.png"]];
		//MY_LOG(@"image url %@", [data objectForKey:@"postImgURL);
		[postImgBtn setEnabled:YES];
		[postImgBtn setFrame:postImg.frame];
		CGSize size = CGSizeZero;
        size = CGSizeMake(postTextView.frame.size.width, postTextView.frame.size.height);
        
		MY_LOG(@"height(postTextView): %f, %f", size.width, size.height);
		
		currentHeight += size.height + heightDescLabelUpper;
		//MY_LOG(@"currentHeight:%f", currentHeight);

		size = [Utils getWrapperSizeWithLabel:descLabel];
     
		descLabel.frame = CGRectMake(descLabel.frame.origin.x, currentHeight, size.width, 14);
		
		//그림의 끝과 현재 높이와 비교하여 선택함
		float postImgEndingEdge = postImg.frame.origin.y + postImg.frame.size.height;
		currentHeight = ( currentHeight + heightDescLabel > postImgEndingEdge) ? currentHeight + heightDescLabel : postImgEndingEdge;
	} else { 
		// 이미지가 없을 때
		[postImg setAlpha:0.0f];
		[postImgBtn setEnabled:NO];
		
		CGSize size = CGSizeZero;
        size = CGSizeMake(postTextView.frame.size.width, postTextView.frame.size.height);
        
		MY_LOG(@"height(postTextView): %f, %f", size.width, size.height);
		
		currentHeight += size.height + heightDescLabelUpper;
		//MY_LOG(@"currentHeight:%f", currentHeight);

		size = [Utils getWrapperSizeWithLabel:descLabel];
		descLabel.frame = CGRectMake(descLabel.frame.origin.x, currentHeight, size.width, 14);
		
		currentHeight += heightDescLabel;
	}

    currentHeight += heightExtBtnAreaUpper;
    extBtnArea.frame = CGRectMake(extBtnArea.frame.origin.x, currentHeight, extBtnArea.frame.size.width, extBtnArea.frame.size.height);
    
    
    currentHeight += extBtnArea.frame.size.height;
	currentHeight += heightFooterViewUpper;
    
   
    // 비즈 부모 포스트라면 POI버튼뷰는 보여주지 말자
    if ([[data objectForKey:@"postId"] isEqualToString:[data objectForKey:@"bizPostId"]]) {
        bottomView.hidden = YES;
    } else {
        bottomView.frame = CGRectMake(bottomView.frame.origin.x,
									  currentHeight,
									  bottomView.frame.size.width,
									  bottomView.frame.size.height);
        currentHeight += heightFooterView;
        currentHeight += 10.0f;
        cellHeight = currentHeight;
    }
	
    // liker images view area
    likerImagesArea.frame = CGRectMake(0.0f, currentHeight, likerImagesArea.frame.size.width, likerImagesArea.frame.size.height);
    //신고, 지우기 버튼 위치 flexible
	MY_LOG(@"height(redrawMainThreadCellWithCellData): %f", currentHeight);
    
    // scrap enable/disable
    if ([[data objectForKey:@"isOpenScrap"] isEqualToString:@"1"]) {
        scrapBtn.enabled = YES;
        
        TScrap* aScrap = [[TScrap findByColumn:@"postId" value:[data objectForKey:@"postId"]] lastObject];
        if (aScrap) {
            MY_LOG(@"기억중이네");
            [scrapBtn setImage:[UIImage imageNamed:@"btn_memoring_detail.png"] forState:UIControlStateNormal];
            [scrapBtn setFrame:CGRectMake(0, 0, 74, 19)];
            [delBtn setFrame:CGRectMake(74+10, 0, 18, 19)];
            [reportBtn setFrame:CGRectMake(74+10, 0, 18, 19)];
            
            scrapBtn.tag = 100;
        } else {
            MY_LOG(@"기억에 없어");
            [scrapBtn setImage:[UIImage imageNamed:@"btn_memory_detail.png"] forState:UIControlStateNormal];
            
            [scrapBtn setFrame:CGRectMake(0, 0, 58, 19)];
            [delBtn setFrame:CGRectMake(58+10, 0, 18, 19)];
            [reportBtn setFrame:CGRectMake(58+10, 0, 18, 19)];

            
            scrapBtn.tag = 101;
        }
    } else {
        scrapBtn.enabled = NO;
    }
}

- (float) getHeight {
	return cellHeight;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)dealloc {
	if (connect != nil)
	{
		[connect stop];
		[connect release];
		connect = nil;
	}
	[postData release];
    [extBtnArea release];
    
    [scrapDelete release];
    [scrapInsert release];
    
    [scrapBtn release];
    [likeButtonStr release];
    [likerImagesArea release];
    [super dealloc];
}


#pragma mark -
#pragma mark IBAction 구현
- (IBAction) profileClicked:(id)sender{
	MY_LOG(@"profileClicked");
	
	MemberInfo* owner = [[[MemberInfo alloc] init] autorelease];
	owner.snsId = [postData objectForKey:@"snsId"];
	owner.nickname = [postData objectForKey:@"nickname"];
	owner.profileImgUrl = [postData objectForKey:@"profileImg"];	
	
	if ([Utils isBrandUser:postData]) { //브랜드면
        GA3(@"발도장상세보기", @"브랜드프로필사진", @"발도장상세보기내");

        BrandHomeViewController* vc = [[[BrandHomeViewController alloc] initWithNibName:@"BrandHomeViewController" bundle:nil] autorelease];
        vc.owner = owner;
        [(UINavigationController*)[ViewControllers sharedViewControllers].tabBarController.selectedViewController pushViewController:vc animated:YES];        
        
    } else {
        GA3(@"발도장상세보기", @"프로필사진", @"발도장상세보기내");	
        
        UIHomeViewController *vc = [[[UIHomeViewController alloc] initWithNibName:@"UIHomeViewController" bundle:nil] autorelease];
        vc.owner = owner;
        [(UINavigationController*)[ViewControllers sharedViewControllers].tabBarController.selectedViewController pushViewController:vc animated:YES];        
    }
}

- (IBAction) postImgClicked:(id)sender {
	MY_LOG(@"postImgClicked");
	GA3(@"발도장상세보기", @"유저생성사진", nil);
	PictureViewController* zoomingViewController = [[PictureViewController alloc] initWithNibName:@"PictureViewController" bundle:nil];
	[zoomingViewController setHidesBottomBarWhenPushed:YES];
	zoomingViewController.pictureURL = [postData objectForKey:@"imgUrl"];
	[(UINavigationController*)[ViewControllers sharedViewControllers].tabBarController.selectedViewController pushViewController:zoomingViewController animated:NO];
	[zoomingViewController release];
}

- (IBAction) openPOIBtnClicked:(id)sender {
	MY_LOG(@"openPOIBtnClicked");
	GA3(@"발도장상세보기", @"POI버튼", nil);
	if ([[postData objectForKey:@"poiKey"] isEqualToString:@""]) {
		[CommonAlert alertWithTitle:@"알림" message:@"너~무 넓어 발도장을\n 찍으실 수 없습니다."];
		return;
	}
	POIDetailViewController *detailViewController = [[POIDetailViewController alloc] initWithNibName:@"POIDetailViewController" bundle:nil];
	detailViewController.poiData = postData;
	[(UINavigationController*)[ViewControllers sharedViewControllers].tabBarController.selectedViewController pushViewController:detailViewController animated:YES];
	
	[detailViewController release];
}

- (IBAction) delBtnClicked:(id)sender {
	UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"알림" message:@"발도장을 삭제하시겠어요? 댓글이 있을 경우 함께 삭제됩니다."
												   delegate:self cancelButtonTitle:@"취소" otherButtonTitles:@"확인", nil] autorelease];
	alert.tag = 100;
	[alert show];
}

- (IBAction) reportBtnClicked:(id)sender {
	UIPostReportViewController* vc = [[UIPostReportViewController alloc] init];
	[vc setPostId:[postData objectForKey:@"postId"]];
	[vc setHidesBottomBarWhenPushed:YES];
	[(UINavigationController*)[ViewControllers sharedViewControllers].tabBarController.selectedViewController pushViewController:vc animated:YES];
	[vc release];
}

- (IBAction)toggleScrap:(UIButton*)sender {
    
    if ([postData objectForKey:@"isOpen"] != nil && [[postData objectForKey:@"isOpen"] intValue] == 0) {
        [CommonAlert alertWithTitle:@"안내" message:@"비공개 발도장은\n기억하기가 안 되요~"];
        return;
    }
    // tag: 100-기억하기, 101-기억취소
    if (scrapBtn.tag == 100) {
        
        GA3(@"발도장상세보기", @"기억하기", nil);
        sender.tag = 101; 
        self.scrapDelete = [[[ScrapDelete alloc] init] autorelease];
        scrapDelete.delegate = self;
        [scrapDelete.params addEntriesFromDictionary:[NSDictionary dictionaryWithObject:[postData objectForKey:@"postId"] 
                                                                                 forKey:@"postId"]];
        [scrapDelete request];
    } else {
        
        GA3(@"발도장상세보기", @"기억하기취소", nil);
        sender.tag = 100;
        self.scrapInsert = [[[ScrapInsert alloc] init] autorelease];
        scrapInsert.delegate = self;
        [scrapInsert.params addEntriesFromDictionary:[NSDictionary dictionaryWithObject:[postData objectForKey:@"postId"] 
                                                                                 forKey:@"postId"]];
        [scrapInsert request];
    }
}

/**
 @brief like 한 사람들 보여주기
 */
- (IBAction)showLikers:(id)sender {
    LikersListViewController *vc = [[[LikersListViewController alloc] initWithNibName:@"LikersListViewController" bundle:nil] autorelease];
    [(UINavigationController*)[ViewControllers sharedViewControllers].tabBarController.selectedViewController pushViewController:vc animated:YES];
}

/**
 @brief likers 리스트 보여주기
 */
- (IBAction)toggleLike:(id)sender {
    selectedLike = !selectedLike;
    if (selectedLike) {
        [likeButtonStr setText:@"좋아요 1"];
    } else {
        [likeButtonStr setText:@"좋아요 0"];
    }
}

- (void)alertView:(UIAlertView*)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (alertView.tag == 100)
	{
		if (buttonIndex == 1)
		{
			// 확인일때  일듯, 0이면 취소일대..
			MY_LOG(@"지운다.");
			[self request];
		}
		return;
	}
	if (alertView.tag == 200)
	{
		//TODO: 지울 것을 어떻게 표시한다?? 노티피케이션으로 처리
		//postData.needToDelete = YES;
		[(UINavigationController*)[ViewControllers sharedViewControllers].tabBarController.selectedViewController popViewControllerAnimated:YES];
	}
	
}

#pragma mark -
#pragma mark 글 삭제 요청
- (void) request
{
	UserContext* userContext = [UserContext sharedUserContext];
	
	CgiStringList* strPostData=[[CgiStringList alloc]init:@"&"];
	[strPostData setMapString:@"svcId" keyvalue:SNS_IPHONE_SVCID];
    [strPostData setMapString:@"appVer" keyvalue:[ApplicationContext appVersion]];
	[strPostData setMapString:@"at" keyvalue:@"1"];
	[strPostData setMapString:@"av" keyvalue:userContext.snsID];
	
	[strPostData setMapString:@"postId" keyvalue:[postData objectForKey:@"postId"]];
	[strPostData setMapString:@"device" keyvalue:SNS_DEVICE_MOBILE_APP];	
		
	if (connect != nil)
	{
		[connect stop];
		[connect release];
		connect = nil;
	}
	
	connect = [[HttpConnect alloc] initWithURL:PROTOCOL_POST_DELETE
												postData: [strPostData description]
												delegate: self
											doneSelector: @selector(onTransDone:)    
										   errorSelector: @selector(onResultError:)  
										progressSelector: nil];
	//[[OperationQueue queue] addOperation:conn];
	//[conn release];
	[strPostData release];
}


- (void) onResultError:(HttpConnect*)up
{
	if (connect != nil)
	{
		[connect release];
		connect = nil;
	}
}

- (void) onTransDone:(HttpConnect*)up
{
	//	MY_LOG(@"<!-- postDelete");
	//	MY_LOG(@"%@", up.stringReply);
	//	MY_LOG(@"postDelete -->");
	
	SBJSON* jsonParser = [SBJSON new];
	[jsonParser setHumanReadable:YES];
	
	NSDictionary* results = (NSDictionary *)[jsonParser objectWithString:up.stringReply error:NULL];
	[jsonParser release];
	
	if (connect != nil)
	{
		[connect release];
		connect = nil;
	}
	
	NSNumber* resultNumber = (NSNumber*)[results objectForKey:@"result"];
	
	if ([resultNumber intValue] == 0) {
		[CommonAlert alertWithTitle:@"안내" message:[results objectForKey:@"description"]];
		return;
	} else {
		[[NSNotificationCenter defaultCenter] postNotificationName:@"postDeleted" object:nil];
		UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"알림" message:@"해당 발도장이 삭제되었습니다."
													   delegate:self cancelButtonTitle:@"닫기" otherButtonTitles:nil, nil] autorelease];
		alert.tag = 200;
		[alert show];
	}
}

#pragma mark - imin protocol

- (void) apiFailed {
    
}

-(void) apiDidLoad:(NSDictionary*) result
{
    if ([[result objectForKey:@"func"] isEqualToString:@"scrapDelete"]) {
        
        if ([[result objectForKey:@"result"] boolValue] == NO) {
             scrapBtn.tag = 100;
            return;
        }
        
        [[TScrap database] executeSql:[NSString stringWithFormat:@"DELETE FROM TScrap WHERE postId = '%@'", [postData objectForKey:@"postId"]]];
        MY_LOG(@"scrap deleted");
        
        [scrapBtn setImage:[UIImage imageNamed:@"btn_memory_detail.png"] forState:UIControlStateNormal];
        
        int scrapCnt = [[postData objectForKey:@"scrapCnt"] intValue];
        scrapCnt--;
        [postData setObject:[NSString stringWithFormat:@"%d", scrapCnt] forKey:@"scrapCnt"];
        
        NSDictionary* userInfo = [NSDictionary dictionaryWithObjectsAndKeys:@"delete", @"mode",
                                  postData, @"scrap", nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"scrapModified" object:nil userInfo:userInfo];        
    }
    
    if ([[result objectForKey:@"func"] isEqualToString:@"scrapInsert"]) {
        
        if ([[result objectForKey:@"result"] boolValue] == NO) {
            scrapBtn.tag = 101;
            return;
        }
        
        [[TScrap database] executeSql:[NSString stringWithFormat:@"INSERT INTO TScrap (postId) values ('%@')", [postData objectForKey:@"postId"]]];
        MY_LOG(@"scrap inserted");
        
        [scrapBtn setImage:[UIImage imageNamed:@"btn_memoring_detail.png"] forState:UIControlStateNormal];
        
        int scrapCnt = [[postData objectForKey:@"scrapCnt"] intValue];
        scrapCnt++;
        [postData setObject:[NSString stringWithFormat:@"%d", scrapCnt] forKey:@"scrapCnt"];
        
        NSDictionary* userInfo = [NSDictionary dictionaryWithObjectsAndKeys:@"insert", @"mode",
                                  postData, @"scrap", nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"scrapModified" object:nil userInfo:userInfo];

    }
    [self redrawMainThreadCellWithCellData:postData];
}



@end
