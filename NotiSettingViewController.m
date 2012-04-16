//
//  NotiSettingViewController.m
//  ImIn
//
//  Created by park ja young on 11. 2. 14..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NotiSettingViewController.h"

#import "GetNoti.h"
#import "SetNoti.h"
#import "iToast.h"

#define NOTIFLAG_1 4    // 다른 사람이 나를 이웃으로 추가
#define NOTIFLAG_2 9    // 새 댓글 / 새 대댓글 (1+8)
#define NOTIFLAG_3 256  // 내 이웃의 발도장 소식
#define NOTIFLAG_4 64   // 뱃지 소식

#define NOTITAG_ALL (NOTIFLAG_1 | NOTIFLAG_2 | NOTIFLAG_3 | NOTIFLAG_4)


@implementation NotiSettingViewController
@synthesize getNoti, setNoti, totalAlaramSwitch;

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    return self;
}
*/

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    
    // 전체 알람의 기본값은 ON 상태, getNoti로 받아온 값이 0이라면 두 번째 섹션을 지워준다.
    self.totalAlaramSwitch = [[[UISwitch alloc] init] autorelease];
    totalAlaramSwitch.on = YES;
    [totalAlaramSwitch addTarget:self action:@selector(toggleTotalAlarm:) forControlEvents:UIControlEventValueChanged];

	[self requestGetNoti];
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (IBAction) popViewController {
	[self.navigationController popViewControllerAnimated:YES];
}

