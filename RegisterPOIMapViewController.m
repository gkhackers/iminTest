//
//  RegisterPOIMapViewController.m
//  ImIn
//
//  Created by KYONGJIN SEO on 12/6/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "RegisterPOIMapViewController.h"

/**
 @brief pinAnnotationView(custom) 의 POI 포인트의 정확한 위치를 전달하기 위한 상하좌우 오차 범위
 @brief 핀 이미지의 포인트가 이미지의 center좌표에서 왼쪽으로 6.2f만큼, 아래쪽으로 16.4f만큼 벗어나 있음.
 */
#define LEFT_MOVEPOINT  -6.2f
#define DOWN_MOVEPOINT 16.4f

@implementation RegisterPOIMapViewController
@synthesize poiCoordinate;

- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void) didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    poiMapView.delegate = self;
    poiMapView.showsUserLocation = YES;
    UIView *notice = [[UIView alloc] initWithFrame:CGRectMake(0, 43, 320, 40)];
    notice.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4];
    [self.view addSubview:notice];
    [notice release];
    
    UILabel* titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,0,320,40)];
	[titleLabel setFont:[UIFont systemFontOfSize:13]];
    titleLabel.numberOfLines = 2;
    titleLabel.lineBreakMode = UILineBreakModeWordWrap;
	titleLabel.text = @"지도를 움직여 주세요.\n(반경 2km 번위 내에서만 조정 가능 합니다)";
    titleLabel.textAlignment = UITextAlignmentCenter;
	titleLabel.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
	titleLabel.textColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:1];
	[notice addSubview:titleLabel];
	[titleLabel release];
    
    aPoiMark = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_pin.png"]];
    [poiMapView addSubview:aPoiMark];
}

- (void) viewDidUnload
{
    [poiMapView release];
    poiMapView = nil;
    [aPoiMark release];
    aPoiMark =nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void) viewWillAppear:(BOOL)animated {
    [self setPOIMap];
    [super viewWillAppear:animated];

    [[UserContext sharedUserContext] recordKissMetricsWithEvent:@"Adjusting Location Page" withInfo:nil];

}

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Buttons
- (IBAction) popToPrevious:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

/**
 @brief 현재 선택한 뷰의 좌표를 coordinate으로 전환
 */
- (IBAction) savePOIPosition {
    GA3(@"위치선택", @"확인", @"위치선택내");
    CGPoint curPoint = CGPointMake(aPoiMark.center.x+LEFT_MOVEPOINT, aPoiMark.center.y+DOWN_MOVEPOINT);
    CLLocationCoordinate2D cood = [poiMapView convertPoint:curPoint toCoordinateFromView:poiMapView];
    
    MY_LOG(@"%f %f", curPoint.x, curPoint.y);
    MY_LOG(@"%f %f", cood.latitude, cood.longitude);
    
    self.poiCoordinate = cood;
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - MKMapView delegate
- (MKAnnotationView *) mapView:(MKMapView *) mapView viewForAnnotation:(id ) annotation {
    
    // 현재 위치 표시
    if ([annotation isKindOfClass:[MKUserLocation class]]) {
        return nil;
    }
    // 핀 표시 안함
    MKAnnotationView *pinView = [[[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:nil] autorelease];
    pinView.image = nil;
    return pinView;
}

#pragma mark - Methods
- (void) setPOIMap {
    
    [poiMapView setRegion:MKCoordinateRegionMakeWithDistance(poiCoordinate, 300, 200)];
    
    MapAnnotation* annotation = [[[MapAnnotation alloc] initWithCoordinate:poiCoordinate] autorelease];
    [poiMapView addAnnotation:annotation];
    
    [poiMapView setCenterCoordinate:poiCoordinate];
    
    CGPoint curPoint = [poiMapView convertCoordinate:poiCoordinate toPointToView:poiMapView];
    CGPoint markPoint = CGPointMake(curPoint.x+6.0f, curPoint.y-16.4f);
    aPoiMark.center = markPoint;
}

- (void) dealloc {
    [poiMapView release];
    [aPoiMark release];
    [super dealloc];
}
@end
