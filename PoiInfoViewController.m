//
//  PoiInfoViewController.m
//  ImIn
//
//  Created by Myungjin Choi on 11. 10. 20..
//  Copyright (c) 2011년 KTH. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "PoiInfoViewController.h"
#import "PoiInfoDetail.h"
#import "UIImageView+WebCache.h"
#import "UIPoiPoliceWriteViewController.h"
#import "PoiPolice.h"
#import "MapAnnotation.h"
#import "CommonWebViewController.h"
#import "UIImageView+WebCache.h"
#import "GoogleMapViewController.h"
#import "PictureViewController.h"

@implementation PoiInfoViewController
@synthesize poiKey, poiInfoDetail, poiInfoResult;

- (void) dealloc
{
    [poiKey release];
    [poiInfoDetail release];
    [poiInfoResult release];
    
    [cellGeneral release];
    [cellMap release];
    [cellCoverTop release];
    [cellDetail release];
    [cellCoverBottom release];
    [cellReportButton release];
    [mainTableView release];
    [categoryIconImageView release];
    [categoryLabel release];
    [poiNameLabel release];
    [addressLabel release];
    [introMsgLabel release];
    [phoneNumberButton release];
    [homepageButton release];
    [promotionLabel release];
    [shopInfoTextView release];
    [mapImageView release];
    [smallMap release];
    [profileImageView release];
    [shopInfoView release];
    [brandmarkImageView release];
    [super dealloc];
}

/**
 @brief Releases the view if it doesn't have a superview.
 @brief Release any cached data, images, etc that aren't in use.
 */
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle

/**
 @brief 
 */
