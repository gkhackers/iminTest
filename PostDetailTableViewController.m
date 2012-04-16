//
//  PostDetailTableViewController.m
//  ImIn
//
//  Created by choipd on 10. 4. 27..
//  Copyright 2010 edbear. All rights reserved.
//

#import "PostDetailTableViewController.h"
#import "PostDetailPostCell.h"
#import "PostDetailBadgeCell.h"
#import "PostDetailReplyCell.h"
#import "PostDetailReplyHeader.h"
#import "JSON.h"
#import "CgiStringList.h"
#import "HttpConnect.h"

#import "const.h"
#import "ReplyCellData.h"
#import "UserContext.h"
#import "UIImageView+WebCache.h"
#import "WriteCommentViewController.h"
#import "ViewControllers.h"
#import "Utils.h"
#import "macro.h"

#import "PostDetailCellNoReply.h"
#import "NetworkTimeoutMessageCell.h"

#import "CommonWebViewController.h"
#import "HomeInfoDetail.h"
#import "CmtList.h"

#import "TScrap.h"

#define COMMENT_PAGE_SIZE 25

@implementation PostDetailTableViewController

@synthesize postData, postList, postIndex;
@synthesize homeInfoDetailResult, homeInfoDetail;
@synthesize cmtList;

#pragma mark -
#pragma mark View lifecycle

- (void)doRequest {
	[self request];
}

- (void)viewDidLoad {
    [super viewDidLoad];

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onDeletePost) name:@"postDeleted" object:nil];
	
	connect = nil;
	replyList = [[NSMutableArray alloc] initWithCapacity:100];
	isReplyListAvailble = NO;
	currentPage = 1; // 페이지는 1부터 시작함
	needToUpdateReReply = NO;
	needToUpdateReply = NO;
	networkTimeout = NO;
	newCmtCnt = [[postData objectForKey:@"cmtCnt"] integerValue];

	
	isFirst = YES;
	firstCellHeight = 0.0f;
	[replyTableView setSeparatorColor:RGB(181, 181, 181)];
	
	invisibleTextView.font = [UIFont fontWithName:@"Helvetica" size:16];
	invisibleTextView.contentInset = UIEdgeInsetsMake(-8,-8,0,0);
    
    [self doRequest];
}

