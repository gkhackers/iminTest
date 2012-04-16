//
//  POIListCell.m
//  ImIn
//
//  Created by choipd on 10. 5. 3..
//  Copyright 2010 edbear. All rights reserved.
//

#import "POIListCell.h"
#import "ViewControllers.h"
#import "macro.h"
#import "UIImageView+WebCache.h"
#import <QuartzCore/QuartzCore.h>
#import "POIDetailViewController.h"
#import "POIListViewController.h"

@implementation POIListCell
@synthesize categoryIcon;
@synthesize poiData;
@synthesize currSelectedTabInt;
@synthesize vcDelegate;
@synthesize currPostWriteFlow;

//@synthesize isPoiList;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        // Initialization code
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
    [super setSelected:selected animated:animated];
	
	UIView* bgView = [[UIView alloc] initWithFrame:self.frame];
	CAGradientLayer *gradient = [CAGradientLayer layer];
	gradient.frame = bgView.bounds;
	gradient.colors = [NSArray arrayWithObjects:(id)[RGB(214, 241, 248) CGColor], (id)[RGB(178, 229, 241) CGColor], nil];
	[bgView.layer insertSublayer:gradient atIndex:0];
	self.selectedBackgroundView = bgView;
	[bgView release];
    // Configure the view for the selected state
}


- (void)dealloc {
    vcDelegate = nil;
    [categoryIcon release];
    [poiData release];
	[super dealloc];
}

- (void) populateCellWithData:(NSDictionary*) aData {
    self.poiData = aData;
    
    if (currPostWriteFlow == NEW_POSTFLOW) {
        [goBtn setImage:[UIImage imageNamed:@"icon_map.png"] forState:UIControlStateNormal];
    } else {
        [goBtn setImage:[UIImage imageNamed:@"btn_poi_home.png"] forState:UIControlStateNormal];
    }
    
    poiName.frame = CGRectMake(55, 12, 220, 20);
	poiName.text = [aData objectForKey:@"poiName"];
    
    
    NSString* imgUrl;
    
    //if (isPoiList && [Utils isBrandUser:aData]) { // poi리스트면서 브랜드면 프로필이미지를
    if ([Utils isBrandUser:aData]) { // 브랜드면 프로필이미지를
        imgUrl = [aData objectForKey:@"profileImg"];
        [categoryIcon setImageWithURL:[NSURL URLWithString:imgUrl] placeholderImage:[UIImage imageNamed:@"delay_nosum70.png"]];
    } else { // poi리스트인데 비 브랜드거나 로컬리스트면 카테고리 이미지를
        imgUrl = [aData objectForKey:@"categoryImg"];
        //70이미지 38로 변경
        imgUrl = [Utils convertImgSize70to38:imgUrl];
        [categoryIcon setImageWithURL:[NSURL URLWithString:imgUrl] placeholderImage:[UIImage imageNamed:@"9000000_38x38_2@2x.png"]];
    }
    
    //MY_LOG(@"imgUrl = %@", imgUrl);
    
    
    BOOL isEvent = 	([aData objectForKey:@"evtId"] && ![[aData objectForKey:@"evtId"] isEqualToString:@""]) || [[aData objectForKey:@"isEvent"] isEqualToString:@"1"];
	if (!isEvent) {		
		eventIcon.hidden = YES;
	} else {  //제목 Label의 가로 길이는 원래 242 -> 220, 그치만 이벤트 아이콘이 붙어야 할 경우엔 이벤트 아이콘 가로 사이즈를 여유있게 빼야 한다. 그래서 아이콘이 붙을 때는 220 -> 198으로 처리
		poiName.frame = CGRectMake(poiName.frame.origin.x,
								   poiName.frame.origin.y,
								   198, poiName.frame.size.height);
		
		CGSize size = [poiName.text sizeWithFont:poiName.font];
		if(size.width <= 198) {// 라벨사이즈의 넓이가 한계치보다 작거나 같으면
			poiName.frame = CGRectMake(poiName.frame.origin.x,
									   poiName.frame.origin.y,
									   size.width, poiName.frame.size.height);
		}
		
		CGRect frame = eventIcon.frame;
		frame.origin.x = poiName.frame.origin.x + poiName.frame.size.width + 3;
		eventIcon.frame = frame;
        
		eventIcon.hidden = NO;
	}	
    
    MY_LOG(@"poiName = %@", poiName);
    
	NSString* distanceString = @"";
	int distance = 0;
	if ([aData objectForKey:@"distance"]) {
		distance = [[aData objectForKey:@"distance"] intValue];
	} else { // distance가 존재하지 않음.
		CGPoint aPoint = CGPointMake([[aData objectForKey:@"pointX"] floatValue], [[aData objectForKey:@"pointY"] floatValue]);
		distance = (int)[Utils getDistanceToHereFrom:aPoint];
	}
    
	if (distance > 1000) {
		distanceString = [NSString stringWithFormat:@"%dkm", (int)(distance / 1000)];
	} else {
		distanceString = [NSString stringWithFormat:@"%dm", distance];
	}		
	
	int totalPoiCnt = [[aData objectForKey:@"totalPoiCnt"] intValue];
    
	NSString* address = [NSString stringWithFormat:@"%@ %@ %@", [aData objectForKey:@"addr1"],
						 [aData objectForKey:@"addr2"],
						 [aData objectForKey:@"addr3"]];
    addr.text = address;
    
    if (totalPoiCnt < 1) {
        description.text = [NSString stringWithFormat:@"%@", distanceString];
    } else {
        description.text = [NSString stringWithFormat:@"%@ | ", distanceString];
    }
    
    CGSize decriptionSize = [description.text sizeWithFont:description.font];
    
    if (totalPoiCnt < 1) {
        footIcon.hidden = YES;
        poiCnt.hidden = YES;
    } else {
        footIcon.hidden = NO;
        poiCnt.hidden = NO;
        
        CGRect frame = footIcon.frame;
        frame.origin.x = description.frame.origin.x + decriptionSize.width + 4;
        footIcon.frame = frame;
        
        frame = poiCnt.frame;
        frame.origin.x = footIcon.frame.origin.x + footIcon.frame.size.width + 5;
        
        poiCnt.frame = frame;
        
        poiCnt.text = [NSString stringWithFormat:@"%d", totalPoiCnt];
    }
}

