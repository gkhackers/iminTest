//
//  CommonAlert.m
//  ImIn
//
//  Created by choipd on 10. 4. 29..
//  Copyright 2010 edbear. All rights reserved.
//

#import "CommonAlert.h"
#import "UserContext.h"
#import "const.h"
//#import "iToast.h"

@implementation CommonAlert

+ (void) alertWithTitle:(NSString*)title message:(NSString*)msg {
    [ApplicationContext stopActivity];
	if (msg == nil || title == nil) return;
	if ([msg compare:@""] == NSOrderedSame) return;
	
//    [[iToast makeText:msg] show];
	if ([msg compare:[UserContext sharedUserContext].lastMsg] == NSOrderedSame)
	{
		if ([msg compare:NETWORK_MSG_TIMOUT] == NSOrderedSame 
			|| [msg compare:NETWORK_MSG_NOCONNECTION] == NSOrderedSame
			|| [msg compare:NETWORK_MSG_SERVERERROR] == NSOrderedSame
			|| [msg compare:GPS_MSG_OUTOFBOUND] == NSOrderedSame
			|| [msg compare:GPS_MSG_NOGPS] == NSOrderedSame)
			return;
	}
	
	[UserContext sharedUserContext].lastMsg = msg;
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"알림"
															message:msg
														   delegate:nil
												  cancelButtonTitle:@"OK"
												  otherButtonTitles:nil];
		
	[alertView show];
	[alertView release];
	
}


@end
