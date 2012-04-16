//
//  BadgeAcquisitionView.m
//  ImIn
//
//  Created by Myungjin Choi on 11. 2. 21..
//  Copyright 2011 KTH. All rights reserved.
//

#import "BadgeAcquisitionView.h"
#import <QuartzCore/QuartzCore.h>
#import "BadgeInfo.h"

CGContextRef CreateARGBBitmapContext (CGImageRef inImage);
CGImageRef ManipulateImagePixelData(CGImageRef inImage);

@implementation BadgeAcquisitionView

@synthesize badgeData, badgeInfo;
@synthesize badgeMessage, delegate, nextOrCloseBtn;
@synthesize biggerBadgeIconLayer;


#pragma mark -
#pragma mark 애니메이숑!!!
- (void) doAnimationWithLayer:(CALayer*) layer withType:(BadgeAnimationType) animationType to:(CGPoint) toPosition
{
	layer.zPosition = 1.0f;	
	
	CGFloat animationDuration = 0.8;
	BOOL removedOnCompletion = YES;
	
	CABasicAnimation* rotateAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.y"];
	rotateAnimation.fromValue = [NSNumber numberWithFloat: 0.0];
	rotateAnimation.toValue = [NSNumber numberWithFloat:M_PI*2];
	rotateAnimation.duration = animationDuration;
	rotateAnimation.repeatCount = 1;
	rotateAnimation.autoreverses = NO;
	rotateAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
	rotateAnimation.removedOnCompletion = removedOnCompletion;
	
	CABasicAnimation* scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
	scaleAnimation.fromValue = [NSNumber numberWithFloat: 1.0f];
	scaleAnimation.toValue = [NSNumber numberWithFloat:3.0f];
	scaleAnimation.duration = animationDuration;
	scaleAnimation.repeatCount = 0;
	scaleAnimation.autoreverses = NO;
	scaleAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
	scaleAnimation.removedOnCompletion = removedOnCompletion;
	
	
	CAKeyframeAnimation *bounceAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
	bounceAnimation.removedOnCompletion = removedOnCompletion;
	
	CGMutablePathRef thePath = CGPathCreateMutable();
	
	CGFloat midX = toPosition.x;
	CGFloat midY = toPosition.y;
	
	CGPathMoveToPoint(thePath, NULL, layer.position.x, layer.position.y);
	CGPathAddLineToPoint(thePath, NULL, midX, midY);
	bounceAnimation.path = thePath;
	bounceAnimation.duration = animationDuration;
	CGPathRelease(thePath);
	
	
	CAAnimationGroup *theGroup = [CAAnimationGroup animation];
	theGroup.delegate = self;
	theGroup.duration = animationDuration;
	theGroup.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
	theGroup.animations = [NSArray arrayWithObjects: rotateAnimation, bounceAnimation, scaleAnimation,  nil];
		
	switch (animationType) {
		case BADGE_ANIMATION_TYPE1: // 뒤집기, 무지개빛 애니메이션,
		{
			[layer addAnimation:theGroup forKey:@"moveToCenter"];
			layer.position = CGPointMake(midX, midY);
			layer.transform = CATransform3DMakeScale(3, 3, 3);
			
			if ([ApplicationContext osVersion] > 3.2) {
				CALayer* lightLayer = [CALayer layer];
				lightLayer.contents = (id)[[UIImage imageNamed:@"badge_light.png"] CGImage];
				lightLayer.bounds = CGRectMake(0, 0, 126, 252);
				lightLayer.position = CGPointMake(-100, 252/2);
				
				
				NSString* url = [badgeData objectForKey:@"badgeImgUrl"];
				if (url == nil) {
					url = [badgeData objectForKey:@"imgUrl"];
				}
				
				
				CGImageRef mask = ManipulateImagePixelData([[Utils getImageFromBaseUrl:url 
																			  withSize:@"252x252" 
																			  withType:@"f"] CGImage]);
				CALayer* maskLayer = [CALayer layer];
				maskLayer.contents = (id)mask;
				CGImageRelease(mask);
				maskLayer.bounds = CGRectMake(0, 0, 84, 84);
				maskLayer.position = CGPointMake(84/2, 84/2);
				
				layer.mask = maskLayer;
				[layer addSublayer:lightLayer];
				
				CABasicAnimation* moveAnimation = [CABasicAnimation animationWithKeyPath:@"position.x"];
				moveAnimation.fromValue = [NSNumber numberWithFloat:-100.0f];
				moveAnimation.toValue = [NSNumber numberWithFloat:320.0f];
				moveAnimation.duration = 1.0f;
				moveAnimation.autoreverses = YES;
				moveAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
				moveAnimation.removedOnCompletion = YES;
				
				[lightLayer addAnimation:moveAnimation forKey:@"move"];				
			}			
			
			break;
		}
		case BADGE_ANIMATION_TYPE2: // 뒤집기, 무지개빛 애니메이션, 진동
			break;
		case BADGE_ANIMATION_TYPE3: // 뒤집기, 무지개빛 애니메이션, 소리
			break;
		case BADGE_ANIMATION_TYPE4: // 뒤집기, 무지개빛 애니메이션, 진동, 소리
			break;
		default:
			break;
	}
}