- (void)viewDidLoad
{
    [super viewDidLoad];

    /// @todo poiKey 가 존재할 때만 존재하는 뷰컨트롤러. 이전에 체크해야지... 유연하게 처리하는 법 없나?
    if (poiKey == nil) {
        [CommonAlert alertWithTitle:@"안내" message:@"없는 장소입니다."];
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    
    if (poiInfoResult) {
        // 위치 변환
        double tmx = [[poiInfoResult objectForKey:@"pointX"] doubleValue];
        double tmy = [[poiInfoResult objectForKey:@"pointY"] doubleValue];
        
        CLLocation* poiLocation = [GeoContext tm2gws84WithTmX:tmx withTmY:tmy];
        MY_LOG(@"poi location = %@", poiLocation);
        [smallMap setRegion:MKCoordinateRegionMakeWithDistance([poiLocation coordinate], 300, 200)];
        [smallMap.layer setBorderColor:[RGB(158, 158, 158) CGColor]];
        [smallMap.layer setBorderWidth:1.0f];
        [smallMap.layer setCornerRadius:10.0f];
        CLLocationCoordinate2D centerCoord = { [poiLocation coordinate].latitude+0.0002, [poiLocation coordinate].longitude };
        [smallMap setCenterCoordinate:centerCoord];
        //[smallMap setCenterCoordinate:CLLocationCoordinate2DMake([poiLocation coordinate].latitude+0.0002, [poiLocation coordinate].longitude)];

        MapAnnotation* annotation = [[[MapAnnotation alloc] initWithCoordinate:[poiLocation coordinate]] autorelease];
        [smallMap addAnnotation:annotation];
    }

    self.poiInfoDetail = [[[PoiInfoDetail alloc] init] autorelease];
    poiInfoDetail.delegate = self;
    [poiInfoDetail.params addEntriesFromDictionary:[NSDictionary dictionaryWithObject:poiKey forKey:@"poiKey"]];
    [poiInfoDetail request];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [cellGeneral release];
    cellGeneral = nil;
    [cellMap release];
    cellMap = nil;
    [cellCoverTop release];
    cellCoverTop = nil;
    [cellDetail release];
    cellDetail = nil;
    [cellCoverBottom release];
    cellCoverBottom = nil;
    [cellReportButton release];
    cellReportButton = nil;
    [mainTableView release];
    mainTableView = nil;
    [categoryIconImageView release];
    categoryIconImageView = nil;
    [categoryLabel release];
    categoryLabel = nil;
    [poiNameLabel release];
    poiNameLabel = nil;
    [addressLabel release];
    addressLabel = nil;
    [introMsgLabel release];
    introMsgLabel = nil;
    [phoneNumberButton release];
    phoneNumberButton = nil;
    [homepageButton release];
    homepageButton = nil;
    [promotionLabel release];
    promotionLabel = nil;
    [shopInfoTextView release];
    shopInfoTextView = nil;
    [mapImageView release];
    mapImageView = nil;
    [smallMap release];
    smallMap = nil;
    [profileImageView release];
    profileImageView = nil;
    [shopInfoView release];
    shopInfoView = nil;
    [brandmarkImageView release];
    brandmarkImageView = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

/**
 @brief POI 데이터 UI에 입력
 */
- (void) redrawUIWithDictionary:(NSDictionary*) data
{
    if ([Utils isBrandUser:data]) {
        [categoryIconImageView setImageWithURL:[NSURL URLWithString:[data objectForKey:@"profileImg"]] placeholderImage:[UIImage imageNamed:@"delay_nosum70.png"]];
        [categoryIconImageView setFrame:CGRectMake(11, 27, 38, 38)];
        [brandmarkImageView setImage:[UIImage imageNamed:@"brand_mark.png"]];
        brandmarkImageView.hidden = NO;
    } else {
        [categoryIconImageView setImageWithURL:[NSURL URLWithString:[Utils convertImgSize70to38:[data objectForKey:@"categoryImg"]]] placeholderImage:[UIImage imageNamed:@"9000000_38x38_2@2x.png"]];
        [categoryIconImageView setFrame:CGRectMake(11+2, 16, 38, 38)];
        brandmarkImageView.hidden = YES;
    }
    [profileImageView setImageWithURL:[NSURL URLWithString:[data objectForKey:@"profileImg"]] placeholderImage:[UIImage imageNamed:@"delay_nosum70.png"]];
    
    NSString* categoryTitle = @"";
    
    if ([data objectForKey:@"categoryName"]) {
        categoryTitle = [data objectForKey:@"categoryName"];
    }
    
    categoryLabel.text = categoryTitle;
    
    poiNameLabel.text = [data objectForKey:@"poiName"];
    
    addressLabel.text = [NSString stringWithFormat:@"%@ %@ %@", 
                         [data objectForKey:@"addr1"],
                         [data objectForKey:@"addr2"],
                         [data objectForKey:@"addr3"]];
    
    introMsgLabel.text = [data objectForKey:@"shopIntro"];
    
    NSString* phoneNo = [data objectForKey:@"shopPhoneNo"];
    if (phoneNo == nil || [phoneNo isEqualToString:@""]) {
        phoneNo = @"미등록";
        [phoneNumberButton setTitleColor:RGB(0x99, 0x99, 0x99) forState:UIControlStateNormal];
        phoneNumberButton.enabled = NO;
    }
    [phoneNumberButton setTitle:phoneNo forState:UIControlStateNormal];
    
    NSString* homepage = [data objectForKey:@"shopHome"];
    if (homepage == nil || [homepage isEqualToString:@""]) {
        homepage = @"미등록";
        [homepageButton setTitleColor:RGB(0x99, 0x99, 0x99) forState:UIControlStateNormal];
        homepageButton.enabled = NO;
    }
    [homepageButton setTitle:homepage forState:UIControlStateNormal];
    
    promotionLabel.text = [data objectForKey:@"svcIntro"];
    NSMutableString* promoText = [NSMutableString stringWithCapacity:500];
    
    NSString* tmp = [data objectForKey:@"shopOpen"];
    
    if (tmp && ![tmp isEqualToString:@""]) {
        [promoText appendFormat:@"▪이용시간: %@\n", tmp];
    }
    
    tmp = [data objectForKey:@"shopClose"];
    
    if (tmp && ![tmp isEqualToString:@""]) {
        [promoText appendFormat:@"▪휴무일: %@\n", tmp];
    }
    
    tmp = [data objectForKey:@"shopRoute"];
    
    if (tmp && ![tmp isEqualToString:@""]) {
        [promoText appendFormat:@"▪%@\n", tmp];
    }
    
    tmp = [data objectForKey:@"shopParking"];
    
    if (tmp && ![tmp isEqualToString:@""]) {
        [promoText appendFormat:@"▪주차: %@\n", tmp];
    }
    
    UIImageView* shopImg01 = (UIImageView*)[cellDetail viewWithTag:100];
    [shopImg01 setImageWithURL:[NSURL URLWithString:[data objectForKey:@"shopImg1"]] placeholderImage:[UIImage imageNamed:@"delay_nophoto91.png"]];
    [shopImg01.layer setCornerRadius:10.0f];
    
    
    UIImageView* shopImg02 = (UIImageView*)[cellDetail viewWithTag:101];
    [shopImg02 setImageWithURL:[NSURL URLWithString:[data objectForKey:@"shopImg2"]] placeholderImage:[UIImage imageNamed:@"delay_nophoto91.png"]];
    [shopImg02.layer setCornerRadius:10.0f];
    
    UIImageView* shopImg03 = (UIImageView*)[cellDetail viewWithTag:102];
    [shopImg03 setImageWithURL:[NSURL URLWithString:[data objectForKey:@"shopImg3"]] placeholderImage:[UIImage imageNamed:@"delay_nophoto91.png"]];
    [shopImg03.layer setCornerRadius:10.0f];
    
    shopInfoTextView.text = promoText;
}

#pragma mark - Table view data source / delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 0.0f;
    switch (indexPath.row) {
        case 0:
        {
            if (poiInfoResult) {
                float aHeight = 59.0f;
                float poiNameOriginY = 37.0f;
                float addressOriginY = 62.0f;
                NSString* poiName = [poiInfoResult objectForKey:@"poiName"];
                if (![poiName isEqualToString:@""]) {
                    CGSize poiNameSize = [poiName sizeWithFont:[UIFont systemFontOfSize:18] constrainedToSize:CGSizeMake(252, 44) lineBreakMode:UILineBreakModeCharacterWrap];
                    poiNameSize.width = 252; // 사이즈 너비 값을 구지 줄일 필요 없음. helvetica bold에서 줄이 늘어나는 문제 발생되어 수정함.
                    addressOriginY = poiNameOriginY + poiNameSize.height + 5;
                    CGRect aRect = poiNameLabel.frame;
                    aRect.size = poiNameSize;
                    [poiNameLabel setFrame:aRect];
                }
                    
                NSString* address = [NSString stringWithFormat:@"%@ %@ %@", 
                                     [poiInfoResult objectForKey:@"addr1"],
                                     [poiInfoResult objectForKey:@"addr2"],
                                     [poiInfoResult objectForKey:@"addr3"]];
                if (![address isEqualToString:@""]) {
                    CGSize aSize = [address sizeWithFont:[UIFont systemFontOfSize:13] constrainedToSize:CGSizeMake(252, 30)];
                    CGRect aRect = addressLabel.frame;
                    aRect.size = aSize;
                    aRect.origin.y = addressOriginY;
                    [addressLabel setFrame:aRect];
                    aHeight = addressOriginY + aSize.height + 5;
                }
                
                NSString* shopIntro = [poiInfoResult objectForKey:@"shopIntro"];
                if (![shopIntro isEqualToString:@""]) {
                    CGSize aSize = [shopIntro sizeWithFont:[UIFont systemFontOfSize:12] constrainedToSize:CGSizeMake(252, 200)];
                    CGRect aRect = introMsgLabel.frame;
                    aRect.origin.y = aHeight;
                    aRect.size = aSize;
                    [introMsgLabel setFrame:aRect];
                    aHeight += aSize.height + 5;
                }
                return aHeight;
            }
            height = 0.0f;
            break;
        }
        case 1:
            height = 122.0f;
            break;
        case 2:
            height = 29.0f;
            break;
        case 3:
        {
            NSMutableString* promoText = [NSMutableString stringWithCapacity:500];
            
            if (poiInfoResult) {
                
                float aHeight = 153.0f; // 프로모션 시작점
                
                NSString* srvIntro = [poiInfoResult objectForKey:@"svcIntro"];
                if (srvIntro && ![srvIntro isEqualToString:@""]) {
                    CGSize aSize = [srvIntro sizeWithFont:[UIFont systemFontOfSize:13] constrainedToSize:CGSizeMake(268, 100)];
                    
                    CGRect aRect = promotionLabel.frame;
                    aRect.origin.y = aHeight;
                    aRect.size = aSize;
                    promotionLabel.frame = aRect;
                    
                    aHeight += aSize.height + 10;
                }
                
                NSString* tmp = [poiInfoResult objectForKey:@"shopOpen"];
                
                if (tmp && ![tmp isEqualToString:@""]) {
                    [promoText appendFormat:@"▪이용시간: %@\n", tmp];
                }
                
                tmp = [poiInfoResult objectForKey:@"shopClose"];
                
                if (tmp && ![tmp isEqualToString:@""]) {
                    [promoText appendFormat:@"▪휴무일: %@\n", tmp];
                }
                
                tmp = [poiInfoResult objectForKey:@"shopRoute"];
                
                if (tmp && ![tmp isEqualToString:@""]) {
                    [promoText appendFormat:@"▪%@\n", tmp];
                }
                
                tmp = [poiInfoResult objectForKey:@"shopParking"];
                
                if (tmp && ![tmp isEqualToString:@""]) {
                    [promoText appendFormat:@"▪주차: %@\n", tmp];
                }
                
                
                MY_LOG(@"1:shopInfoView = %@", NSStringFromCGRect(shopInfoView.frame));
                if (![promoText isEqualToString:@""]) {
                    CGSize aSize = [promoText sizeWithFont:[UIFont systemFontOfSize:12.0f] constrainedToSize:CGSizeMake(268, 134) lineBreakMode:UILineBreakModeWordWrap];
                    MY_LOG(@"promoText[%@] size = %@", promoText, NSStringFromCGSize(aSize));
                    aSize.height += 30;
                    
                    CGRect aRect = shopInfoView.frame;
                    aRect.origin.y = aHeight;
                    aRect.size = aSize;
                    
                    shopInfoView.frame = aRect;
                    
                    aHeight += aSize.height;
                }
                MY_LOG(@"2:shopInfoView = %@", NSStringFromCGRect(shopInfoView.frame));
                MY_LOG(@"3:height = %f", aHeight);
                return aHeight;
            }
            height = 0.0f;
            break;
        }
        case 4:
            height = 16.0f;
            break;
        case 5:
            height = 72.0f;
            break;
        default:
            break;
    }
    return height;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 6;
}

/**
 @brief Using Custom TableViewCell xib files
 */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    switch (indexPath.row) {
        case 0:
            cell = [tableView dequeueReusableCellWithIdentifier:@"cellGeneral"];
            if (cell == nil) {
                cell = cellGeneral;
            }
            break;

        case 1:
            cell = [tableView dequeueReusableCellWithIdentifier:@"cellMap"];
            if (cell == nil) {
                cell = cellMap;
            }
            break;

        case 2:
            cell = [tableView dequeueReusableCellWithIdentifier:@"cellCoverTop"];
            if (cell == nil) {
                cell = cellCoverTop;
            }
            break;
            
        case 3:
            cell = [tableView dequeueReusableCellWithIdentifier:@"cellDetail"];
            if (cell == nil) {
                cell = cellDetail;
                [cell.contentView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"poisang_rbox_middle.png"]]];
            }
            break;
            
        case 4:
            cell = [tableView dequeueReusableCellWithIdentifier:@"cellCoverBottom"];
            if (cell == nil) {
                cell = cellCoverBottom;
            }
            break;
            
        case 5:
            cell = [tableView dequeueReusableCellWithIdentifier:@"cellReportButton"];
            if (cell == nil) {
                cell = cellReportButton;
            }
            break;
            
        default:
            cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
            if (cell == nil) {
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"] autorelease];
            }
            break;
    }
    
    // Configure the cell...
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     */
}


