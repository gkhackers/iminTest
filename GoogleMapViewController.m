//
//  GoogleMapViewController.m
//  ImIn
//
//  Created by Myungjin Choi on 11. 11. 9..
//  Copyright (c) 2011년 KTH. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import "GoogleMapViewController.h"
#import "MapAnnotation.h"
#import "CommonWebViewController.h"
#import "UIPoiPoliceWriteViewController.h"
#import "UIImageView+WebCache.h"
#import "MKMapView+Additions.h"

#import "PoiPolice.h"

@interface GoogleMapViewController (private)
- (void)relocateGoogleLogo;
@end

@implementation GoogleMapViewController
@synthesize mapInfo;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
	NSString* poiName = [mapInfo objectForKey:@"poiName"];
	NSString* addr1 = [mapInfo objectForKey:@"addr1"];
	NSString* addr2 = [mapInfo objectForKey:@"addr2"];
	NSString* addr3 = [mapInfo objectForKey:@"addr3"];
	NSString* phoneNum = [mapInfo objectForKey:@"shopPhoneNo"];
    NSString* addrInfo = [NSString stringWithFormat:@"%@ %@ %@", addr1, addr2, addr3];
    
    // 주소 길이가 얼마나 되는지 확인
    CGSize addrSize = [addrInfo sizeWithFont:[UIFont systemFontOfSize:12] constrainedToSize:CGSizeMake(250, 40) lineBreakMode:UILineBreakModeWordWrap];
    MY_LOG(@"addrSize = %@", NSStringFromCGSize(addrSize));
    
    float offset = addrSize.height - 15;
    
    if (offset > 0) {
        // 주소가 두 줄 이상이다.
        
        CGRect f = infoViewWithPhone.frame;
        f.size.height += offset;
        f.origin.y -= offset;
        infoViewWithPhone.frame = f;
        
        f = infoViewWithoutPhone.frame;
        f.size.height += offset;
        f.origin.y -= offset;
        infoViewWithoutPhone.frame = f;
    }
    
    [profileImageView setImageWithURL:[NSURL URLWithString:[mapInfo objectForKey:@"profileImg"]] placeholderImage:[UIImage imageNamed:@"nowin_icon.png"]];
    
    titleLabel.text = poiName;
    
    if (phoneNum && ![phoneNum isEqualToString:@""]) {
        
        infoViewWithPhone.hidden = NO;
        
        UILabel* addrLabel = (UILabel*)[infoViewWithPhone viewWithTag:200];
        CGRect f = addrLabel.frame;
        f.size = addrSize;
        addrLabel.frame = f;
        
        [(UILabel*)[infoViewWithPhone viewWithTag:100] setText:poiName];
        [addrLabel setText:addrInfo];
        [(UILabel*)[infoViewWithPhone viewWithTag:300] setText:phoneNum];
        
    } else {
        
        infoViewWithoutPhone.hidden = NO;
        
        UILabel* addrLabel = (UILabel*)[infoViewWithoutPhone viewWithTag:200];
        CGRect f = addrLabel.frame;
        f.size = addrSize;
        addrLabel.frame = f;
        
        [(UILabel*)[infoViewWithoutPhone viewWithTag:100] setText:poiName];
        [addrLabel setText:addrInfo];
    }

    // 위치 변환
    double tmx = [[mapInfo objectForKey:@"pointX"] doubleValue];
    double tmy = [[mapInfo objectForKey:@"pointY"] doubleValue];
    
    CLLocation* poiLocation = [GeoContext tm2gws84WithTmX:tmx withTmY:tmy];
    MY_LOG(@"poi location = %@", poiLocation);
    [mapView setRegion:MKCoordinateRegionMakeWithDistance([poiLocation coordinate], 300, 200)];
    
    MapAnnotation* annotation = [[[MapAnnotation alloc] initWithCoordinate:[poiLocation coordinate]] autorelease];
    [mapView addAnnotation:annotation];

    mapView.showsUserLocation = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [self relocateGoogleLogo];
}

