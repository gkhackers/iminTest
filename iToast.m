//
//  iToast.m
//  iToast
//
//  Created by Diallo Mamadou Bobo on 2/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//  Modified by Kyongjin Seo on 3/2012.

#import "iToast.h"
#import <QuartzCore/QuartzCore.h>

static iToastSettings *sharedSettings = nil;

@interface iToast(private)

- (iToast *) settings;

@end


@implementation iToast


- (id) initWithText:(NSString *) tex{
	if (self = [super init]) {
		text = [tex copy];
	}
	
	return self;
}

- (void) show{
	
	iToastSettings *theSettings = _settings;
	
	if (!theSettings) {
		theSettings = [iToastSettings getSharedSettings];
	}
    
    UIFont *font = [UIFont fontWithName:@"Helvetica" size:14.0];

	CGSize textSize = [text sizeWithFont:font constrainedToSize:CGSizeMake(200, 60)];
	    
	UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 70, textSize.width + 15, textSize.height + 5)];
	label.backgroundColor = [UIColor clearColor];
	label.textColor = [UIColor whiteColor];
    label.textAlignment = UITextAlignmentCenter;
	label.font = font;
	label.text = text;
	label.numberOfLines = 3;
	//label.shadowColor = [UIColor darkGrayColor];
	//label.shadowOffset = CGSizeMake(1, 1);
    
	UIButton *v = [UIButton buttonWithType:UIButtonTypeCustom];
	v.frame = CGRectMake(0, 0, textSize.width + 30, 150);
	label.center = CGPointMake(v.frame.size.width / 2, v.frame.size.height / 2 + 30.0f);
	[v addSubview:label];
    [label release];
	
    UILabel *topLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, v.frame.size.width, 60.0f)];
    topLabel.text = @"!";
    topLabel.textColor = [UIColor whiteColor];
    topLabel.textAlignment = UITextAlignmentCenter;
    topLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:60.0];
    topLabel.backgroundColor = [UIColor clearColor];
    topLabel.center =  CGPointMake(v.frame.size.width / 2, v.frame.size.height / 2 - 30.0f);
    [v addSubview:topLabel];
    [topLabel release];
    
	v.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
	v.layer.cornerRadius = 5;
	
	UIWindow *window = [[[UIApplication sharedApplication] windows] objectAtIndex:0];
	
//	CGPoint point = CGPointMake(window.frame.size.width/2, window.frame.size.height/2);
    CGPoint point = CGPointZero;	
    
	if (theSettings.gravity == iToastGravityTop) {
		point = CGPointMake(window.frame.size.width / 2, 160);
	}else if (theSettings.gravity == iToastGravityBottom) {
		point = CGPointMake(window.frame.size.width / 2, window.frame.size.height - 70);
	}else if (theSettings.gravity == iToastGravityCenter) {
		point = CGPointMake(window.frame.size.width/2, window.frame.size.height/2);
	}else{
		point = theSettings.postition;
	}
	
	point = CGPointMake(point.x + offsetLeft, point.y + offsetTop);
	v.center = point;
	NSTimer *timer1 = [NSTimer timerWithTimeInterval:((float)theSettings.duration)/1000 
											 target:self selector:@selector(hideToast:) 
										   userInfo:nil repeats:NO];
	[[NSRunLoop mainRunLoop] addTimer:timer1 forMode:NSDefaultRunLoopMode];
	
	[window addSubview:v];
	
	view = [v retain];
    view.tag = TAG_iTOAST;

	[v addTarget:self action:@selector(hideToast:) forControlEvents:UIControlEventTouchDown];
}

- (void) hideToast:(NSTimer*)theTimer{
	[UIView beginAnimations:nil context:NULL];
	view.alpha = 0;
	[UIView commitAnimations];
	
	NSTimer *timer2 = [NSTimer timerWithTimeInterval:0.5
                                              target:self selector:@selector(removeToast:) 
										   userInfo:nil repeats:NO];
	[[NSRunLoop mainRunLoop] addTimer:timer2 forMode:NSDefaultRunLoopMode];
}

- (void) removeToast:(NSTimer*)theTimer{
	[view removeFromSuperview];
}

+ (iToast *) makeText:(NSString *) _text{
	iToast *toast = [[[iToast alloc] initWithText:_text] autorelease];
	
	return toast;
}


- (iToast *) setDuration:(NSInteger ) duration{
	[self theSettings].duration = duration;
	return self;
}

- (iToast *) setGravity:(iToastGravity) gravity 
			 offsetLeft:(NSInteger) left
			  offsetTop:(NSInteger) top{
	[self theSettings].gravity = gravity;
	offsetLeft = left;
	offsetTop = top;
	return self;
}

- (iToast *) setGravity:(iToastGravity) gravity{
	[self theSettings].gravity = gravity;
	return self;
}

- (iToast *) setPostion:(CGPoint) _position{
	[self theSettings].postition = CGPointMake(_position.x, _position.y);
	
	return self;
}

-(iToastSettings *) theSettings{
	if (!_settings) {
		_settings = [[iToastSettings getSharedSettings] copy];
	}
	
	return _settings;
}

@end


@implementation iToastSettings
@synthesize duration;
@synthesize gravity;
@synthesize postition;
@synthesize images;

- (void) setImage:(UIImage *) img forType:(iToastType) type{
	if (!images) {
		images = [[NSMutableDictionary alloc] initWithCapacity:4];
	}
	
	if (img) {
		NSString *key = [NSString stringWithFormat:@"%i", type];
		[images setValue:img forKey:key];
	}
}


+ (iToastSettings *) getSharedSettings{
	if (!sharedSettings) {
		sharedSettings = [iToastSettings new];
		sharedSettings.gravity = iToastGravityBottom;
		sharedSettings.duration = iToastDurationShort;
	}
	
	return sharedSettings;
	
}

- (id) copyWithZone:(NSZone *)zone{
	iToastSettings *copy = [iToastSettings new];
	copy.gravity = self.gravity;
	copy.duration = self.duration;
	copy.postition = self.postition;
	
	NSArray *keys = [self.images allKeys];
	
	for (NSString *key in keys){
		[copy setImage:[images valueForKey:key] forType:[key intValue]];
	}
	
	return copy;
}

@end