- (void)viewWillAppear:(BOOL)animated {
	
	isSelectAndMove = NO;

    [[UserContext sharedUserContext] recordKissMetricsWithEvent:@"Post Detail Page" withInfo:nil];
	
	MY_LOG(@"======== %@ update", NSStringFromClass([self class]));
	
	[self logViewControllerName];
    [super viewWillAppear:animated];
	if ([[postData objectForKey:@"isBadge"] isEqualToString:@"1"]) {
		titleLabel.text = [NSString stringWithFormat:@"%@의 뱃지", [postData objectForKey:@"nickname"]];
	} else {
        if ([[postData objectForKey:@"postType"] isEqualToString:@"2"]) {
            titleLabel.text = [NSString stringWithFormat:@"%@의 받은선물", [postData objectForKey:@"nickname"]];
        } else {
            titleLabel.text = [NSString stringWithFormat:@"%@의 발도장", [postData objectForKey:@"nickname"]];
        }
	}

	if (dataToUpdate == nil)
		return;
	
	BOOL isRereply = ![dataToUpdate.parentID isEqualToString:dataToUpdate.cmtID];
	
	// 대댓글에 대한 변화
	if (dataToUpdate.comment != nil && isRereply) {
		[self requestReReplyList];
		return;
	}
	
	// 댓글에 대한 변화
	if (dataToUpdate.comment != nil && !isRereply) {
		[replyList insertObject:dataToUpdate atIndex:0];
		
		// 댓글이 바뀌었기에 업데이트 해준다
        if (postList != nil && [postList count] != 0) {
            [postList replaceObjectAtIndex:postIndex withObject:postData];            
        }
		
		[replyTableView reloadData];
		
		if (dataToUpdate != nil) {
			[dataToUpdate release];
			dataToUpdate = nil;
		}
		
		return;
	}
	
	// 글 삭제에 대한 변화
	if ([dataToUpdate.status isEqualToString:@"delete"]) {		
		[replyList removeObject:dataToUpdate];
		[replyTableView reloadData];
		
		if (dataToUpdate != nil) {
			[dataToUpdate release];
			dataToUpdate = nil;		
		}
		return;
	}
}	

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
	if (connect != nil) {
		[connect stop];
		[connect release];
		connect = nil;
	}
	
	if (!isSelectAndMove && dataToUpdate != nil) {
		[dataToUpdate release];
		dataToUpdate = nil;		
	}
	
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
//    return isReplyListAvailble || networkTimeout ? 2 : 1;
    return 2;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
	
	if(section == 0) {
		return 1;
	} else {
        int replyCnt = [replyList count];
		if (networkTimeout || replyCnt == 0) { //여기서 댓글 갯수가 0일지라도 1을 리턴 해주는 이유: 댓글이 없다는 공지를 넣기 위해서.
			return 1;
		} else {
			return replyCnt;
		}
	}
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	if(indexPath.section == 0) {
		//포스트 영역
		switch (indexPath.row) {
			case 0:
			{
				if ([[postData objectForKey:@"isBadge"] isEqualToString:@"1"] || [[postData objectForKey:@"postType"] isEqualToString:@"2"]) {
					static NSString *CellIdentifier = @"PostDetailBadgeCell";
					UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
					
					if (cell == nil) {
						NSArray* nibObjects = [[NSBundle mainBundle] loadNibNamed:@"PostDetailBadgeCell" owner:nil options:nil];
						for (id currentObject in nibObjects) {
							if([currentObject isKindOfClass:[PostDetailBadgeCell class]]) {
								cell = (PostDetailBadgeCell*) currentObject;
								[(PostDetailBadgeCell*)cell redrawMainThreadCellWithCellData:postData];
							}
						}
					} else {
						[(PostDetailBadgeCell*)cell refreshDescLabel];
					}		
					return cell;
				} else {
                    static NSString *CellIdentifier = @"PostDetailPostCell";
                    PostDetailPostCell *cell = (PostDetailPostCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                    
                    if (cell == nil) {
                        cell = [[[NSBundle mainBundle] loadNibNamed:@"PostDetailPostCell" owner:nil options:nil] lastObject];
                    } 
                    [cell redrawMainThreadCellWithCellData:postData];
                    return cell;
				}
			}
			default:
			{
				// 예외 처리 임시
				static NSString *CellIdentifier = @"OtherCell";
				UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
				
				if (cell == nil) {
					cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];					
				}
				cell.textLabel.text = [NSString stringWithFormat:@"Cell %d", indexPath.row];
				return cell;
			}
		}		
		
	} else {
		// 댓글 영역
		if (networkTimeout) {
			static NSString *CellIdentifier = @"NetworkTimeoutMessageCell";
			NetworkTimeoutMessageCell *cell = (NetworkTimeoutMessageCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
			
			if (cell == nil) {
				NSArray* nibObjects = [[NSBundle mainBundle] loadNibNamed:@"NetworkTimeoutMessageCell" owner:nil options:nil];
				
				for (id currentObject in nibObjects) {
					if([currentObject isKindOfClass:[NetworkTimeoutMessageCell class]]) {
						cell = (NetworkTimeoutMessageCell*) currentObject;
					}
				}
			}
			return cell;
			
		} else {
			if ([replyList count] != 0) {
				static NSString *CellIdentifier = @"PostDetailReplyCell";
				PostDetailReplyCell *cell = (PostDetailReplyCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
				
				if (cell == nil) {
					NSArray* nibObjects = [[NSBundle mainBundle] loadNibNamed:@"PostDetailReplyCell" owner:nil options:nil];
					
					for (id currentObject in nibObjects) {
						if([currentObject isKindOfClass:[PostDetailReplyCell class]]) {
							cell = (PostDetailReplyCell*) currentObject;
						}
					}
					ReplyCellData* data = (ReplyCellData*)[replyList objectAtIndex:indexPath.row];
					cell.cellData = data;
					cell.postData = postData;
					[cell redrawUI];
				}
				return cell;
				
			} else { // 댓글 갯수가 0 이면
				static NSString *CellIdentifier = @"ReplyCellWhenEmpty";
				PostDetailCellNoReply *cell = (PostDetailCellNoReply*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
				
				if (cell == nil) {
					NSArray* nibObjects = [[NSBundle mainBundle] loadNibNamed:@"PostDetailCellNoReply" owner:nil options:nil];
					
					for (id currentObject in nibObjects) {
						if([currentObject isKindOfClass:[PostDetailCellNoReply class]]) {
							cell = (PostDetailCellNoReply*) currentObject;
						}
					}
				}
				
				return cell;
			}			
		}
	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	if (indexPath.section == 0 && indexPath.row == 0) {
		//TODO: 이유를 알 수 없지만 이곳에 두번씩 들어온다. 처음에 들어올 때는 제대로 height값을 가져오나,
		//      두번째 들어올 때는 제대로 된 값을 가져오지 못한다. (label의 너비가 넓어짐.
		//      그래서 그 원인을 분석 할 때까지 여기 플래그로 두 번째 진입시에는 처음의 값을 돌려주도록 강제했다.
		if (isFirst == NO) {
			return firstCellHeight;
		}

        // 높이 정보 초기값
        float currentHeight = 0.0f;
        const float heightPostLabelUpper = 10.0f;
        const float heightDescLabelUpper = 7.0f; 
        const float heightExtBtnAreaUpper = 12.0f;
        const float heightFooterViewUpper = 15.0f;
        const float heightFooterView = 40.0f;
        const float heightExtBtnArea = 19.0f;
		const float heightDescLabel = 13.0f;
		const float heightPostImage = 53.0f;
        const float heightLikersView = 40.0f;
		const float postImgEndingEdge = heightPostLabelUpper + heightPostImage;
		const float inset = 10.0f;
		
		if ([[postData objectForKey:@"isBadge"] isEqualToString:@"1"] || [[postData objectForKey:@"postType"] isEqualToString:@"2"]) {
			if ([[postData objectForKey:@"postType"] isEqualToString:@"2"]) {
                if ([[postData objectForKey:@"post"] isEqualToString:@""]) {
                    invisibleTextView.text = @"선물도장!";
                } else {
                    invisibleTextView.text = [postData objectForKey:@"post"];
                }
            } else {
                if ([[postData objectForKey:@"post"] isEqualToString:@""]) {
                    invisibleTextView.text = @"뺏지!";
                } else {
                    invisibleTextView.text = [postData objectForKey:@"badgeMsg"];
                }
            }

			currentHeight += heightPostLabelUpper+25;
			[invisibleTextView sizeToFit];
			CGSize c = CGSizeZero;
            c = CGSizeMake(invisibleTextView.contentSize.width, invisibleTextView.contentSize.height);
			c.height -= 16;
			invisibleTextView.contentSize = c;
			
			CGRect f = CGRectZero;
            f = CGRectMake(invisibleTextView.frame.origin.x, invisibleTextView.frame.origin.y, invisibleTextView.frame.size.width, invisibleTextView.frame.size.height);
			f.size.height = invisibleTextView.contentSize.height;
			invisibleTextView.frame = f;
			
			CGSize size = CGSizeZero;
            size = CGSizeMake(invisibleTextView.frame.size.width, invisibleTextView.frame.size.height);//[Utils getWrapperSizeWithLabel:invisibleLabel fixedWidthMode:YES fixedHeightMode:NO];
			MY_LOG(@"size.height: %f, %@", size.height, invisibleTextView.text);
			
			currentHeight += size.height + heightDescLabelUpper+8;
			currentHeight += heightDescLabel;
			MY_LOG(@"currentHeight:%f", currentHeight);
		}
		else {
            // 뷰의 데이터 초기화
            if ([[postData objectForKey:@"post"] isEqualToString:@""]) {
                invisibleTextView.text = @"발도장 쿡!";
            } else {
                invisibleTextView.text = [postData objectForKey:@"post"];
            }
            
            //글윗쪽 여백
            currentHeight += heightPostLabelUpper;
            MY_LOG(@"currentHeight:%f", currentHeight);
            
            if ( nil != [postData objectForKey:@"imgUrl"] && ![[postData objectForKey:@"imgUrl"] isEqualToString:@""]) { 
                // 이미지가 있을 때
                [invisibleTextView sizeToFit];
                CGSize c = CGSizeZero;
                c = CGSizeMake(invisibleTextView.contentSize.width, invisibleTextView.contentSize.height);
                c.height -= 16;
                invisibleTextView.contentSize = c;
                
                CGRect f = CGRectZero;
                f = CGRectMake(invisibleTextView.frame.origin.x, invisibleTextView.frame.origin.y, invisibleTextView.frame.size.width, invisibleTextView.frame.size.height);
                f.size.height = invisibleTextView.contentSize.height;
                invisibleTextView.frame = f;
                
                CGSize size = CGSizeZero;
                size = CGSizeMake(invisibleTextView.frame.size.width, invisibleTextView.frame.size.height);//[Utils getWrapperSizeWithLabel:invisibleLabel fixedWidthMode:YES fixedHeightMode:NO];
                MY_LOG(@"size.height: %f, %@", size.height, invisibleTextView.text);
                currentHeight += size.height + heightDescLabelUpper;
                MY_LOG(@"currentHeight:%f", currentHeight);
                
                //그림의 끝과 현재 높이와 비교하여 선택함
                currentHeight = ( currentHeight + heightDescLabel > postImgEndingEdge ) ? currentHeight + heightDescLabel : postImgEndingEdge;
                MY_LOG(@"currentHeight:%f", currentHeight);				
            } else { 
                // 이미지가 없을 때
                CGRect originalFrame = CGRectZero;
                originalFrame = CGRectMake(invisibleTextView.frame.origin.x, invisibleTextView.frame.origin.y, invisibleTextView.frame.size.width, invisibleTextView.frame.size.height);
                originalFrame.size.width += 60.0f;			
                invisibleTextView.frame = originalFrame;
                
                [invisibleTextView sizeToFit];
                
                CGSize c = CGSizeZero;
                c = CGSizeMake(invisibleTextView.contentSize.width, invisibleTextView.contentSize.height);
                c.height -= 16;
                invisibleTextView.contentSize = c;
                
                CGRect f = CGRectZero;
                f = CGRectMake(invisibleTextView.frame.origin.x, invisibleTextView.frame.origin.y, invisibleTextView.frame.size.width, invisibleTextView.frame.size.height);
                f.size.height = invisibleTextView.contentSize.height;
                invisibleTextView.frame = f;
                
                
                CGSize size = CGSizeZero;
                size = CGSizeMake(invisibleTextView.frame.size.width, invisibleTextView.frame.size.height);
                
                //[Utils getWrapperSizeWithLabel:invisibleLabel fixedWidthMode:YES fixedHeightMode:NO];
                MY_LOG(@"size.height: %f", size.height);
                
                currentHeight += size.height + heightDescLabelUpper;
                MY_LOG(@"currentHeight:%f", currentHeight);
                
                currentHeight += heightDescLabel;
                MY_LOG(@"currentHeight:%f", currentHeight);
            }
		}
        
        if ([postData objectForKey:@"postType"] == nil || [[postData objectForKey:@"postType"] isEqualToString:@"0"]) { //광장에서 들어오는 포스트는 postType값이 없다. 마이홈에서 들어오는 포스트는 postType이 있다.
            if (![[postData objectForKey:@"postId"] isEqualToString:[postData objectForKey:@"bizPostId"]]) {
                currentHeight += heightExtBtnAreaUpper;
                currentHeight += heightExtBtnArea;
                currentHeight += heightFooterViewUpper;
                currentHeight += heightFooterView;
            }
		}
        
        if ([[postData objectForKey:@"postId"] isEqualToString:[postData objectForKey:@"bizPostId"]]) {
            currentHeight += heightExtBtnAreaUpper;
            currentHeight += heightExtBtnArea;
        }
    
		currentHeight += inset;	
		currentHeight += heightLikersView;  //likers image list & button
        
		MY_LOG(@"currentHeight:%f", currentHeight);
		
		MY_LOG(@"height for row에서 값 %f", currentHeight);
		if (isFirst) {
			firstCellHeight = currentHeight;
			isFirst = NO;
		}
		
		MY_LOG(@"height(heightforrow): %f", currentHeight);
        

		
		return currentHeight;
		
	} else {
		//댓글 영역
		if ([replyList count] > indexPath.row) {
			ReplyCellData* cmtCellData = (ReplyCellData*)[replyList objectAtIndex:indexPath.row];
			commentInvisibleLabel.text = cmtCellData.comment;
			CGSize size = [Utils getWrapperSizeWithLabel:commentInvisibleLabel fixedWidthMode:YES fixedHeightMode:NO];
			
			float cellHeight = 6.0f + 30.0f + size.height + 6.0f;
			
			return cellHeight < 67 ? 67 : cellHeight;
		} else {
			// 댓글이 없을 때, 네트워크 불안할때
            return 220.0f;
		}	
	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	
	if(section == 1) {
		return 39.0f;
	} else {
		return 0.0f;
	}
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    NSString* nibName = nil;
    if ([[UserContext sharedUserContext].snsID isEqualToString:[postData objectForKey:@"snsId"]]) {
        nibName = @"PostDetailReplyHeader";
    } else {
        NSString* lastDigit = [[UserContext sharedUserContext].snsID substringFromIndex:[UserContext sharedUserContext].snsID.length - 2];
        
        if ([lastDigit intValue] % 2 == 0) {
            // B
            nibName = @"PostDetailReplyHeaderB";
        } else {
            // A
            nibName = @"PostDetailReplyHeaderA";
        }
    }

	NSArray* nibObjects = [[NSBundle mainBundle] loadNibNamed:nibName owner:nil options:nil];
	
	
	PostDetailReplyHeader* headerView = nil;
	
	for (id currentObject in nibObjects) {
		if([currentObject isKindOfClass:[PostDetailReplyHeader class]]) {
			headerView = (PostDetailReplyHeader*) currentObject;
		}
	}
	
	return headerView;
}


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	// 그냥 나가는 경우와 선택해서 이동하는 경우를 구분하기 위한 플래그 viewWillAppear 에서 NO로 초기화됨.
	isSelectAndMove = YES;
	
	if (indexPath.section == 0) {
		return;
	}
	
	if ([replyList count] == 0 || [replyList count] < indexPath.row) {
		return;
	}
	
	for (int i=0; i < [replyList count]; i++) {
		if (i == indexPath.row) {
			continue;
		}
		PostDetailReplyCell* cell = (PostDetailReplyCell*)[tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:indexPath.section]];
		[cell disappearConextMenu:YES];
	}
	
	PostDetailReplyCell* cell = (PostDetailReplyCell*)[tableView cellForRowAtIndexPath:indexPath];
	[cell toggleContextMenu:YES];
	[cell setDelegate:self];

	if(dataToUpdate != nil) {
		[dataToUpdate release];
	}
	// 셀에 대한 조작은 한 뒤 돌려받을 자료구조를 생성하고 셀에 넘긴다.
	dataToUpdate = [[[ReplyCellData alloc] init] retain];
	cell.dataToUpdate = dataToUpdate;
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"postDeleted" object:nil];

    [super viewDidUnload];
    
    [invisibleLabel release];
    invisibleLabel = nil;
    
	[invisibleTextView release];
    invisibleTextView = nil;
    
	[commentInvisibleLabel release];
    commentInvisibleLabel = nil;
	
    [titleLabel release];
    titleLabel = nil;
    
	[replyTableView release];
    replyTableView = nil;
}


- (void)dealloc {
	if (connect != nil)
	{
		[connect stop];
		[connect release];
		connect = nil;
	}
	[replyList release];
	[postData release];
	[postList release];
    [homeInfoDetailResult release];
    [homeInfoDetail release];
    [cmtList release];
    [super dealloc];
}


#pragma mark -
#pragma mark IBAction처리

- (IBAction) popViewController {
	[self.navigationController popViewControllerAnimated:YES];
}

- (IBAction) openCommentView {
    
    GA3(@"발도장상세보기", @"댓글입력영역", nil);
    
	isSelectAndMove = YES;
	
	MY_LOG (@"===> postData = %@", postData);
	if ([[postData objectForKey:@"postId"] isEqualToString:@""]) {
		[CommonAlert alertWithTitle:@"안내" message:@"여기에서는 댓글을 쓸 수 없어요~!"];
		return;
	}
	//dataToUpdate 초기화 해서 보낸다.
	if (dataToUpdate != nil) {
		[dataToUpdate release];
	}
	
	
	MY_LOG(@"open Comment view");
	WriteCommentViewController* vc = [[WriteCommentViewController alloc] initWithNibName:@"WriteCommentViewController" bundle:nil];
	vc.poiData = postData;
	dataToUpdate = [[[ReplyCellData alloc] init] retain];
	vc.replyCellData = dataToUpdate;
	
	UINavigationController *navController = [[[UINavigationController alloc] initWithRootViewController:vc] autorelease];
	[navController setNavigationBarHidden:YES] ;
	[self presentModalViewController:navController animated:YES];
	
	[vc release];
	
	needToUpdateReply = YES;
}



#pragma mark -
#pragma mark 덧글/대덧글 목록 조회 프로토콜 요청

- (void) request
{	
    self.cmtList = [[[CmtList alloc] init] autorelease];
    cmtList.delegate = self;
    [cmtList.params addEntriesFromDictionary:[NSDictionary dictionaryWithObjectsAndKeys:[postData objectForKey:@"postId"], @"postId",
                                              [postData objectForKey:@"snsId"], @"snsId",
                                              [NSString stringWithFormat:@"%d", COMMENT_PAGE_SIZE], @"scale",
                                              [NSString stringWithFormat:@"%d", currentPage], @"currPage", nil]];
    
    [cmtList request];
    
//	CgiStringList* strPostData=[[CgiStringList alloc]init:@"&"];
//	[strPostData setMapString:@"svcId" keyvalue:SNS_IPHONE_SVCID];
//    [strPostData setMapString:@"appVer" keyvalue:[ApplicationContext appVersion]];
//	[strPostData setMapString:@"device" keyvalue:SNS_DEVICE_MOBILE_APP];	
//	[strPostData setMapString:@"snsId" keyvalue:[postData objectForKey:@"snsId"]];
//	[strPostData setMapString:@"postId" keyvalue:[postData objectForKey:@"postId"]];
//	[strPostData setMapString:@"at" keyvalue:@"1"];
//	[strPostData setMapString:@"av" keyvalue:[UserContext sharedUserContext].snsID];
//	[strPostData setMapString:@"scale" keyvalue:[NSString stringWithFormat:@"%d", COMMENT_PAGE_SIZE]];
//	[strPostData setMapString:@"currPage" keyvalue:[NSString stringWithFormat:@"%d", currentPage]];
//	
//	if (connect != nil)
//	{
//		[connect stop];
//		[connect release];
//		connect = nil;
//	}
//	
//	connect = [[HttpConnect alloc] initWithURL: PROTOCOL_CMT_LIST
//						   postData: [strPostData description]
//						   delegate: self
//					   doneSelector: @selector(onTransDone:)
//					  errorSelector: @selector(onResultError:)
//				   progressSelector: nil];
//	[strPostData release];
}

- (void) requestMore
{
	if (currentPage * COMMENT_PAGE_SIZE < totalComment) {
		currentPage++;
		[self request];
	}
}

- (void) requestReReplyList
{
	CgiStringList* strPostData=[[CgiStringList alloc]init:@"&"];
	[strPostData setMapString:@"svcId" keyvalue:SNS_IPHONE_SVCID];
    [strPostData setMapString:@"appVer" keyvalue:[ApplicationContext appVersion]];
	[strPostData setMapString:@"device" keyvalue:SNS_DEVICE_MOBILE_APP];	
	[strPostData setMapString:@"snsId" keyvalue:[UserContext sharedUserContext].snsID];
	[strPostData setMapString:@"postId" keyvalue:[postData objectForKey:@"postId"]];
	[strPostData setMapString:@"at" keyvalue:@"1"];
	[strPostData setMapString:@"av" keyvalue:[UserContext sharedUserContext].snsID];
	[strPostData setMapString:@"scale" keyvalue:[NSString stringWithFormat:@"%d", 100]];
	[strPostData setMapString:@"currPage" keyvalue:[NSString stringWithFormat:@"%d", 1]];
	[strPostData setMapString:@"lt" keyvalue:@"R"];
	[strPostData setMapString:@"parentId" keyvalue:dataToUpdate.parentID];
	
	if (connect != nil)
	{
		[connect stop];
		[connect release];
		connect = nil;
	}
	
	connect = [[HttpConnect alloc] initWithURL: PROTOCOL_CMT_LIST
									  postData: [strPostData description]
									  delegate: self
								  doneSelector: @selector(onTransReReplyDone:)
								 errorSelector: @selector(onResultError:)
							  progressSelector: nil];
	//[[OperationQueue queue] addOperation:conn];
	//[conn release];
	[strPostData release];
}

//- (void) onDelCommentTransDone:(HttpConnect*)up
//{
//	SBJSON* jsonParser = [SBJSON new];
//	[jsonParser setHumanReadable:YES];
//	
//	NSDictionary* results = (NSDictionary *)[jsonParser objectWithString:up.stringReply error:NULL];
//	[jsonParser release];
//	
//	NSNumber* resultNumber = (NSNumber*)[results objectForKey:@"result"];
//	
//	if ([resultNumber intValue] == 0) { //에러처리
//		[CommonAlert alertWithTitle:@"안내" message:[results objectForKey:@"description"]];
//		return;
//	}
//
//	
//	MY_LOG(@"삭제해버리자.");
//
//	NSString* cmtId = [results objectForKey:@"cmtId"];
//	
//	NSMutableArray* arrayToDelete = [NSMutableArray arrayWithCapacity:[replyList count]];
//	for (ReplyCellData* cellData in replyList) {
//		// 대댓 글 뿐만 아니라 댓글을 지울 때는 그 하위 대댓글 모두를 함께 지워준다.
//		if ([cellData.cmtID isEqualToString:cmtId] ||
//			[cellData.parentID isEqualToString:cmtId]) {
//			[arrayToDelete addObject:cellData];
//			
//			// 만약 댓글이면, 댓글 갯수를 하나 줄여준다.
//			BOOL hasParent = [cellData.parentID isEqualToString:cellData.cmtID];
//			if (hasParent) {
//				int cmtCounter = [[postData objectForKey:@"cmtCnt"] intValue] - 1;
//				[postData setObject:[NSString stringWithFormat:@"%d", cmtCounter] forKey:@"cmtCnt"];
//				[postList replaceObjectAtIndex:postIndex withObject:postData];
//			}
//		}
//	}
//	[replyList removeObjectsInArray:arrayToDelete];
//	[replyTableView reloadData];
//	
//}




#pragma mark -
#pragma mark UIScrollView delegate

- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView {
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
	if (isEnd) {
        [self requestMore];
	}
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	//MY_LOG(@"%f, %f", scrollView.contentOffset.y + 378, scrollView.contentSize.height);
	if (scrollView.contentOffset.y + 378 > scrollView.contentSize.height) {
		isEnd = YES;
	} else {
		isEnd = NO;
	}

	
}

- (void) onDeletePost {
	
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"postDeleted" object:nil];
	
	if (postList != nil && postIndex < [postList count]) {
		[postList removeObjectAtIndex:postIndex];
	}
}

