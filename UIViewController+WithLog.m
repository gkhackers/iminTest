//
//  UIViewController+WithLog.m
//  ImIn
//
//  Created by choipd on 10. 7. 6..
//  Copyright 2010 edbear. All rights reserved.
//

#import "UIViewController+WithLog.h"
#import "UserContext.h"

@implementation UIViewController (WithLog)
- (void) logViewControllerName {
	NSMutableArray* callStack = [UserContext sharedUserContext].vcCallStack;
	NSString* className = NSStringFromClass([self class]);
	
	[UserContext sharedUserContext].lastViewControllerClassName = className;
	if ([callStack count] == 20) {
		[callStack removeObjectAtIndex:0];
	}
	[callStack addObject: className];
	//MY_LOG(@"view controller name = %@", className);
	
	NSString* stackString = @"";
	
	for (int i=0; i < [callStack count]; i++) {
		stackString = [stackString stringByAppendingFormat: @"%@ > ", [callStack objectAtIndex:i]];
	}
	//MY_LOG(@"%@", stackString);
}
@end
