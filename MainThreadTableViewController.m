//
//  MainThreadTableViewController.m
//  ImIn
//
//  Created by choipd on 10. 4. 22..
//  Copyright 2010 edbear. All rights reserved.
//

#import "MainThreadTableViewController.h"
#import "MainThreadCell.h"
#import "UIImageView+WebCache.h"
#import "PostDetailTableViewController.h"

#import "ViewControllers.h"
#import <QuartzCore/QuartzCore.h>

#import "HttpConnect.h"
#import "const.h"
#import "UserContext.h"
#import "Utils.h"

#import "JSON.h"
#import "macro.h"
#import "UIPlazaViewController.h"
#import "EventCell.h"
#import "BizWebViewController.h"
#import "PostComposeViewController.h"
#import "NSString+URLEncoding.h"
#import "iToast.h"



#define MAX_XPOI_LIST 15
@implementation MainThreadTableViewController

@synthesize cellDataList;
@synthesize delegate;
@synthesize footerView;
@synthesize isNeighborList, isToMeNeighbor, isFromPlazaVC;
@synthesize selectedIndexPath;
@synthesize latestPostID, lastPostID;
@synthesize curPosition;
@synthesize enclosingClassName;
@synthesize eventFirstData, eventTotalCnt;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
		isFromPlazaVC = NO;
		self.lastPostID = @"";
		self.latestPostID = @"";
        eventTotalCnt = 0;

    }
    return self;
}

- (void) updateParameter {
	lastUpdateDate = [Utils stringFromDate:[NSDate date]];
	lastUpdate.text = [NSString stringWithFormat:@"마지막 갱신: %@", lastUpdateDate];
	
	if ([cellDataList count] > 0) {
		self.lastPostID =  [[cellDataList lastObject] objectForKey:@"postId"];
		self.latestPostID = [[cellDataList objectAtIndex:0] objectForKey:@"postId"];		
	}
}

- (void) updateRange {
	loadTail.text = @"더 보시려면 끌어올려 주세요.";
	loadTailBtn.enabled = YES;
}


- (void) scrapModified:(NSNotification*) noti
{
	MY_LOG(@"스크랩에 변경이 일어났다");
    
    NSDictionary* scrapModificationInfo = [noti userInfo];
    NSDictionary* modifiedScrap = [scrapModificationInfo objectForKey:@"scrap"];
    
    int i = 0;
    for (NSDictionary* aScrap in cellDataList) {
        if ([[aScrap objectForKey:@"postId"] isEqualToString:[modifiedScrap objectForKey:@"postId"]]) {
            [cellDataList replaceObjectAtIndex:i withObject:modifiedScrap];
            break;
        }
        i++;
    }
    
    [self.tableView reloadData];
}


#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
	[self.tableView setDelegate:self];
	//[self.tableView setSeparatorColor:[UIColor clearColor]]; 
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
   
	self.lastPostID = nil;
	connect = nil;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(scrapModified:) name:@"scrapModified" object:nil];

}


- (void)viewWillAppear:(BOOL)animated {
	// 최신보기가 없으면 header를 없애준다.
	if (![delegate respondsToSelector:@selector(mainThreadRequestLatest)] ) {
		headerView.hidden = YES;
	}
	
	isTop = NO;
	isEnd = NO;
	isLoading = NO;

	
	
	if (cellDataList == nil) { // cellDataList가 메모리 워닝등의 이유로 날아 가는 경우가 발생할 수 있음.
		self.cellDataList = [[[NSMutableArray alloc] initWithCapacity:25] autorelease];
	}
    
	[self updateParameter];
	
	//선택한 셀이 삭제되거나 수정된 경우 업데이트 처리: Model과 View를 분리하자. 데이터에서 지워지면 뷰에서도 사라지도록
	[self.tableView reloadData];
	
	footerView.hidden = NO;
	loadTailBtn.enabled = NO;
	
	// 손을떼면 새로운 글을 불러옵니다 - 표시는 처음에는 목록 상단에 숨어서 보이지 않도록.
	UIEdgeInsets scrollInset = ((UIScrollView*)self.view).contentInset;
	
	scrollInset.top = -60;
	[((UIScrollView*)self.view) setContentInset:scrollInset];
}