#pragma mark - ImIn Protocol
/// @brief POI신고
- (void) requestPolice
{
	if (poiKey == nil) return;
    
    PoiPolice* poiPolice = [[PoiPolice alloc] init];
    poiPolice.delegate = self;
    [poiPolice.params addEntriesFromDictionary:[NSDictionary dictionaryWithObjectsAndKeys:@"더 이상 영업하지 않는 곳입니다.", @"msg", poiKey, @"poiKey", nil]];
    [poiPolice request];
}

/**
 @brief request 결과 Success
 @param a NSDictionary result for api
 @param a NSObject to be released
 */
- (void) apiDidLoadWithResult:(NSDictionary *)result whichObject:(NSObject *)theObject
{
    if ([[result objectForKey:@"func"] isEqualToString:@"poiInfoDetail"]) {
        MY_LOG(@"%@", result);
        self.poiInfoResult = result;
        [self redrawUIWithDictionary:poiInfoResult];
        [mainTableView reloadData];
    }
    
    if ([[result objectForKey:@"func"] isEqualToString:@"poiPolice"]) {
        if ([[result objectForKey:@"result"] boolValue]) {
            [CommonAlert alertWithTitle:@"에러" message:@"장소에 대한 신고가\n완료되었습니다."];
            [self popVC:nil];
        } else {
            [CommonAlert alertWithTitle:@"에러" message:[result objectForKey:@"description"]];
        }
        [theObject release];
    }
}

