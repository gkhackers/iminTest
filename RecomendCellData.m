//
//  RecomendCellData.m
//  ImIn
//
//  Created by 태한 김 on 10. 6. 11..
//  Copyright 2010 kth. All rights reserved.
//

#import "RecomendCellData.h"


@implementation RecomendCellData

@synthesize	snsId;
@synthesize	nickName;
@synthesize	profileImgURL;
@synthesize	columbusNum;
@synthesize	neighborNum;
@synthesize	latestPoiName;
@synthesize md5phoneNumber;
@synthesize needToDelete;
@synthesize isFriend;
@synthesize recomType;
@synthesize cpName;
@synthesize recomCnt, cpNeighborName, knownType, scrapCnt;
@synthesize comment;


- (id) initWithDictionary: (NSDictionary*) pData
{
	self = [super init];
	if( nil != self ){
		self.snsId = [pData objectForKey:@"snsId"];
		self.nickName = [pData objectForKey:@"nickname"];
		self.profileImgURL = [pData objectForKey:@"profileImg"];
		self.columbusNum = [pData objectForKey:@"totalColumbusCnt"];
		self.neighborNum = [pData objectForKey:@"totalNeighborCnt"];
		self.latestPoiName = [pData objectForKey:@"poiName"];
		self.md5phoneNumber = [pData objectForKey:@"md5phoneNo"];
		needToDelete = NO;
		self.isFriend = [pData objectForKey:@"isFriend"];
		self.recomType = [pData objectForKey:@"recomType"];
		self.cpName = [pData objectForKey:@"cpName"];
        
        self.recomCnt = [pData objectForKey:@"recomCnt"];
        self.cpNeighborName = [pData objectForKey:@"cpNeighborName"];
        self.knownType = [pData objectForKey:@"knownType"];
        self.scrapCnt = [pData objectForKey:@"scrapCnt"];
        self.comment = [pData objectForKey:@"comment"];
	}

	return self;
}

- (void) updateDescription {
}

- (void) dealloc
{
	[snsId release];
	[nickName release];
	[profileImgURL release];
	[columbusNum release];
	[neighborNum release];
	[latestPoiName release];
	[md5phoneNumber release];
	[isFriend release];
	[recomType release];
	[cpName release];
    
    [recomCnt release];
	[cpNeighborName release];
	[knownType release];
	[scrapCnt release];
    [comment release];

	
	[super dealloc];
}

@end