- (IBAction) setSave {
	[self requestSetNoti];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [settingTableView release];
    settingTableView = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillDisappear:(BOOL)animated {
}

- (void)dealloc {
	[getNoti release];
	[setNoti release];
    [settingTableView release];
    [totalAlaramSwitch release];
    [super dealloc];
}


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    NSInteger retNumOfSection;
    
    if (totalAlaramSwitch.on) {
        retNumOfSection = 2;
    } else {
        retNumOfSection = 1;
    }
    
	return retNumOfSection;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
	NSInteger retValue = 0;
	
    if (totalAlaramSwitch.on) {
        switch (section) {
            case 0:
                retValue = 1;
                break;
            case 1:
                retValue = 4;
                break;
//            case 2:
//                retValue = 1;
                break;
        }        
    } else {
        switch (section) {
            case 0:
                retValue = 1;
                break;
//            case 1:
//                retValue = 1;
                break;
        }
    }
	return retValue;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 52.0;
//    if (totalAlaramSwitch.on) {
//        if (indexPath.section == 2) { 
//            return 43.0;
//        }
//        else {
//            return 52.0;
//        }        
//    } else {
//        if (indexPath.section == 1) { 
//            return 43.0;
//        }
//        else {
//            return 52.0;
//        }
//    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 76.0;
    }
    return 0.0f;
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
	UIView* aView = nil;
	if (section == 0) {
		aView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 76)] autorelease];
		UILabel* aLabel = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 76)] autorelease];
		aLabel.textAlignment = UITextAlignmentCenter;
		aLabel.text = @"내 발도장에 댓글/대댓글이 달리거나\n이웃이 발도장 찍었을 때 등\n다양한 소식들을 즉시 알림을 통해 받을 수 있어요~";
		aLabel.numberOfLines = 3;
		aLabel.font = [UIFont systemFontOfSize:12.0f];
		aLabel.backgroundColor = [UIColor clearColor];
		aLabel.textColor = RGB(17, 17, 17);
		
		[aView addSubview:aLabel];
	}
	return aView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *CellIdentifier;
	CellIdentifier = @"Cell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];		
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		cell.textLabel.textColor = RGB(17, 17, 17);
        
        if (totalAlaramSwitch.on) {  // 전체설정이 되어 있으면
            if(indexPath.section == 0) // 전체
            {
                cell.accessoryView = totalAlaramSwitch;
            }
            
            if(indexPath.section == 1) // 하단
            {
                UISwitch* aSwitch = [[[UISwitch alloc] init] autorelease];
                [aSwitch addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
                cell.accessoryView = aSwitch;
            }
        } else {
            if(indexPath.section == 0) // 전체
            {
                UISwitch* aSwitch = [[[UISwitch alloc] init] autorelease];
                
                totalAlaramSwitch = aSwitch;
                
                [aSwitch addTarget:self action:@selector(toggleTotalAlarm:) forControlEvents:UIControlEventValueChanged];
                cell.accessoryView = aSwitch;	
            }
        }
    }
        
    if (totalAlaramSwitch.on) {  // 전체설정이 되어 있으면
        switch (indexPath.section) {
            case 0:
                cell.textLabel.text = @"전체 알림 설정";
                [cell.textLabel setFont:[UIFont systemFontOfSize:17.0f]];
                cell.accessoryView.tag = NOTITAG_ALL;
                break;
            case 1:
                [cell.textLabel setFont:[UIFont systemFontOfSize:13.0f]];
                
                switch (indexPath.row) {
                    case 0:
                        cell.textLabel.numberOfLines = 2;
                        cell.textLabel.text = @"나를 이웃으로 추가한\n사람이 있을 때";
                        
                        [(UISwitch *)cell.accessoryView setOn:((notiBit & NOTIFLAG_1) == NOTIFLAG_1)]; 
                        cell.accessoryView.tag = NOTIFLAG_1;
                        break;
                    case 1:
                        cell.textLabel.numberOfLines = 2;
                        cell.textLabel.text = @"내 글에 새 댓글/대댓글이\n등록되었을 때";
                        [(UISwitch *)cell.accessoryView setOn:((notiBit & NOTIFLAG_2) == NOTIFLAG_2)]; 
                        cell.accessoryView.tag = NOTIFLAG_2;
                        break;
                    case 2:
                        cell.textLabel.text = @"이웃의 발도장 소식(전체)";
                        [(UISwitch *)cell.accessoryView setOn:((notiBit & NOTIFLAG_3) == NOTIFLAG_3)]; 
                        cell.accessoryView.tag = NOTIFLAG_3;
                        break;
                    case 3:
                        cell.textLabel.text = @"이웃의 뱃지 획득 소식";		
                        [(UISwitch *)cell.accessoryView setOn:((notiBit & NOTIFLAG_4) == NOTIFLAG_4)]; 
                        cell.accessoryView.tag = NOTIFLAG_4;
                        break;
                }
                break;
//                case 2:
//                    cell.backgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"btnnew_set_finish.png"]] autorelease];
//                    break;
                
            default:
                break;
        } 
    } else { //전체 설정이 꺼져있으면
        switch (indexPath.section) {
            case 0:
                cell.textLabel.text = @"전체 알림 설정";
                [cell.textLabel setFont:[UIFont systemFontOfSize:17.0f]];
                cell.accessoryView.tag = NOTITAG_ALL;
                break;
//                case 1:
//                    cell.backgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"btnnew_set_finish.png"]] autorelease];
//                    break;
                
            default:
                break;
        } 
    }
		
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (totalAlaramSwitch.on) {
        if (indexPath.section == 2) {
            [self requestSetNoti];
        }
    } else {
        if (indexPath.section == 1) {
            [self requestSetNoti];
        }        
    }
}

- (void) updateSwitchStatusWithNotiBit:(int) aBit
{
	if (aBit > NOTITAG_ALL) {
        aBit = NOTITAG_ALL;
    }
    	
	((UISwitch*)[self.view viewWithTag:NOTIFLAG_1]).on = ((aBit & NOTIFLAG_1) == NOTIFLAG_1);
	((UISwitch*)[self.view viewWithTag:NOTIFLAG_2]).on = ((aBit & NOTIFLAG_2) == NOTIFLAG_2);
	((UISwitch*)[self.view viewWithTag:NOTIFLAG_3]).on = ((aBit & NOTIFLAG_3) == NOTIFLAG_3);
	((UISwitch*)[self.view viewWithTag:NOTIFLAG_4]).on = ((aBit & NOTIFLAG_4) == NOTIFLAG_4);
//	((UISwitch*)[self.view viewWithTag:NOTITAG_ALL]).on = ((aBit & NOTITAG_ALL) == NOTITAG_ALL);
	
	notiBit = aBit;
}

