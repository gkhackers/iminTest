//
//  FBInvitationViewController.m
//  ImIn
//
//  Created by choipd on 10. 7. 30..
//  Copyright 2010 edbear. All rights reserved.
//

#import "FBInvitationViewController.h"
#import "UserContext.h"
#import "HttpConnect.h"
#import "CgiStringList.h"


@implementation FBInvitationViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
		cpCode = @"52"; // facebook
    }
    return self;
}

- (void) viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	MY_LOG(@"selected");
	
	[self.navigationController dismissModalViewControllerAnimated:YES];
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
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
    [super dealloc];
}

- (IBAction) popViewController {
	[self.navigationController popViewControllerAnimated:YES];
}

- (IBAction) refreshFacebookList {
	MY_LOG(@"페북 리프레시하자");
	[self requestCpRefresh];
}

@end