/**
 @brief request 결과 Fail
 @param a object to be released
 */
- (void) apiFailedWhichObject:(NSObject *)theObject
{
    if ([NSStringFromClass([theObject class]) isEqualToString:@"PoiPolice"]) {
        [theObject release];
    }
}

#pragma mark - UIButton Actions
/**
 @brief 버튼 클릭 시
 @return IBAction
 */
- (IBAction)popVC:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)goReportVC:(id)sender {
    GA3(@"POI상세정보", @"틀린정보신고하기", @"POI상세정보내");
    UIActionSheet* selectionSheet = [[[UIActionSheet alloc]
                                      initWithTitle:nil 
                                      delegate:self 
                                      cancelButtonTitle:@"취소" 
                                      destructiveButtonTitle:nil
                                      otherButtonTitles:@"더이상 영업하지 않는 곳",@"장소 명칭 정정", @"사실과 다른 관련 정보", nil] autorelease];
	[selectionSheet showInView:self.view.window];
}

- (IBAction)openHomepage:(id)sender {
    GA3(@"POI상세정보", @"홈페이지주소", @"POI상세정보내");
    CommonWebViewController* vc = [[[CommonWebViewController alloc] initWithNibName:@"CommonWebViewController" bundle:nil] autorelease];
    vc.urlString = [poiInfoResult objectForKey:@"shopHome"];
    vc.viewType = BOTTOM;
    
    [self presentModalViewController:vc animated:YES];
}

