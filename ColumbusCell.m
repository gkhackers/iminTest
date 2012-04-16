//
//  ColumbusCell.m
//  ImIn
//
//  Created by park ja young on 11. 2. 9..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ColumbusCell.h"
#import "UIImageView+WebCache.h"
#import "UIHomeViewController.h"
#import "BrandHomeViewController.h"
@implementation ColumbusCell

@synthesize profileImage, nickname, writeDate, areaBtn, noColumbus, columbusImg;
@synthesize cellData;
@synthesize columbusProfileImgURL, snsID;
@synthesize preColumbusInfo;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {

		    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state.
}


- (void)dealloc {	
	[profileImage release];
	[nickname release];
	[writeDate release];
	[areaBtn release];
	[cellData release];
	[noColumbus release];
	[columbusProfileImgURL release];
	[snsID release];
	[preColumbusInfo release];
	[columbusImg release];
	
	[super dealloc];
}

- (void) redrawColumbusCellWithCellData: (NSDictionary*) columbusCellData : (NSInteger)isRequestDone {
	switch (isRequestDone) {
		case 0:
			if([columbusCellData count] > 0)
			{
				preColumbusInfo.hidden = YES;
				profileImage.hidden = NO;
				columbusImg.hidden = NO;
				areaBtn.hidden = NO;
				
				self.cellData = columbusCellData;
				if ([[columbusCellData objectForKey:@"status"] isEqualToString:@"0"]) { //유저가 탈퇴한 경우
					MY_LOG(@"콜럼버스인 유저가 회원탈퇴한 경우");
					isColumbus = FALSE;
					noColumbus.hidden = NO;
					nickname.hidden = YES;
					writeDate.hidden = YES;
					noColumbus.text = @"콜럼버스가 떠나셨어요~";
				}
				else {
					if ([[columbusCellData objectForKey:@"isDel"] isEqualToString:@"1"]) {
						MY_LOG(@"콜럼버스가 삭제 된 경우");
						isColumbus = FALSE;
						// 콜럼버스가 삭제된 경우
						noColumbus.hidden = NO;
						nickname.hidden = YES;
						writeDate.hidden = YES;
						noColumbus.text = @"콜럼버스가 떠나셨습니다.";
					} else {
						MY_LOG(@"콜럼버스가 정상인 경우");
						// 콜럼버스가 정상인 경우
						isColumbus = TRUE;
						self.snsID = [columbusCellData objectForKey:@"snsId"];
						NSString* columbusName = [columbusCellData objectForKey:@"nickname"];
						
						MY_LOG(@"self.snsID = %@, columbusName = %@", self.snsID, columbusName);
						nickname.text = columbusName;
						
						CGRect columbusFrame = nickname.frame;
						CGSize columbusSize = [columbusName sizeWithFont: nickname.font
													   constrainedToSize: columbusFrame.size
														   lineBreakMode: UILineBreakModeWordWrap];
						NSInteger intervalWidth = 5;
						columbusFrame.size.width = columbusSize.width + intervalWidth;
						
						nickname.frame = columbusFrame;
						CGRect foundDateFrame = writeDate.frame;
						foundDateFrame.origin.x = columbusFrame.origin.x + columbusFrame.size.width;
						writeDate.frame = foundDateFrame;
						
						self.columbusProfileImgURL = [columbusCellData objectForKey:@"profileImg"];
						[profileImage setImageWithURL:[NSURL URLWithString:columbusProfileImgURL]
									 placeholderImage:[UIImage imageNamed:@"delay_nosum70.png"]];
						
						
						NSString* registerDate = [columbusCellData objectForKey:@"regDate"];
						writeDate.text = [NSString stringWithFormat:@"(Since %@)", [Utils getSimpleDateWithString:registerDate]];		
						nickname.hidden = NO;
						writeDate.hidden = NO;
						noColumbus.hidden = YES;			
					}
				}
			}
			else {
				MY_LOG(@"콜럼버스가 없는 경우");
				preColumbusInfo.hidden = YES;
				profileImage.hidden = NO;
				columbusImg.hidden = NO;
				areaBtn.hidden = NO;
				
				isColumbus = FALSE;
				noColumbus.hidden = NO;
				nickname.hidden = YES;
				writeDate.hidden = YES;
				noColumbus.text = @"첫 발도장을 찍어 콜럼버스가 되보세요~";
			}		
			
			break;
		case 1:
			profileImage.hidden = YES;
			columbusImg.hidden = YES;
			nickname.hidden = YES;
			writeDate.hidden = YES;
			areaBtn.hidden = YES;
			preColumbusInfo.text = @"네트웍 오류입니다.";
			preColumbusInfo.hidden = NO;
			
			break;
		case 2:
			profileImage.hidden = YES;
			columbusImg.hidden = YES;
			nickname.hidden = YES;
			writeDate.hidden = YES;
			areaBtn.hidden = YES;
			preColumbusInfo.text = @"콜럼버스를 로딩중이예요~~";
			preColumbusInfo.hidden = NO;
			
			break;
		default:
			break;
	}
}

- (IBAction) columbusCellClicked {
	if (isColumbus) {
		MY_LOG(@"콜럼버스 영역 클릭 => %@,", snsID);
		
		GA3(@"POI", @"콜럼버스영역", nil);
		
		MemberInfo* owner = [[[MemberInfo alloc] init] autorelease];
		owner.snsId = snsID;
		owner.nickname = nickname.text;
		owner.profileImgUrl = columbusProfileImgURL;	

        if ([Utils isBrandUser:cellData]) { //브랜드면
            BrandHomeViewController* vc = [[[BrandHomeViewController alloc] initWithNibName:@"BrandHomeViewController" bundle:nil] autorelease];
            vc.owner = owner;
            [(UINavigationController*)[ViewControllers sharedViewControllers].tabBarController.selectedViewController pushViewController:vc animated:YES];        
            
        } else {
            UIHomeViewController *vc = [[[UIHomeViewController alloc] initWithNibName:@"UIHomeViewController" bundle:nil] autorelease];
            vc.owner = owner;
            [(UINavigationController*)[ViewControllers sharedViewControllers].tabBarController.selectedViewController pushViewController:vc animated:YES];        
        }
	}
	else {
		MY_LOG (@"is Columbus False");
	}

}

@end