- (IBAction)poiGoHome:(id)sender {
    if (currPostWriteFlow == NEW_POSTFLOW) {
        if (currSelectedTabInt == 1) {
            GA3(@"발도장찍을장소", @"장소지도가기버튼", @"가본장소_발도장내");
        } else {
            GA3(@"발도장찍을장소", @"장소지도가기버튼", @"주변장소_발도장내");
        }
        
        [(POIListViewController*)vcDelegate goPoiDetail:poiData];
    } else {
        NSString* userType = [poiData objectForKey:@"userType"];
        NSString* bizType = [poiData objectForKey:@"bizType"];
        NSString* gaText = nil;
        
        if (currSelectedTabInt == 1) {
            gaText = @"가본장소_발도장내";
        } else {
            gaText = @"주변장소_발도장내";
        }
        
        if (([poiData objectForKey:@"evtId"] && ![[poiData objectForKey:@"evtId"] isEqualToString:@""]) || [[poiData objectForKey:@"isEvent"] isEqualToString:@"1"]) { //이벤트
            if (([bizType isEqualToString:@"BT0001"] || [bizType isEqualToString:@"BT0002"]) && [userType isEqualToString:@"UB0001"]) { //브랜드 이벤트
                GA3(@"발도장찍을장소", @"브랜드이벤트화살표", gaText);
            } else if ([bizType isEqualToString:@"BT0001"] || [bizType isEqualToString:@"BT0002"]) { //브랜드 이벤트
                GA3(@"발도장찍을장소", @"브랜드이벤트화살표", gaText);
            } else if ([bizType isEqualToString:@"BT0003"]) { //소상공인 이벤트
                GA3(@"발도장찍을장소", @"주인장이벤트화살표", gaText);
            } else { //일반 이벤트
                GA3(@"발도장찍을장소", @"화살표", gaText);
            }
        } else { //이벤트가 아닌 POI
            GA3(@"발도장찍을장소", @"화살표", gaText);
        }
        
        POIDetailViewController *detailViewController = [[[POIDetailViewController alloc] initWithNibName:@"POIDetailViewController" bundle:nil] autorelease];
        detailViewController.poiData = poiData;
        
        [(UINavigationController*)[ViewControllers sharedViewControllers].tabBarController.selectedViewController pushViewController:detailViewController animated:YES];
        if ([(POIListViewController*)vcDelegate respondsToSelector:@selector(dismissModalViewControllerAnimated)]) {
            [NSTimer scheduledTimerWithTimeInterval:0.1 target:vcDelegate selector:@selector(dismissModalViewControllerAnimated) userInfo:nil repeats:NO];
        }
    }
}

@end
