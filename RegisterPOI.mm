//
//  RegisterPOI.m
//  ImIn
//
//  Created by choipd on 10. 6. 2..
//  Copyright 2010 edbear. All rights reserved.
//

#import "RegisterPOI.h"
#import "UserContext.h"
#import "CommonAlert.h"
#import "const.h"
#import "HttpConnect.h"
#import "CgiStringList.h"
#import "JSON.h"
#import "ViewControllers.h"
#import "MapAnnotation.h"
#import "UserContext.h"
#import "CoordTrans.h"
#import "AutoCompletion.h"
#import "POIDetailViewController.h"
#import "PostComposeViewController.h"
#import "RegisterPOIMapViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "IsDenyWord.h"

@interface RegisterPOI() {
@private
    
}
- (NSMutableArray *) stringArray;
- (void) requestAutoCompletionWithString;
- (void) textFieldEditing:(NSNotification *) noti;
@end


@implementation RegisterPOI

@synthesize inputPoiName, poiLocation, smallMap;
//@synthesize poiSearchList, autoCompletion, searchText;
@synthesize rootViewController;
@synthesize isDenyWord;

- (void) viewDidLoad {
    [super viewDidLoad];

	connect = nil;
    searchTextField.delegate = self;

    [smallMap.layer setBorderColor:[RGB(158, 158, 158) CGColor]];
    [smallMap.layer setBorderWidth:1.0f];
    [smallMap.layer setCornerRadius:10.0f];
    
	UIImage *round = [UIImage imageNamed:@"bg_textbox.png"]; 
	UIImage *strImage = [round stretchableImageWithLeftCapWidth:12 topCapHeight:12]; 
	searchRoundImage.image = strImage;
	searchTextField.text = inputPoiName;
	[searchTextField becomeFirstResponder];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldEditing:) name:UITextFieldTextDidChangeNotification object:nil];
    
    titleView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f,0.0f,304.0f,22.0f)];
    [titleView setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.4]];
    [smallMap addSubview:titleView];
    [titleView release];
    
    titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(28.0f,6.0f,240.0f,11.0f)];
	[titleLabel setFont:[UIFont systemFontOfSize:11]];
	titleLabel.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
	titleLabel.textColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:1];
	[titleView addSubview:titleLabel];
	[titleLabel release];
    
    UIImageView* poiicon = [[UIImageView alloc] initWithFrame:CGRectMake(9.0f,4.0f,14.0f,14.0f)];
    [poiicon setImage:[UIImage imageNamed:@"icon_local_small.png"]];
    [titleView addSubview:poiicon];
    [poiicon release];
    
    double tmx = [[GeoContext sharedGeoContext].lastTmX doubleValue];
    double tmy = [[GeoContext sharedGeoContext].lastTmY doubleValue];
    
    self.poiLocation = [GeoContext tm2gws84WithTmX:tmx withTmY:tmy];  // 초기화

    /* 자동완성 기능 주석처리
    poiListTableView.frame = CGRectZero;

    poiListTableView.frame = CGRectMake(8.0f, 58.0f, 304.0f, 34*9);
    poiListTableView.backgroundColor = [UIColor clearColor];
    poiListTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    poiListTableView.hidden = YES;
    poiListTableView.bounces = NO;
     */
}

- (void) viewDidAppear:(BOOL)animated {
    	
    curLocation = CGPointMake([[GeoContext sharedGeoContext].lastTmX intValue], [[GeoContext sharedGeoContext].lastTmY intValue]);
	if (largeMap)
	{
        self.poiLocation = [[[CLLocation alloc] initWithLatitude:[largeMap poiCoordinate].latitude longitude:[largeMap poiCoordinate].longitude] autorelease];
        
		CGPoint modLocation = [self TMPositionForLatitude:[largeMap poiCoordinate].latitude  forLongitude:[largeMap poiCoordinate].longitude];
		if ([self distanceBetweenPointsA:modLocation B:curLocation] > 2000)
		{
			MY_LOG(@"원래 장소와의 거리:%f",[self distanceBetweenPointsA:modLocation B:curLocation]);
			[CommonAlert alertWithTitle:@"알림" message:@"GPS 위치좌표 기준\n반경 2KM내에서 변경 가능해요!"];
		}
		else curLocation = modLocation;
	}
    [self setSmallMap];
	[self setMapTitle:[GeoContext sharedGeoContext].lastFullAddress];
}