- (IBAction)openPhonecall:(id)sender {
    GA3(@"POI상세정보", @"전화버튼", @"POI상세정보내");
    NSString* telStr = [poiInfoResult objectForKey:@"shopPhoneNo"];
	if([[[UIDevice currentDevice] systemVersion] doubleValue] < 4.0) {
		UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"알림" message:@"지금 전화를 거시겠어요?\n아임IN 앱은 종료됩니다 "
                                                        delegate:self cancelButtonTitle:@"취소" otherButtonTitles:@"확인", nil] autorelease];
		alert.tag = 200;
		[alert show];
	} else {
		NSString* tel = [NSString stringWithFormat:@"tel:%@",telStr];
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:tel]];
	}

}

- (IBAction)openLargeMap:(id)sender {    
    GA3(@"POI상세정보", @"지도보기", @"POI상세정보내");
    GoogleMapViewController* mapVC = [[[GoogleMapViewController alloc] init] autorelease];
    mapVC.mapInfo = poiInfoResult;
    
    [mapVC setHidesBottomBarWhenPushed:YES];
    
    [(UINavigationController*)[ViewControllers sharedViewControllers].tabBarController.selectedViewController pushViewController:mapVC animated:YES];

}

- (IBAction)openPhoto:(id)sender {
    GA3(@"POI상세정보", @"브랜드사진", @"POI상세정보내");
    int tag = [sender tag];
    int index = tag - 200;
    NSString* imgUrl = nil;
    switch (index) {
        case 0:
            imgUrl = [poiInfoResult objectForKey:@"shopImg1"];
            break;
        case 1:
            imgUrl = [poiInfoResult objectForKey:@"shopImg2"];
            break;
        case 2:
            imgUrl = [poiInfoResult objectForKey:@"shopImg3"];
            break;
        default:
            break;
    }
    
    if (imgUrl && ![imgUrl isEqualToString:@""]) {
        PictureViewController* zoomingViewController = [[PictureViewController alloc] initWithNibName:@"PictureViewController" bundle:nil];
        [zoomingViewController setPictureURL:imgUrl];
        [zoomingViewController setHidesBottomBarWhenPushed:YES];
        [(UINavigationController*)[ViewControllers sharedViewControllers].tabBarController.selectedViewController pushViewController:zoomingViewController animated:NO];
        [zoomingViewController release];
    }
}

