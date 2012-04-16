//
//  ViewControllers.m
//  ImIn
//
//  Created by choipd on 10. 4. 27..
//  Copyright 2010 edbear. All rights reserved.
//

#import "ViewControllers.h"
#import "UIPlazaViewController.h"
#import "MyHomeViewController.h"
//#import "UIHomeViewController.h"
#import "UINeighborsViewController.h"

@implementation ViewControllers

@synthesize plazaViewController;
@synthesize homeViewController;
@synthesize neighbersViewController;
@synthesize badgeViewController;
@synthesize feedViewController;
@synthesize settingViewController;
@synthesize tabBarController;

//
// singleton stuff
//
static ViewControllers *_sharedViewControllers = nil;


+ (ViewControllers *)sharedViewControllers
{
    if (_sharedViewControllers == nil) {
        _sharedViewControllers = [[super allocWithZone:NULL] init];
    }
    return _sharedViewControllers;    
}

+ (id)allocWithZone:(NSZone *)zone
{
    return [[self sharedViewControllers] retain];
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

- (id)retain
{
    return self;
}

- (NSUInteger)retainCount
{
    return NSUIntegerMax;  //denotes an object that cannot be released
}

- (oneway void)release
{
    //do nothing
}

- (id)autorelease
{
    return self;
}


-(void) dealloc {
	[plazaViewController release];
	[homeViewController release];
	[neighbersViewController release];
	[badgeViewController release];
	[feedViewController release];
	[settingViewController release];
	[tabBarController release];
	[super dealloc];
}

-(void) refreshAllViewController {
	[(UIPlazaViewController*)plazaViewController setHasLoaded:NO];
	[(UIPlazaViewController*)plazaViewController setNeedToUpdate:YES];
	[(UINeighborsViewController*)neighbersViewController setHasLoaded:NO];
}

- (void) refreshNeighborVC {
	[(UINeighborsViewController*)neighbersViewController setHasLoaded:NO];
}

@end