- (void) viewWillAppear:(BOOL)animated {

	[self logViewControllerName];
	[super viewWillAppear:animated];

    [[UserContext sharedUserContext] recordKissMetricsWithEvent:@"Registering POI Page" withInfo:nil];
}

- (void) viewWillDisappear:(BOOL)animated {
	if (connect != nil) {
		[connect stop];
		[connect release];
		connect = nil;
	}
}

- (void) didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void) viewDidUnload {
    [inputPoiName release];
    inputPoiName = nil;
    smallMap.delegate = nil;
    [smallMap release];
    smallMap = nil;
    [largeMap release];
    largeMap = nil;
    [poiLocation release];
    poiLocation = nil;
//    [poiListTableView release];
//    poiListTableView = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void) dealloc {
	if (connect != nil)
	{
		[connect stop];
		[connect release];
		connect = nil;
	}

	[inputPoiName release];    
    smallMap.delegate = nil;
    [smallMap release];
    [largeMap release];
    [poiLocation release];
    [isDenyWord release];
    
//    [poiListTableView release];
//    [poiSearchList release];
//    [autoCompletion release];
//    [searchText release];

    [super dealloc];
}

- (void) setSmallMap {
    // 위치 변환
    MY_LOG(@"poi location = %@", poiLocation);   
    // annotations 가 존재하면 제거
    [self.smallMap removeAnnotations:self.smallMap.annotations];
    [smallMap setRegion:MKCoordinateRegionMakeWithDistance([poiLocation coordinate], 100, 100)];
    //[smallMap setCenterCoordinate:CLLocationCoordinate2DMake([poiLocation coordinate].latitude+0.0002, [poiLocation coordinate].longitude)];
    CLLocationCoordinate2D centerCoord = { [poiLocation coordinate].latitude+0.0002, [poiLocation coordinate].longitude };
    [smallMap setCenterCoordinate:centerCoord];
    MapAnnotation* annotation = [[MapAnnotation alloc] initWithCoordinate:[poiLocation coordinate]];
    [smallMap addAnnotation:annotation];
    [annotation release];
}

- (void) setMapTitle:(NSString*)title {
	titleLabel.text = title;
}

#pragma mark - customized methods
- (NSMutableArray *) stringArray {
    /*
    NSString *originalString = [NSString stringWithFormat:@"동일한 명칭의 장소(%d개)가 이미 존재합니다", [poiSearchList count]];
    
    NSArray *croppedArray = [originalString componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"()"]];
    
    NSMutableArray *stringArray = [NSMutableArray array];
    
    NSString *str1 = [croppedArray objectAtIndex:0];
    NSString *str2 = [NSString stringWithFormat:@"(%@)", [croppedArray objectAtIndex:1]];
    NSString *str3 = [croppedArray objectAtIndex:2];
    
    CGFloat fontsize = 0.0f;
    
    if (str2.length < 5 || str2.length == 5) {
        fontsize = 14.0f;
    } else if (str2.length > 5 || str2.length < 8) {
        fontsize = 13.0f;
    } else if (str2.length == 8 || str2.length > 8) {
        fontsize = 12.0f;
    }
    UIFont *font = [UIFont fontWithName:@"helvetica" size:fontsize];
    
    CGSize size1 = [str1 sizeWithFont:font];
    UILabel *lb1 = [[[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0, size1.width, 14.0f)] autorelease];
    lb1.text = str1;
    lb1.font = font;
    lb1.backgroundColor = [UIColor clearColor];
    [stringArray addObject:lb1];
    
    CGSize size2 = [str2 sizeWithFont:font];
    UILabel *lb2 = [[[UILabel alloc] initWithFrame:CGRectMake(size1.width, 0, size2.width, 14.0f)] autorelease];
    lb2.text = str2;
    lb2.font = font;
    lb2.backgroundColor = [UIColor clearColor];
    lb2.textColor = [UIColor colorWithRed:51/255.0f green:170/255.0f blue:214/255.0f alpha:1.0f];
    [stringArray addObject:lb2];
    
    CGSize size3 = [str3 sizeWithFont:font];
    
    if (size1.width + size2.width + size3.width > 280) {
        size3.width = 280.0f - (size1.width + size2.width);
    }
    UILabel *lb3 = [[[UILabel alloc] initWithFrame:CGRectMake(size1.width + size2.width, 0, size3.width, 14.0f)] autorelease];
    lb3.text = str3;
    lb3.font = font;
    lb3.backgroundColor = [UIColor clearColor];
    [stringArray addObject:lb3];
    
    return  stringArray;
     */
    return nil;
}

