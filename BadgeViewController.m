//
//  BadgeViewController.m
//  ImIn
//
//  Created by Myungjin Choi on 11. 2. 18..
//  Copyright 2011 KTH. All rights reserved.
//

#import "BadgeViewController.h"
#import "BadgeList.h"
#import "LastBadgeList.h"
#import "BadgeImageView.h"

// cells
#import "LatestBadgeCell.h"
#import "AlbumBadgeCell.h"
#import "ListBadgeCell.h"
#import "SetBadgeCell.h"

#import "TFeedList.h"
#import "NotiList.h"

#import "UpdateNotificationView.h"
#import "CommonWebViewController.h"
#import "BadgeDetailView.h"

#import "NSString+URLEncoding.h"
#import <QuartzCore/QuartzCore.h>

@implementation BadgeViewController
@synthesize lastBadgeArray, badgeArray, owner, badgeListArray;
@synthesize lastBadgeList, badgeList;
@synthesize manager;


#define NUMBER_OF_BADGES_IN_CELL_DEFAULT 3;


#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(closeVC) name:@"closeAndGoHome" object:nil];
	
	NSAssert(owner != nil, @"badge 소유자 정보는 전달되어야 한다");
	titleLabel.text = [NSString stringWithFormat:@"%@님의 뱃지", owner.nickname];

	if ([owner.snsId isEqualToString:[UserContext sharedUserContext].snsID]) { // 본인의 뱃지라면
		viewModeButton.hidden = NO;
        [self requestNotiList];

	} else {
		viewModeButton.hidden = YES;
	}
	
	setBadgeCellList = [[NSMutableDictionary dictionaryWithCapacity:10] retain];

	
	//UI 스타일 초기화
	badgeTableView.separatorColor = [UIColor clearColor];
	badgeTableView.backgroundColor = [UIColor clearColor];
	isAlbumView = YES; // 앨범형태로 보여준다.
	
	apiDidLoadCnt = 0; // reloadData 두번 호출 방지용 카운터
	
	[self requestLastBadgeList];
	[self requestBadgeList];
    
    
	
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(badgeTapped:) 
												 name:BADGE_IMAGE_TAPPED_NOTIFICATION 
											   object:nil];
}

- (void) viewWillAppear:(BOOL)animated {
    [self.manager hideUpdateNotification:NO];
}

- (void)dealloc {
	[lastBadgeArray release];
	[badgeListArray release];
	[badgeArray release];
	[owner release];
	
	[badgeList release];
	[lastBadgeList release];
	
	[setBadgeCellList release];
    [manager release];
	
    [super dealloc];
}

#pragma mark -
#pragma mark 아임인 프로토콜 구현
- (void) requestBadgeList {
	self.badgeList = [[[BadgeList alloc] init] autorelease];
	badgeList.delegate = self;

	NSArray* keys = [NSArray arrayWithObjects:@"snsId", @"scale", @"listType", @"isAlbum", nil];
	NSArray* values = [NSArray arrayWithObjects:owner.snsId, @"100", @"0", @"1", nil];
	[badgeList.params addEntriesFromDictionary:[NSDictionary dictionaryWithObjects:values forKeys:keys]];
	
	[badgeList requestWithAuth:YES withIndicator:YES];	
}

- (void) requestLastBadgeList {
	self.lastBadgeList = [[[LastBadgeList alloc] init] autorelease];
	lastBadgeList.delegate = self;
	
	NSArray* keys = [NSArray arrayWithObjects:@"snsId", @"scale", @"listType",  nil];
	NSArray* values = [NSArray arrayWithObjects:owner.snsId, @"3", @"2",  nil];
	[lastBadgeList.params addEntriesFromDictionary:[NSDictionary dictionaryWithObjects:values forKeys:keys]];

	[lastBadgeList requestWithAuth:YES withIndicator:YES];
}

- (void)requestNotiList {
    
    NotiList *notiList = [[NotiList alloc] init];
    notiList.delegate = self;
    [notiList.params addEntriesFromDictionary:[NSDictionary dictionaryWithObjectsAndKeys:@"B", @"notiType", nil]];
    [notiList request];
}

