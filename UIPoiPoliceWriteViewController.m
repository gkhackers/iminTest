//
//  UIPoiPoliceWriteViewController.m
//  ImIn
//
//  Created by mandolin on 10. 9. 7..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "UIPoiPoliceWriteViewController.h"
#import "PoiPolice.h"

@implementation UIPoiPoliceWriteViewController
@synthesize poiPolice, poiId, preString;

 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        poiId = nil;
		preString = nil;
    }
    return self;
}



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	UIImage *image = [UIImage imageNamed:@"round_input_box.png"]; 
	UIImage *strImage = [image stretchableImageWithLeftCapWidth:12 topCapHeight:12]; 
	textViewBgImage.image = strImage;
	[contentTextView becomeFirstResponder];
} 


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [poiId release];
    [preString release];
    [poiPolice release];
    
    [super dealloc];
}

- (IBAction) popViewController
{
	[self.navigationController popViewControllerAnimated:YES];
}
- (IBAction) doRequest
{
	if (poiId == nil) return;
    
    NSString* msgStr = [NSString stringWithFormat:@"[%@] %@", preString, contentTextView.text];
    
    self.poiPolice = [[[PoiPolice alloc] init] autorelease];
    poiPolice.delegate = self;
    
    [poiPolice.params addEntriesFromDictionary:[NSDictionary dictionaryWithObjectsAndKeys:
                                                poiId, @"poiKey",
                                                [UserContext sharedUserContext].snsID, @"snsId",
                                                msgStr, @"msg", nil]];
    [poiPolice request];
}

- (void) apiDidLoad:(NSDictionary *)result
{
    if ([[result objectForKey:@"func"] isEqualToString:@"poiPolice"]) {
        [CommonAlert alertWithTitle:@"알림" message:@"정상적으로 신고 처리 되었습니다. 빠른시간 내 운영자 확인 후 조치하도록 하겠습니다."];
        [self popViewController];
        return;
    }
}

- (void) apiFailed
{
    [CommonAlert alertWithTitle:@"에러" message:@"신고 등록에 실패하였습니다."];
}


// TextView Delegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range 
 replacementText:(NSString *)text
{
    // Any new character added is passed in as the "text" parameter
    if ([text isEqualToString:@"\n"]) {
        // Be sure to test for equality using the "isEqualToString" message
        [textView resignFirstResponder];
		
        // Return FALSE so that the final '\n' character doesn't get added
        return FALSE;
    }
    // For any other character return TRUE so that the text gets added to the view
    return TRUE;
}

- (void)textViewDidChange:(UITextView *)textView {
	NSInteger textLength = [textView.text length];
	if (textLength > 200){
			textView.text = [textView.text substringToIndex:200];
	}
		
}


@end
