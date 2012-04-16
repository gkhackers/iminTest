//
//  WriteResultData.m
//  ImIn
//
//  Created by choipd on 10. 5. 13..
//  Copyright 2010 edbear. All rights reserved.
//

#import "WriteResultData.h"


@implementation WriteResultData
@synthesize badgeID, badgeName, badgeImgURL;
@synthesize isCaptain, isNewCaptain, isPoiAliasPerm, point, evtPoint, poiPoint, postPoint, imgPoint, totalPoint;
@synthesize poiName, poiAliasName, poiKey;
@synthesize isColumbus, columbusNickname, columbusProfileImg, columbusTotalPoint;
@synthesize isDuplPoi, aNewPoiKey;
@synthesize isOpen;
@synthesize pointDesc, pointDesc2;
@synthesize wvUrl;

- (void) dealloc {
	[poiName release];
	[poiAliasName release];
	
	[badgeID release];
	[badgeName release];
	[badgeImgURL release];
	[poiKey release];
	[point release];
	[evtPoint release];
	[poiPoint release];
	[imgPoint release];
	[postPoint release];
	[totalPoint release];

	[columbusNickname release];
	[columbusProfileImg release];
	[columbusTotalPoint release];
	[pointDesc release];
	[pointDesc release];
	[aNewPoiKey release];
    [wvUrl release];
	
	[super dealloc];
}
@end