- (MKAnnotationView *) mapView:(MKMapView *) mapView viewForAnnotation:(id ) annotation {
    
    // 현재 위치 표시
    if ([annotation isKindOfClass:[MKUserLocation class]]) {
        return nil;
    }
	MKPinAnnotationView *customAnnotationView=[[[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:nil] autorelease];
    customAnnotationView.image = nil;

    if ([Utils isBrandUser:mapInfo]) {
        UIView* aBallonView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 50, 59)] autorelease];
        [profileImageView setFrame:CGRectMake(5, 5, 38, 38)];
        [aBallonView addSubview:profileImageView];
        [aBallonView addSubview:[[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"poisang_balloon.png"]] autorelease]];
        [aBallonView setFrame:CGRectMake(-10, -20, 50, 59)];        
        [customAnnotationView addSubview:aBallonView];
   } 
//        else {
//        UIImageView* aPoiMark = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"nowin_icon.png"]] autorelease];
//        [aPoiMark setFrame:CGRectMake(-7, -4, 28, 41)];
//        [customAnnotationView addSubview:aPoiMark];
//    }
    
    //customAnnotationView.pinColor = [UIColor clearColor];
    customAnnotationView.animatesDrop = YES;
//    customAnnotationView.canShowCallout = YES;
//	UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
//	[rightButton addTarget:self action:@selector(annotationViewClick:) forControlEvents:UIControlEventTouchUpInside];
//	customAnnotationView.rightCalloutAccessoryView = rightButton;
    
    return customAnnotationView;
}

- (IBAction) annotationViewClick:(id) sender {
    MY_LOG(@"clicked");

    double dtmx = [[mapInfo objectForKey:@"pointX"] doubleValue];
    double dtmy = [[mapInfo objectForKey:@"pointY"] doubleValue];
    double stmx = [[GeoContext sharedGeoContext].lastTmX doubleValue];
    double stmy = [[GeoContext sharedGeoContext].lastTmY doubleValue];
    
    CLLocation* src = [GeoContext tm2gws84WithTmX:stmx withTmY:stmy];
    CLLocation* dst = [GeoContext tm2gws84WithTmX:dtmx withTmY:dtmy];
    

    NSString* urlString = [NSString stringWithFormat:@"http://maps.google.com/maps?daddr=%f,%f&saddr=%f,%f#bmb=1", 
                           dst.coordinate.latitude, dst.coordinate.longitude,
                           src.coordinate.latitude, src.coordinate.longitude];
    MY_LOG(@"map url = %@", urlString);
    
//    [[UIApplication sharedApplication] openURL:[NSURL URLWithString: urlString]];
    CommonWebViewController* vc = [[[CommonWebViewController alloc] initWithNibName:@"CommonWebViewController" bundle:nil] autorelease];
    vc.urlString = urlString;
    [self presentModalViewController:vc animated:YES];
}

- (void)viewDidUnload
{
    [mapView release];
    mapView = nil;
    [titleLabel release];
    titleLabel = nil;
    [infoViewWithoutPhone release];
    infoViewWithoutPhone = nil;
    [infoViewWithPhone release];
    infoViewWithPhone = nil;
    [profileImageView release];
    profileImageView = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
    [mapView release];
    [titleLabel release];
    
    [mapInfo release];
    
    [infoViewWithoutPhone release];
    [infoViewWithPhone release];
    [profileImageView release];
    [super dealloc];
}
- (IBAction)closeVC:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)phoneCall:(id)sender {
    if([[[UIDevice currentDevice] systemVersion] doubleValue] < 4.0) {
		UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"알림" message:@"지금 전화를 거시겠어요?\n아임IN 앱은 종료됩니다 "
                                                        delegate:self cancelButtonTitle:@"취소" otherButtonTitles:@"확인", nil] autorelease];
		alert.tag = 200;
		[alert show];
	} else {
		NSString* tel = [NSString stringWithFormat:@"tel:%@",[mapInfo objectForKey:@"shopPhoneNo"]];
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:tel]];
	}
}

