//
//  TwitterInvitationViewController.m
//  ImIn
//
//  Created by choipd on 10. 7. 30..
//  Copyright 2010 edbear. All rights reserved.
//

#import "TwitterInvitationViewController.h"
#import "UserContext.h"
#import "CgiStringList.h"
#import "HttpConnect.h"
#import "JSON.h"
#import "SNSInvitationTableCell.h"


@implementation TwitterInvitationViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
		cpCode = @"51"; //twitter
    }
    return self;
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

- (IBAction) refreshTwitterList {
	MY_LOG(@"트위터 리프레시하자");
	[self requestCpRefresh];
}




@end