- (NSArray*) reformatArray:(NSArray*) aArray {
	
	NSMutableArray* arrayToReturn = [NSMutableArray array];
	NSMutableArray* aGroupArray = nil;
	
	int subIdx = 0;	// sub array의 index
	for (int i=0; i < [aArray count]; i++) {
		int numberOfBadgeInCell = NUMBER_OF_BADGES_IN_CELL_DEFAULT;
		int memberCnt = [[[aArray objectAtIndex:i] objectForKey:@"memberCnt"] intValue];
		
		if (memberCnt == 0) { // 일반 뱃지들이라면
			if (subIdx % numberOfBadgeInCell == 0) {
				subIdx = 0;
				// 생성
				aGroupArray = [NSMutableArray arrayWithCapacity:numberOfBadgeInCell];
			}
			[aGroupArray addObject:[aArray objectAtIndex:i]];
			if ( subIdx % numberOfBadgeInCell == (numberOfBadgeInCell - 1) ) {
				// 넣기
				[arrayToReturn addObject:aGroupArray];
			}
			subIdx++;
		} else { // 세트 뱃지들이면 그냥 추가
			if (subIdx % numberOfBadgeInCell != 0) {
				[arrayToReturn addObject:aGroupArray];
				subIdx = 0;
			}
			[arrayToReturn addObject:[[aArray objectAtIndex:i] objectForKey:@"member"]];
		}
	}
	return arrayToReturn;
}

- (NSArray*) reformatArrayListType:(NSArray*) aArray {
	NSMutableArray* arrayToReturn = [NSMutableArray array];
	for (NSDictionary* aBadge in aArray) {
		if ([[aBadge objectForKey:@"memberCnt"] intValue]) {
			for (NSDictionary* aSubBadge in [aBadge objectForKey:@"member"]) {
				[arrayToReturn addObject:aSubBadge];
			}
		} else {
			[arrayToReturn addObject: aBadge];
		}
	}
	return arrayToReturn;
}

- (void) apiFailedWhichObject:(NSObject *)theObject {
	// 뱃지 목록 시도에서 하나 혹은 둘 다 실패하는 경우에도 그려주도록 수정 
    if ( [NSStringFromClass([theObject class]) isEqualToString:@"NotiList"] ) {
        [theObject release];
    } else { 
        [badgeTableView reloadData];
    }
}

- (void) apiDidLoadWithResult:(NSDictionary *)result whichObject:(NSObject *)theObject
{
	if ([[result objectForKey:@"func"] isEqualToString:@"lastBadgeList"]) {
		
		self.lastBadgeArray = [result objectForKey:@"data"];

		if (++apiDidLoadCnt == 2) {
			[badgeTableView reloadData];			
		}
	}
	
	if ([[result objectForKey:@"func"] isEqualToString:@"badgeList"]) {
		self.badgeArray = [self reformatArray:[result objectForKey:@"data"]];
		self.badgeListArray = [self reformatArrayListType:[result objectForKey:@"data"]];
		
		int badgeCnt = [[result objectForKey:@"badgeCnt"] intValue];
		int totalCnt = [[result objectForKey:@"totalCnt"] intValue];
		
		numberOfBadgeOwned.text = [NSString stringWithFormat:@"%d/%d,", badgeCnt, totalCnt];
		myBadgeProgress.text = [NSString stringWithFormat:@"%.0f%%", (float)badgeCnt / (float)totalCnt * 100.0f];
		
		sectionHeaderViewForTotalBadge.alpha = 0.0;
		[UIView beginAnimations:@"progressHeader" context:nil];
		[UIView setAnimationDuration:1.5];
		sectionHeaderViewForTotalBadge.alpha = 1.0;
		[UIView commitAnimations];
		sectionHeaderViewForTotalBadge.alpha = 1.0;
		
		if (++apiDidLoadCnt == 2) {
			[badgeTableView reloadData];			
		}
	}
    
    if ([[result objectForKey:@"func"] isEqualToString:@"notiList"]) {
        
        [theObject release];
        
        NSArray *notiArray = [result objectForKey:@"data"];
        NSMutableArray *finalList = [NSMutableArray array];
        for (NSDictionary *noti in notiArray) {
            if ( [[noti objectForKey:@"openType"] isEqualToString:@"O"] ) {
                NSDate *oldDate = [[NSUserDefaults standardUserDefaults] objectForKey:@"lastBadgeNotification"];
                
                NSDateFormatter *oldFormat = [[[NSDateFormatter alloc] init] autorelease];
                [oldFormat setDateFormat:@"yyyy-MM-dd"];
                
                NSString *oldDateString = [oldFormat stringFromDate:oldDate];
                
                NSDateFormatter *newFormat = [[[NSDateFormatter alloc] init] autorelease];
                [newFormat setDateFormat:@"yyyy-MM-dd"];
                NSString *newDate = [newFormat stringFromDate:[NSDate date]];
                
                if (oldDate != nil) {
                    NSComparisonResult orderResult = [oldDateString compare:newDate];
                    
                    if (orderResult == NSOrderedAscending) {
                        MY_LOG(@"%d", orderResult);
                        [finalList addObject:noti];
                    }
                }
            } else {
                [finalList addObject:noti];
            }
        }
        
        if ([finalList count] == 0) {
            return;
        } else {
            self.manager = [[[NotiManager alloc] init] autorelease];
            manager.delegate = self;
            [manager showUpdateNotification:finalList];
        }
    }
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
	return ([lastBadgeArray count] == 0) ? 1 : 2; 
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
	int totalSection = tableView.numberOfSections;
	
	if (totalSection == 1) {
		return isAlbumView ? [badgeArray count] : [badgeListArray count];
	} else {
		return (section == 0) ? 1 : (isAlbumView ? [badgeArray count] : [badgeListArray count]);
	}
}