- (void) toggleTotalAlarm:(UISwitch*) switchView {
	MY_LOG(@"switchView.tag = %d", switchView.tag);

	int bit = switchView.tag;

	if (switchView.on) {
		notiBit = notiBit | bit;
        if (settingTableView.numberOfSections == 1) {
//            [settingTableView beginUpdates];
//            [settingTableView insertSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:NO]; 
//            [settingTableView endUpdates];
            
        }
	} else {
		notiBit = notiBit & ~bit;
        if (settingTableView.numberOfSections == 2) {
            [settingTableView beginUpdates];
            [settingTableView deleteSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation: UITableViewRowAnimationTop]; 
            [settingTableView endUpdates];
            return;
        }
	}
        
    
	MY_LOG(@"current notiBit = %d", notiBit);
	[self updateSwitchStatusWithNotiBit:notiBit]; 
    [settingTableView reloadData];
}


- (void) switchChanged:(UISwitch*) switchView {	
	
	MY_LOG(@"switchView.tag = %d", switchView.tag);
	
	int bit = switchView.tag;
	
	if (switchView.on) {
		notiBit = notiBit | bit;
	} else {
		notiBit = notiBit & ~bit;
	}
	
	MY_LOG(@"current notiBit = %d", notiBit);
	[self updateSwitchStatusWithNotiBit:notiBit];
}

# pragma mark -
# pragma mark API 요청
- (void) requestGetNoti {
	self.getNoti = [[[GetNoti alloc] init] autorelease];
	getNoti.delegate = self;
	[getNoti request];
}

- (void) requestSetNoti {
	self.setNoti = [[[SetNoti alloc] init] autorelease];
	setNoti.delegate = self;
	NSString* notiBitString = [NSString stringWithFormat:@"%d", notiBit];
	[setNoti.params addEntriesFromDictionary:[NSDictionary dictionaryWithObject:notiBitString forKey:@"appNotiType"]];
	[setNoti request];
}


- (void) apiFailedWhichObject:(NSObject*) aObject {
	MY_LOG(@"API 에러");

	if (aObject == getNoti) {
        UIWindow *window = [[[UIApplication sharedApplication] windows] objectAtIndex:0];
        UIView *v = (UIView *)[window viewWithTag:TAG_iTOAST];
        if (!v) {
            iToast *msg = [[iToast alloc] initWithText:@"네트워크가 불안합니다. \n잠시 후 다시 시도해 주세요~"];
            [msg setDuration:2000];
            [msg setGravity:iToastGravityCenter];
            [msg show];
            [msg release];
        }
        //		[CommonAlert alertWithTitle:@"안내" message:@"네트워크가 불안합니다. \n잠시 후 다시 시도해 주세요~"];
        [self performSelector:@selector(popVC) withObject:nil afterDelay:1];
	}
	
	if (aObject == setNoti) {
        UIWindow *window = [[[UIApplication sharedApplication] windows] objectAtIndex:0];
        UIView *v = (UIView *)[window viewWithTag:TAG_iTOAST];
        if (!v) {
            iToast *msg = [[iToast alloc] initWithText:@"네트워크가 불안합니다. \n잠시 후 다시 시도해 주세요~"];
            [msg setDuration:2000];
            [msg setGravity:iToastGravityCenter];
            [msg show];
            [msg release];
        }
        //		[CommonAlert alertWithTitle:@"안내" message:@"네트워크가 불안하여, \n알림설정에 실패하였습니다."];
		[self performSelector:@selector(popVC) withObject:nil afterDelay:1];
	}
}

- (void) apiDidLoad:(NSDictionary *)result {
	
	NSAssert(result, @"result는 nil이면 안됨");
	
	if ([[result objectForKey:@"func"] isEqualToString:@"getNoti"]) {
	
		NSNumber* notiBitNumber = [result objectForKey:@"appNotiType"];
        MY_LOG(@"getNoti=%@", notiBitNumber);
		
		NSAssert(notiBitNumber, @"appNotiType을 못받아왔다");
        
        if ([notiBitNumber intValue] == 0) {
            totalAlaramSwitch.on = NO;
            [settingTableView deleteSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation: UITableViewRowAnimationNone];
        }
		
		[self updateSwitchStatusWithNotiBit:[notiBitNumber intValue]];
        [settingTableView reloadData];
	}
	
	if ([[result objectForKey:@"func"] isEqualToString:@"setNoti"]) {
		[self.navigationController popViewControllerAnimated:YES];
		// 별도로 해줄게 없군
	}
}


- (void) popVC {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
