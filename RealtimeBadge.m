//
//  RealtimeBadge.m
//  ImIn
//
//  Created by Myungjin Choi on 11. 10. 31..
//  Copyright (c) 2011년 KTH. All rights reserved.
//

#import "RealtimeBadge.h"

@implementation RealtimeBadge
@synthesize delegate;
@synthesize badgeList;


- (void) dealloc {
    [badgeList release];
    [super dealloc];
}

// 뱃지 획득시에 보여줄 이미지를 다운받는다
- (void) downloadImageWithUrl:(NSString*) baseUrl
{	
	NSString* url = [baseUrl stringByReplacingOccurrencesOfString:@"126x126" withString:@"252x252"];
	
	[Utils requestImageCacheWithURL:url
						   delegate:self
					   doneSelector:@selector(badgeDownloadDone:) 
					  errorSelector:@selector(badgeError:) cacheHitSelector:@selector(badgeCacheDone:)];
	
	url = [url stringByReplacingOccurrencesOfString:@"252x252_f" withString:@"252x252_b"];
	
	[Utils requestImageCacheWithURL:url
						   delegate:self
					   doneSelector:@selector(badgeDownloadDone:)
					  errorSelector:@selector(badgeError:) cacheHitSelector:@selector(badgeCacheDone:)];
}

- (void) downloadImageWithArray:(NSArray*) aBadgeList
{
    self.badgeList = aBadgeList;
	totalDownloads = [aBadgeList count] * 2; // front and back
	downloadCompleted = 0;
	downloadFailed = 0;
	for (NSDictionary* badgeInfo in aBadgeList) {
		NSString* url = [badgeInfo objectForKey:@"badgeImgUrl"];
		[self downloadImageWithUrl:url];
	}
}


- (void) badgeDownloadDone:(NSString*) url {
	downloadCompleted++;
	if (downloadCompleted == totalDownloads) {
		downloadCompleted = 0;
        [self badgeDownloadCompleted];
	}
	MY_LOG(@"뱃지 획득 이미지 받았음: %@", url);
}

- (void) badgeCacheDone:(NSString*) url {
	downloadCompleted++;
	if (downloadCompleted == totalDownloads) {
		downloadCompleted = 0;
        [self badgeDownloadCompleted];
	}
	MY_LOG(@"뱃지 획득 이미지 캐시: %@", url);
}

- (void) badgeDownloadCompleted
{
    if ([self.delegate respondsToSelector:@selector(badgeDownloadCompleted)]) {
        [self.delegate badgeDownloadCompleted];
    }    
}

- (void) badgeError:(NSString*) url {
	downloadFailed++;
	MY_LOG(@"뱃지 획득 이미지 에러: %@", url);
    
	if (downloadFailed + downloadCompleted == totalDownloads) {
		[CommonAlert alertWithTitle:@"안내" message:@"뱃지 리소스 다운로드에 실패했습니다. 정상적으로 이미지가 나오지 않을 수 있습니다."];		
		[self badgeDownloadCompleted];
	}
}


@end