- (void)animationDidStart:(CAAnimation *)anim
{
	if (isFrontSide) {
		badgeRearSide.hidden = YES;
	}
}


- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag
{
	if (!isFrontSide) {
		badgeRearSide.hidden = NO;
	} 
}


- (void) awakeFromNib
{
	isFrontSide = YES;
	badgeRearSide.layer.name = @"badgeRearSide";
	difficulty.layer.name = @"difficulty";
	since.layer.name = @"since";
	totalUser.layer.name = @"totalUser";
}

- (void) startOpeningAnimationFrom:(CGPoint) fromPosition to:(CGPoint) toPosition {
	self.biggerBadgeIconLayer = [CALayer layer];
	biggerBadgeIconLayer.doubleSided = NO;
	biggerBadgeIconLayer.name = [NSString stringWithFormat:@"biggerBadgeIcon"];
	biggerBadgeIconLayer.opaque = 1.0f;
	NSString* url = [badgeData objectForKey:@"badgeImgUrl"];
	if (url == nil) {
		url = [badgeData objectForKey:@"imgUrl"];
	}
	[biggerBadgeIconLayer setContents:(id)[[Utils getImageFromBaseUrl:url withSize:@"252x252" withType:@"f"] CGImage]];
	[biggerBadgeIconLayer setBounds:CGRectMake(0, 0, 84, 84)];
	[biggerBadgeIconLayer setPosition:CGPointMake(fromPosition.x, fromPosition.y)];
	
	[self.layer insertSublayer:biggerBadgeIconLayer above:badgeRearSide.layer];
	
	[self doAnimationWithLayer:biggerBadgeIconLayer withType:BADGE_ANIMATION_TYPE1 to:toPosition];
	
	[UIView beginAnimations:@"fadeOutGetMsg" context:nil];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(fadeInGuideMsg)];
	[UIView setAnimationDelay:1.5];
	[UIView setAnimationDuration:0.75];
	getMsgTextView.alpha = 0.0f;
	[UIView commitAnimations];
	
}

- (void) fadeInGuideMsg 
{
	[UIView beginAnimations:@"fadeInGuideMsg" context:nil];
	[UIView setAnimationDelay:0.0];
	[UIView setAnimationDuration:0.8];
	guideMsgTextView.alpha = 1.0f;
	[UIView commitAnimations];
	
}

- (void) drawBasicInfo
{
	titleLabel.text = [badgeData objectForKey:@"badgeName"];
	getMsgTextView.text = [badgeData objectForKey:@"badgeGetMsg"];	
	guideMsgTextView.text = [badgeData objectForKey:@"badgeGuideMsg"];
}

- (void) requestBadgeInfo
{
	NSAssert(badgeData, @"뱃지에 대한 일차정보는 호출한 VC에서 넘겨받아야 함");
	[self drawBasicInfo];
	self.badgeInfo = [[[BadgeInfo alloc] init] autorelease];
	[badgeInfo.params addEntriesFromDictionary:[NSDictionary
												dictionaryWithObjectsAndKeys:
												[badgeData objectForKey:@"badgeId"], @"badgeId",
												@"4", @"scale4LastUserList", 
												[UserContext sharedUserContext].snsID, @"snsId", nil]];
	badgeInfo.delegate = self;
	[badgeInfo request];
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code.
 }
 */