/**
 @brief POI이름을 설정하기 위한 선행작업
 
 이때 addr1를 대한민국으로 세팅한다.
 */
- (void) registerPOIName {

	// 새로운 장소에 대한 기초 정보를 채운다
	NSDictionary* poiData = [NSDictionary dictionaryWithObjectsAndKeys:
							 [searchTextField text], @"poiName",
							 [[NSNumber numberWithInt:curLocation.x] stringValue], @"pointX",
							 [[NSNumber numberWithInt:curLocation.y] stringValue], @"pointY",
							 @"대한민국", @"addr1",
							 [GeoContext sharedGeoContext].lastFullAddress, @"addr",
							 nil];
    
    if ([rootViewController isEqualToString:@"PostComposeViewController"]) {
        [(PostComposeViewController*)[self.navigationController.viewControllers objectAtIndex:0] setPoiData:poiData];
        
        if ([ApplicationContext osVersion] > 3.2) {
            [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(popToRootView) userInfo:nil repeats:NO];
        } else {
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moveToTop:) name:@"moveToTop" object:nil];
        }
        
    } else {
        
        PostComposeViewController* postComposeViewController = [[[PostComposeViewController alloc] initWithNibName:@"PostComposeViewController" bundle:nil] autorelease];
        postComposeViewController.hidesBottomBarWhenPushed = YES;
        postComposeViewController.poiData = poiData;

        UINavigationController *navController = [[[UINavigationController alloc] initWithRootViewController:postComposeViewController] autorelease];
        [navController setNavigationBarHidden:YES] ;
        
        if ([ApplicationContext osVersion] > 3.2) {
            [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(popToRootView) userInfo:nil repeats:NO];
        } else {
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moveToTop:) name:@"moveToTop" object:nil];
        }
        
        [[ApplicationContext sharedApplicationContext] performSelector:@selector(presentVC:) withObject:navController afterDelay:0.0];
    }
}

- (void) popToRootView
{
	[self.navigationController popToRootViewControllerAnimated:YES];
}

/**
 @brief 큰 지도 보여주기
 */

- (IBAction) popLargeMap
{
    GA3(@"장소명직접등록", @"지도", @"장소명직접등록내");	
    
    if (!largeMap) {
        largeMap = [[RegisterPOIMapViewController alloc] init];
    }
    [largeMap setHidesBottomBarWhenPushed:YES];
    
    largeMap.poiCoordinate = poiLocation.coordinate;
    
    [self.navigationController pushViewController:largeMap animated:YES];
}

- (void) moveToTop:(NSNotification*) noti
{
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"moveToTop" object:nil];
	// 0.25초 인터벌을 둔 것은, RegistgerPOI vc가 발도장 찍기 vc의 parentVC인데 이것이 먼저 없어 지지 않도록 조치하기 위해서 추가함
	[NSTimer scheduledTimerWithTimeInterval:0.0 target:self selector:@selector(popToRootView) userInfo:nil repeats:NO];
}

-(IBAction) popToPrevious {
	[self.navigationController popViewControllerAnimated:YES];
}

/**
 @brief 이름이 금칙어가 아닌지 체크하고 금칙어가 아니면 글쓰기로 이동
 */
-(IBAction) checkPoiNameIsValid {
	//서버쪽으로 쿼리 던진다 성공하면 글쓰기 페이지로 고고!
	[self doRequest];
}

/**
 @brief 두 점사이의 거리
 @param first 시작점
 @param second 끝점
 */
- (CGFloat) distanceBetweenPointsA:(CGPoint)first B:(CGPoint)second
{
	CGFloat deltaX = second.x - first.x;
	CGFloat deltaY = second.y - first.y;
	return sqrt(deltaX*deltaX + deltaY*deltaY );
}

