//
//  EventCell.m
//  ImIn
//
//  Created by ja young park on 11. 9. 29..
//  Copyright 2011년 __MyCompanyName__. All rights reserved.
//

#import "EventCell.h"
#import <QuartzCore/QuartzCore.h>
#import "macro.h"

@implementation EventCell

#define EVENTSTRING_HEIGHT  18

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
    }
    return self;
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [super setHighlighted:highlighted animated:animated];
    
    if(highlighted) {
        [eventBg setImage:[UIImage imageNamed:@"evt_bg_on.png"]];
    } else {
        [eventBg setImage:[UIImage imageNamed:@"evt_bg.png"]];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
	UIView* bgView = [[UIView alloc] initWithFrame:self.frame];
	CAGradientLayer *gradient = [CAGradientLayer layer];
	gradient.frame = bgView.bounds;
	gradient.colors = [NSArray arrayWithObjects:(id)[RGB(214, 241, 248) CGColor], (id)[RGB(178, 229, 241) CGColor], nil];
	[bgView.layer insertSublayer:gradient atIndex:0];
	self.selectedBackgroundView = bgView;
	[bgView release];
//    [super setSelected:selected animated:animated];
//
//    if(selected) {
//        [eventBg setImage:[UIImage imageNamed:@"evt_bg_on.png"]];
//    } else {
//        [eventBg setImage:[UIImage imageNamed:@"evt_bg.png"]];
//    }
    // Configure the view for the selected state
}

- (void)dealloc {	

	[eventBg release];
    [seperator release];
    [eventIcon release];
	[super dealloc];
}

- (void) redrawEventCellWithCellData: (NSDictionary*) eventCellData : (NSInteger)totalEventCnt {
    //if ( totalEventCnt < 2 ) {// 이벤트가 한개 이하다.
    if ( 0 < totalEventCnt && totalEventCnt < 2 ) {// 이벤트가 한개 이하다.
        eventNumBg.hidden = YES;
        eventNum.hidden = YES;
        eventString.text = [eventCellData objectForKey:@"eventCopy"];
//        CGSize textSize = [eventString.text sizeWithFont:[UIFont fontWithName:@"helvetica" size:14.0f] forWidth:246.0f lineBreakMode:UILineBreakModeWordWrap];
//        NSUInteger lineCnt = (int)(textSize.height / 14.0f);
        
        float eventStringHeight = 0.0f;
        eventStringHeight = [Utils getWrapperSizeWithLabel:eventString fixedWidthMode:YES fixedHeightMode:NO].height;

        
        if (eventStringHeight > EVENTSTRING_HEIGHT) {
            
            CGRect lineframe = seperator.frame;
            lineframe.origin.y = 58.0f;
            seperator.frame = lineframe;
            CGRect textframe = eventString.frame;
            textframe.size.height = 59.0f;
            eventString.frame = textframe;
            
            CGRect iconframe = eventIcon.frame;
            iconframe.origin.y = 21.0f;
            eventIcon.frame = iconframe;
        } else {
            CGRect lineframe = seperator.frame;
            lineframe.origin.y = 42.0f;
            seperator.frame = lineframe;
            CGRect textframe = eventString.frame;
            textframe.size.height = 43.0f;
            eventString.frame = textframe;
            
            CGRect iconframe = eventIcon.frame;
            iconframe.origin.y = 13.0f;
            eventIcon.frame = iconframe;      
        }
    } else {
        eventString.text = @"주변에서 진행중인 이벤트";
        eventNumBg.hidden = NO;
        eventNum.hidden = NO;
        eventNum.text = [NSString stringWithFormat:@"%d", totalEventCnt];
    }
}

- (void) redrawEventCellWithCellData: (NSDictionary*) eventCellData {
    eventNumBg.hidden = YES;
    eventNum.hidden = YES;
    eventString.text = [eventCellData objectForKey:@"eventCopy"];
    
    CGRect lineframe = seperator.frame;
    lineframe.origin.y = 58.0f;
    seperator.frame = lineframe;
    CGRect textframe = eventString.frame;
    textframe.size.height = 59.0f;
    eventString.frame = textframe;
    
    CGRect iconframe = eventIcon.frame;
    iconframe.origin.y = 21.0f;
    eventIcon.frame = iconframe;
}

@end
