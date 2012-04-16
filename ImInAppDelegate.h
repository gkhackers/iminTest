//
//  ImInAppDelegate.h
//  ImIn
//
//  Created by mandolin on 10. 4. 5..
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@class UILoginViewController;
@class ISDatabase;
/**
 @brief 아임인 앱 구동 초기화 및 APNS처리
 */

@interface ImInAppDelegate : NSObject <UIApplicationDelegate, UITabBarControllerDelegate, CLLocationManagerDelegate> {
	UIWindow *window;
	
	UITabBarController* tabBarController;
	
	BOOL isToForeground;
	ISDatabase* database;
	
	BOOL isPushOn;

}

@property (nonatomic, retain) UITabBarController* tabBarController;

- (NSURL *)applicationDocumentsDirectory;


- (UITabBarController*) tabBar;
- (void) addTabBar;
- (void) restartTabBar;
-(void)saveDeviceTokenToRemote:(NSData *)deviceToken;
- (void) setupDatabase;
- (void) apnsHandlerWithMessage:(NSString*) message;
- (void) commonWebVCWithResult:(NSString*)resultKey;
@end