- (void) doAnimationWithLayer:(CALayer*) layer
{
	NSString* url = [badgeData objectForKey:@"badgeImgUrl"];
	if (url == nil) {
		url = [badgeData objectForKey:@"imgUrl"];
	}
	
	
	if (isFrontSide) {
		isFrontSide = NO;
		[layer setContents:(id)[[Utils getImageFromBaseUrl:url withSize:@"252x252" withType:@"b"] CGImage]];
	} else {
		isFrontSide = YES;
		[layer setContents:(id)[[Utils getImageFromBaseUrl:url withSize:@"252x252" withType:@"f"] CGImage]];
	}
	
	layer.zPosition = -10;
	CGFloat animationDuration = 0.4;
	BOOL removedOnCompletion = YES;
	
	CABasicAnimation* rotateAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.y"];
	rotateAnimation.fromValue = [NSNumber numberWithFloat: 0.0];
	rotateAnimation.toValue = [NSNumber numberWithFloat:M_PI];
	rotateAnimation.duration = animationDuration;
	rotateAnimation.repeatCount = 1;
	rotateAnimation.autoreverses = NO;
	rotateAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
	rotateAnimation.removedOnCompletion = removedOnCompletion;
	
	CAAnimationGroup *theGroup = [CAAnimationGroup animation];
	theGroup.delegate = self;
	theGroup.duration = animationDuration;
	theGroup.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
	theGroup.animations = [NSArray arrayWithObjects: rotateAnimation, nil];
	
	[layer addAnimation:theGroup forKey:@"flip"];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch *touch = [touches anyObject];
	CGPoint tapLocation = [touch locationInView:self.superview];
	CALayer *layer = [self.layer hitTest:tapLocation];
	MY_LOG(@"Layer Name = %@", layer.name);
	
	if ([layer.name isEqualToString:@"biggerBadgeIcon"]
		|| [layer.name isEqualToString:@"difficulty"]
		|| [layer.name isEqualToString:@"since"]
		|| [layer.name isEqualToString:@"badgeRearSide"]
		|| [layer.name isEqualToString:@"totalUser"]) {
		[self doAnimationWithLayer:biggerBadgeIconLayer];
		
	}
	
}	

- (void)dealloc {
	[badgeData release];
	[badgeInfo release];
	[delegate release];
	
	[nextOrCloseBtn release];
	[badgeMessage release];
	
	if (badgeInfo != nil) {
		[badgeInfo release];
	}
		
	[biggerBadgeIconLayer release];
	
    [super dealloc];
}


- (void) apiFailed {
	
}

- (void) apiDidLoad:(NSDictionary *)result {
	
	if ([[result objectForKey:@"func"] isEqualToString:@"badgeInfo"]) {
		
		NSAssert([[result objectForKey:@"level"] intValue] < 6, @"level이 5이하");
		NSAssert([result objectForKey:@"regDate"], @"regDate 와야함");
		
		int difficultyValue = [[result objectForKey:@"difficulty"] intValue];
		
		NSString* regDate = [result objectForKey:@"regDate"];
		
		if ([regDate isEqualToString:@""]) {
			since.hidden = YES;
		} else {
			NSString* getDate = [Utils getSimpleDateWithString:[result objectForKey:@"regDate"]];
			since.text = getDate;			
		}

		NSString* userCnt = [NSString stringWithFormat:@"총 %d 명", [[result objectForKey:@"userCnt"] intValue]];
		totalUser.text = userCnt;
		
		NSString* difficultyString = @"";
		for (int i=0; i < difficultyValue; i++) {
			difficultyString = [difficultyString stringByAppendingFormat:@"★"];
		}
		difficulty.text = difficultyString;
		
	}
	
	
}

- (IBAction) nextBadge {
	if (delegate != nil && [delegate respondsToSelector:@selector(goNextBadge)]) {
		[delegate performSelector:@selector(goNextBadge)];
	}
}

- (IBAction) closeView {
	if (delegate != nil && [delegate respondsToSelector:@selector(closeView)]) {
		[delegate performSelector:@selector(closeView)];
	}	
}

@end

