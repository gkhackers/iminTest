//
//  PhoneNeighborViewController.m
//  ImIn
//
//  Created by edbear on 10. 12. 7..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PhoneNeighborViewController.h"
#import "PhoneNeighborList.h"
#import "NoListInfoView.h"

#import "SNSInvitationTableCell.h"


@implementation PhoneNeighborViewController
@synthesize phoneNeighborList, noListInfoView;

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

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void) viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}



- (void) request
{
	self.phoneNeighborList = [[[PhoneNeighborList alloc] init] autorelease];
	self.phoneNeighborList.delegate = self;
	
	NSDictionary* phoneBook = [[UserContext sharedUserContext] getPhoneBook];
	
	NSString* phoneNumberListString = @"";
	
	for (NSString* key in phoneBook) {
		phoneNumberListString = [phoneNumberListString stringByAppendingString:key];
		phoneNumberListString = [phoneNumberListString stringByAppendingString:@"|"];	
	}
	
	self.phoneNeighborList.phoneNo = phoneNumberListString;
	self.phoneNeighborList.isResetNeighbor = @"1";
	self.phoneNeighborList.currPage = [NSString stringWithFormat:@"%d", currPage];
	self.phoneNeighborList.scale = [NSString stringWithFormat:@"%d", scale];
	
	[self.phoneNeighborList request];
}

- (void) apiFailed {
	MY_LOG(@"API 에러");
}

- (void) apiDidLoad:(NSDictionary *)result {
	
	// phoneNeighborList API
	if ([[result objectForKey:@"func"] isEqualToString:@"phoneNeighborList"]) {
		
		NSArray* dataList = [result objectForKey:@"data"];
		
		for (NSDictionary* aData in dataList) {
			if (![[aData objectForKey:@"snsId"] isEqualToString:@""]) {
				// snsId가 비어 있다면 빈 리스트로 간주하고 무시함. 
				NSMutableDictionary* aMutableData = [NSMutableDictionary dictionaryWithDictionary:aData];
				[aMutableData addEntriesFromDictionary:[NSDictionary dictionaryWithObjectsAndKeys:@"-1", @"cpCode", nil]];
				[self.cellDataList addObject:aMutableData];
				MY_LOG(@"postId: %@\t snsId: %@\t nickname: %@",
					   [aData objectForKey:@"postId"], 
					   [aData objectForKey:@"snsId"], 
					   [aData objectForKey:@"nickname"]);				
			}
		}
		
		
		if ([self.cellDataList count] == 0) {
			self.noListInfoView = [[[NoListInfoView alloc] initWithFrame:myTableView.frame] autorelease];
			self.noListInfoView.label1.text = @"내 폰 주소록에 있는 아임IN 유저가 없습니다.";
			self.noListInfoView.label2.text = @"친구들에게 아임IN을 알려보세요~";
			[self.view addSubview:self.noListInfoView];
		} else {
			if(self.noListInfoView != nil)
			{
				[self.noListInfoView removeFromSuperview];
				self.noListInfoView = nil;
			}
		}

		
		[myTableView reloadData];
		
		scale = [(NSNumber*)[result objectForKey:@"scale"] intValue];
		currPage = [(NSNumber*)[result objectForKey:@"currPage"] intValue];
		totalCnt = [(NSNumber*)[result objectForKey:@"totalCnt"] intValue];
		isLoaded = YES;
	}		
}

- (void)dealloc {
	[phoneNeighborList release];
	[noListInfoView release];
    [super dealloc];
}

#pragma mark -
#pragma mark IBAction
- (IBAction) popViewController {
	[self.navigationController popViewControllerAnimated:YES];
}


@end