#pragma mark - < delegate >
#pragma mark MKMapView
- (MKAnnotationView *) mapView:(MKMapView *) mapView viewForAnnotation:(id ) annotation {
	MKPinAnnotationView *customPinView = [[[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:nil] autorelease];
    customPinView.animatesDrop = YES;
    
	return customPinView;
}

#pragma mark UIAlertView
- (void)alertView:(UIAlertView*)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (alertView.tag == 200 & buttonIndex == 1)
	{
        NSString* telStr = [poiInfoResult objectForKey:@"shopPhoneNo"];
		NSString* tel = [NSString stringWithFormat:@"tel:%@",telStr];
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:tel]];		
	}
}

#pragma mark UIActionsheet
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (buttonIndex == 3) return;
	if (buttonIndex == 0) [self requestPolice]; // 영업하지 않는곳
	
	if (buttonIndex == 1)
	{
		UIPoiPoliceWriteViewController* pv = [[UIPoiPoliceWriteViewController alloc] initWithNibName:@"UIPoiPoliceWriteViewController" bundle:nil];
		
		[pv setPoiId:poiKey];
		[pv setPreString:@"장소 명칭 정정"];
		[(UINavigationController*)[ViewControllers sharedViewControllers].tabBarController.selectedViewController pushViewController:pv animated:YES];
		[pv release];
	}
	if (buttonIndex == 2)
	{
		UIPoiPoliceWriteViewController* pv = [[UIPoiPoliceWriteViewController alloc] initWithNibName:@"UIPoiPoliceWriteViewController" bundle:nil];
		[pv setPoiId:poiKey];
		[pv setPreString:@"사실과 다른 관련 정보"];
		[(UINavigationController*)[ViewControllers sharedViewControllers].tabBarController.selectedViewController pushViewController:pv animated:YES];
		[pv release];
	}
}
@end