- (CGPoint) TMPositionForLatitude:(double)lat forLongitude:(double)lon
{
    TM tmpos = CCoordTrans::convLLToTM(LonAndLat(lon,lat), WGS84, TM_M);
	MY_LOG(@"변환좌표:(%f , %f)",tmpos.getX(),tmpos.getY());
    
    CGPoint returnPoint = CGPointMake(tmpos.getX(), tmpos.getY());
    
    return returnPoint;
}

- (CGPoint) coordnateForTMX:(NSNumber*)tmx TMY:(NSNumber*)tmy
{
    CLLocation *posLocation = [GeoContext tm2gws84WithTmX:[tmx doubleValue] withTmY:[tmy doubleValue]];
    CGPoint transPos = CGPointMake(posLocation.coordinate.latitude, posLocation.coordinate.longitude);
    
    return transPos;
}

- (void) textFieldEditing:(NSNotification *) noti {
//    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(tick:) object:nil];
//    [self performSelector:@selector(tick:) withObject:nil afterDelay:0.5];
}

- (void) tick:(NSTimer*) timer
{
    /*
    MY_LOG(@"this tick = %@", searchTextField.text); 
    if (searchTextField.text == nil || [searchTextField.text isEqualToString:@""]) {
        [poiListTableView setHidden:YES];
    } else  {
        self.searchText = searchTextField.text;
        [self requestAutoCompletionWithString];
    }
     */
}


//#pragma mark - Network methods
//
//- (void) onResultError:(HttpConnect*)up
//{
//	
//	[CommonAlert alertWithTitle:@"단말의 네트워크 전송에 문제가 있습니다." message:up.stringError];
//	if (connect != nil)
//	{
//		[connect release];
//		connect = nil;
//	}
//}
///**
// @brief 금칙어 확인 결과 처리
// */
//- (void) onTransDone:(HttpConnect*)up
//{
//	
//	MY_LOG(@"<!-- isDenyWord");
//	MY_LOG(@"%@", up.stringReply);
//	MY_LOG(@"isDenyWord-->");
//	
//	SBJSON* jsonParser = [SBJSON new];
//	[jsonParser setHumanReadable:YES];
//
//	NSDictionary* results = (NSDictionary *)[jsonParser objectWithString:up.stringReply error:NULL];
//	[jsonParser release];
//
//	if (connect != nil)
//	{
//		[connect release];
//		connect = nil;
//	}
//	
//	
//	NSNumber* resultNumber = (NSNumber*)[results objectForKey:@"result"];
//	
//	if ([resultNumber intValue] == 0) { //에러처리
//		[CommonAlert alertWithTitle:@"안내" message:[results objectForKey:@"description"]];
//		return;
//	}
//	
//	NSNumber* isDenyWord = (NSNumber*)[results objectForKey:@"isDenyWord"];
//	NSNumber* isDuplPoi = (NSNumber*)[results objectForKey:@"isDuplPoi"];
//
//	if ([isDuplPoi intValue] == 1) {
//		[CommonAlert alertWithTitle:@"안내" message:@"이미 사용 중인 장소명입니다. 다시 입력해 주세요."];
//		return;
//	}
//	
//	if ([isDenyWord intValue] == 1) {
//		[CommonAlert alertWithTitle:@"안내" message:@"금칙어가 포함되었어요. 금칙어 NO!"];
//		return;		
//	}
//	
//	[self registerPOIName];
//}

/**
 @brief 금칙어인지 확인 요청
 */
- (void) request {
    self.isDenyWord = [[[IsDenyWord alloc] init] autorelease];
    isDenyWord.delegate = self;
    
    [isDenyWord.params addEntriesFromDictionary:[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d", (int)curLocation.x], @"pointX",
                                                 [NSString stringWithFormat:@"%d", (int)curLocation.y], @"pointY",
                                                 @"3", @"type",
                                                 [searchTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]], @"word" , nil]];
    
    [isDenyWord requestWithAuth:NO withIndicator:NO];
    