- (void)viewWillDisappear:(BOOL)animated {
	if (connect != nil)
	{
		[connect stop];
		[connect release];
		connect = nil;
	}
	isLoading = NO;
}
/*
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}
*/
/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

//- (NSString *)claasNameOfTableView {
//    return NSStringFromClass([self class]);
//}

#pragma mark -
#pragma mark Table view data source
//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section  //2
//{
//    //UIView* viewToReturn = nil;
//	
//    UIView *viewToReturn = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 30)] autorelease];
//    viewToReturn.
//    if (section == 0)
//        [viewToReturn setBackgroundColor:[UIColor clearColor]];
//    else 
//        [viewToReturn setBackgroundColor:[UIColor clearColor]];
//    return viewToReturn;
//
//}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    MY_LOG(@"enclosingClassName = %@", enclosingClassName);
    
    if ([enclosingClassName isEqualToString:@"UIPlazaViewController"]) {
        return 3;
    }
    // Return the number of sections.
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if ([enclosingClassName isEqualToString:@"UIPlazaViewController"]) {
        if (section == 0) {
            return 1;
        }
        else if (section == 1) {
            if (eventTotalCnt > 0) {
                return 1;
            } else {
                return 0;
            }
        } else {
            return [cellDataList count];
        }
    }
    else
        return [cellDataList count];
}
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([enclosingClassName isEqualToString:@"UIPlazaViewController"] && indexPath.section == 0) {
        cell.backgroundColor = [UIColor colorWithRed:235/255.0f green:250/255.0f blue:255.0f alpha:1.0f];
    }
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    if ([enclosingClassName isEqualToString:@"UIPlazaViewController"] && indexPath.section == 0) {
        static NSString *CellIdentifier = @"inputCell";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            UIImageView *bgColor = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 54)];
            [bgColor setImage:[UIImage imageNamed:@"input_foot_bg.png"]];
            [cell addSubview:bgColor];
            [bgColor release];
            
