//
//  UIPlazaViewController.h
//  ImIn
//
//  Created by mandolin on 10. 4. 5..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainThreadTableViewController.h"
#import "HttpConnect.h"

@class HttpConnect;

@class PlazaSliderViewController;
@class UIPlazaMainHeaderViewController;
@class MainThreadTableViewController;
@class NoticeBarViewController;
@class EmptyListMessageViewController;
@class EventList;
@class PlazaPostList;

/**
 @brief 광장 탭의 루트 뷰컨트롤러
 */
@interface UIPlazaViewController : UIViewController <MainThreadProtocol, ImInProtocolDelegate>
{
	NSMutableArray* cellDataList;
    NSDictionary* eventFirstData;
    NSInteger eventTotalCnt;
	UIPlazaMainHeaderViewController* plazaMainHeaderController;
	PlazaSliderViewController* plazaSliderViewController;
	MainThreadTableViewController* mainThreadTableViewController;
	EmptyListMessageViewController* emptyListMessageViewController;
    
    EventList* eventList;
    PlazaPostList* plazaPostList;

	NoticeBarViewController* noticeBarViewController;
	
	BOOL isSliderShown;
	BOOL isLogin;
	BOOL needToUpdate;
	BOOL hasLoaded;
//	NSTimeInterval intervalWithLastUpdate;
	
	int requestRetryCount;
	
	NSString* sliderRange;
	
	HttpConnect* connect;

    NSArray* defaultText;
    NSArray* morningText;
    NSArray* lunchText;
    NSArray* eveningText;
    NSArray* nightText;
    NSArray* holidayText;    
    
    NSDate *preDelayDate;
    NSString * inputCellText;
}

//- (void) onTransDone:(HttpConnect*)up;
//- (void) request;
- (void) requestOfPlazaList;
- (void) toggleSliderView;
- (void) toggleNoticeView;
- (void) refresh;
- (void) openNoticeView;
- (void) closeNoticeView;
- (void) apnsHandlerWithMessage:(NSString*) message;
- (void) openWelcomeTutorial;
- (void) requestOfEvent;
- (NSString*) getPlazaQuestText;

@property (nonatomic) BOOL isLogin;
@property (readwrite) BOOL hasLoaded;
@property (readwrite) BOOL needToUpdate;
@property (nonatomic, retain) NSString* sliderRange;
@property (nonatomic, retain) NSMutableArray* cellDataList;
@property (nonatomic, retain) PlazaSliderViewController* plazaSliderViewController;
@property (nonatomic, retain) UIPlazaMainHeaderViewController* plazaMainHeaderController;
@property (nonatomic, retain) MainThreadTableViewController* mainThreadTableViewController;
@property (nonatomic, retain) EventList* eventList;
@property (nonatomic, retain) PlazaPostList* plazaPostList;
@property (nonatomic, retain) NSDictionary* eventFirstData;
@property (readwrite) NSInteger eventTotalCnt;
@property (nonatomic, retain) NSArray* defaultText;
@property (nonatomic, retain) NSArray* morningText;
@property (nonatomic, retain) NSArray* lunchText;
@property (nonatomic, retain) NSArray* eveningText;
@property (nonatomic, retain) NSArray* nightText;
@property (nonatomic, retain) NSArray* holidayText;  
@property (nonatomic, retain) NSDate *preDelayDate;
@property (nonatomic, retain) NSString * inputCellText;

@end