//	CgiStringList* strPostData=[[CgiStringList alloc]init:@"&"];
//	[strPostData setMapString:@"svcId" keyvalue:SNS_IPHONE_SVCID];
//	
//	[strPostData setMapString:@"pointX" keyvalue:[NSString stringWithFormat:@"%d", (int)curLocation.x]];
//	[strPostData setMapString:@"pointY" keyvalue:[NSString stringWithFormat:@"%d", (int)curLocation.y]];
//	[strPostData setMapString:@"type" keyvalue:@"3"]; //3:발도장명
//	[strPostData setMapString:@"word" keyvalue:[searchTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
//       
//	if (connect != nil)
//	{
//		[connect stop];
//		[connect release];
//		connect = nil;
//	}
//	
//	connect = [[HttpConnect alloc] initWithURL:PROTOCOL_IS_DENY_WORD
//						   postData: [strPostData description]
//						   delegate: self
//					   doneSelector: @selector(onTransDone:)    
//					  errorSelector: @selector(onResultError:)  
//				   progressSelector: nil];
//	//[[OperationQueue queue] addOperation:conn];
//	//[conn release];
//	[strPostData release];
}

/**
 @brief 금칙어인지 요청하기 전에 걸러냄
 */
- (void) doRequest {
	if ([[searchTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""]) {
		[CommonAlert alertWithTitle:@"안내" message:@"장소명은 필수입력입니다."];
		return;
	}
	
	if([searchTextField.text length] > 20) {
		[CommonAlert alertWithTitle:@"안내" message:@"최대 20자까지 입력해주세요"];
		return;
	}
	
	NSCharacterSet* emojiCharacterSet = [NSCharacterSet characterSetWithRange:NSMakeRange(0xe001, 0xe537-0xe001)];
	if ([searchTextField.text rangeOfCharacterFromSet:emojiCharacterSet].location != NSNotFound) {
		[CommonAlert alertWithTitle:@"안내" message:@"이모티콘 특수문자는 장소명으로 쓰실 수 없어요."];
		return;
	}
		
	NSCharacterSet* denyCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@"{}|\\"];
	
	if ([searchTextField.text rangeOfCharacterFromSet:denyCharacterSet].location != NSNotFound) {
		[CommonAlert alertWithTitle:@"안내" message:@"특수문자는 장소명으로 쓰실 수 없어요."];
		return;
	}
	
    GA3(@"장소명직접등록", @"확인버튼", @"장소명직접등록내");

	[self request];
}

/**
 @brief 자동완성기능 : 존재하는 POI 리스트 요청
        주석처리
 */
- (void) requestAutoCompletionWithString {
    /*
    self.autoCompletion = [[[AutoCompletion alloc] init] autorelease];
    autoCompletion.delegate = self;
    autoCompletion.data = [NSDictionary dictionaryWithObjectsAndKeys:searchText, @"query",
                           [[GeoContext sharedGeoContext].lastTmX stringValue], @"x", 
                           [[GeoContext sharedGeoContext].lastTmY stringValue], @"y", 
                           @"4", @"poi",
                           nil];
    
    [autoCompletion request];
     */
}