#pragma mark -
#pragma mark iminProtocol

- (void) apiFailedWhichObject:(NSObject *)theObject {
    if (dataToUpdate != nil) {
        [dataToUpdate release];
        dataToUpdate = nil;		
    }
    
    networkTimeout = YES;

    if ([NSStringFromClass([theObject class]) isEqualToString:@"CmtDelete"]) {
        [theObject release];
    } 
    
    [replyTableView reloadData]; 
}

- (void) apiDidLoadWithResult:(NSDictionary *)result whichObject:(NSObject *)theObject {
    if ([[result objectForKey:@"func"] isEqualToString:@"homeInfoDetail"]) {
        self.homeInfoDetailResult = result;
        
        if ([[homeInfoDetailResult objectForKey:@"isDenyGuest"] isEqualToString:@"1"]) { // 차단 유저
            NSString* msg = [NSString stringWithFormat:@"%@님이 선물을 사양하셨어요~", [postData objectForKey:@"nickname"]];
            [CommonAlert alertWithTitle:@"안내" message:msg];
            return;
        }
        
        CommonWebViewController* vc = [[[CommonWebViewController alloc] initWithNibName:@"CommonWebViewController" bundle:nil] autorelease];
        
        vc.urlString = [NSString stringWithFormat:@"%@?snsId=%@&device=%@&osVer=%@&targetSnsId=%@", 
                        HEARTCON_GIFT,
                        [UserContext sharedUserContext].snsID,
                        [ApplicationContext deviceId],
                        [[UIDevice currentDevice] systemVersion],
                        [postData objectForKey:@"snsId"]];
        
        vc.titleString = @"선물하기";
        vc.viewType = HEARTCON;
        
        [(UINavigationController*)[ViewControllers sharedViewControllers].tabBarController.selectedViewController 
         presentModalViewController:vc animated:YES];

    }
    
    if ([[result objectForKey:@"func"] isEqualToString:@"cmtList"]) {
        if ([[result objectForKey:@"result"] boolValue] == NO) {
            [CommonAlert alertWithTitle:@"안내" message:[result objectForKey:@"description"]];
            return;
        }
        
        NSArray* cmtListData = [result objectForKey:@"data"];
        
        int lastCellIndex = [replyList count] - 2;
        if (lastCellIndex < 0) {
            lastCellIndex = 0;
        }
        
        for (NSDictionary *cmtData in cmtListData) {
            ReplyCellData* cellData = [[[ReplyCellData alloc] initWithDictionary:cmtData] autorelease];		
            [replyList addObject:cellData];
        }
        
        currentPage = [[result objectForKey:@"currPage"] intValue];
        totalComment = [[result objectForKey:@"totalCnt"] intValue];
        
        if (totalComment != [[postData objectForKey:@"cmtCnt"] intValue]) {
            [postData setObject:[NSString stringWithFormat:@"%d", totalComment] forKey:@"cmtCnt"];
            if (postIndex != NSNotFound) {
                [postList replaceObjectAtIndex:postIndex withObject:postData];
                
            }
        }
        
        scale = [[result objectForKey:@"scale"] intValue];
        
        isReplyListAvailble = YES;
        
        [replyTableView reloadData];
        
        if ([replyList count] > 0 && [cmtListData count] > 0 &&  lastCellIndex > 0) {
            [replyTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:lastCellIndex inSection:1] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
        }
    }
    
    if ([[result objectForKey:@"func"] isEqualToString:@"cmtDelete"]) {
        [theObject release];
        NSNumber* resultNumber = (NSNumber*)[result objectForKey:@"result"];
        
        if ([resultNumber intValue] == 0) { //에러처리
            [CommonAlert alertWithTitle:@"안내" message:[result objectForKey:@"description"]];
            return;
        }
        NSString* cmtId = [result objectForKey:@"cmtId"];
        
        NSMutableArray* arrayToDelete = [NSMutableArray arrayWithCapacity:[replyList count]];
        for (ReplyCellData* cellData in replyList) {
            // 대댓 글 뿐만 아니라 댓글을 지울 때는 그 하위 대댓글 모두를 함께 지워준다.
            if ([cellData.cmtID isEqualToString:cmtId] ||
                [cellData.parentID isEqualToString:cmtId]) {
                [arrayToDelete addObject:cellData];
                
                // 만약 댓글이면, 댓글 갯수를 하나 줄여준다.
                BOOL hasParent = [cellData.parentID isEqualToString:cellData.cmtID];
                if (hasParent) {
                    int cmtCounter = [[postData objectForKey:@"cmtCnt"] intValue] - 1;
                    [postData setObject:[NSString stringWithFormat:@"%d", cmtCounter] forKey:@"cmtCnt"];
                    [postList replaceObjectAtIndex:postIndex withObject:postData];
                }
            }
        }
        [replyList removeObjectsInArray:arrayToDelete];
        [replyTableView reloadData];
    }
}

