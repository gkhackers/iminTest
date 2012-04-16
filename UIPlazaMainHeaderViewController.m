//
//  UIPlazaMainHeaderViewController.m
//
//  Created by choipd on 10. 4. 20..
//  Copyright 2010 edbear. All rights reserved.
//



#import <AudioToolbox/AudioServices.h>
#import "UIPlazaMainHeaderViewController.h"
#import "ViewControllers.h"
#import "UIPlazaViewController.h"
#import "POIListViewController.h"
#import "UserContext.h"
#import "Utils.h"
#import "UIPlazaViewController.h"

@implementation UIPlazaMainHeaderViewController

static float POINAME_MAXWIDTH = 130.0f;


- (void) redrawUI {
	NSString* currentArea = [GeoContext sharedGeoContext].lastDongAddress;
	
#ifdef GEO_DEBUG
	[CommonAlert alertWithTitle:@"" message:[NSString stringWithFormat:@"헤더뷰 %@", currentArea]];
#endif
	
	if (currentArea != nil && ![currentArea isEqualToString:@""]) {
		poiName.text = currentArea;
		MY_LOG(@"%@", poiName.text);
		//poiName.text = @"아주이름이길고긴동이름테스트동";
	} else {
		poiName.text = @"대한민국";
	}
    
	CGSize labelSize = [Utils getWrapperSizeWithLabel:poiName];
	
	//최대길이를 넘기면 ...처리
	if (labelSize.width > POINAME_MAXWIDTH) {
		labelSize.width = POINAME_MAXWIDTH;
	}
	
	CGRect frame = [poiName frame];
	frame.size = labelSize;
	[poiName setFrame:frame];
	
	frame.origin = CGPointMake(frame.origin.x + labelSize.width - 50.0f, sliderToggleButton.frame.origin.y);
	frame.size = CGSizeMake(133.0f, 42.0f);
	[sliderToggleButton setFrame:frame];	
}

- (void) viewDidLoad {
	bTogleSearch=NO;
	// Notification Center
	center = [NSNotificationCenter defaultCenter];
	[center addObserver:self selector:@selector(geoPositionChange:) name:@"geoPositionChange" object:nil];
}

- (void) viewDidUnload {
	// Notification Center Upload
	[center removeObserver:self];	
}

- (void)viewWillAppear:(BOOL)animated {
	
	[self redrawUI];
}


- (IBAction) toggleMenu 
{
	MY_LOG(@"toggle menu");	

	[self redrawUI];
	UIPlazaViewController* plazaVC = (UIPlazaViewController*)[ViewControllers sharedViewControllers].plazaViewController;
#ifdef APP_STORE_FINAL
	[plazaVC refresh];
#else
	[plazaVC toggleNoticeView];
#endif
}


- (IBAction) toggleRadius
{
	if (bTogleSearch) {
		bTogleSearch = NO;
		[sliderToggleButton setImage:[UIImage imageNamed:@"radius_off.png"] forState:UIControlStateNormal];
	} else {
		bTogleSearch = YES;
		[sliderToggleButton setImage:[UIImage imageNamed:@"radius_on.png"] forState:UIControlStateNormal];
		//GA 적용
		GA3(@"광장",@"거리조절버튼",@"광장내");
	}
    
	[(UIPlazaViewController*)[ViewControllers sharedViewControllers].plazaViewController toggleSliderView];
}
- (IBAction) doPostWrite
{
	MY_LOG(@"발도장 찍기");
	//GA 적용
	GA3(@"광장",@"발도장찍기",@"광장내");
	GA1(@"발도장찍기버튼_광장상단");
	
	POIListViewController* poiListViewController = [[POIListViewController alloc] initWithNibName:@"POIListViewController" bundle:nil];
    poiListViewController.currPostWriteFlow = OLD_POSTFLOW;
	[(UINavigationController*)[ViewControllers sharedViewControllers].tabBarController.selectedViewController pushViewController:poiListViewController animated:YES];
	[poiListViewController release];
}

#pragma mark -
- (void) geoPositionChange:(NSNotification *) theNotification
{
	if (![poiName.text isEqualToString:@"대한민국"]) {
		UIPlazaViewController* vc = (UIPlazaViewController*)[ViewControllers sharedViewControllers].plazaViewController;
		[vc openNoticeView];		
	} else {
		// PoiName이 대한민국이었다가 다른 내용으로 바뀌었다면 Refresh하도록...
		UIPlazaViewController* vc = (UIPlazaViewController*)[ViewControllers sharedViewControllers].plazaViewController;
		[vc refresh];
	}

	[self redrawUI];
}

@end