//            UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 53)];
//            CAGradientLayer *gradient = [CAGradientLayer layer];
//            gradient.frame = bgView.bounds;
//            gradient.colors = [NSArray arrayWithObjects:(id)[RGB(238, 251, 255) CGColor], (id)[RGB(214, 245, 255) CGColor], nil];
//            [bgView.layer insertSublayer:gradient atIndex:0];
//            [cell addSubview:bgView];
//            [bgView release];
            
            
//            UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 52, 320, 1)];
//            line.backgroundColor = [UIColor colorWithRed:181/255.0f green:181/255.0f blue:181/255.0f alpha:1.0f];
//            [cell addSubview:line];
//            [line release];
            
            UIImageView *inputImgView = [[UIImageView alloc] initWithFrame:CGRectMake(9, 9, 302, 36)];
            [inputImgView setImage:[UIImage imageNamed:@"input_bg.png"]];
            [cell addSubview:inputImgView];
            [inputImgView release];
            
            UIImageView *poiIcon = [[UIImageView alloc] initWithFrame:CGRectMake(21, 18, 14, 19)];
            [poiIcon setImage:[UIImage imageNamed:@"marker_ico.png"]];
            [cell addSubview:poiIcon];
            [poiIcon release];
            
            UILabel *text = [[UILabel alloc] initWithFrame:CGRectMake(40, 9, 279, 35)];
            text.tag = 100;
            [text setFont:[UIFont fontWithName:@"helvetica" size:14.0f]];
            [text setTextColor:[UIColor colorWithRed:136/255.0f green:136/255.0f blue:136/255.0f alpha:1.0f]];
            text.backgroundColor = [UIColor clearColor];
            [cell addSubview:text];
            [text release];
        }

        UILabel *text = (UILabel*)[cell viewWithTag:100];
        [text setText:[(UIPlazaViewController*)[ViewControllers sharedViewControllers].plazaViewController getPlazaQuestText]];
        
        return cell;
        
    } else if ([enclosingClassName isEqualToString:@"UIPlazaViewController"] && indexPath.section == 1) {
        
        if (eventTotalCnt > 0) {
            static NSString *CellIdentifier = @"evnetCell";
            EventCell *cell = (EventCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil) {
                NSArray* nibObjects = [[NSBundle mainBundle] loadNibNamed:@"EventCell" owner:nil options:nil];
                
                for (id currentObject in nibObjects) {
                    if([currentObject isKindOfClass:[EventCell class]]) {
                        cell = (EventCell*) currentObject;
                    }
                }
                //[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            }
            
            [cell redrawEventCellWithCellData:eventFirstData : eventTotalCnt];
            return cell;
        }
        
    } else {
        if ([cellDataList count] < indexPath.row) {	// cellDataList를 미쳐 가져오기 전에 테이블 뷰를 그려줘야 하는 문제를 방지하기 위해 삽입한 조건
            static NSString *CellIdentifier = @"Cell";
            
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil) {
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
            }
            
            // Configure the cell...
            
            return cell;
        } else {
            static NSString *CellIdentifier2 = @"mainThreadCell";
            
            MainThreadCell *cell = (MainThreadCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier2];
            
            if (cell == nil) {
                //			MY_LOG(@"Cell created");
                NSArray* nibObjects = [[NSBundle mainBundle] loadNibNamed:@"MainThreadCell" owner:nil options:nil];
                
                for (id currentObject in nibObjects) {
                    if([currentObject isKindOfClass:[MainThreadCell class]]) {
                        cell = (MainThreadCell*) currentObject;
                    }
                }
            }
            
            if ([cellDataList count] > indexPath.row) { // cellDataList를 미쳐 가져오기 전에 테이블 뷰를 그려줘야 하는 문제를 방지하기 위해 삽입한 조건
                NSDictionary* cellData = [cellDataList objectAtIndex:indexPath.row];
                cell.isNeighbor = isNeighborList;
                cell.isToMeNeighbor = isToMeNeighbor;
                cell.curPosition = curPosition;
                
                //cell.cellHeight = currentHeight-2;
                [cell redrawMainThreadCellWithCellData:cellData];
            }
            
            return cell;
        }

    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//	MY_LOG(@"row: %d", indexPath.row);
//	MY_LOG(@"contents size: %f , %f", self.tableView.contentSize.width, self.tableView.contentSize.height);
    if ([enclosingClassName isEqualToString:@"UIPlazaViewController"] && indexPath.section == 0) {
        return 54.0f;
    }
    else if ([enclosingClassName isEqualToString:@"UIPlazaViewController"] && eventTotalCnt > 0 && indexPath.section == 1) {
        if (eventTotalCnt == 1) {            
            CGSize textSize = [[eventFirstData objectForKey:@"eventCopy"] sizeWithFont:[UIFont fontWithName:@"helvetica" size:14.0f] constrainedToSize:CGSizeMake(246.0, 36.0) lineBreakMode:UILineBreakModeWordWrap];
            MY_LOG(@"textSize.height = %f", textSize.height);
            NSUInteger lineCnt = (int)(textSize.height / 18.0f);
           
            if (lineCnt == 2) {
                return 59.0f;
            } else {
               return 43.0f;
            }
        } else {
            return 43.0f;
        }
        return 0.0f;
	} else {		
		NSDictionary* cellData = [cellDataList objectAtIndex:indexPath.row];
		
		currentHeight = 0.0f;
		float topInSet = 12.0f;
		float poiNameHeight = 20.0f;
		float poiPostInSet = 2.0f;
		
		currentHeight += topInSet + poiNameHeight + poiPostInSet;
		
		float postHeight = [MainThreadCell requiredLabelSize:cellData withType:isNeighborList].height;
		float postDescInSet = 4.0f;
		
		if (postHeight == 0) {
			currentHeight += postDescInSet;
		} else {
			currentHeight += postHeight + postDescInSet;
		}
		
		
		float descHeight = 13.0f;
		currentHeight += descHeight;
		
        float imageBottom;
        if ([Utils isBrandUser:cellData]) { //브랜드면
            imageBottom = 75.0f;
        } else {
            imageBottom = 63.0f;
            //imageBottom = 75.0f;
        }
		
		currentHeight = (currentHeight > imageBottom) ? currentHeight : imageBottom;
		float bottomInSet = 10.0f;
		
		currentHeight += bottomInSet;
		
		return currentHeight;		
		
	}

}