- (void) openGiftSend:(UIButton*) sender
{
    if (sender.tag == 100) {
        //A:왼쪽
        GA3(@"발도장상세보기", @"선물", @"왼쪽");
    } else {
        GA3(@"발도장상세보기", @"선물", @"오른쪽");
    }

    self.homeInfoDetail = [[[HomeInfoDetail alloc] init] autorelease];
	homeInfoDetail.delegate = self;
	[homeInfoDetail.params addEntriesFromDictionary:[NSDictionary dictionaryWithObject:[postData objectForKey:@"snsId"] forKey:@"snsId"]];
	[homeInfoDetail request];
}

- (void) onResultError:(HttpConnect*)up
{
    if (connect != nil)
    {
        [connect release];
        connect = nil;
    }
    
    if (dataToUpdate != nil) {
        [dataToUpdate release];
        dataToUpdate = nil;		
    }
    
    networkTimeout = YES;
    
    [replyTableView reloadData];
}

- (void) onTransReReplyDone:(HttpConnect*)up
{
//    MY_LOG(@"**** cmtList ***** :\n%@", up.stringReply);
//    
//    SBJSON* jsonParser = [SBJSON new];
//    [jsonParser setHumanReadable:YES];
//    
//    NSDictionary* results = (NSDictionary *)[jsonParser objectWithString:up.stringReply error:NULL];
//    [jsonParser release];
    
    NSDictionary* results = [up.stringReply objectFromJSONString];
    
    if (connect != nil)
    {
        [connect release];
        connect = nil;
    }
    
    NSArray* cmtListData = [results objectForKey:@"data"];
    
    int indexToUpdate = 0;
    NSMutableArray* arrayToDelete = [NSMutableArray arrayWithCapacity:[cmtListData count]];
    for (ReplyCellData* cellData in replyList) {
        if ([cellData.parentID isEqualToString:dataToUpdate.parentID]) {
            if (![cellData.parentID isEqualToString:cellData.cmtID]) {
                [arrayToDelete addObject:cellData];
            } else {
                indexToUpdate = [replyList indexOfObject:cellData] + 1;
            }
        }
    }
    
    [replyList removeObjectsInArray:arrayToDelete];
    
    NSMutableArray* rereplyList = [NSMutableArray arrayWithCapacity:[cmtListData count]];
    
    for (NSDictionary *cmtData in cmtListData) {
        ReplyCellData* cellData = [[[ReplyCellData alloc] initWithDictionary:cmtData] autorelease];
        [rereplyList addObject:cellData];
    }
    
    for (int i=0; i<[rereplyList count]; i++) {
        [replyList insertObject:[rereplyList objectAtIndex:i] atIndex:indexToUpdate++];	
    }
    
    isReplyListAvailble = YES;
    [replyTableView reloadData];
    
    needToUpdateReReply = NO;
    
    if (dataToUpdate != nil) {
        [dataToUpdate release];
        dataToUpdate = nil;		
    }
}

