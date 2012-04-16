//
//  AlbumPreviewViewController.m
//  ImIn
//
//  Created by Myungjin Choi on 11. 12. 28..
//  Copyright (c) 2011년 KTH. All rights reserved.
//

#import "AlbumPreviewViewController.h"

@implementation AlbumPreviewViewController
@synthesize previewImageView;
@synthesize delegate;
@synthesize image;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [[UIApplication sharedApplication] setStatusBarHidden:YES animated:NO];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [[UIApplication sharedApplication] setStatusBarHidden:NO animated:NO];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    if (image) {
        [previewImageView setImage:image];
    }
}

- (void)viewDidUnload
{
    [self setPreviewImageView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
    [previewImageView release];
    [image release];
    
    [super dealloc];
}
- (IBAction)useThisImage:(id)sender {
    if ([self.delegate respondsToSelector:@selector(returnImage:)]) {
        [self.delegate performSelector:@selector(returnImage:) withObject:previewImageView.image];
    }
    [self.navigationController popViewControllerAnimated:NO];
}

- (IBAction)cancelThisImage:(id)sender {
    [self.navigationController popViewControllerAnimated:NO];
}
@end