/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([enclosingClassName isEqualToString:@"UIPlazaViewController"] && indexPath.section == 0) {
        GA1(@"광장_발도장입력유도 클릭");
        GA3(@"광장", @"발도장찍기 - 유도 바", [(UIPlazaViewController*)[ViewControllers sharedViewControllers].plazaViewController getPlazaQuestText]);
        PostComposeViewController *vc = [[[PostComposeViewController alloc] initWithNibName:@"PostComposeViewController" bundle:nil] autorelease];	
        vc.hidesBottomBarWhenPushed = YES;
        UINavigationController *navController = [[[UINavigationController alloc] initWithRootViewController:vc] autorelease];
        [navController setNavigationBarHidden:YES] ;
        
        [[ApplicationContext sharedApplicationContext] presentVC:navController];
    }
    else if ([enclosingClassName isEqualToString:@"UIPlazaViewController"] && indexPath.section == 1) {
        if (eventTotalCnt > 0) {
            BizWebViewController* vc = [[[BizWebViewController alloc] initWithNibName:@"BizWebViewController" bundle:nil] autorelease];
            
            NSString* titleText = nil;
            
            if (eventTotalCnt > 1) {
                GA1(@"광장이벤트배너여러개");
                GA3(@"광장", @"이벤트배너", @"광장내");
                
                NSString* encoded = [[NSString stringWithFormat:@"진행중인 이벤트 %d", eventTotalCnt] URLEncodedString];
                titleText = [NSString stringWithFormat:@"&title_text=%@&right_enable=y&pointX=%@&pointY=%@", encoded, [GeoContext sharedGeoContext].lastTmX, [GeoContext sharedGeoContext].lastTmY];
                vc.urlString = [EVENT_LIST_URL stringByAppendingString:titleText];
                vc.curPosition = @"23";
            } else {
                GA1(@"광장이벤트배너한개");
                
                if ([Utils isBrandUser:eventFirstData]) {
                    GA3(@"광장", @"브랜드이벤트배너", @"광장내");
                } else  {
                    GA3(@"광장", @"주인장이벤트배너", @"광장내");
                }
                
                NSString* encoded = [@"이벤트 상세보기" URLEncodedString];
                titleText = [NSString stringWithFormat:@"&title_text=%@&right_enable=y&pointX=%@&pointY=%@", encoded, [GeoContext sharedGeoContext].lastTmX, [GeoContext sharedGeoContext].lastTmY];
                vc.urlString = [[eventFirstData objectForKey:@"eventInfoLink"] stringByAppendingString:titleText];
                vc.curPosition = @"22";
            }
            
            MY_LOG(@"event url = %@", vc.urlString);
            [(UINavigationController*)[ViewControllers sharedViewControllers].tabBarController.selectedViewController 
             presentModalViewController:vc animated:YES];
        }        
    } else {
	
        self.selectedIndexPath = indexPath;

        MY_LOG(@"%%%%%%%% selectedIndexPath %d", selectedIndexPath.row);

        if ([cellDataList count] == 0 || [cellDataList count] < indexPath.row) {
            return;
        }
        NSDictionary* cellData = [cellDataList objectAtIndex:indexPath.row];

        if ([[cellData objectForKey:@"postId"] isEqualToString:@""]) {
            // 잘못된 postID 에 대해서는 못가게 막자
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            return;
        }

        MY_LOG(@"발도장 상세보기 = %@", curPosition);

        if([curPosition isEqualToString:@"1"]) {
            GA3(@"광장", @"발도장상세보기", @"광장내");
        } else if ([curPosition isEqualToString:@"2"]) {
            GA3(@"이웃", @"발도장상세보기", @"내가추가한이웃");
        } else if ([curPosition isEqualToString:@"21"]) {
            GA3(@"이웃", @"발도장상세보기", @"나를추가한이웃");
        } else if ([curPosition isEqualToString:@"3"]) {
            GA3(@"마이홈", @"발도장상세보기", @"마이홈내");
        } else if ([curPosition isEqualToString:@"4"]) {
            GA3(@"타인홈", @"발도장상세보기", @"타인홈내");
        }
        PostDetailTableViewController* vc = [[[PostDetailTableViewController alloc] 
                                             initWithNibName:@"PostDetailTableViewController" 
                                              bundle:nil] autorelease];
        vc.postList = cellDataList;
        vc.postData = [[[NSMutableDictionary alloc] initWithDictionary:cellData] autorelease];
        vc.postIndex = indexPath.row;


        [[tableView cellForRowAtIndexPath:indexPath] setSelected:FALSE animated:YES];

        [(UINavigationController*)[ViewControllers sharedViewControllers].tabBarController.selectedViewController pushViewController:vc animated:YES];

        [self.navigationController dismissModalViewControllerAnimated:YES];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	MY_LOG(@"Got a memory warning");
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
	MY_LOG(@"MainThreadTableViewController viewDidUnload!!!");	
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"scrapModified" object:nil];
}