//- (void) onTransDone:(HttpConnect*)up
//{
//    MY_LOG(@"**** cmtList ***** :\n%@", up.stringReply);
//    
//    SBJSON* jsonParser = [SBJSON new];
//    [jsonParser setHumanReadable:YES];
//    
//    NSDictionary* results = (NSDictionary *)[jsonParser objectWithString:up.stringReply error:NULL];
//    [jsonParser release];
//    
//    if ([[results objectForKey:@"result"] boolValue] == NO) {
//        [CommonAlert alertWithTitle:@"안내" message:[results objectForKey:@"description"]];
//        return;
//    }
//    
//    if (connect != nil)
//    {
//        [connect release];
//        connect = nil;
//    }
//    NSArray* cmtListData = [results objectForKey:@"data"];
//    
//    int lastCellIndex = [replyList count] - 2;
//    if (lastCellIndex < 0) {
//        lastCellIndex = 0;
//    }
//    
//    for (NSDictionary *cmtData in cmtListData) {
//        ReplyCellData* cellData = [[[ReplyCellData alloc] initWithDictionary:cmtData] autorelease];		
//        [replyList addObject:cellData];
//    }
//    
//    currentPage = [[results objectForKey:@"currPage"] intValue];
//    totalComment = [[results objectForKey:@"totalCnt"] intValue];
//    
//    if (totalComment != [[postData objectForKey:@"cmtCnt"] intValue]) {
//        [postData setObject:[NSString stringWithFormat:@"%d", totalComment] forKey:@"cmtCnt"];
//        if (postIndex != NSNotFound) {
//            [postList replaceObjectAtIndex:postIndex withObject:postData];
//            
//        }
//    }
//    
//    scale = [[results objectForKey:@"scale"] intValue];
//    
//    isReplyListAvailble = YES;
//    
//    [replyTableView reloadData];
//    
//    if ([replyList count] > 0 && [cmtListData count] > 0 &&  lastCellIndex > 0) {
//        [replyTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:lastCellIndex inSection:1] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
//    }
//}


@end

