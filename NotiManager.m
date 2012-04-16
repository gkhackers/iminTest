//
//  NotiContext.m
//  ImIn
//
//  Created by KYONGJIN SEO on 11/2/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "NotiManager.h"
#import "UpdateNotificationView.h"

@implementation NotiManager
@synthesize delegate;
@synthesize updateNotiView;

- (void) showUpdateNotification : (NSMutableArray *) resultArray {
    
    UIWindow *mainWindow = [[UIApplication sharedApplication] keyWindow];
        
    self.updateNotiView = [[[UpdateNotificationView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)] autorelease];
    [mainWindow addSubview:updateNotiView];
    updateNotiView.delegate = self;
    [updateNotiView processNotiList:resultArray];
}

- (void) removeUpdateNotification : (NSDictionary *) result {
    [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:@"lastBadgeNotification"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [updateNotiView removeFromSuperview];
}

- (void) hideUpdateNotification:(BOOL)hidden {

    [updateNotiView setHidden:hidden];
    
    if (hidden == YES) {
        [updateNotiView automoveNotifications:NO];
    } else {
        [updateNotiView automoveNotifications:YES];
    }
}

- (void) sendDataToViewController:(NSDictionary *) result {
    if( [self.delegate respondsToSelector:@selector(didFinishedUpdateNotifications:)] )
    {
        [self.delegate didFinishedUpdateNotifications:result];
    } else {
        MY_LOG(@"%@ has failed", NSStringFromClass([self class]));
    } 
}

- (void) dealloc
{
    [updateNotiView release];
    [super dealloc];
}

@end
