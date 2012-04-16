//
//  PlazaSliderViewController.m
//  ImIn
//
//  Created by choipd on 10. 4. 21..
//  Copyright 2010 edbear. All rights reserved.
//

#import "PlazaSliderViewController.h"
#import "ViewControllers.h"
#import "UIPlazaViewController.h"
#import "UIPlazaMainHeaderViewController.h"
#import "UserContext.h"
#import "GeoContext.h"


@implementation PlazaSliderViewController
@synthesize range;

- (IBAction)sliderChanged:(id)sender {
    range = [(UISlider*)sender value] * [(UISlider*)sender value] * [(UISlider*)sender value];
    
	if (range > 600) {
		range = 600.0f;
	}
	
	if (range < 2.0) {
		range = 2.0f;
	}
	
    radiusLabel.text = [NSString stringWithFormat:@"%.1fkm", range];
}

- (void) hideRadius {
	[[(UIPlazaViewController*)[ViewControllers sharedViewControllers].plazaViewController plazaMainHeaderController] toggleRadius];
}

- (IBAction)sliderTouchUpInside:(id)sender {
	MY_LOG(@"리로드합시다.!!!");
    
    range = [(UISlider*)sender value] * [(UISlider*)sender value] * [(UISlider*)sender value];
    
	if (range > 600) {
		range = 600.0f;
	}
	
	if (range < 2.0) {
		range = 2.0f;
	}
	
	[self hideRadius];

    UIPlazaViewController* vc = (UIPlazaViewController*)[ViewControllers sharedViewControllers].plazaViewController;
	[vc refresh];

}

- (IBAction)touchDown {
	MY_LOG(@"터치 다운");
}

- (IBAction)touchUp {
	MY_LOG(@"터치 업");
}


/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    
	if ([GeoContext sharedGeoContext].cntNoGPSrecv > 0) {
        radiusSlider.value = 8.6f;
        range = 600.0f;
        radiusLabel.text = [NSString stringWithFormat:@"%.1fkm", range];
    }
		
    if (radiusSlider.value * radiusSlider.value * radiusSlider.value > 600.0f) {
        radiusLabel.text = @"600.0km";
        range = 600.0f;
    } else {
        range = radiusSlider.value * radiusSlider.value * radiusSlider.value;
        radiusLabel.text = [NSString stringWithFormat:@"%.1fkm", range];
    }
	
	radiusSlider.backgroundColor = [UIColor clearColor];  

	UIImage *stretchLeftTrack = [[UIImage imageNamed:@"radiusbar_off.png"]
								stretchableImageWithLeftCapWidth:9.0 topCapHeight:0.0];
	UIImage *stretchRightTrack = [[UIImage imageNamed:@"radiusbar_on.png"]
								 stretchableImageWithLeftCapWidth:9.0 topCapHeight:0.0];
	
	[radiusSlider setThumbImage: [UIImage imageNamed:@"radiusbar_ball.png"] forState:UIControlStateNormal];
	[radiusSlider setMinimumTrackImage:stretchLeftTrack forState:UIControlStateNormal];
	[radiusSlider setMaximumTrackImage:stretchRightTrack forState:UIControlStateNormal];	
	pressed = NO;
}

- (void)drawRect {
	MY_LOG(@"drawRect");
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
}


@end