- (void)dealloc {
	if (connect != nil)
	{
		[connect stop];
		[connect release];
		connect = nil;
	}
	
	[lastPostID release];
	[latestPostID release];
	[selectedIndexPath release];
    [enclosingClassName release];
    [eventFirstData release];
	
    [super dealloc];
}


#pragma mark -
#pragma mark UIScrollView delegate

- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView {

}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {

	if (isTop && !isEnd) {
		[self doRequestLatest];
		return;
	}
	
	if (isEnd && !isTop) {
		[self doRequestBefore];
		return;
	}
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	if (scrollView.contentOffset.y < 0) {
		float y = scrollView.contentOffset.y;
		if (y < -60) {
			y = -60;
		}
		CGAffineTransform transform = CGAffineTransformMakeRotation(y * M_PI / 60);
		arrow.transform = transform;
		isTop = YES;
	} else {
		isTop = NO;
	}
		
	if (scrollView.contentOffset.y + self.tableView.frame.size.height + 10 > scrollView.contentSize.height) {
		isEnd = YES;
	} else {
		isEnd = NO;
	}
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
//	if (isEnd == NO && scrollView.contentOffset.y + 378 > footerView.frame.origin.y) {
//		isEnd == YES;
//		//[(UIPlazaViewController*)[ViewControllers sharedViewControllers].plazaViewController closeNoticeView];
//	}
}


#pragma mark -
#pragma mark reload plaza poi list

- (void) showNext:(HttpConnect*)up {
//	MY_LOG(@"show next!");
//	MY_LOG(@"%@", up.stringReply);
//	SBJSON* jsonParser = [SBJSON new];
//	[jsonParser setHumanReadable:YES];
//	
//	NSDictionary* results = (NSDictionary *)[jsonParser objectWithString:up.stringReply error:NULL];
//	[jsonParser release];
	
    NSDictionary* results = [up.stringReply objectFromJSONString];
	if (connect != nil)
	{
		[connect release];
		connect = nil;
	}
	
	NSNumber* resultNumber = (NSNumber*)[results objectForKey:@"result"];
	
	if ([resultNumber intValue] == 0) { //에러처리
		[CommonAlert alertWithTitle:@"에러" message:[results objectForKey:@"description"]];
		return;
	}
	
	NSArray* resultList = [results objectForKey:@"data"];
	
	NSUInteger numberOfResults = [resultList count];
	if (numberOfResults > 0) {
		for (int i=0; i < numberOfResults; i++) {
			NSDictionary* data = (NSDictionary*) [resultList objectAtIndex:i];
			[cellDataList insertObject:data atIndex:i];
		}
	}
	[self updateParameter];			
	[self.tableView reloadData];
	isLoading = NO;
}

