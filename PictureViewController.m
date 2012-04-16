//
//  PictureViewController.m
//  ImIn
//
//  Created by choipd on 10. 5. 25..
//  Copyright 2010 edbear. All rights reserved.
//

#import "PictureViewController.h"
#import "UIImageView+WebCache.h"


@implementation PictureViewController

@synthesize pictureURL;

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

- (void)viewDidLoad {
    [super viewDidLoad];
	if ([pictureURL rangeOfString:@"no_prf"].location != NSNotFound) {
		[picture setImageWithURL:[NSURL URLWithString: pictureURL] 
				placeholderImage:[UIImage imageNamed:@"nonimg_full.png"]];
	} else {
        NSRange thumb1Range = [pictureURL rangeOfString:@"_thumb1" options:NSBackwardsSearch];
        if (thumb1Range.location != NSNotFound) {
            UIImageView* thumbnail = [UIImageView new];
            
            [thumbnail setImageWithURL:[NSURL URLWithString: pictureURL]];
            NSString* thumb6ImageURL = [pictureURL stringByReplacingCharactersInRange:thumb1Range withString:@"_thumb6"];
            
            if (thumbnail.image != nil) {
                [picture setImageWithURL:[NSURL URLWithString: thumb6ImageURL] 
                        placeholderImage: thumbnail.image];			
            } else {
                [picture setImageWithURL:[NSURL URLWithString: thumb6ImageURL] 
                        placeholderImage: [UIImage imageNamed:@"photoload_big.png"]];
            }
            
            [thumbnail release];
        } else {
            UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"알림" message:@"이미지 링크가 잘못되어 \n볼수가 없어요~"
                                                            delegate:self cancelButtonTitle:nil otherButtonTitles:@"확인", nil] autorelease];
            alert.tag = 100;
            [alert show];
        }
	}
}

- (void)viewWillAppear:(BOOL)animated
{
    [[UIApplication sharedApplication] setStatusBarHidden:YES animated:NO];
	[self logViewControllerName];
	[super viewWillAppear:animated];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [[UIApplication sharedApplication] setStatusBarHidden:NO animated:NO];
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

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
    [super dealloc];
	[pictureURL release];
}

-(IBAction) popWindow {
	[self.navigationController popViewControllerAnimated:NO];
}

- (void)alertView:(UIAlertView*)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 100)
	{
		[self.navigationController popViewControllerAnimated:NO];
	}
}

@end
