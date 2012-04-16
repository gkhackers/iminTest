//
//  RealtimeBadge.h
//  ImIn
//
//  Created by Myungjin Choi on 11. 10. 31..
//  Copyright (c) 2011년 KTH. All rights reserved.
//


@protocol RealtimeBadgeProtocol <NSObject>
@required
- (void) badgeDownloadCompleted;
@end


@interface RealtimeBadge : NSObject <RealtimeBadgeProtocol> {
    id<RealtimeBadgeProtocol> delegate;
    
    NSUInteger downloadCompleted;
	NSUInteger totalDownloads;
	NSUInteger downloadFailed;
    
    NSArray* badgeList; // 획득한 뱃지 목록
}

@property (assign) id<RealtimeBadgeProtocol> delegate;
@property (retain, nonatomic) NSArray* badgeList;


- (void) downloadImageWithArray:(NSArray*) aBadgeList;

@end