- (void) errorOnShowNext:(HttpConnect*)up {
    //itoast
    UIWindow *window = [[[UIApplication sharedApplication] windows] objectAtIndex:0];
    UIView *v = (UIView *)[window viewWithTag:TAG_iTOAST];
    if (!v) {
        iToast *msg = [[iToast alloc] initWithText:up.stringError];
        [msg setDuration:2000];
        [msg setGravity:iToastGravityCenter];
        [msg show];
        [msg release];
    }

//	[CommonAlert alertWithTitle:@"에러" message:up.stringError];
	if (connect != nil)
	{
		[connect release];
		connect = nil;
	}
	isLoading = NO;
}

- (void) showPrevious:(HttpConnect*)up {
	footerSelectedBackgroundView.hidden = YES;	
//	SBJSON* jsonParser = [SBJSON new];
//	[jsonParser setHumanReadable:YES];
//	
//	NSDictionary* results = (NSDictionary *)[jsonParser objectWithString:up.stringReply error:NULL];
//	[jsonParser release];

	NSDictionary* results = [up.stringReply objectFromJSONString];
	if (connect != nil)
	{
		[connect release];
		connect = nil;
	}
	
	NSNumber* resultNumber = (NSNumber*)[results objectForKey:@"result"];
	
	if ([resultNumber intValue] == 0) { //에러처리
		[CommonAlert alertWithTitle:@"에러" message:[results objectForKey:@"description"]];
		return;
	}
	
	NSArray* resultList = [results objectForKey:@"data"];
	
	if ([resultList count] == 0) {
		footerView.hidden = NO;
		loadTail.text = @"마지막 페이지입니다.";
//		loadTailBtn.enabled = NO;
	} else {
		footerView.hidden = NO;
		loadTail.text = @"더 보시려면 끌어올려 주세요.";
//		loadTailBtn.enabled = YES;
	}

	int lastCellIndex = [cellDataList count] - 1;
	if (lastCellIndex < 0) {
		lastCellIndex = 0;
	}

	[cellDataList addObjectsFromArray:resultList];
	[self.tableView reloadData];
	
    int selSection = 0;
	if ([resultList count] > 0 && [cellDataList count] > 0) {
        // mainThreadTableViewController를 쓰는 테이블에 대해서 section이 추가되면 이곳에도 추가 되어야 한다.
        if (self.tableView.numberOfSections == 3) {
            selSection = 2;
        } else if (self.tableView.numberOfSections == 2) {
            selSection = 1;
        } else {
            selSection = 0;
        }
		[self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:lastCellIndex inSection:selSection] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
	}

	[self updateParameter];
	
	isLoading = NO;
}

- (void) errorOnShowPrevious:(HttpConnect*)up {
//	footerView.backgroundColor = [UIColor clearColor];
	footerSelectedBackgroundView.hidden = YES;
//	MY_LOG(@"error on show previous");
//	MY_LOG(@"%@", up.stringError);
    UIWindow *window = [[[UIApplication sharedApplication] windows] objectAtIndex:0];
    UIView *v = (UIView *)[window viewWithTag:TAG_iTOAST];
    if (!v) {
        iToast *msg = [[iToast alloc] initWithText:up.stringError];
        [msg setDuration:2000];
        [msg setGravity:iToastGravityCenter];
        [msg show];
        [msg release];
    }

//	[CommonAlert alertWithTitle:@"에러" message:up.stringError];
	//[indicator stopAnimating];
	if (connect != nil)
	{
		[connect release];
		connect = nil;
	}
	
	isLoading = NO;
}