// 세트 뱃지 인지 확인
- (BOOL) isThisSetBadge:(NSArray*) aArray {
	return [[[aArray lastObject] objectForKey:@"memberCnt"] intValue] > 0;
}

// 각 셀의 뱃지 멤버 수
- (NSInteger) numberOfMemberInCell:(NSArray*) aArray {
	return [[[aArray lastObject] objectForKey:@"memberCnt"] intValue];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	int totalSection = [self numberOfSectionsInTableView:tableView];
	static const float rowHeightInSet = 20.0f;
	if ((totalSection == 1 && indexPath.section == 0) || (totalSection == 2 && indexPath.section == 1)) {
		// 전체 뱃지
		if (isAlbumView) {
			switch ([self numberOfMemberInCell:[badgeArray objectAtIndex:indexPath.row]]) {
				case 0: return 112.0f;
				case 3: return 282.0f + rowHeightInSet;
				case 4: return 367.0f + rowHeightInSet;
				case 5: return 381.0f + rowHeightInSet;
				case 6: return 396.0f + rowHeightInSet;
				case 7: return 481.0f + rowHeightInSet;
				case 8: return 510.0f + rowHeightInSet;
				case 9: return 510.0f + rowHeightInSet;
				default: return 112.0f;
			}			
		} else {
			return 102.0f;
		}

	} else {
		// 최근 획득 뱃지
		return 114.0f;
		
	}
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    	
	int totalSection = [self numberOfSectionsInTableView:tableView];
    
	if ((totalSection == 1 && indexPath.section == 0) || (totalSection == 2 && indexPath.section == 1)) {
		// 전체 뱃지
		
		if (isAlbumView) { 			// 앨범형 보기
			NSArray* badgeListForCell = [badgeArray objectAtIndex:indexPath.row];
			NSAssert([badgeListForCell count] < 10, @"뱃지 한 셀 안에는 9개 넘길 수 없다.");

			if ([self isThisSetBadge:badgeListForCell]) {
				NSString* setBadgeNib = [NSString stringWithFormat:@"SetBadgeCell%d", [self numberOfMemberInCell:badgeListForCell]];
				NSString* setBadgeKey = [NSString stringWithFormat:@"setBadge%d", indexPath.row];
				SetBadgeCell *cell = [setBadgeCellList objectForKey:setBadgeKey];
				if (cell == nil) {
					cell = [[[NSBundle mainBundle] loadNibNamed:setBadgeNib owner:nil options:nil] lastObject];
					[setBadgeCellList addEntriesFromDictionary:[NSDictionary dictionaryWithObject:cell forKey:setBadgeKey]];
					[cell populateWithArray:badgeListForCell];
				}
				
				return cell;
				
			} else {
				static NSString *CellIdentifier = @"album3"; // 일반 뱃지 셀
				
				AlbumBadgeCell *cell = (AlbumBadgeCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
				if (cell == nil) {
					cell = [[[NSBundle mainBundle] loadNibNamed:@"AlbumBadgeCell3" owner:nil options:nil] lastObject];
				}
				
				[cell populateWithArray:badgeListForCell];
				
				return cell;
			}			
		} else {		// 리스트형 보기
			NSDictionary* aBadge = [badgeListArray objectAtIndex:indexPath.row];
			
			static NSString *CellIdentifier = @"listBadge"; // 리스트 뱃지

			ListBadgeCell *cell = (ListBadgeCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
			if (cell == nil) {
				cell = [[[NSBundle mainBundle] loadNibNamed:@"ListBadgeCell" owner:nil options:nil] lastObject];
			}
			
			[cell populateWithDictionary:aBadge];
			
			return cell;
		}
	} else {
		// 최근 획득 뱃지
		
		static NSString *CellIdentifier = @"lastest"; // 최근 뱃지
		
		LatestBadgeCell *cell = (LatestBadgeCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		if (cell == nil) {
			cell = [[[NSBundle mainBundle] loadNibNamed:@"LatestBadgeCell" owner:nil options:nil] lastObject];
		}
		
		[cell populateWithArray:lastBadgeArray];
		
		return cell;
		
	}
}

// section header
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return 24.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	
	if ([lastBadgeArray count] == 0) {
		return sectionHeaderViewForTotalBadge;
	} else {
		return (section == 0) ? sectionHeaderViewForLastestBadge : sectionHeaderViewForTotalBadge;
	}
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
    /*
    <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
    // ...
    // Pass the selected object to the new view controller.
    [self.navigationController pushViewController:detailViewController animated:YES];
    [detailViewController release];
    */
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
	[[NSNotificationCenter defaultCenter] removeObserver:self name:BADGE_IMAGE_TAPPED_NOTIFICATION object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"closeAndGoHome" object:nil];
}


- (IBAction) closeVC {
	[self dismissModalViewControllerAnimated:YES];
}

// 앨범형과 리스트형을 토글
- (IBAction) toggleViewType:(UIButton*) sender {
	if (isAlbumView) {
		GA3(@"뱃지", @"뱃지리스트로보기", @"마이홈내");
		// 리스트뷰로 바뀜
		//badgeTableView.separatorColor = [[[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"badge_between_line.png"]] autorelease];

		isAlbumView = NO;
		[sender setImage:[UIImage imageNamed:@"badge_btn_toggle_on.png"] forState:UIControlStateNormal];
	} else {
		GA3(@"뱃지", @"뱃지보기", @"뱃지앨범형");
		// 앨범 뷰로 바뀜
		//badgeTableView.separatorColor = [UIColor clearColor];

		isAlbumView = YES;
		[sender setImage:[UIImage imageNamed:@"badge_btn_toggle_off.png"] forState:UIControlStateNormal];
	}
	[badgeTableView reloadData];
}


#pragma mark -
#pragma mark NSNotificationCenter
// 뱃지가 눌렸다
- (void) badgeTapped:(NSNotification*) noti {
	MY_LOG(@"뱃지 눌렸음");
	
	if ([owner.snsId isEqualToString:[UserContext sharedUserContext].snsID]) {
		GA3(@"뱃지상세보기", @"뱃지이미지태핑", @"마이홈내");
	} else {
		GA3(@"뱃지상세보기", @"뱃지이미지태핑", @"타인홈내");
	}

	NSDictionary* badgeData = [noti userInfo];
	NSAssert(badgeData != nil, @"뱃지 데이터는 노티의 userInfo로 넘어와야함.");
	
	if ([[badgeData objectForKey:@"isBadge"] isEqualToString:@"1"]) { // 뱃지를 소유하고 있다면
#ifdef APP_STORE_FINAL_OFF
		BadgeImageView* badgeImageView = (BadgeImageView*)[noti object];
		
		MY_LOG(@"뱃지이름: %@, 위치: %@", [badgeData objectForKey:@"badgeName"], NSStringFromCGRect(badgeImageView.frame));
#endif
        
        NSString* sqlQueryText = [NSString stringWithFormat:@"UPDATE TFeedList set read = 1 where evtId = 100005 and read = 0 and snsId = %@ and badgeId = %@", [UserContext sharedUserContext].snsID, [badgeData objectForKey:@"badgeId"]];
        MY_LOG(@"update badge read: %@", sqlQueryText);
        [[TFeedList database] executeSql:sqlQueryText];
        
		BadgeDetailView* blackPanel = [[[NSBundle mainBundle] loadNibNamed:@"BadgeDetailView" 
																	 owner:self options:nil] lastObject];
        blackPanel.delegate = self;
		blackPanel.badgeData = badgeData;
		blackPanel.owner = owner;
		[blackPanel requestBadgeInfo];
		
		[self.view addSubview:blackPanel];
		[blackPanel startOpeningAnimation];
	} else { // 뱃지가 없다면
		[CommonAlert alertWithTitle:@"안내" message:[badgeData objectForKey:@"badgeGuideMsg"]];
	}
}

#pragma mark - Update Notification Delegate
- (void)didFinishedUpdateNotifications:(NSDictionary*)result {
    MY_LOG(@"didFinishedUpdateNotifications:");
    
    if (result != nil && ![[result objectForKey:@"url"] isEqualToString:@""]) {
        CommonWebViewController *webVC = [[CommonWebViewController alloc] initWithNibName:nil bundle:nil];
        
        webVC.urlString = [[result objectForKey:@"url"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];                
        [self presentModalViewController:webVC animated:YES];
        
        [webVC release];
    }
}
@end

