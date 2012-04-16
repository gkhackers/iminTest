//
//  UpdateNotificationView.m
//  ImIn
//
//  Created by KYONGJIN SEO on 11/2/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "UpdateNotificationView.h"

#import "NotiManager.h"

@interface UpdateNotificationView (Private)
- (void)sortNotificationList;
- (void)closeView;
- (void)moveToDetail;
- (void)loadPage:(int)page;
@end

@implementation UpdateNotificationView
@synthesize notiListArray;
@synthesize currentPosition;
@synthesize delegate;
@synthesize contentScrollView;

- (id) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        UIView *coverView = [[UIView alloc] initWithFrame:self.bounds];
        coverView.backgroundColor = [UIColor clearColor];
        [self addSubview:coverView];
        [coverView release];

        UIImageView *bgImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 238, 320, 242)];
        bgImgView.image = [UIImage imageNamed:@"popup_box.png"];
        [self addSubview:bgImgView];
        [bgImgView release];
        
        self.contentScrollView = [[[UIScrollView alloc] initWithFrame:CGRectMake(44, 285, 232, 100)] autorelease];
        [contentScrollView setBackgroundColor:[UIColor clearColor]];
        contentScrollView.contentSize = CGSizeZero;
        contentScrollView.showsVerticalScrollIndicator = NO;
        contentScrollView.showsHorizontalScrollIndicator = NO;
        contentScrollView.delegate = self;
        contentScrollView.pagingEnabled = YES;
        [self addSubview:contentScrollView];
                
        pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(44, 394, 232, 6)];
        pageControl.currentPage = 0;
        pageControl.numberOfPages = 0;
        [self addSubview:pageControl];
        
        UIImageView *closeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(271, 263, 17, 17)];
        [closeImageView setImage:[UIImage imageNamed:@"popup_btn_close.png"]];
        [self addSubview:closeImageView];
        [closeImageView release];
        
        UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [closeButton setFrame:CGRectMake(260, 250, 40, 30)];
        [closeButton addTarget:self action:@selector(closeView) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:closeButton];
        [self bringSubviewToFront:closeButton];
        
        UIButton *moveButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [moveButton setFrame:CGRectMake(44, 410, 232, 33)];
        [moveButton setTitle:@"상세보기" forState:UIControlStateNormal];
        [moveButton setImage:[UIImage imageNamed:@"popup_btn_bottome.png"] forState:UIControlStateNormal];
        [moveButton addTarget:self action:@selector(moveToDetail) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:moveButton];
        
        currentPosition = 0;
        isEnd = NO;
    }
    return self;
}

- (void) dealloc {
    [contentScrollView release];
    [pageControl release];
    [notiListArray release];
    if (scrollTimer != nil)
	{
		[scrollTimer invalidate];
		[scrollTimer release];
	}
    [super dealloc];
}

#pragma mark - Button selector

- (void) closeView {
    MY_LOG(@"closeView %@", self);
    [self automoveNotifications:NO];
    isEnd = YES;
    
    if([self.delegate respondsToSelector:@selector(removeUpdateNotification:)]) {
        
        [(NotiManager*)delegate removeUpdateNotification:nil];
    } else {
        MY_LOG(@"No Selector in %@", NSStringFromClass([self class]));
    }
}

- (void) moveToDetail {
    
    [(NotiManager*)delegate sendDataToViewController:[NSDictionary dictionaryWithObject:[[notiListArray objectAtIndex:pageControl.currentPage] objectForKey:@"url"] forKey:@"url"]];
    
    [(NotiManager*)delegate hideUpdateNotification:YES];
}

#pragma mark - methods list
- (void) automoveNotifications:(BOOL)move {
    
    if (move) { // stop animation
        if (scrollTimer == nil) {
            scrollTimer = [NSTimer scheduledTimerWithTimeInterval:4 target:self selector:@selector(moveToNextPage) userInfo:nil
                                                          repeats:YES];
        } 
    } else {
        if (scrollTimer != nil) {
            [scrollTimer invalidate];
            scrollTimer = nil;
        }
    }
}

- (void) loadPage:(int)page {
    if (page < 0 || page >= totalPageCnt) {
        return;
    }
    
    UILabel *title = (UILabel*)[contentScrollView viewWithTag:1100 + page];
    UILabel *content = (UILabel*)[contentScrollView viewWithTag:1000 + page];
   
    if (content == nil) {
        title = [[[UILabel alloc] initWithFrame:CGRectMake(contentScrollView.frame.size.width * page, 0, 232, 18)] autorelease];
        title.tag = 1100 + page;
        title.backgroundColor = [UIColor clearColor];
        title.textAlignment = UITextAlignmentCenter;
        title.textColor = [UIColor colorWithRed:113/255.0f green:229/255.0f blue:255/255.0f alpha:1.0f];
        title.font = [UIFont fontWithName:@"helvetica" size:18];
        [contentScrollView addSubview:title];
        
        content = [[[UILabel alloc] initWithFrame:CGRectMake(contentScrollView.frame.size.width * page , 28, 232, 67)] autorelease];
        content.tag = 1000 + page;
        content.numberOfLines = 4;
        content.backgroundColor = [UIColor clearColor];
        content.textAlignment = UITextAlignmentCenter;
        content.textColor = [UIColor colorWithRed:254/255.0f green:254/255.0f blue:254/255.0f alpha:1.0f];
        content.font = [UIFont fontWithName:@"helvetica" size:13];
        [contentScrollView addSubview:content];
    }
    title.text = [[notiListArray objectAtIndex:page] objectForKey:@"title"];
    content.text = [[notiListArray objectAtIndex:page] objectForKey:@"content"];
}

- (void) moveToNextPage {
    
    int currentPage = pageControl.currentPage + 1;
    
    if (currentPage == totalPageCnt) {
        currentPage = 0;
        pageControl.currentPage = currentPage;
    }
    
    [self loadPage:currentPage-1];
    [self loadPage:currentPage];
    [self loadPage:currentPage+1];

    CGRect frame = contentScrollView.frame;
    frame.origin.x = contentScrollView.frame.size.width * currentPage;
    if (currentPage == 0) {
        [contentScrollView scrollRectToVisible:CGRectMake(frame.origin.x, 0, frame.size.width, frame.size.height) animated:NO];
    } else {
        [contentScrollView scrollRectToVisible:CGRectMake(frame.origin.x, 0, frame.size.width, frame.size.height) animated:YES];
    }
}

- (void) processNotiList:(NSMutableArray *)resultArray {
    
    totalPageCnt = [resultArray count];
    self.notiListArray = resultArray;
    [self sortNotificationList];
    [self loadPage:0];
    [self loadPage:1];
    contentScrollView.contentSize = CGSizeMake(232*totalPageCnt, 100);
    pageControl.numberOfPages = totalPageCnt;
    [self automoveNotifications:YES];
}

- (void) sortNotificationList {
    
    NSSortDescriptor *sortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"notiOrder" ascending:YES] autorelease];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    [notiListArray sortedArrayUsingDescriptors:sortDescriptors];
}

#pragma mark - UIScrollView Delegate
- (void) scrollViewDidScroll:(UIScrollView *)scrollView {
    int currentPage = 0;
    CGFloat pageWidth = scrollView.frame.size.width;
    currentPage = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    
    [pageControl setCurrentPage:currentPage];
    [self loadPage:currentPage-1];
    [self loadPage:currentPage];
    [self loadPage:currentPage+1];
}

- (void) scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (scrollTimer != nil) {
        [self automoveNotifications:NO];
    }
}

- (void) scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (scrollTimer == nil) {
        [self automoveNotifications:YES];
    }
}

@end