- (void) doRequestLatest {

//	int currentTabIndex = [ViewControllers sharedViewControllers].tabBarController.selectedIndex;
	
//	if (currentTabIndex != 0 && currentTabIndex != 2) {
//		return;
//	}
	
	[self requestLatest];
}

/*
 * requestLastest
 * 특정 postId 이후의 (최신) 글을 가져오도록 요청함
 */
- (void) requestLatest {
	
	if (isLoading) {
		return;
	}
	
    //최신데이타를 갱신할때 이벤트 데이타도 함께 갱신되도록 요청
    if ([enclosingClassName isEqualToString:@"UIPlazaViewController"]) {
        [(UIPlazaViewController*)[ViewControllers sharedViewControllers].plazaViewController requestOfEvent];
    }
    
	CgiStringList *strPostData;

	if ( nil == [delegate mainThreadRequestAddress] ) return; // 주소가 없으면 동작 하지 않아야 함.
	if (![delegate respondsToSelector:@selector(mainThreadRequestLatest)] ) return;
	
	if( [delegate respondsToSelector:@selector(mainThreadRequestLatest)] ) {
		strPostData = [delegate mainThreadRequestLatest];
		if (strPostData == nil) {
			return;
		}
		[strPostData setMapString:@"postId" keyvalue:[NSString stringWithFormat:@"-%@", latestPostID]];
		[strPostData setMapString:@"maxScale" keyvalue:PLAZA_MAIN_THREAD_DEFAULT_ROWS_NUMBER];

		if (connect != nil)
		{
			[connect stop];
			[connect release];
			connect = nil;
		}
		
		connect = [[HttpConnect alloc] initWithURL:[delegate mainThreadRequestAddress]
										  postData: [strPostData description]
										  delegate: self
									  doneSelector: @selector(showNext:) 
									 errorSelector: @selector(errorOnShowNext:)  
								  progressSelector: nil];
		
		isLoading = YES;		
	}
}

- (IBAction) doRequestBefore {
	//footerView.backgroundColor = RGB(209, 241, 248);
	
	footerSelectedBackgroundView.hidden = NO;
	CAGradientLayer *gradient = [CAGradientLayer layer];
	gradient.frame = footerSelectedBackgroundView.bounds;
	gradient.colors = [NSArray arrayWithObjects:(id)[RGB(214, 241, 248) CGColor], (id)[RGB(178, 229, 241) CGColor], nil];
	[footerSelectedBackgroundView.layer insertSublayer:gradient atIndex:0];
	
	
	
	//[[OperationQueue queue] cancelAllOperations];
	[self requestBefore];
}

/*
 * requestBefore
 * 이전 글 요청
 */
- (void) requestBefore { // 더 보시려면 끌어올려 주세요.
	
	if (isLoading) {
		return;
	}
	
	CgiStringList *strPostData;

	if( nil == [delegate mainThreadRequestAddress] ) return; // 주소가 없으면 동작 하지 않아야 함.
	if( [delegate respondsToSelector:@selector(mainThreadRequestMore)] ) {
		strPostData = [delegate mainThreadRequestMore];
		[strPostData setMapString:@"postId" keyvalue:lastPostID];
		[strPostData setMapString:@"maxScale" keyvalue:PLAZA_MAIN_THREAD_NEXT_ROWS_NUMBER];
		
		
		if (connect != nil)
		{
			[connect stop];
			[connect release];
			connect = nil;
		}
		
		connect = [[HttpConnect alloc] initWithURL:[delegate mainThreadRequestAddress]
										  postData: [strPostData description]
										  delegate: self
									  doneSelector: @selector(showPrevious:)    
									 errorSelector: @selector(errorOnShowPrevious:)
								  progressSelector: nil];
		
		isLoading = YES;		
	}

}


@end

