//
//  NoListInfoView.m
//  ImIn
//
//  Created by 태한 김 on 10. 6. 17..
//  Copyright 2010 kth. All rights reserved.
//

#import "NoListInfoView.h"
#import "macro.h"

@implementation NoListInfoView

@synthesize label1, label2, faceImgView;

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
		label1 = [[UILabel alloc]initWithFrame:CGRectMake(130, (frame.size.height/2)-12 , 200, 14)];
		label2 = [[UILabel alloc]initWithFrame:CGRectMake(130, (frame.size.height/2)+5 , 200, 14)];
		[label1 setFont:[UIFont fontWithName:@"Helvetica" size:12.0]];
		[label2 setFont:[UIFont fontWithName:@"Helvetica" size:12.0]];
		[label1 setBackgroundColor:[UIColor clearColor]];
		[label2 setBackgroundColor:[UIColor clearColor]];
		[label1 setTextColor:[UIColor darkGrayColor]];
		[label2 setTextColor:[UIColor darkGrayColor]];

		/*if( frame.size.height < 350 )
		{	// 화면이 작을때
			faceImgView = [[UIImageView alloc]initWithFrame:CGRectMake(80, (frame.size.height/2)-15, 38, 44)];
			[faceImgView setImage:[UIImage imageNamed:@"main_noreply_icon_small.png"]];
		}else { */
			// 화면이 클때
			faceImgView = [[UIImageView alloc]initWithFrame:CGRectMake(120, (frame.size.height/2)-50, 78, 88)];
			[faceImgView setImage:[UIImage imageNamed:@"main_noreply_icon.png"]];
        			
			[label1 setFrame:CGRectMake(0, (frame.size.height/2)+45, 320, 14)];
			[label2 setFrame:CGRectMake(0, (frame.size.height/2)+63, 320, 14)];
			[label1 setTextAlignment:UITextAlignmentCenter];
			[label2 setTextAlignment:UITextAlignmentCenter];
		//}

		self.backgroundColor = RGB(242,242,242);
		[self addSubview:label1];
		[self addSubview:label2];
		[self addSubview:faceImgView];
    }
    return self;
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/


- (void)dealloc {
	if (label1 != nil)
		[label1 release];
	if (label2 != nil)
		[label2 release];
	[faceImgView release];
    [super dealloc];
}

-(void) removeInfoViewFromSuperview
{
	[self removeFromSuperview];
}

@end
