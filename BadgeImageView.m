//
//  BadgeImageView.m
//  ImIn
//
//  Created by Myungjin Choi on 11. 2. 21..
//  Copyright 2011 KTH. All rights reserved.
//

#import "BadgeImageView.h"
#import "BadgeDetailView.h"

#define DOUBLE_TAP_DELAY 0.35

@interface BadgeImageView ()
- (void)handleSingleTap;
- (void)handleDoubleTap;
@end

@implementation BadgeImageView
//@synthesize delegate;
@synthesize badgeData;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setUserInteractionEnabled:YES];
        [self setMultipleTouchEnabled:NO];
    }
    return self;
}

- (void) awakeFromNib {
	[self setUserInteractionEnabled:YES];
	[self setMultipleTouchEnabled:NO];
}

- (void) dealloc {
	[badgeData release];
	[super dealloc];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch *touch = [touches anyObject];
	tapLocation = [touch locationInView:self];	
	
	if ([touch tapCount] == 1) {
		[self performSelector:@selector(handleSingleTap) withObject:nil afterDelay:DOUBLE_TAP_DELAY];
	} else if([touch tapCount] == 2) {
		[self handleDoubleTap];
	}
}

#pragma mark Private

- (void)handleSingleTap {
	
	CGPoint centerPoint = [self.superview convertPoint:self.center toView:nil];
	NSValue* center = [NSValue valueWithCGPoint:centerPoint];
	
	NSMutableDictionary* aData = [NSMutableDictionary dictionaryWithDictionary:badgeData];
	[aData addEntriesFromDictionary:[NSDictionary dictionaryWithObjectsAndKeys:center, @"startPoint", nil]];
	[[NSNotificationCenter defaultCenter] postNotificationName:BADGE_IMAGE_TAPPED_NOTIFICATION object:self userInfo:aData];
}

- (void)handleDoubleTap {
}

@end