- (IBAction)reportWrongInfo:(id)sender {
    UIActionSheet* selectionSheet = [[[UIActionSheet alloc]
                                      initWithTitle:nil 
                                      delegate:self 
                                      cancelButtonTitle:@"취소" 
                                      destructiveButtonTitle:nil
                                      otherButtonTitles:@"더이상 영업하지 않는 곳",@"장소 명칭 정정", @"사실과 다른 관련 정보", nil] autorelease];
	[selectionSheet showInView:self.view.window];
}


- (void)alertView:(UIAlertView*)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (alertView.tag == 200 & buttonIndex == 1)
	{
		NSString* tel = [NSString stringWithFormat:@"tel:%@",[mapInfo objectForKey:@"shopPhoneNo"]];
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:tel]];		
	}
}


#pragma mark - ImIn Protocol

- (void) apiDidLoadWithResult:(NSDictionary *)result whichObject:(NSObject *)theObject
{
    if ([[result objectForKey:@"func"] isEqualToString:@"poiPolice"]) {
        if ([[result objectForKey:@"result"] boolValue]) {
            [CommonAlert alertWithTitle:@"에러" message:@"장소에 대한 신고가\n완료되었습니다."];
        } else {
            [CommonAlert alertWithTitle:@"에러" message:[result objectForKey:@"description"]];
        }
        [theObject release];
    }
}

- (void) apiFailedWhichObject:(NSObject *)theObject
{
    if ([NSStringFromClass([theObject class]) isEqualToString:@"PoiPolice"]) {
        [theObject release];
    }
}

//// POI신고 관련
- (void) requestPolice {
    NSString* poiKey = [mapInfo objectForKey:@"poiKey"];
    
    if (poiKey == nil) return;
    
    PoiPolice* poiPolice = [[PoiPolice alloc] init];
    poiPolice.delegate = self;
    [poiPolice.params addEntriesFromDictionary:[NSDictionary dictionaryWithObjectsAndKeys:@"더 이상 영업하지 않는 곳입니다.", @"msg", poiKey, @"poiKey", nil]];
    [poiPolice request];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{	
	if (buttonIndex == 3) return;
	if (buttonIndex == 0) [self requestPolice]; // 영업하지 않는곳
	
	if (buttonIndex == 1)
	{
		UIPoiPoliceWriteViewController* pv = [[UIPoiPoliceWriteViewController alloc] initWithNibName:@"UIPoiPoliceWriteViewController" bundle:nil];
		
		[pv setPoiId:[mapInfo objectForKey:@"poiKey"]];
		[pv setPreString:@"장소 명칭 정정"];
		[(UINavigationController*)[ViewControllers sharedViewControllers].tabBarController.selectedViewController pushViewController:pv animated:YES];
		[pv release];
	}
	if (buttonIndex == 2)
	{
		UIPoiPoliceWriteViewController* pv = [[UIPoiPoliceWriteViewController alloc] initWithNibName:@"UIPoiPoliceWriteViewController" bundle:nil];
		[pv setPoiId:[mapInfo objectForKey:@"poiKey"]];
		[pv setPreString:@"사실과 다른 관련 정보"];
		[(UINavigationController*)[ViewControllers sharedViewControllers].tabBarController.selectedViewController pushViewController:pv animated:YES];
		[pv release];
	}
    
}

- (void)relocateGoogleLogo {
    UIImageView *logo = [mapView googleLogo];
    if (logo == nil) {
        return;
    }
    CGRect frame = logo.frame;
    if (infoViewWithPhone.hidden) {
        frame.origin.y = 300.0f;
    } else {
        frame.origin.y = 280.0f;
    }
    logo.frame = frame;
}

@end