#pragma mark - MKMapView delegate
- (MKAnnotationView *) mapView:(MKMapView *) mapView viewForAnnotation:(id ) annotation {
    
	MKPinAnnotationView *customAnnotationView=[[[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:nil] autorelease];    
    
//    UIImageView* aPoiMark = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"nowin_icon.png"]] autorelease];
//    [aPoiMark setFrame:CGRectMake(-7, -4, 28, 41)];
//    [customAnnotationView addSubview:aPoiMark];
    
    return customAnnotationView;
}

/**
 자동완성 기능 주석처리
 */
/* 
#pragma mark -
#pragma mark UITableView delegate/datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    } else if (section == 1) {
        return [poiSearchList count];
    } else {
        return 1;
    }
    return 0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return 34.0f;
    } else if (indexPath.section == 2) {
        return 33.0f;
    } else {
        return 32.0f;
    }
    return 0.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
       
    if (indexPath.section == 0) {

        NSString *cellIdentifer = @"noticeCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifer];
        
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifer] autorelease];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.backgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg_overlap.png"]] autorelease];
            UIView *line = [[[UIView alloc] initWithFrame:CGRectMake(0, 33, 304, 1)] autorelease];
            line.backgroundColor = [UIColor colorWithRed:203/255.0f green:203/255.0f blue:203/255.0f alpha:1];
            [cell addSubview:line];
            
            UIView *notiView = [[[UIView alloc] initWithFrame:CGRectMake(12.0f, 11.0f, 280.0f, 14.0f)] autorelease];
            [cell.contentView addSubview:notiView];
            notiView.tag = 1001;
        }

        UIView *notiView = (UIView*)[cell viewWithTag:1001];

        for (UILabel *lb in [notiView subviews]) {
            [lb removeFromSuperview];
        } 
        
        NSMutableArray *strLabelArray = [self stringArray];
        for (UILabel* lb in strLabelArray) {
            [notiView addSubview:lb];
        }
                
        notiView.frame = CGRectMake(12.0f, 11.0f, 280, 32);
        return cell;

    } else if (indexPath.section == 1) {
        NSString *cellIdentifer = @"seasrchListCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifer];
        
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifer] autorelease];
            cell.backgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"back_bg_line.png"]] autorelease];        
            cell.accessoryView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"btn_location_arrow.png"]] autorelease];   
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            UIView *line = [[[UIView alloc] initWithFrame:CGRectMake(0, 31, 304, 1)] autorelease];
            line.backgroundColor = [UIColor colorWithRed:203/255.0f green:203/255.0f blue:203/255.0f alpha:1];
            line.tag = 1000;
            [cell addSubview:line];
        }
        cell.textLabel.text = [[poiSearchList objectAtIndex:indexPath.row] objectForKey:@"poiName"];
        
        return cell;
        
    } else {
        NSString *cellIdentifer = @"cancelCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifer];
        
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifer] autorelease];
            cell.accessoryView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"btn_location_arrow.png"]] autorelease];   
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.backgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"btn_cancel.png"]] autorelease];
        }
        return cell;
        
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        searchTextField.text = [[poiSearchList objectAtIndex:indexPath.row] objectForKey:@"poiName"];
        
        //poi 페이지로 이동
        NSDictionary *poiData = [poiSearchList objectAtIndex:indexPath.row];
        POIDetailViewController *vc = [[POIDetailViewController alloc] initWithNibName:@"POIDetailViewController" bundle:nil];
        vc.poiData = poiData;
        [(UINavigationController*)[ViewControllers sharedViewControllers].tabBarController.selectedViewController pushViewController:vc animated:YES];
        [vc release];

    } else if (indexPath.section == 2) {
        [poiListTableView setHidden:YES];
    }
}

#pragma mark - UITextField delegate

- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
	[textField resignFirstResponder];
	return YES;
}

- (void) textFieldDidEndEditing:(UITextField *)textField
{
	[textField resignFirstResponder];
}

- (BOOL) textFieldShouldClear:(UITextField *)textField {
    self.poiSearchList = nil;
    [poiListTableView setHidden:YES];
    [poiListTableView reloadData];
    return YES;
}
*/

#pragma mark ImInProtocol delegate
-(void) apiDidLoad:(NSDictionary*) result {
    
//    if ([[result objectForKey:@"func"] isEqualToString:@"autoCompletion"]) {
//        MY_LOG(@"%@", [result objectForKey:@"data"]);
//
//        NSUInteger resultCnt = [[result objectForKey:@"data"] count];
//        if (resultCnt > 0) {
//            self.poiSearchList = [result objectForKey:@"data"];
//            [poiListTableView setHidden:NO];
//            [poiListTableView reloadData];
//        } else {
//            [poiListTableView setHidden:YES];
//        }
//    }
    if ([[result objectForKey:@"func"] isEqualToString:@"isDenyWord"]) {
        NSNumber* resultNumber = (NSNumber*)[result objectForKey:@"result"];
        
        if ([resultNumber intValue] == 0) { //에러처리
            [CommonAlert alertWithTitle:@"안내" message:[result objectForKey:@"description"]];
            return;
        }
        
        NSNumber* isDW = (NSNumber*)[result objectForKey:@"isDenyWord"];
        NSNumber* isDuplPoi = (NSNumber*)[result objectForKey:@"isDuplPoi"];
        
        if ([isDuplPoi intValue] == 1) {
            [CommonAlert alertWithTitle:@"안내" message:@"이미 사용 중인 장소명입니다. 다시 입력해 주세요."];
            return;
        }
        
        if ([isDW intValue] == 1) {
            [CommonAlert alertWithTitle:@"안내" message:@"금칙어가 포함되었어요. 금칙어 NO!"];
            return;		
        }
        
        [self registerPOIName];
    }
}

-(void) apiFailed {
    
    MY_LOG(@"apiFailed");
}

@end
