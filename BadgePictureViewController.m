//
//  BadgePictureViewController.m
//  ImIn
//
//  Created by park ja young on 11. 2. 18..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "BadgePictureViewController.h"
#import "UIImageView+WebCache.h"

@implementation BadgePictureViewController

@synthesize pictureImageView, pictureUrl, postType;

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    return self;
}
*/

- (void)viewWillAppear:(BOOL)animated {
	[self logViewControllerName];
	[super viewWillAppear:animated];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];

	//http://imindev.paran.com/sns/htdocs/img/badge/26_126x126_f_1.png
    UIImageView* thumbnail = [UIImageView new];
    if ([postType isEqualToString:@"2"]) {
        if (pictureUrl != nil) {
            MY_LOG(@"pictureUrl = %@", pictureUrl);
            NSRange thumb1Range = [pictureUrl rangeOfString:@"_"];
            if (thumb1Range.location != NSNotFound) { //std1.jpg
                NSString* temp= [pictureUrl substringFromIndex:thumb1Range.location+1];
                thumb1Range = [temp rangeOfString:@"."];
                if (thumb1Range.location != NSNotFound) {
                    temp= [temp substringToIndex:thumb1Range.location]; // std1
                    thumb1Range = [pictureUrl rangeOfString:temp];
                    if (thumb1Range.location != NSNotFound) {
                        NSString* ImageUrl = [pictureUrl stringByReplacingCharactersInRange:thumb1Range withString:@"std4"];
                        [thumbnail setImageWithURL:[NSURL URLWithString: ImageUrl]];
                        if (thumbnail.image != nil) {
                            [pictureImageView setImageWithURL:[NSURL URLWithString: ImageUrl] 
                                             placeholderImage: thumbnail.image];			
                        } else {
                            [pictureImageView setImageWithURL:[NSURL URLWithString: ImageUrl] 
                                             placeholderImage: [UIImage imageNamed:@"photoload_big.png"]];
                        }
                    } else {
                        [self errorAlert];
                    }
                } else {
                    [self errorAlert];
                }
            } else {
                [self errorAlert];
            }
        } else {
            [pictureImageView setImageWithURL:[NSURL URLWithString: pictureUrl] 
                             placeholderImage: [UIImage imageNamed:@"photoload_big.png"]];
        }
    } else {
        if (pictureUrl != nil) {
            NSRange thumb1Range = [pictureUrl rangeOfString:@"_"];
            if (thumb1Range.location != NSNotFound) {
                NSString* temp= [pictureUrl substringFromIndex:thumb1Range.location+1]; // 126x126_f_1.png
                thumb1Range = [temp rangeOfString:@"_"];
                if (thumb1Range.location != NSNotFound) {
                    temp= [temp substringToIndex:thumb1Range.location]; // 126x126
                    thumb1Range = [pictureUrl rangeOfString:temp];
                    if (thumb1Range.location != NSNotFound) {
                        NSString* ImageUrl = [pictureUrl stringByReplacingCharactersInRange:thumb1Range withString:@"370x370"];
                        
                        [thumbnail setImageWithURL:[NSURL URLWithString: ImageUrl]];
                        if (thumbnail.image != nil) {
                            [pictureImageView setImageWithURL:[NSURL URLWithString: ImageUrl] 
                                             placeholderImage: thumbnail.image];			
                        } else {
                            [pictureImageView setImageWithURL:[NSURL URLWithString: ImageUrl] 
                                             placeholderImage: [UIImage imageNamed:@"photoload_big.png"]];
                        }
                    } else {
                        [self errorAlert];
                    }
                } else {
                    [self errorAlert];
                }
            } else {
                [self errorAlert];
            }
        } else {
            [pictureImageView setImageWithURL:[NSURL URLWithString: pictureUrl] 
                             placeholderImage: [UIImage imageNamed:@"photoload_big.png"]];
        }
    }
    [thumbnail release];
}

- (void) errorAlert {
    UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"알림" message:@"이미지 링크가 잘못되어 \n볼수가 없어요~"
                                                    delegate:self cancelButtonTitle:nil otherButtonTitles:@"확인", nil] autorelease];
    alert.tag = 100;
    [alert show];
}
/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
	[pictureImageView release];
	[pictureUrl release];
    [postType release];
	
    [super dealloc];
}

- (IBAction) goPopView {
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