CGContextRef CreateARGBBitmapContext (CGImageRef inImage)
{
    CGContextRef    context = NULL;
    CGColorSpaceRef colorSpace;
    void *          bitmapData;
    int            bitmapByteCount;
    int            bitmapBytesPerRow;
	
	// Get image width, height. We'll use the entire image.
    size_t pixelsWide = CGImageGetWidth(inImage);
    size_t pixelsHigh = CGImageGetHeight(inImage);
	
    // Declare the number of bytes per row. Each pixel in the bitmap in this
    // example is represented by 4 bytes; 8 bits each of red, green, blue, and
    // alpha.
    bitmapBytesPerRow   = (pixelsWide * 4);
    bitmapByteCount     = (bitmapBytesPerRow * pixelsHigh);
	
    // Use the generic RGB color space.
    colorSpace = CGColorSpaceCreateDeviceRGB();
    if (colorSpace == NULL)
    {
        fprintf(stderr, "Error allocating color space\n");
        return NULL;
    }
	
    // Allocate memory for image data. This is the destination in memory
    // where any drawing to the bitmap context will be rendered.
    bitmapData = malloc( bitmapByteCount );
    if (bitmapData == NULL) 
    {
        fprintf (stderr, "Memory not allocated!");
        CGColorSpaceRelease( colorSpace );
        return NULL;
    }
	
    // Create the bitmap context. We want pre-multiplied ARGB, 8-bits 
    // per component. Regardless of what the source image format is 
    // (CMYK, Grayscale, and so on) it will be converted over to the format
    // specified here by CGBitmapContextCreate.
    context = CGBitmapContextCreate (bitmapData,
									 pixelsWide,
									 pixelsHigh,
									 8,      // bits per component
									 bitmapBytesPerRow,
									 colorSpace,
									 kCGImageAlphaPremultipliedFirst);
    if (context == NULL)
    {
        free (bitmapData);
        fprintf (stderr, "Context not created!");
    }
	
    // Make sure and release colorspace before returning
    CGColorSpaceRelease( colorSpace );
	
    return context;
}

CGImageRef ManipulateImagePixelData(CGImageRef inImage)
{
    // Create the bitmap context
    CGContextRef cgctx = CreateARGBBitmapContext(inImage);
    if (cgctx == NULL) 
    { 
        // error creating context
        return nil;
    }
	
	int            bitmapByteCount;
    int            bitmapBytesPerRow;
	
	// Get image width, height. We'll use the entire image.
    size_t pixelsWide = CGImageGetWidth(inImage);
    size_t pixelsHigh = CGImageGetHeight(inImage);
	
    // Declare the number of bytes per row. Each pixel in the bitmap in this
    // example is represented by 4 bytes; 8 bits each of red, green, blue, and
    // alpha.
    bitmapBytesPerRow   = (pixelsWide * 4);
    bitmapByteCount     = (bitmapBytesPerRow * pixelsHigh);
	
	// Get image width, height. We'll use the entire image.
    size_t w = CGImageGetWidth(inImage);
    size_t h = CGImageGetHeight(inImage);
    CGRect rect = {{0,0},{w,h}}; 
	
    // Draw the image to the bitmap context. Once we draw, the memory 
    // allocated for the context for rendering will then contain the 
    // raw image data in the specified color space.
    CGContextDrawImage(cgctx, rect, inImage);
	
    // Now we can get a pointer to the image data associated with the bitmap
    // context.
    UInt8 *data = (UInt8*)CGBitmapContextGetData (cgctx);
    if (data != NULL)
    {
		
        // **** You have a pointer to the image data ****
		for (int i=0; i < bitmapByteCount; i += 4) {
			if (data[i] == 0) {
				data[i] = 0x00;
				data[i+1] = data[i+2] = data[i+3] = 0x00;
			} else {
				data[i] = 0xff;
				data[i+1] = data[i+2] = data[i+3] = 0xff;
			}
		}
		
		cgctx = CGBitmapContextCreate(data,  
									  CGImageGetWidth( inImage ),  
									  CGImageGetHeight( inImage ),  
									  8,  
									  CGImageGetBytesPerRow( inImage ),  
									  CGImageGetColorSpace( inImage ),  
									  kCGImageAlphaPremultipliedFirst );  
        // **** Do stuff with the data here ****
		
    }
	
	CGImageRef imageRef = CGBitmapContextCreateImage (cgctx);
	
    // When finished, release the context
    CGContextRelease(cgctx); 
    // Free image data memory for the context
    if (data)
    {
		memset(data, 0, bitmapByteCount);
        free(data);
    }
	return imageRef;
}
